import Foundation
import SwiftData
import Observation

@Observable
final class HistoryViewModel {
    var workouts: [Workout] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchWorkouts() {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        workouts = (try? modelContext.fetch(descriptor)) ?? []
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
        modelContext.delete(workoutExercise)
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
