import Foundation
import SwiftData
import Observation

// MARK: - Data Structures

enum TimeRange: String, CaseIterable, Identifiable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case allTime = "All"

    var id: String { rawValue }

    var startDate: Date? {
        let calendar = Calendar.current
        switch self {
        case .oneMonth: return calendar.date(byAdding: .month, value: -1, to: .now)
        case .threeMonths: return calendar.date(byAdding: .month, value: -3, to: .now)
        case .sixMonths: return calendar.date(byAdding: .month, value: -6, to: .now)
        case .oneYear: return calendar.date(byAdding: .year, value: -1, to: .now)
        case .allTime: return nil
        }
    }
}

struct WeeklyFrequency: Identifiable {
    let id = UUID()
    let weekStartDate: Date
    let count: Int
}

struct MuscleGroupSplit: Identifiable {
    let id = UUID()
    let muscleGroup: MuscleGroup
    let count: Int
    let percentage: Double
}

struct StrengthDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let maxWeight: Double
    let estimatedOneRepMax: Double
    let averageRPE: Double?
}

// MARK: - ViewModel

@Observable
final class ProgressViewModel {
    var selectedTimeRange: TimeRange = .threeMonths
    var selectedExercise: Exercise?
    var availableExercises: [Exercise] = []

    // Summary stats
    var totalWorkouts: Int = 0
    var totalWorkoutsThisMonth: Int = 0
    var totalVolume: Double = 0
    var currentStreak: Int = 0
    var personalRecordCount: Int = 0

    // Chart data
    var weeklyFrequencyData: [WeeklyFrequency] = []
    var muscleGroupData: [MuscleGroupSplit] = []
    var strengthProgressionData: [StrengthDataPoint] = []

    private let modelContext: ModelContext
    private var cachedCompletedWorkouts: [Workout] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public

    func fetchData() {
        let allWorkouts = fetchCompletedWorkouts()
        cachedCompletedWorkouts = allWorkouts
        let filteredWorkouts = filterByTimeRange(allWorkouts)

        totalWorkouts = filteredWorkouts.count
        totalWorkoutsThisMonth = computeWorkoutsThisMonth(from: allWorkouts)
        totalVolume = computeTotalVolume(from: filteredWorkouts)
        currentStreak = computeStreak(from: allWorkouts)
        personalRecordCount = computePRCount(from: filteredWorkouts, allWorkouts: allWorkouts)

        weeklyFrequencyData = computeWeeklyFrequency(from: filteredWorkouts)
        muscleGroupData = computeMuscleGroupSplit(from: filteredWorkouts)

        fetchAvailableExercises(filteredWorkouts: filteredWorkouts)

        if let exercise = selectedExercise {
            strengthProgressionData = computeStrengthProgression(for: exercise, from: filteredWorkouts)
        } else {
            strengthProgressionData = []
        }
    }

    func updateTimeRange(_ range: TimeRange) {
        selectedTimeRange = range
        fetchData()
    }

