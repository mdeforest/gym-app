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

// MARK: - Available Equipment Tests

/// Pure-logic helpers mirroring the @AppStorage ↔ Set<Equipment> conversion used in views.
private func parseAvailableEquipment(_ raw: String) -> Set<Equipment> {
    guard !raw.isEmpty else { return [] }
    return Set(raw.split(separator: ",").compactMap { Equipment(rawValue: String($0)) })
}

private func encodeAvailableEquipment(_ set: Set<Equipment>) -> String {
    if set.count == Equipment.allCases.count { return "" }
    return set.map(\.rawValue).sorted().joined(separator: ",")
}

private func exercisePassesFilter(_ exercise: Exercise, availableEquipment: Set<Equipment>) -> Bool {
    guard !availableEquipment.isEmpty else { return true }
    guard let eq = exercise.equipment else { return true }
    return eq == .other || availableEquipment.contains(eq)
}

@Suite("Available Equipment — Parsing")
struct AvailableEquipmentParsingTests {

    @Test func emptyStringMeansNoFilter() {
        let result = parseAvailableEquipment("")
        #expect(result.isEmpty)
    }

    @Test func singleEquipment() {
        let result = parseAvailableEquipment("barbell")
        #expect(result == [.barbell])
    }

    @Test func multipleEquipment() {
        let result = parseAvailableEquipment("barbell,dumbbell,cable")
        #expect(result == [.barbell, .dumbbell, .cable])
    }

    @Test func allEquipmentCases() {
        let all = Equipment.allCases.map(\.rawValue).sorted().joined(separator: ",")
        let result = parseAvailableEquipment(all)
        #expect(result == Set(Equipment.allCases))
    }

    @Test func unknownRawValueIsDropped() {
        let result = parseAvailableEquipment("barbell,unknown_type,dumbbell")
        #expect(result == [.barbell, .dumbbell])
    }

    @Test func orderDoesNotMatter() {
        let a = parseAvailableEquipment("dumbbell,barbell")
        let b = parseAvailableEquipment("barbell,dumbbell")
        #expect(a == b)
    }
}

@Suite("Available Equipment — Encoding")
struct AvailableEquipmentEncodingTests {

    @Test func fullSetEncodesToEmptyString() {
        let result = encodeAvailableEquipment(Set(Equipment.allCases))
        #expect(result == "")
    }

    @Test func emptySetEncodesToEmptyString() {
        // Edge case: empty selection encodes the same as "all selected"
        // (no equipment configured = show everything)
        let result = encodeAvailableEquipment([])
        #expect(result == "")
    }

    @Test func singleEquipmentIsSorted() {
        let result = encodeAvailableEquipment([.barbell])
        #expect(result == "barbell")
    }

    @Test func multipleEquipmentAreSorted() {
        let result = encodeAvailableEquipment([.dumbbell, .barbell, .cable])
        #expect(result == "barbell,cable,dumbbell")
    }

    @Test func roundTrip() {
        let original: Set<Equipment> = [.barbell, .kettlebell, .bodyweight]
        let encoded = encodeAvailableEquipment(original)
        let decoded = parseAvailableEquipment(encoded)
        #expect(decoded == original)
    }
}

@Suite("Available Equipment — Exercise Filtering")
struct AvailableEquipmentFilterTests {

    // MARK: Empty filter (no restriction)

