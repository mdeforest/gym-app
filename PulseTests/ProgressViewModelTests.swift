import Foundation
import Testing
import SwiftData
@testable import Pulse

// MARK: - Helpers

@MainActor
private func makeIsolatedContext() throws -> ModelContext {
    let container = try DataService.createPreviewContainer()
    return ModelContext(container)
}

@MainActor
private func makeCompletedWorkout(
    context: ModelContext,
    startDate: Date = .now,
    exercises: [(Exercise, [(weight: Double, reps: Int)])] = []
) -> Workout {
    let workout = Workout(startDate: startDate)
    workout.endDate = startDate.addingTimeInterval(3600)
    context.insert(workout)

    for (index, (exercise, sets)) in exercises.enumerated() {
        let we = WorkoutExercise(order: index, exercise: exercise)
        we.workout = workout
        for (setIndex, setData) in sets.enumerated() {
            let set = ExerciseSet(order: setIndex, weight: setData.weight, reps: setData.reps)
            set.isCompleted = true
            set.workoutExercise = we
        }
    }

    try? context.save()
    return workout
}

// MARK: - ProgressViewModel Tests

@Suite("ProgressViewModel Tests", .serialized)
@MainActor
struct ProgressViewModelTests {

    // MARK: Summary Stats

    @Test func totalWorkoutsCountsCompletedOnly() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .allTime

        _ = makeCompletedWorkout(context: context)

        let activeWorkout = Workout()
        context.insert(activeWorkout)
        try context.save()