    func updateSelectedExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        let source = cachedCompletedWorkouts.isEmpty ? fetchCompletedWorkouts() : cachedCompletedWorkouts
        let workouts = filterByTimeRange(source)
        strengthProgressionData = computeStrengthProgression(for: exercise, from: workouts)
    }

    // MARK: - Formatting

    func formattedVolume(_ volume: Double) -> String {
        if volume >= 1_000_000 {
            return String(format: "%.1fM", volume / 1_000_000)
        } else if volume >= 10_000 {
            return String(format: "%.0fK", volume / 1_000)
        } else if volume >= 1_000 {
            return String(format: "%.1fK", volume / 1_000)
        }
        return String(format: "%.0f", volume)
    }

    // MARK: - Private: Fetching

    private func fetchCompletedWorkouts() -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func filterByTimeRange(_ workouts: [Workout]) -> [Workout] {
        guard let start = selectedTimeRange.startDate else { return workouts }
        return workouts.filter { $0.startDate >= start }
    }

    private func fetchAvailableExercises(filteredWorkouts: [Workout]) {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        guard let exercises = try? modelContext.fetch(descriptor) else { return }

        let favorites = exercises.filter { $0.isFavorite && !$0.isCardio }

        if !favorites.isEmpty {
            availableExercises = favorites
        } else {
            availableExercises = exercises.filter { !$0.isCardio && !$0.workoutExercises.isEmpty }
        }

        if selectedExercise == nil || !availableExercises.contains(where: { $0.persistentModelID == selectedExercise?.persistentModelID }) {
            selectedExercise = availableExercises.first
            if let first = selectedExercise {
                strengthProgressionData = computeStrengthProgression(for: first, from: filteredWorkouts)
            } else {
                strengthProgressionData = []
            }
        }
    }

    // MARK: - Private: Summary Stats

    private func computeWorkoutsThisMonth(from workouts: [Workout]) -> Int {
        let calendar = Calendar.current
        let now = Date.now
        return workouts.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .month) }.count
    }

    private func computeTotalVolume(from workouts: [Workout]) -> Double {
        var volume: Double = 0
        for workout in workouts {
            for workoutExercise in workout.exercises {
                for set in workoutExercise.sets where set.isCompleted && set.setType == .normal {
                    volume += set.weight * Double(set.reps)
                }
            }
        }
        return volume
    }

    private func computeStreak(from workouts: [Workout]) -> Int {
        guard !workouts.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        let workoutDays = Set(workouts.map { calendar.startOfDay(for: $0.startDate) })

        var streak = 0
        var checkDate = today

        // If no workout today, check if yesterday had one — allow "in-progress" streaks
        if !workoutDays.contains(checkDate) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            if !workoutDays.contains(checkDate) {
                return 0
            }
        }

        while workoutDays.contains(checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        return streak
    }

    private func computePRCount(from filteredWorkouts: [Workout], allWorkouts: [Workout]) -> Int {
        var prCount = 0

        // Build all-time max per exercise
        var allTimeMax: [PersistentIdentifier: Double] = [:]
        for workout in allWorkouts {
            for workoutExercise in workout.exercises {
                guard let exercise = workoutExercise.exercise, !exercise.isCardio else { continue }
                let maxWeight = workoutExercise.sets
                    .filter { $0.isCompleted && $0.setType == .normal }
                    .map(\.weight)
                    .max() ?? 0
                let id = exercise.persistentModelID
                allTimeMax[id] = max(allTimeMax[id] ?? 0, maxWeight)
            }
        }

        // Build max within filtered range per exercise
        var rangeMax: [PersistentIdentifier: Double] = [:]
        for workout in filteredWorkouts {
            for workoutExercise in workout.exercises {
                guard let exercise = workoutExercise.exercise, !exercise.isCardio else { continue }
                let maxWeight = workoutExercise.sets
                    .filter { $0.isCompleted && $0.setType == .normal }
                    .map(\.weight)
                    .max() ?? 0
                let id = exercise.persistentModelID
                rangeMax[id] = max(rangeMax[id] ?? 0, maxWeight)
            }
        }

        for (id, rangeValue) in rangeMax {
            if let allTimeValue = allTimeMax[id], rangeValue >= allTimeValue, rangeValue > 0 {
                prCount += 1
            }
        }

        return prCount
    }

    // MARK: - Private: Chart Computations

    private func computeWeeklyFrequency(from workouts: [Workout]) -> [WeeklyFrequency] {
        let calendar = Calendar.current

        guard !workouts.isEmpty else { return [] }

        // Determine range
        let rangeStart: Date
        if let start = selectedTimeRange.startDate {
            rangeStart = start
        } else if let oldest = workouts.last {
            rangeStart = oldest.startDate
        } else {
            return []
        }

        // Build week start -> count mapping
        var weekCounts: [Date: Int] = [:]
        for workout in workouts {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: workout.startDate)?.start ?? workout.startDate
            weekCounts[weekStart, default: 0] += 1
        }

        // Fill in all weeks from range start to now
        var result: [WeeklyFrequency] = []
        var current = calendar.dateInterval(of: .weekOfYear, for: rangeStart)?.start ?? rangeStart
        let now = Date.now

        while current <= now {
            result.append(WeeklyFrequency(
                weekStartDate: current,
                count: weekCounts[current] ?? 0
            ))
            current = calendar.date(byAdding: .weekOfYear, value: 1, to: current)!
        }

        return result
    }

    private func computeMuscleGroupSplit(from workouts: [Workout]) -> [MuscleGroupSplit] {
        var counts: [MuscleGroup: Int] = [:]
        var total = 0

        for workout in workouts {
            for workoutExercise in workout.exercises {
                guard let group = workoutExercise.exercise?.muscleGroup else { continue }
                counts[group, default: 0] += 1
                total += 1
            }
        }

        guard total > 0 else { return [] }

        return MuscleGroup.allCases.compactMap { group in
            guard let count = counts[group], count > 0 else { return nil }
            return MuscleGroupSplit(
                muscleGroup: group,
                count: count,
                percentage: Double(count) / Double(total) * 100
            )
        }
    }

    private func computeStrengthProgression(for exercise: Exercise, from workouts: [Workout]) -> [StrengthDataPoint] {
        var dataPoints: [StrengthDataPoint] = []

        for workout in workouts {
            for workoutExercise in workout.exercises {
                guard workoutExercise.exercise?.persistentModelID == exercise.persistentModelID else { continue }

                let completedSets = workoutExercise.sets.filter { $0.isCompleted && $0.setType == .normal }
                guard !completedSets.isEmpty else { continue }

                // Find the set with the highest estimated 1RM (Epley formula)
                let bestSet = completedSets.max(by: { a, b in
                    let aRM = a.reps > 1 ? a.weight * (1 + Double(a.reps) / 30.0) : a.weight
                    let bRM = b.reps > 1 ? b.weight * (1 + Double(b.reps) / 30.0) : b.weight
                    return aRM < bRM
                })!
                let maxWeight = bestSet.weight
                let oneRM = bestSet.reps > 1
                    ? maxWeight * (1 + Double(bestSet.reps) / 30.0)
                    : maxWeight

                let rpeValues = completedSets.compactMap(\.rpe)
                let avgRPE: Double? = rpeValues.isEmpty ? nil : rpeValues.reduce(0, +) / Double(rpeValues.count)

                dataPoints.append(StrengthDataPoint(
                    date: workout.startDate,
                    maxWeight: maxWeight,
                    estimatedOneRepMax: oneRM,
                    averageRPE: avgRPE
                ))
            }
        }

        return dataPoints.sorted { $0.date < $1.date }
    }
}