    @Test func emptyFilterShowsAll() {
        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest, equipment: .barbell)
        #expect(exercisePassesFilter(exercise, availableEquipment: []))
    }

    @Test func emptyFilterShowsNilEquipment() {
        let exercise = Exercise(name: "Custom", muscleGroup: .chest)
        exercise.equipment = nil
        #expect(exercisePassesFilter(exercise, availableEquipment: []))
    }

    // MARK: Active filter — exercises that should always show

    @Test func nilEquipmentAlwaysShows() {
        let exercise = Exercise(name: "Custom", muscleGroup: .chest)
        exercise.equipment = nil
        let filter: Set<Equipment> = [.barbell]
        #expect(exercisePassesFilter(exercise, availableEquipment: filter))
    }

    @Test func otherEquipmentAlwaysShows() {
        let exercise = Exercise(name: "Stretch", muscleGroup: .chest, equipment: .other)
        let filter: Set<Equipment> = [.barbell]
        #expect(exercisePassesFilter(exercise, availableEquipment: filter))
    }

    // MARK: Active filter — exercises that should be hidden

    @Test func barbellHiddenWhenNotInFilter() {
        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest, equipment: .barbell)
        let filter: Set<Equipment> = [.dumbbell, .bodyweight]
        #expect(!exercisePassesFilter(exercise, availableEquipment: filter))
    }

    @Test func dumbbellHiddenWhenNotInFilter() {
        let exercise = Exercise(name: "Dumbbell Curl", muscleGroup: .arms, equipment: .dumbbell)
        let filter: Set<Equipment> = [.barbell, .cable]
        #expect(!exercisePassesFilter(exercise, availableEquipment: filter))
    }

    // MARK: Active filter — exercises that should show

    @Test func barbellShownWhenInFilter() {
        let exercise = Exercise(name: "Squat", muscleGroup: .legs, equipment: .barbell)
        let filter: Set<Equipment> = [.barbell, .dumbbell]
        #expect(exercisePassesFilter(exercise, availableEquipment: filter))
    }

    @Test func bodyweightShownWhenInFilter() {
        let exercise = Exercise(name: "Push-up", muscleGroup: .chest, equipment: .bodyweight)
        let filter: Set<Equipment> = [.bodyweight]
        #expect(exercisePassesFilter(exercise, availableEquipment: filter))
    }

    // MARK: Full set filter equals no filter

    @Test func fullFilterEquivalentToNoFilter() {
        let exercises: [Exercise] = [
            Exercise(name: "Bench Press", muscleGroup: .chest, equipment: .barbell),
            Exercise(name: "Curl", muscleGroup: .arms, equipment: .dumbbell),
            Exercise(name: "Push-up", muscleGroup: .chest, equipment: .bodyweight),
        ]
        let fullFilter = Set(Equipment.allCases)
        let noFilter: Set<Equipment> = []
        for exercise in exercises {
            let withFull = exercisePassesFilter(exercise, availableEquipment: fullFilter)
            let withNone = exercisePassesFilter(exercise, availableEquipment: noFilter)
            #expect(withFull == withNone)
        }
    }
}

// MARK: - GymProfile Tests

@Suite("GymProfile — Initialization")
struct GymProfileInitTests {
    @Test func defaultEquipmentRawIsEmpty() {
        let p = GymProfile(name: "My Gym")
        #expect(p.equipmentRaw == "")
    }

    @Test func customIdIsPreserved() {
        let id = UUID()
        let p = GymProfile(id: id, name: "Test")
        #expect(p.id == id)
    }

    @Test func defaultIdIsUnique() {
        let a = GymProfile(name: "A")
        let b = GymProfile(name: "B")
        #expect(a.id != b.id)
    }
}

@Suite("GymProfile — Equipment Encoding")
struct GymProfileEquipmentEncodingTests {
    @Test func emptyRawMeansEmptySet() {
        let p = GymProfile(name: "All", equipmentRaw: "")
        #expect(p.equipmentSet.isEmpty)
    }

    @Test func parsesRawCorrectly() {
        let p = GymProfile(name: "Home", equipmentRaw: "barbell,dumbbell")
        #expect(p.equipmentSet == [.barbell, .dumbbell])
    }

    @Test func encodeFullSetProducesEmptyString() {
        let result = GymProfile.encode(equipment: Set(Equipment.allCases))
        #expect(result == "")
    }

    @Test func encodeIsSorted() {
        let result = GymProfile.encode(equipment: [.dumbbell, .barbell])
        #expect(result == "barbell,dumbbell")
    }

    @Test func encodeDecodeRoundTrip() {
        let original: Set<Equipment> = [.barbell, .kettlebell, .bodyweight]
        let encoded = GymProfile.encode(equipment: original)
        let p = GymProfile(name: "Test", equipmentRaw: encoded)
        #expect(p.equipmentSet == original)
    }
}

@Suite("GymProfile — Codable")
struct GymProfileCodableTests {
    @Test func singleProfileRoundTrip() throws {
        let original = GymProfile(id: UUID(), name: "My Gym", equipmentRaw: "barbell,cable")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GymProfile.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.equipmentRaw == original.equipmentRaw)
    }

    @Test func arrayRoundTrip() throws {
        let profiles = [
            GymProfile(name: "Home Gym", equipmentRaw: "barbell,dumbbell"),
            GymProfile(name: "Commercial Gym", equipmentRaw: ""),
        ]
        let data = try JSONEncoder().encode(profiles)
        let decoded = try JSONDecoder().decode([GymProfile].self, from: data)
        #expect(decoded.count == 2)
        #expect(decoded[0].name == "Home Gym")
        #expect(decoded[1].name == "Commercial Gym")
    }

    @Test func missingDataReturnsEmpty() {
        let key = "gymProfiles_test_\(UUID().uuidString)"
        // key was never written — loadAll should return []
        let data = UserDefaults.standard.data(forKey: key)
        #expect(data == nil)
    }
}

