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

    @Test func equipmentDefaultsToOther() {
        let exercise = Exercise(name: "Pull-up", muscleGroup: .back)
        #expect(exercise.equipment == .other)
    }

    @Test func initWithEquipment() {
        let exercise = Exercise(name: "Barbell Bench Press", muscleGroup: .chest, equipment: .barbell)
        #expect(exercise.equipment == .barbell)
    }

    @Test func initWithBodyweightEquipment() {
        let exercise = Exercise(name: "Push-up", muscleGroup: .chest, equipment: .bodyweight)
        #expect(exercise.equipment == .bodyweight)
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

// MARK: - Equipment Tests

@Suite("Equipment Tests")
struct EquipmentTests {

    @Test func allCasesCount() {
        #expect(Equipment.allCases.count == 8)
    }

    @Test func displayNames() {
        #expect(Equipment.barbell.displayName == "Barbell")
        #expect(Equipment.dumbbell.displayName == "Dumbbell")
        #expect(Equipment.cable.displayName == "Cable")
        #expect(Equipment.machine.displayName == "Machine")
        #expect(Equipment.bodyweight.displayName == "Bodyweight")
        #expect(Equipment.kettlebell.displayName == "Kettlebell")
        #expect(Equipment.bands.displayName == "Bands")
        #expect(Equipment.other.displayName == "Other")
    }

    @Test func rawValues() {
        #expect(Equipment.barbell.rawValue == "barbell")
        #expect(Equipment.dumbbell.rawValue == "dumbbell")
        #expect(Equipment.cable.rawValue == "cable")
        #expect(Equipment.machine.rawValue == "machine")
        #expect(Equipment.bodyweight.rawValue == "bodyweight")
        #expect(Equipment.kettlebell.rawValue == "kettlebell")
        #expect(Equipment.bands.rawValue == "bands")
        #expect(Equipment.other.rawValue == "other")
    }

    @Test func idEqualsRawValue() {
        for equipment in Equipment.allCases {
            #expect(equipment.id == equipment.rawValue)
        }
    }

    @Test func codableRoundTrip() throws {
        for equipment in Equipment.allCases {
            let encoded = try JSONEncoder().encode(equipment)
            let decoded = try JSONDecoder().decode(Equipment.self, from: encoded)
            #expect(decoded == equipment)
        }
    }

    @Test func initFromRawValue() {
        #expect(Equipment(rawValue: "barbell") == .barbell)
        #expect(Equipment(rawValue: "bodyweight") == .bodyweight)
        #expect(Equipment(rawValue: "unknown") == nil)
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

    @Test func seedDataCoversAllEquipmentTypes() {
        let types = Set(ExerciseSeedData.exercises.map(\.equipment))
        for equipment in Equipment.allCases {
            #expect(types.contains(equipment), "No seeded exercises use \(equipment.displayName)")
        }
    }

    @Test func seedDataExercisesHaveNonEmptyNames() {
        #expect(ExerciseSeedData.exercises.allSatisfy { !$0.name.isEmpty })
    }
}

// MARK: - SetType Tests

@Suite("SetType Tests")
struct SetTypeTests {
    @Test func allCasesCount() {
        #expect(SetType.allCases.count == 2)
    }

    @Test func rawValues() {
        #expect(SetType.normal.rawValue == "normal")
        #expect(SetType.warmup.rawValue == "warmup")
    }

    @Test func initFromRawValue() {
        #expect(SetType(rawValue: "normal") == .normal)
        #expect(SetType(rawValue: "warmup") == .warmup)
        #expect(SetType(rawValue: "unknown") == nil)
    }
}

// MARK: - PRType Tests

@Suite("PRType Tests")
struct PRTypeTests {
    @Test func allCasesCount() {
        #expect(PRType.allCases.count == 3)
    }

    @Test func displayNames() {
        #expect(PRType.weight.displayName == "Weight")
        #expect(PRType.estimated1RM.displayName == "Est. 1RM")
        #expect(PRType.volume.displayName == "Volume")
    }

    @Test func icons() {
        #expect(PRType.weight.icon == "scalemass.fill")
        #expect(PRType.estimated1RM.icon == "bolt.fill")
        #expect(PRType.volume.icon == "chart.bar.fill")
    }
}

// MARK: - ExerciseSet Computed Property Tests

@Suite("ExerciseSet Computed Property Tests")
struct ExerciseSetComputedTests {
    @Test func setTypeDefaultsToNormal() {
        let set = ExerciseSet(order: 0)
        #expect(set.setType == .normal)
    }

    @Test func setTypeInitWithWarmup() {
        let set = ExerciseSet(order: 0, setType: .warmup)
        #expect(set.setType == .warmup)
        #expect(set.setTypeRaw == "warmup")
    }

    @Test func setTypeRoundTrip() {
        let set = ExerciseSet(order: 0)
        set.setType = .warmup
        #expect(set.setType == .warmup)
        set.setType = .normal
        #expect(set.setType == .normal)
    }

    @Test func isAnyPRFalseByDefault() {
        let set = ExerciseSet(order: 0)
        #expect(!set.isAnyPR)
    }

    @Test func isAnyPRTrueWhenWeightPR() {
        let set = ExerciseSet(order: 0)
        set.isWeightPR = true
        #expect(set.isAnyPR)
    }

    @Test func isAnyPRTrueWhenEstimated1RMPR() {
        let set = ExerciseSet(order: 0)
        set.isEstimated1RMPR = true
        #expect(set.isAnyPR)
    }

    @Test func isAnyPRTrueWhenVolumePR() {
        let set = ExerciseSet(order: 0)
        set.isVolumePR = true
        #expect(set.isAnyPR)
    }

    @Test func prTypesEmptyByDefault() {
        let set = ExerciseSet(order: 0)
        #expect(set.prTypes.isEmpty)
    }

    @Test func prTypesContainsAllFlags() {
        let set = ExerciseSet(order: 0)
        set.isWeightPR = true
        set.isEstimated1RMPR = true
        set.isVolumePR = true
        let types = set.prTypes
        #expect(types.count == 3)
        #expect(types.contains(.weight))
        #expect(types.contains(.estimated1RM))
        #expect(types.contains(.volume))
    }

    @Test func rpeNilByDefault() {
        let set = ExerciseSet(order: 0)
        #expect(set.rpe == nil)
    }
}

// MARK: - WorkoutExercise Computed Property Tests

@Suite("WorkoutExercise Computed Property Tests")
struct WorkoutExerciseComputedTests {
    @Test func isInSupersetFalseByDefault() {
        let we = WorkoutExercise(order: 0)
        #expect(!we.isInSuperset)
    }

    @Test func isInSupersetTrueWithGroupId() {
        let we = WorkoutExercise(order: 0, supersetGroupId: UUID())
        #expect(we.isInSuperset)
    }
}

// MARK: - TemplateSet Tests

@Suite("TemplateSet Tests")
struct TemplateSetTests {
    @Test func initializationDefaults() {
        let ts = TemplateSet(order: 0)
        #expect(ts.order == 0)
        #expect(ts.weight == 0)
        #expect(ts.reps == 0)
        #expect(ts.setType == .normal)
    }

    @Test func initWithValues() {
        let ts = TemplateSet(order: 2, weight: 135, reps: 8)
        #expect(ts.weight == 135)
        #expect(ts.reps == 8)
        #expect(ts.order == 2)
    }

    @Test func setTypeWarmup() {
        let ts = TemplateSet(order: 0, setType: .warmup)
        #expect(ts.setType == .warmup)
    }

    @Test func setTypeRoundTrip() {
        let ts = TemplateSet(order: 0)
        ts.setType = .warmup
        #expect(ts.setType == .warmup)
        ts.setType = .normal
        #expect(ts.setType == .normal)
    }
}

// MARK: - TimeRange Tests

@Suite("TimeRange Tests")
struct TimeRangeTests {
    @Test func allCasesCount() {
        #expect(TimeRange.allCases.count == 5)
    }

    @Test func rawValues() {
        #expect(TimeRange.oneMonth.rawValue == "1M")
        #expect(TimeRange.threeMonths.rawValue == "3M")
        #expect(TimeRange.sixMonths.rawValue == "6M")
        #expect(TimeRange.oneYear.rawValue == "1Y")
        #expect(TimeRange.allTime.rawValue == "All")
    }

    @Test func idEqualsRawValue() {
        for range in TimeRange.allCases {
            #expect(range.id == range.rawValue)
        }
    }

    @Test func allTimeStartDateIsNil() {
        #expect(TimeRange.allTime.startDate == nil)
    }

    @Test func otherRangesHaveNonNilStartDates() {
        let ranges: [TimeRange] = [.oneMonth, .threeMonths, .sixMonths, .oneYear]
        for range in ranges {
            #expect(range.startDate != nil, "\(range.rawValue) should have a non-nil startDate")
        }
    }

    @Test func startDatesAreInThePast() {
        let ranges: [TimeRange] = [.oneMonth, .threeMonths, .sixMonths, .oneYear]
        for range in ranges {
            if let start = range.startDate {
                #expect(start < Date.now)
            }
        }
    }

    @Test func startDatesAreOrderedChronologically() {
        let oneMonth = TimeRange.oneMonth.startDate!
        let threeMonths = TimeRange.threeMonths.startDate!
        let sixMonths = TimeRange.sixMonths.startDate!
        let oneYear = TimeRange.oneYear.startDate!
        #expect(oneMonth > threeMonths)
        #expect(threeMonths > sixMonths)
        #expect(sixMonths > oneYear)
    }
}

// MARK: - PersonalRecordService Formula Tests

@Suite("PersonalRecordService Formula Tests")
struct PersonalRecordFormulaTests {
    @Test func estimatedOneRepMaxSingleRep() {
        #expect(PersonalRecordService.estimatedOneRepMax(weight: 100, reps: 1) == 100)
    }

    @Test func estimatedOneRepMaxMultipleReps() {
        let result = PersonalRecordService.estimatedOneRepMax(weight: 100, reps: 10)
        let expected = 100.0 * (1 + 10.0 / 30.0)
        #expect(abs(result - expected) < 0.001)
    }

    @Test func estimatedOneRepMaxZeroReps() {
        #expect(PersonalRecordService.estimatedOneRepMax(weight: 100, reps: 0) == 0)
    }

    @Test func estimatedOneRepMaxZeroWeight() {
        #expect(PersonalRecordService.estimatedOneRepMax(weight: 0, reps: 10) == 0)
    }

    @Test func setVolumeCalculation() {
        #expect(PersonalRecordService.setVolume(weight: 135, reps: 5) == 675)
    }

    @Test func setVolumeZeroWeight() {
        #expect(PersonalRecordService.setVolume(weight: 0, reps: 10) == 0)
    }

    @Test func setVolumeZeroReps() {
        #expect(PersonalRecordService.setVolume(weight: 100, reps: 0) == 0)
    }
}

// MARK: - PlateCalculatorService Tests

@Suite("PlateCalculatorService Tests")
struct PlateCalculatorServiceTests {
    @Test func targetBelowBarReturnsEmpty() {
        let result = PlateCalculatorService.calculatePlates(targetWeight: 40, barWeight: 45, unit: "lbs")
        #expect(result.plates.isEmpty)
        #expect(result.perSideWeight == 0)
    }

    @Test func targetEqualsBarReturnsEmpty() {
        let result = PlateCalculatorService.calculatePlates(targetWeight: 45, barWeight: 45, unit: "lbs")
        #expect(result.plates.isEmpty)
    }

    @Test func zeroBarWeightReturnsEmpty() {
        let result = PlateCalculatorService.calculatePlates(targetWeight: 135, barWeight: 0, unit: "lbs")
        #expect(result.plates.isEmpty)
    }

    @Test func setup135lbs() {
        // 135 - 45 = 90 / 2 = 45 per side → 1×45
        let result = PlateCalculatorService.calculatePlates(targetWeight: 135, barWeight: 45, unit: "lbs")
        #expect(result.plates.count == 1)
        #expect(result.plates[0].weight == 45)
        #expect(result.plates[0].count == 1)
        #expect(result.perSideWeight == 45)
        #expect(result.remainder == 0)
    }

    @Test func setup225lbs() {
        // 225 - 45 = 180 / 2 = 90 per side → 2×45
        let result = PlateCalculatorService.calculatePlates(targetWeight: 225, barWeight: 45, unit: "lbs")
        #expect(result.plates.count == 1)
        #expect(result.plates[0].weight == 45)
        #expect(result.plates[0].count == 2)
        #expect(result.perSideWeight == 90)
    }

    @Test func setup315lbs() {
        // 315 - 45 = 270 / 2 = 135 per side → 3×45
        let result = PlateCalculatorService.calculatePlates(targetWeight: 315, barWeight: 45, unit: "lbs")
        #expect(result.plates.count == 1)
        #expect(result.plates[0].weight == 45)
        #expect(result.plates[0].count == 3)
    }

    @Test func mixedPlates155lbs() {
        // 155 - 45 = 110 / 2 = 55 per side → 1×45 + 1×10
        let result = PlateCalculatorService.calculatePlates(targetWeight: 155, barWeight: 45, unit: "lbs")
        #expect(result.perSideWeight == 55)
        let totalPlateWeight = result.plates.reduce(0.0) { $0 + $1.weight * Double($1.count) }
        #expect(abs(totalPlateWeight - 55) < 0.01)
    }

    @Test func smallestPlate50lbs() {
        // 50 - 45 = 5 / 2 = 2.5 per side → 1×2.5
        let result = PlateCalculatorService.calculatePlates(targetWeight: 50, barWeight: 45, unit: "lbs")
        #expect(result.plates.count == 1)
        #expect(result.plates[0].weight == 2.5)
        #expect(result.plates[0].count == 1)
    }

    @Test func kgMode() {
        // 60kg - 20kg bar = 40 / 2 = 20 per side → 1×20kg
        let result = PlateCalculatorService.calculatePlates(targetWeight: 60, barWeight: 20, unit: "kg")
        #expect(result.plates.count == 1)
        #expect(result.plates[0].weight == 20)
        #expect(result.plates[0].count == 1)
    }
}