        vm.fetchData()
        #expect(vm.totalWorkouts == 1)
    }

    @Test func totalWorkoutsThisMonthFiltersCorrectly() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)

        _ = makeCompletedWorkout(context: context, startDate: .now)

        let oldDate = Calendar.current.date(byAdding: .month, value: -2, to: .now)!
        _ = makeCompletedWorkout(context: context, startDate: oldDate)

        vm.fetchData()
        #expect(vm.totalWorkoutsThisMonth == 1)
    }

    @Test func totalVolumeCalculation() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .allTime

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)

        // 100 lbs x 10 reps = 1000, 150 lbs x 5 reps = 750 -> total 1750
        _ = makeCompletedWorkout(context: context, exercises: [
            (exercise, [(weight: 100, reps: 10), (weight: 150, reps: 5)])
        ])

        vm.fetchData()
        #expect(vm.totalVolume == 1750)
    }

    @Test func currentStreakConsecutiveDays() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        for dayOffset in 0..<3 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            _ = makeCompletedWorkout(context: context, startDate: date)
        }

        vm.fetchData()
        #expect(vm.currentStreak == 3)
    }

    @Test func currentStreakBreaksOnGap() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        _ = makeCompletedWorkout(context: context, startDate: today)

        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        _ = makeCompletedWorkout(context: context, startDate: twoDaysAgo)

        vm.fetchData()
        #expect(vm.currentStreak == 1)
    }

    @Test func currentStreakZeroWhenNoRecentWorkouts() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)

        let calendar = Calendar.current
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: .now)!
        _ = makeCompletedWorkout(context: context, startDate: fiveDaysAgo)

        vm.fetchData()
        #expect(vm.currentStreak == 0)
    }

    // MARK: Volume Formatting

    @Test func formattedVolumeSmall() throws {
        let vm = ProgressViewModel(modelContext: try makeIsolatedContext())
        #expect(vm.formattedVolume(500) == "500")
    }

    @Test func formattedVolumeThousands() throws {
        let vm = ProgressViewModel(modelContext: try makeIsolatedContext())
        #expect(vm.formattedVolume(1500) == "1.5K")
    }

    @Test func formattedVolumeTenThousands() throws {
        let vm = ProgressViewModel(modelContext: try makeIsolatedContext())
        #expect(vm.formattedVolume(15000) == "15K")
    }

    @Test func formattedVolumeMillions() throws {
        let vm = ProgressViewModel(modelContext: try makeIsolatedContext())
        #expect(vm.formattedVolume(1_500_000) == "1.5M")
    }

    // MARK: Weekly Frequency

    @Test func weeklyFrequencyGroupsCorrectly() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .oneMonth

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        _ = makeCompletedWorkout(context: context, startDate: today)
        _ = makeCompletedWorkout(context: context, startDate: today.addingTimeInterval(3600))

        vm.fetchData()

        let thisWeekData = vm.weeklyFrequencyData.last
        #expect(thisWeekData != nil)
        #expect(thisWeekData?.count == 2)
    }

    @Test func weeklyFrequencyFillsZeroWeeks() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .oneMonth

        _ = makeCompletedWorkout(context: context, startDate: .now)

        vm.fetchData()

        let zeroWeeks = vm.weeklyFrequencyData.filter { $0.count == 0 }
        #expect(!zeroWeeks.isEmpty)
    }

    // MARK: Muscle Group Split

    @Test func muscleGroupSplitPercentages() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .allTime

        let chest = Exercise(name: "Bench", muscleGroup: .chest)
        let legs = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(chest)
        context.insert(legs)

        // 2 chest exercises, 1 legs exercise
        _ = makeCompletedWorkout(context: context, exercises: [
            (chest, [(weight: 135, reps: 10)]),
            (chest, [(weight: 135, reps: 10)]),
            (legs, [(weight: 225, reps: 5)])
        ])

        vm.fetchData()

        let chestSplit = vm.muscleGroupData.first { $0.muscleGroup == .chest }
        let legsSplit = vm.muscleGroupData.first { $0.muscleGroup == .legs }

        #expect(chestSplit != nil)
        #expect(legsSplit != nil)

        // 2/3 ≈ 66.67%, 1/3 ≈ 33.33%
        if let chest = chestSplit {
            #expect(chest.percentage > 60 && chest.percentage < 70)
        }
        if let legs = legsSplit {
            #expect(legs.percentage > 30 && legs.percentage < 40)
        }
    }

    @Test func muscleGroupSplitExcludesEmpty() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .allTime

        let chest = Exercise(name: "Bench", muscleGroup: .chest)
        context.insert(chest)

        _ = makeCompletedWorkout(context: context, exercises: [
            (chest, [(weight: 135, reps: 10)])
        ])

        vm.fetchData()

        #expect(vm.muscleGroupData.count == 1)
        #expect(vm.muscleGroupData.first?.muscleGroup == .chest)
    }

    // MARK: Strength Progression

    @Test func strengthProgressionMaxWeight() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .allTime

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)

        let date1 = Calendar.current.date(byAdding: .day, value: -7, to: .now)!
        _ = makeCompletedWorkout(context: context, startDate: date1, exercises: [
            (exercise, [(weight: 135, reps: 10), (weight: 155, reps: 5)])
        ])

        vm.selectedExercise = exercise
        vm.fetchData()

        #expect(vm.strengthProgressionData.count == 1)
        #expect(vm.strengthProgressionData.first?.maxWeight == 155)
    }

    @Test func strengthProgressionSortedByDate() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .allTime

        let exercise = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(exercise)

        let olderDate = Calendar.current.date(byAdding: .day, value: -14, to: .now)!
        let newerDate = Calendar.current.date(byAdding: .day, value: -7, to: .now)!

        _ = makeCompletedWorkout(context: context, startDate: newerDate, exercises: [
            (exercise, [(weight: 225, reps: 5)])
        ])
        _ = makeCompletedWorkout(context: context, startDate: olderDate, exercises: [
            (exercise, [(weight: 200, reps: 5)])
        ])

        vm.selectedExercise = exercise
        vm.fetchData()

        #expect(vm.strengthProgressionData.count == 2)
        #expect(vm.strengthProgressionData.first!.date < vm.strengthProgressionData.last!.date)
    }

    // MARK: Time Range Filtering

    @Test func timeRangeFilterExcludesOldWorkouts() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .oneMonth

        _ = makeCompletedWorkout(context: context, startDate: .now)

        let oldDate = Calendar.current.date(byAdding: .month, value: -3, to: .now)!
        _ = makeCompletedWorkout(context: context, startDate: oldDate)

        vm.fetchData()
        #expect(vm.totalWorkouts == 1)
    }

    @Test func timeRangeAllTimeIncludesEverything() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .allTime

        _ = makeCompletedWorkout(context: context, startDate: .now)

        let oldDate = Calendar.current.date(byAdding: .year, value: -2, to: .now)!
        _ = makeCompletedWorkout(context: context, startDate: oldDate)

        vm.fetchData()
        #expect(vm.totalWorkouts == 2)
    }

    // MARK: Available Exercises

    @Test func availableExercisesExcludesCardio() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)

        let strength = Exercise(name: "Bench", muscleGroup: .chest)
        let cardio = Exercise(name: "Running", muscleGroup: .cardio, isCardio: true)
        context.insert(strength)
        context.insert(cardio)

        _ = makeCompletedWorkout(context: context, exercises: [
            (strength, [(weight: 135, reps: 10)])
        ])

        // Add a workout exercise for cardio too
        let workout = Workout(startDate: .now)
        workout.endDate = .now.addingTimeInterval(1800)
        context.insert(workout)
        let we = WorkoutExercise(order: 0, exercise: cardio)
        we.workout = workout
        we.durationSeconds = 1800
        try context.save()

        vm.fetchData()

        #expect(!vm.availableExercises.contains { $0.isCardio })
        #expect(vm.availableExercises.contains { $0.name == "Bench" })
    }

    @Test func availableExercisesPrioritizesFavorites() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .allTime

        let bench = Exercise(name: "Bench", muscleGroup: .chest)
        let squat = Exercise(name: "Squat", muscleGroup: .legs)
        let row = Exercise(name: "Row", muscleGroup: .back)
        bench.isFavorite = true
        squat.isFavorite = true
        context.insert(bench)
        context.insert(squat)
        context.insert(row)

        _ = makeCompletedWorkout(context: context, exercises: [
            (bench, [(weight: 135, reps: 10)]),
            (squat, [(weight: 225, reps: 5)]),
            (row, [(weight: 135, reps: 10)])
        ])

        vm.fetchData()

        #expect(vm.availableExercises.count == 2)
        #expect(vm.availableExercises.allSatisfy { $0.isFavorite })
    }

    @Test func availableExercisesFallsBackWhenNoFavorites() throws {
        let context = try makeIsolatedContext()
        let vm = ProgressViewModel(modelContext: context)
        vm.selectedTimeRange = .allTime

        let bench = Exercise(name: "Bench", muscleGroup: .chest)
        let squat = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(bench)
        context.insert(squat)

        _ = makeCompletedWorkout(context: context, exercises: [
            (bench, [(weight: 135, reps: 10)]),
            (squat, [(weight: 225, reps: 5)])
        ])

        vm.fetchData()

        // No favorites, so should show all used exercises
        #expect(vm.availableExercises.count == 2)
    }
}