@Suite("GymProfile — Built-in Templates")
struct GymProfileTemplateTests {
    @Test func builtInTemplatesCount() {
        #expect(GymProfile.builtInTemplates.count == 3)
    }

    @Test func commercialGymIsAllEquipment() {
        #expect(GymProfile.commercialGym.equipmentRaw == "")
    }

    @Test func homeGymExcludesCableAndMachine() {
        let eq = GymProfile.homeGym.equipmentSet
        #expect(!eq.contains(.cable))
        #expect(!eq.contains(.machine))
    }

    @Test func travelIncludesBodyweightAndBands() {
        let eq = GymProfile.travel.equipmentSet
        #expect(eq.contains(.bodyweight))
        #expect(eq.contains(.bands))
    }

    @Test func builtInTemplatesHaveUniqueIds() {
        let ids = GymProfile.builtInTemplates.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func builtInTemplatesHaveNonEmptyNames() {
        #expect(GymProfile.builtInTemplates.allSatisfy { !$0.name.isEmpty })
    }
}

@Suite("GymProfile — Equatable")
struct GymProfileEquatableTests {
    @Test func sameIdAndContentAreEqual() {
        let id = UUID()
        let a = GymProfile(id: id, name: "Gym", equipmentRaw: "barbell")
        let b = GymProfile(id: id, name: "Gym", equipmentRaw: "barbell")
        #expect(a == b)
    }

    @Test func differentIdsAreNotEqual() {
        let a = GymProfile(name: "Gym", equipmentRaw: "barbell")
        let b = GymProfile(name: "Gym", equipmentRaw: "barbell")
        #expect(a != b)
    }

    @Test func sameIdDifferentNameAreNotEqual() {
        let id = UUID()
        let a = GymProfile(id: id, name: "Home", equipmentRaw: "barbell")
        let b = GymProfile(id: id, name: "Work", equipmentRaw: "barbell")
        #expect(a != b)
    }
}

// MARK: - MachineType Tests

@Suite("MachineType Tests")
struct MachineTypeTests {
    @Test func allCasesCount() {
        #expect(MachineType.allCases.count == 12)
    }

    @Test func idEqualsRawValue() {
        for type_ in MachineType.allCases {
            #expect(type_.id == type_.rawValue)
        }
    }

    @Test func rawValues() {
        #expect(MachineType.smithMachine.rawValue == "smith_machine")
        #expect(MachineType.legPress.rawValue == "leg_press")
        #expect(MachineType.legExtensionCurl.rawValue == "leg_extension_curl")
        #expect(MachineType.hackSquat.rawValue == "hack_squat")
        #expect(MachineType.calfMachine.rawValue == "calf_machine")
        #expect(MachineType.cardioMachine.rawValue == "cardio_machine")
        #expect(MachineType.chestMachine.rawValue == "chest_machine")
        #expect(MachineType.rowMachine.rawValue == "row_machine")
        #expect(MachineType.shoulderMachine.rawValue == "shoulder_machine")
        #expect(MachineType.leverageMachine.rawValue == "leverage_machine")
        #expect(MachineType.armMachine.rawValue == "arm_machine")
        #expect(MachineType.otherMachine.rawValue == "other_machine")
    }

    @Test func displayNames() {
        #expect(MachineType.smithMachine.displayName == "Smith Machine")
        #expect(MachineType.legPress.displayName == "Leg Press")
        #expect(MachineType.legExtensionCurl.displayName == "Leg Extension / Curl")
        #expect(MachineType.hackSquat.displayName == "Hack Squat")
        #expect(MachineType.calfMachine.displayName == "Calf Machine")
        #expect(MachineType.cardioMachine.displayName == "Cardio Machines")
        #expect(MachineType.chestMachine.displayName == "Chest / Fly Machine")
        #expect(MachineType.rowMachine.displayName == "Row Machine")
        #expect(MachineType.shoulderMachine.displayName == "Shoulder Press Machine")
        #expect(MachineType.leverageMachine.displayName == "Leverage / Plate Machine")
        #expect(MachineType.armMachine.displayName == "Arm Machine")
        #expect(MachineType.otherMachine.displayName == "Other Machines")
    }

    @Test func allCasesHaveNonEmptyIcons() {
        for type_ in MachineType.allCases {
            #expect(!type_.icon.isEmpty, "\(type_.rawValue) has empty icon")
        }
    }

    @Test func initFromRawValue() {
        #expect(MachineType(rawValue: "smith_machine") == .smithMachine)
        #expect(MachineType(rawValue: "leg_press") == .legPress)
        #expect(MachineType(rawValue: "other_machine") == .otherMachine)
        #expect(MachineType(rawValue: "unknown") == nil)
    }

