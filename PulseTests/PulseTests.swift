import Testing
import SwiftData
@testable import Pulse

@Suite("Workout Model Tests")
struct WorkoutModelTests {
    @Test func workoutInitialization() {
        let workout = Workout()
        #expect(workout.isActive)
        #expect(workout.endDate == nil)
        #expect(workout.exercises.isEmpty)
    }

    @Test func workoutDuration() {
        let workout = Workout(startDate: Date(timeIntervalSince1970: 0))
        workout.endDate = Date(timeIntervalSince1970: 3600)
        #expect(workout.duration == 3600)
    }

    @Test func workoutFinishSetsInactive() {
        let workout = Workout()
        workout.endDate = .now
        #expect(!workout.isActive)
    }
}

@Suite("Exercise Model Tests")
struct ExerciseModelTests {
    @Test func exerciseInitialization() {
        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        #expect(exercise.name == "Bench Press")
        #expect(exercise.muscleGroup == .chest)
        #expect(!exercise.isCustom)
        #expect(!exercise.isCardio)
    }

    @Test func customExercise() {
        let exercise = Exercise(name: "My Exercise", muscleGroup: .arms, isCustom: true)
        #expect(exercise.isCustom)
    }
}

@Suite("ExerciseSet Model Tests")
struct ExerciseSetModelTests {
    @Test func setInitialization() {
        let set = ExerciseSet(order: 0, weight: 135, reps: 8)
        #expect(set.weight == 135)
        #expect(set.reps == 8)
        #expect(!set.isCompleted)
    }
}

@Suite("Seed Data Tests")
struct SeedDataTests {
    @Test func seedDataIsNotEmpty() {
        #expect(!ExerciseSeedData.exercises.isEmpty)
    }

    @Test func seedDataCoversAllMuscleGroups() {
        let groups = Set(ExerciseSeedData.exercises.map(\.muscleGroup))
        for group in MuscleGroup.allCases {
            #expect(groups.contains(group), "Missing exercises for \(group.displayName)")
        }
    }
}
