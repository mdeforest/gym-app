import Foundation
import SwiftData
import Observation

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let dayNumber: Int
    let isCurrentMonth: Bool
    let isToday: Bool
    let hasWorkout: Bool
    let isFuture: Bool
}

@Observable
final class HistoryViewModel {
    var workouts: [Workout] = []
    var displayedMonth: Date = Date()
    var selectedDate: Date? = nil
    private var workoutDays: Set<DateComponents> = []

    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private let modelContext: ModelContext
    private let calendar = Calendar.current

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Data Fetching

    func fetchWorkouts() {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        workouts = (try? modelContext.fetch(descriptor)) ?? []
        updateWorkoutDays()
    }

    // MARK: - Calendar

    var filteredWorkouts: [Workout] {
        guard let selectedDate else { return workouts }
        return workouts.filter { calendar.isDate($0.startDate, inSameDayAs: selectedDate) }
    }

    func selectDate(_ date: Date) {
        if let current = selectedDate, calendar.isDate(current, inSameDayAs: date) {
            selectedDate = nil
        } else {
            selectedDate = date
        }
    }

    func clearDateSelection() {
        selectedDate = nil
    }

    func goToPreviousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    var canGoToNextMonth: Bool {
        let now = Date()
        let currentMonth = calendar.dateComponents([.year, .month], from: now)
        let displayed = calendar.dateComponents([.year, .month], from: displayedMonth)
        return displayed.year! < currentMonth.year! ||
            (displayed.year == currentMonth.year && displayed.month! < currentMonth.month!)
    }

    func goToNextMonth() {
        guard canGoToNextMonth,
              let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return }
        displayedMonth = newMonth
    }

    func hasWorkout(on date: Date) -> Bool {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return workoutDays.contains(components)
    }

    func formattedMonthYear(_ date: Date) -> String {
        Self.monthYearFormatter.string(from: date)
    }

    func daysInMonth() -> [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }

        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let leadingEmptyDays = firstWeekday - calendar.firstWeekday
        let adjustedLeading = leadingEmptyDays < 0 ? leadingEmptyDays + 7 : leadingEmptyDays

        var days: [CalendarDay] = []

        let today = calendar.startOfDay(for: Date())

        // Leading days from previous month
        for offset in (0..<adjustedLeading).reversed() {
            if let date = calendar.date(byAdding: .day, value: -(offset + 1), to: firstDayOfMonth) {
                days.append(CalendarDay(
                    date: date,
                    dayNumber: calendar.component(.day, from: date),
                    isCurrentMonth: false,
                    isToday: false,
                    hasWorkout: false,
                    isFuture: false
                ))
            }
        }

        // Days in current month
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(CalendarDay(
                    date: date,
                    dayNumber: day,
                    isCurrentMonth: true,
                    isToday: calendar.isDateInToday(date),
                    hasWorkout: hasWorkout(on: date),
                    isFuture: calendar.startOfDay(for: date) > today
                ))
            }
        }

        // Trailing days to complete the last row
        let remainder = days.count % 7
        if remainder > 0 {
            let trailingDays = 7 - remainder
            let lastDayOfMonth = monthInterval.end
            for offset in 0..<trailingDays {
                if let date = calendar.date(byAdding: .day, value: offset, to: lastDayOfMonth) {
                    days.append(CalendarDay(
                        date: date,
                        dayNumber: calendar.component(.day, from: date),
                        isCurrentMonth: false,
                        isToday: false,
                        hasWorkout: false,
                        isFuture: false
                    ))
                }
            }
        }

        return days
    }

    private func updateWorkoutDays() {
        workoutDays = Set(workouts.map { calendar.dateComponents([.year, .month, .day], from: $0.startDate) })
    }

    func createBackdatedWorkout(on date: Date) -> Workout {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .hour, value: 1, to: startOfDay) ?? startOfDay
        let workout = Workout(startDate: startOfDay)
        workout.endDate = endOfDay
        modelContext.insert(workout)
        save()
        fetchWorkouts()
        return workout
    }

    func deleteWorkout(_ workout: Workout) {
        modelContext.delete(workout)
        save()
        fetchWorkouts()
    }

    // MARK: - Editing

    func addSet(to workoutExercise: WorkoutExercise) {
        let order = workoutExercise.sets.count
        let newSet = ExerciseSet(order: order)
        if let lastSet = workoutExercise.sortedSets.last {
            newSet.weight = lastSet.weight
            newSet.reps = lastSet.reps
        }
        newSet.isCompleted = true
        newSet.workoutExercise = workoutExercise
        save()
    }

    func deleteSet(_ exerciseSet: ExerciseSet, from workoutExercise: WorkoutExercise) {
        let deletedOrder = exerciseSet.order
        modelContext.delete(exerciseSet)
        for set in workoutExercise.sets where set.order > deletedOrder {
            set.order -= 1
        }
        save()
    }

    func addExercise(_ exercise: Exercise, to workout: Workout) {
        let order = workout.exercises.count
        let workoutExercise = WorkoutExercise(order: order, exercise: exercise)
        workoutExercise.workout = workout
        if !exercise.isCardio {
            let defaultSet = ExerciseSet(order: 0)
            defaultSet.isCompleted = true
            defaultSet.workoutExercise = workoutExercise
        }
        exercise.lastUsedDate = .now
        save()
    }

    func removeExercise(_ workoutExercise: WorkoutExercise) {
        if workoutExercise.isInSuperset {
            removeFromSuperset(workoutExercise)
        }
        modelContext.delete(workoutExercise)
        save()
    }

    func linkAsSuperset(_ exerciseA: WorkoutExercise, _ exerciseB: WorkoutExercise) {
        if let existingGroup = exerciseA.supersetGroupId {
            exerciseB.supersetGroupId = existingGroup
        } else if let existingGroup = exerciseB.supersetGroupId {
            exerciseA.supersetGroupId = existingGroup
        } else {
            let groupId = UUID()
            exerciseA.supersetGroupId = groupId
            exerciseB.supersetGroupId = groupId
        }
        save()
    }

    func removeFromSuperset(_ workoutExercise: WorkoutExercise) {
        guard let groupId = workoutExercise.supersetGroupId,
              let workout = workoutExercise.workout else { return }

        workoutExercise.supersetGroupId = nil

        let remaining = workout.exercises.filter { $0.supersetGroupId == groupId }
        if remaining.count == 1 {
            remaining.first?.supersetGroupId = nil
        }
        save()
    }

    func groupedExercises(for workout: Workout) -> [[WorkoutExercise]] {
        WorkoutViewModel.groupExercises(workout.exercises)
    }

    func moveExerciseGroup(from source: Int, to destination: Int, in workout: Workout) {
        var groups = groupedExercises(for: workout)
        guard source != destination, source < groups.count, destination < groups.count else { return }
        let moved = groups.remove(at: source)
        groups.insert(moved, at: destination)
        WorkoutViewModel.reassignOrders(groups)
        save()
    }

    func toggleSetType(_ exerciseSet: ExerciseSet) {
        exerciseSet.setType = (exerciseSet.setType == .normal) ? .warmup : .normal
        if exerciseSet.setType == .warmup {
            exerciseSet.rpe = nil
        }
        save()
    }

    func updateDates(for workout: Workout, startDate: Date, endDate: Date) {
        workout.startDate = startDate
        workout.endDate = endDate
        save()
    }

    func formattedDuration(_ workout: Workout) -> String {
        guard let duration = workout.duration else { return "--" }
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }

    // MARK: - Private

    private func save() {
        try? modelContext.save()
    }
}