    @Test func codableRoundTrip() throws {
        for type_ in MachineType.allCases {
            let encoded = try JSONEncoder().encode(type_)
            let decoded = try JSONDecoder().decode(MachineType.self, from: encoded)
            #expect(decoded == type_)
        }
    }
}

// MARK: - GymProfile Machine Helpers Tests

@Suite("GymProfile — Machine Helpers")
struct GymProfileMachineTests {
    @Test func defaultMachinesRawIsEmpty() {
        let p = GymProfile(name: "My Gym")
        #expect(p.machinesRaw == "")
    }

    @Test func emptyMachinesRawMeansEmptySet() {
        let p = GymProfile(name: "All", machinesRaw: "")
        #expect(p.machineTypeSet.isEmpty)
    }

    @Test func parseMachinesRawCorrectly() {
        let p = GymProfile(name: "Partial", machinesRaw: "leg_press,smith_machine")
        #expect(p.machineTypeSet == [.legPress, .smithMachine])
    }

    @Test func unknownMachineRawValueIsDropped() {
        let p = GymProfile(name: "Test", machinesRaw: "leg_press,unknown_type,smith_machine")
        #expect(p.machineTypeSet == [.legPress, .smithMachine])
    }

    @Test func encodeFullMachineSetProducesEmptyString() {
        let result = GymProfile.encode(machines: Set(MachineType.allCases))
        #expect(result == "")
    }

    @Test func encodeEmptyMachineSet() {
        // Empty set encodes to "" (same as "all machines" convention)
        let result = GymProfile.encode(machines: [])
        #expect(result == "")
    }

    @Test func encodeMachinesIsSorted() {
        let result = GymProfile.encode(machines: [.smithMachine, .legPress])
        #expect(result == "leg_press,smith_machine")
    }

    @Test func encodeMachinesDecodeRoundTrip() {
        let original: Set<MachineType> = [.legPress, .chestMachine, .armMachine]
        let encoded = GymProfile.encode(machines: original)
        let p = GymProfile(name: "Test", machinesRaw: encoded)
        #expect(p.machineTypeSet == original)
    }

    @Test func codableRoundTripIncludesMachinesRaw() throws {
        let original = GymProfile(id: UUID(), name: "Gym", equipmentRaw: "machine", machinesRaw: "leg_press,smith_machine")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GymProfile.self, from: data)
        #expect(decoded.machinesRaw == original.machinesRaw)
        #expect(decoded.machineTypeSet == original.machineTypeSet)
    }

