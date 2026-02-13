import Foundation
import Testing
import SwiftData
@testable import Pulse

// MARK: - Workout Model Tests

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

    @Test func durationNilWhenNoEndDate() {
        let workout = Workout()
        #expect(workout.duration == nil)
    }

    @Test func notesNilByDefault() {
        let workout = Workout()
        #expect(workout.notes == nil)
    }

    @Test func exercisesEmptyByDefault() {
        let workout = Workout()
        #expect(workout.exercises.isEmpty)
    }

    @Test func customStartDate() {
        let date = Date(timeIntervalSince1970: 1000)
        let workout = Workout(startDate: date)
        #expect(workout.startDate == date)
    }
}

// MARK: - Exercise Model Tests

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

    @Test func cardioExercise() {
        let exercise = Exercise(name: "Running", muscleGroup: .cardio, isCardio: true)
        #expect(exercise.isCardio)
        #expect(exercise.muscleGroup == .cardio)
    }

    @Test func exerciseDescriptionAndInstructions() {
        let exercise = Exercise(
            name: "Bench Press",
            muscleGroup: .chest,
            exerciseDescription: "A compound pushing exercise",
            instructions: "Lie on bench, press up"
        )
        #expect(exercise.exerciseDescription == "A compound pushing exercise")
        #expect(exercise.instructions == "Lie on bench, press up")
    }

    @Test func defaultRestSeconds() {
        let exercise = Exercise(name: "Squat", muscleGroup: .legs, defaultRestSeconds: 120)
        #expect(exercise.defaultRestSeconds == 120)
    }

    @Test func defaultRestSecondsNilByDefault() {
        let exercise = Exercise(name: "Curl", muscleGroup: .arms)
        #expect(exercise.defaultRestSeconds == nil)
    }

    @Test func lastUsedDateNilByDefault() {
        let exercise = Exercise(name: "Pull-up", muscleGroup: .back)
        #expect(exercise.lastUsedDate == nil)
    }

    @Test func defaultStringsAreEmpty() {
        let exercise = Exercise(name: "Test", muscleGroup: .chest)
        #expect(exercise.exerciseDescription == "")
        #expect(exercise.instructions == "")
    }
}

// MARK: - ExerciseSet Model Tests

@Suite("ExerciseSet Model Tests")
struct ExerciseSetModelTests {
    @Test func setInitialization() {
        let set = ExerciseSet(order: 0, weight: 135, reps: 8)
        #expect(set.weight == 135)
        #expect(set.reps == 8)
        #expect(!set.isCompleted)
    }

    @Test func defaultValues() {
        let set = ExerciseSet(order: 0)
        #expect(set.weight == 0)
        #expect(set.reps == 0)
        #expect(!set.isCompleted)
    }

    @Test func toggleCompletion() {
        let set = ExerciseSet(order: 0, weight: 100, reps: 10)
        #expect(!set.isCompleted)
        set.isCompleted = true
        #expect(set.isCompleted)
        set.isCompleted = false
        #expect(!set.isCompleted)
    }

    @Test func orderPreserved() {
        let set = ExerciseSet(order: 5, weight: 225, reps: 3)
        #expect(set.order == 5)
    }
}

// MARK: - MuscleGroup Tests

@Suite("MuscleGroup Tests")
struct MuscleGroupTests {
    @Test func allCasesCount() {
        #expect(MuscleGroup.allCases.count == 7)
    }

    @Test func displayNames() {
        #expect(MuscleGroup.chest.displayName == "Chest")
        #expect(MuscleGroup.back.displayName == "Back")
        #expect(MuscleGroup.shoulders.displayName == "Shoulders")
        #expect(MuscleGroup.arms.displayName == "Arms")
        #expect(MuscleGroup.legs.displayName == "Legs")
        #expect(MuscleGroup.core.displayName == "Core")
        #expect(MuscleGroup.cardio.displayName == "Cardio")
    }

    @Test func idEqualsRawValue() {
        for group in MuscleGroup.allCases {
            #expect(group.id == group.rawValue)
        }
    }

    @Test func rawValues() {
        #expect(MuscleGroup.chest.rawValue == "chest")
        #expect(MuscleGroup.back.rawValue == "back")
        #expect(MuscleGroup.shoulders.rawValue == "shoulders")
        #expect(MuscleGroup.arms.rawValue == "arms")
        #expect(MuscleGroup.legs.rawValue == "legs")
        #expect(MuscleGroup.core.rawValue == "core")
        #expect(MuscleGroup.cardio.rawValue == "cardio")
    }
}

// MARK: - WorkoutExercise Model Tests

@Suite("WorkoutExercise Model Tests")
struct WorkoutExerciseModelTests {
    @Test func initialization() {
        let we = WorkoutExercise(order: 2)
        #expect(we.order == 2)
        #expect(we.exercise == nil)
        #expect(we.workout == nil)
        #expect(we.sets.isEmpty)
    }

    @Test func cardioFieldsNilByDefault() {
        let we = WorkoutExercise(order: 0)
        #expect(we.durationSeconds == nil)
        #expect(we.distanceMeters == nil)
    }

    @Test func initWithExercise() {
        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        let we = WorkoutExercise(order: 0, exercise: exercise)
        #expect(we.exercise?.name == "Bench Press")
    }
}

// MARK: - WorkoutTemplate Model Tests

@Suite("WorkoutTemplate Model Tests")
struct WorkoutTemplateModelTests {
    @Test func initialization() {
        let template = WorkoutTemplate(name: "Push Day")
        #expect(template.name == "Push Day")
        #expect(template.exercises.isEmpty)
        #expect(template.lastUsedDate == nil)
    }

    @Test func exerciseCountEmpty() {
        let template = WorkoutTemplate(name: "Test")
        #expect(template.exerciseCount == 0)
    }

    @Test func muscleGroupsEmptyWhenNoExercises() {
        let template = WorkoutTemplate(name: "Empty")
        #expect(template.muscleGroups.isEmpty)
    }
}

// MARK: - TemplateExercise Model Tests

@Suite("TemplateExercise Model Tests")
struct TemplateExerciseModelTests {
    @Test func initializationDefaults() {
        let te = TemplateExercise(order: 0)
        #expect(te.order == 0)
        #expect(te.setCount == 3)
        #expect(te.defaultWeight == 0)
        #expect(te.defaultReps == 0)
    }

    @Test func cardioDefaultsNil() {
        let te = TemplateExercise(order: 0)
        #expect(te.defaultDurationSeconds == nil)
        #expect(te.defaultDistanceMeters == nil)
    }

    @Test func customDefaults() {
        let te = TemplateExercise(order: 1, setCount: 5, defaultWeight: 135, defaultReps: 8)
        #expect(te.setCount == 5)
        #expect(te.defaultWeight == 135)
        #expect(te.defaultReps == 8)
    }

    @Test func exerciseNilByDefault() {
        let te = TemplateExercise(order: 0)
        #expect(te.exercise == nil)
        #expect(te.template == nil)
    }
}

// MARK: - Seed Data Tests

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