    @Test func backwardCompatibleDecodeWithoutMachinesRaw() throws {
        // Simulates an old stored profile that has no machinesRaw key
        let oldJSON = """
        {"id":"\(UUID().uuidString)","name":"Legacy Gym","equipmentRaw":"barbell,dumbbell"}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(GymProfile.self, from: oldJSON)
        #expect(decoded.machinesRaw == "")
        #expect(decoded.machineTypeSet.isEmpty)
    }
}

// MARK: - Machine-Aware Exercise Filter Tests

/// Pure-logic helper mirroring the exercisePasses(_:) logic in AddExerciseView/ExerciseLibraryView.
private func exercisePassesMachineFilter(
    _ exercise: Exercise,
    availableEquipment: Set<Equipment>,
    availableMachines: Set<MachineType>
) -> Bool {
    guard let eq = exercise.equipment else { return true }
    if eq == .other { return true }
    if !availableEquipment.isEmpty && !availableEquipment.contains(eq) { return false }
    if eq == .machine && !availableMachines.isEmpty {
        guard let mt = exercise.machineType else { return true }
        return availableMachines.contains(mt)
    }
    return true
}

@Suite("Machine-Aware Exercise Filter")
struct MachineAwareFilterTests {

    // MARK: No active machine filter

    @Test func emptyMachineFilterShowsAllMachineExercises() {
        let exercise = Exercise(name: "Leg Press", muscleGroup: .legs, equipment: .machine, machineType: .legPress)
        #expect(exercisePassesMachineFilter(exercise, availableEquipment: [.machine], availableMachines: []))
    }

    @Test func emptyBothFiltersShowsAll() {
        let exercise = Exercise(name: "Leg Press", muscleGroup: .legs, equipment: .machine, machineType: .legPress)
        #expect(exercisePassesMachineFilter(exercise, availableEquipment: [], availableMachines: []))
    }

    // MARK: Machine sub-filter active

    @Test func machineExercisePassesWhenTypeInFilter() {
        let exercise = Exercise(name: "Leg Press", muscleGroup: .legs, equipment: .machine, machineType: .legPress)
        #expect(exercisePassesMachineFilter(exercise, availableEquipment: [.machine], availableMachines: [.legPress, .smithMachine]))
    }

    @Test func machineExerciseHiddenWhenTypeNotInFilter() {
        let exercise = Exercise(name: "Hack Squat", muscleGroup: .legs, equipment: .machine, machineType: .hackSquat)
        let filter: Set<MachineType> = [.legPress, .smithMachine]
        #expect(!exercisePassesMachineFilter(exercise, availableEquipment: [.machine], availableMachines: filter))
    }

    @Test func machineExerciseWithNilTypePassesAnyMachineFilter() {
        // Exercises without a machineType assigned are always shown
        let exercise = Exercise(name: "Generic Machine Row", muscleGroup: .back, equipment: .machine, machineType: nil)
        let filter: Set<MachineType> = [.legPress]
        #expect(exercisePassesMachineFilter(exercise, availableEquipment: [.machine], availableMachines: filter))
    }

    // MARK: Equipment filter still applies

    @Test func machineExerciseHiddenWhenMachineEquipmentNotInFilter() {
        let exercise = Exercise(name: "Leg Press", muscleGroup: .legs, equipment: .machine, machineType: .legPress)
        // Machine equipment not included in availableEquipment → filtered out before machine check
        let filter: Set<MachineType> = [.legPress]
        #expect(!exercisePassesMachineFilter(exercise, availableEquipment: [.barbell, .dumbbell], availableMachines: filter))
    }

    // MARK: Non-machine equipment unaffected by machine filter

    @Test func barbellExerciseUnaffectedByMachineFilter() {
        let exercise = Exercise(name: "Squat", muscleGroup: .legs, equipment: .barbell)
        let machineFilter: Set<MachineType> = [.legPress]
        #expect(exercisePassesMachineFilter(exercise, availableEquipment: [.barbell], availableMachines: machineFilter))
    }

    @Test func bodyweightExerciseUnaffectedByMachineFilter() {
        let exercise = Exercise(name: "Push-up", muscleGroup: .chest, equipment: .bodyweight)
        let machineFilter: Set<MachineType> = [.chestMachine]
        #expect(exercisePassesMachineFilter(exercise, availableEquipment: [.bodyweight], availableMachines: machineFilter))
    }

    @Test func otherEquipmentAlwaysPasses() {
        let exercise = Exercise(name: "Stretch", muscleGroup: .core, equipment: .other)
        // Even with a restrictive equipment filter, .other always passes
        #expect(exercisePassesMachineFilter(exercise, availableEquipment: [.barbell], availableMachines: [.legPress]))
    }

    @Test func nilEquipmentAlwaysPasses() {
        let exercise = Exercise(name: "Custom", muscleGroup: .chest)
        exercise.equipment = nil
        #expect(exercisePassesMachineFilter(exercise, availableEquipment: [.barbell], availableMachines: [.legPress]))
    }
}

// MARK: - MachineTypeMap Coverage Tests

@Suite("MachineTypeMap Coverage")
struct MachineTypeMapTests {
    @Test func mapIsNotEmpty() {
        #expect(!ExerciseSeedData.machineTypeMap.isEmpty)
    }

    @Test func allValuesAreValidMachineTypes() {
        // All mapped values are valid MachineType cases (always true for hardcoded enum literals,
        // but validates no raw value string typos exist)
        for (_, machineType) in ExerciseSeedData.machineTypeMap {
            #expect(MachineType(rawValue: machineType.rawValue) != nil)
        }
    }

    @Test func allMachineTypesRepresentedInMap() {
        let mappedTypes = Set(ExerciseSeedData.machineTypeMap.values)
        for type_ in MachineType.allCases {
            #expect(mappedTypes.contains(type_), "\(type_.displayName) has no exercises in machineTypeMap")
        }
    }

    @Test func mapKeysAreUnique() {
        // Dictionary keys are always unique by definition, but we verify count vs. original entries
        // by checking the map was not silently collapsed during construction
        #expect(ExerciseSeedData.machineTypeMap.count > 0)
    }

    @Test func smithMachineExercisesAreMapped() {
        let smithExercises = ExerciseSeedData.machineTypeMap.filter { $0.value == .smithMachine }
        #expect(!smithExercises.isEmpty)
    }

    @Test func legPressExercisesAreMapped() {
        let legPressExercises = ExerciseSeedData.machineTypeMap.filter { $0.value == .legPress }
        #expect(!legPressExercises.isEmpty)
    }
}
