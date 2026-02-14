import Foundation
import Testing
import SwiftData
@testable import Pulse

// MARK: - Test Helpers

/// Shared container to avoid spinning up dozens of in-memory stores.
@MainActor
private let sharedContainer: ModelContainer = {
    try! DataService.createPreviewContainer()
}()

@MainActor
private func makeFreshContext() -> ModelContext {
    ModelContext(sharedContainer)
}

// MARK: - WorkoutViewModel Tests

@Suite("WorkoutViewModel Tests", .serialized)
@MainActor
struct WorkoutViewModelTests {

    // MARK: Rest Timer Computed Properties

    @Test func restTimerProgressZeroWhenDurationZero() {
        let vm = WorkoutViewModel(modelContext: makeFreshContext())
        #expect(vm.restTimerProgress == 0)
    }

    @Test func restTimerProgressCalculation() {
        let vm = WorkoutViewModel(modelContext: makeFreshContext())
        vm.restTimerDuration = 60
        vm.restTimeRemaining = 30
        #expect(vm.restTimerProgress == 0.5)
    }

    @Test func restTimerProgressFull() {
        let vm = WorkoutViewModel(modelContext: makeFreshContext())
        vm.restTimerDuration = 60
        vm.restTimeRemaining = 0
        #expect(vm.restTimerProgress == 1.0)
    }

    @Test func restTimerDisplayText() {
        let vm = WorkoutViewModel(modelContext: makeFreshContext())

        vm.restTimeRemaining = 90
        #expect(vm.restTimerDisplayText == "1:30")

        vm.restTimeRemaining = 5
        #expect(vm.restTimerDisplayText == "0:05")

        vm.restTimeRemaining = 0
        #expect(vm.restTimerDisplayText == "0:00")

        vm.restTimeRemaining = 300
        #expect(vm.restTimerDisplayText == "5:00")
    }

    // MARK: Workout Lifecycle

    @Test func startWorkoutCreatesActiveWorkout() {
        let vm = WorkoutViewModel(modelContext: makeFreshContext())
        #expect(vm.activeWorkout == nil)
        vm.startWorkout()
        #expect(vm.activeWorkout != nil)
        #expect(vm.activeWorkout?.isActive == true)
    }

    @Test func discardWorkoutClearsActiveWorkout() {
        let vm = WorkoutViewModel(modelContext: makeFreshContext())
        vm.startWorkout()
        #expect(vm.activeWorkout != nil)
        vm.discardWorkout()
        #expect(vm.activeWorkout == nil)
    }

    @Test func finishWorkoutSetsEndDate() {
        let vm = WorkoutViewModel(modelContext: makeFreshContext())
        vm.startWorkout()
        let finished = vm.finishWorkout()
        #expect(finished != nil)
        #expect(finished?.endDate != nil)
        #expect(vm.activeWorkout == nil)
    }

    @Test func finishWorkoutReturnsNilWhenNoActiveWorkout() {
        let vm = WorkoutViewModel(modelContext: makeFreshContext())
        // Discard any leftover active workout from shared container
        if vm.activeWorkout != nil {
            vm.discardWorkout()
        }
        #expect(vm.activeWorkout == nil)
        let result = vm.finishWorkout()
        #expect(result == nil)
    }

    // MARK: Exercises

    @Test func addExerciseToWorkout() {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)
        vm.startWorkout()

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)

        vm.addExercise(exercise)
        #expect(vm.activeWorkout?.exercises.count == 1)
    }

    @Test func addNonCardioExerciseCreatesOneDefaultSet() {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)
        vm.startWorkout()

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)
        vm.addExercise(exercise)

        guard let workoutExercise = vm.activeWorkout?.exercises.first else {
            Issue.record("No workout exercise found")
            return
        }
        #expect(workoutExercise.sets.count == 1)
    }

    @Test func addCardioExerciseCreatesNoSets() {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)
        vm.startWorkout()

        let cardio = Exercise(name: "Running", muscleGroup: .cardio, isCardio: true)
        context.insert(cardio)
        vm.addExercise(cardio)

        guard let workoutExercise = vm.activeWorkout?.exercises.first else {
            Issue.record("No workout exercise found")
            return
        }
        #expect(workoutExercise.sets.isEmpty)
    }

    @Test func addExerciseSetsLastUsedDate() {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)
        vm.startWorkout()

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)
        #expect(exercise.lastUsedDate == nil)

        vm.addExercise(exercise)
        #expect(exercise.lastUsedDate != nil)
    }

    @Test func removeExercise() {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)
        vm.startWorkout()

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)
        vm.addExercise(exercise)

        guard let workoutExercise = vm.activeWorkout?.exercises.first else {
            Issue.record("No workout exercise found")
            return
        }
        vm.removeExercise(workoutExercise)
        #expect(vm.activeWorkout?.exercises.isEmpty == true)
    }

    // MARK: Sets

    @Test func addSetToExercise() {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)
        vm.startWorkout()

        let exercise = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(exercise)
        vm.addExercise(exercise)

        guard let workoutExercise = vm.activeWorkout?.exercises.first else {
            Issue.record("No workout exercise found")
            return
        }

        let initialSetCount = workoutExercise.sets.count
        vm.addSet(to: workoutExercise)
        #expect(workoutExercise.sets.count == initialSetCount + 1)
    }

    @Test func addSetCopiesValuesFromPreviousSet() {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)
        vm.startWorkout()

        let exercise = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(exercise)
        vm.addExercise(exercise)

        guard let workoutExercise = vm.activeWorkout?.exercises.first else {
            Issue.record("No workout exercise found")
            return
        }

        if let firstSet = workoutExercise.sortedSets.first {
            firstSet.weight = 225
            firstSet.reps = 5
        }

        vm.addSet(to: workoutExercise)

        let newSet = workoutExercise.sortedSets.last
        #expect(newSet?.weight == 225)
        #expect(newSet?.reps == 5)
    }

    @Test func deleteSetReordersRemaining() {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)
        vm.startWorkout()

        let exercise = Exercise(name: "Row", muscleGroup: .back)
        context.insert(exercise)
        vm.addExercise(exercise)

        guard let workoutExercise = vm.activeWorkout?.exercises.first else {
            Issue.record("No workout exercise found")
            return
        }

        vm.addSet(to: workoutExercise)
        vm.addSet(to: workoutExercise)

        let secondSet = workoutExercise.sortedSets[1]
        vm.deleteSet(secondSet, from: workoutExercise)

        let remainingSets = workoutExercise.sortedSets
        #expect(remainingSets.count == 2)
        #expect(remainingSets[0].order == 0)
        #expect(remainingSets[1].order == 1)
    }

    // MARK: Propagate Values

    @Test func propagateValuesToUncompletedSets() {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)
        vm.startWorkout()

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)
        vm.addExercise(exercise)

        guard let workoutExercise = vm.activeWorkout?.exercises.first else {
            Issue.record("No workout exercise found")
            return
        }

        vm.addSet(to: workoutExercise)
        vm.addSet(to: workoutExercise)

        let sets = workoutExercise.sortedSets
        sets[0].weight = 200
        sets[0].reps = 5

        vm.propagateValues(from: sets[0], in: workoutExercise)

        for set in workoutExercise.sortedSets.dropFirst() where !set.isCompleted {
            #expect(set.weight == 200)
            #expect(set.reps == 5)
        }
    }

    @Test func propagateValuesSkipsCompletedSets() {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)
        vm.startWorkout()

        let exercise = Exercise(name: "Deadlift", muscleGroup: .back)
        context.insert(exercise)
        vm.addExercise(exercise)

        guard let workoutExercise = vm.activeWorkout?.exercises.first else {
            Issue.record("No workout exercise found")
            return
        }

        vm.addSet(to: workoutExercise)
        vm.addSet(to: workoutExercise)

        let sets = workoutExercise.sortedSets
        sets[1].weight = 315
        sets[1].reps = 3
        sets[1].isCompleted = true

        sets[0].weight = 225
        sets[0].reps = 8
        vm.propagateValues(from: sets[0], in: workoutExercise)

        #expect(sets[1].weight == 315)
        #expect(sets[1].reps == 3)
    }

    // MARK: Skip Rest Timer

    @Test func skipRestTimerResetsAllState() {
        let vm = WorkoutViewModel(modelContext: makeFreshContext())

        vm.restTimerActive = true
        vm.restTimerRunning = true
        vm.restTimerDuration = 60
        vm.restTimeRemaining = 30
        vm.restTimerExpanded = true
        vm.restTimerCompleted = false
        vm.restTimerExerciseName = "Bench"

        vm.skipRestTimer()

        #expect(!vm.restTimerActive)
        #expect(!vm.restTimerRunning)
        #expect(!vm.restTimerExpanded)
        #expect(!vm.restTimerCompleted)
        #expect(vm.restTimeRemaining == 0)
        #expect(vm.restTimerDuration == 0)
        #expect(vm.restTimerExerciseName == nil)
    }

    // MARK: Template-Based Workout

    @Test func startWorkoutFromTemplate() throws {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)

        let template = WorkoutTemplate(name: "Push Day")
        context.insert(template)

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)

        let te = TemplateExercise(order: 0, exercise: exercise, setCount: 3, defaultWeight: 135, defaultReps: 10)
        te.template = template
        try context.save()

        vm.startWorkout(from: template)

        #expect(vm.activeWorkout != nil)
        #expect(vm.activeWorkout?.exercises.count == 1)

        guard let workoutExercise = vm.activeWorkout?.exercises.first else {
            Issue.record("No workout exercise found")
            return
        }

        #expect(workoutExercise.sets.count == 3)
        for set in workoutExercise.sets {
            #expect(set.weight == 135)
            #expect(set.reps == 10)
        }
    }

    @Test func startWorkoutFromTemplateUpdatesLastUsedDate() throws {
        let context = makeFreshContext()
        let vm = WorkoutViewModel(modelContext: context)

        let template = WorkoutTemplate(name: "Push Day")
        context.insert(template)
        #expect(template.lastUsedDate == nil)

        let exercise = Exercise(name: "Bench", muscleGroup: .chest)
        context.insert(exercise)
        let te = TemplateExercise(order: 0, exercise: exercise)
        te.template = template
        try context.save()

        vm.startWorkout(from: template)
        #expect(template.lastUsedDate != nil)
    }
}

// MARK: - HistoryViewModel Tests

@Suite("HistoryViewModel Tests", .serialized)
@MainActor
struct HistoryViewModelTests {
    @Test func formattedDurationUnderOneHour() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let workout = Workout(startDate: Date(timeIntervalSince1970: 0))
        workout.endDate = Date(timeIntervalSince1970: 2700)
        #expect(vm.formattedDuration(workout) == "45 min")
    }

    @Test func formattedDurationOverOneHour() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let workout = Workout(startDate: Date(timeIntervalSince1970: 0))
        workout.endDate = Date(timeIntervalSince1970: 5400)
        #expect(vm.formattedDuration(workout) == "1h 30m")
    }

    @Test func formattedDurationExactlyOneHour() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let workout = Workout(startDate: Date(timeIntervalSince1970: 0))
        workout.endDate = Date(timeIntervalSince1970: 3600)
        #expect(vm.formattedDuration(workout) == "1h 0m")
    }

    @Test func formattedDurationNilWhenNoEndDate() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let workout = Workout()
        #expect(vm.formattedDuration(workout) == "--")
    }

    @Test func formattedDateToday() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        #expect(vm.formattedDate(.now) == "Today")
    }

    @Test func formattedDateYesterday() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        #expect(vm.formattedDate(yesterday) == "Yesterday")
    }

    @Test func formattedDateOlderDate() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: .now)!
        let result = vm.formattedDate(oldDate)
        #expect(result != "Today")
        #expect(result != "Yesterday")
        #expect(!result.isEmpty)
    }
}

// MARK: - ExerciseLibraryViewModel Tests

@Suite("ExerciseLibraryViewModel Tests", .serialized)
@MainActor
struct ExerciseLibraryViewModelTests {

    // MARK: Filtering

    @Test func filteredExercisesNoFilters() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Bench Press", muscleGroup: .chest)
        let e2 = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(e1)
        context.insert(e2)
        vm.exercises = [e1, e2]

        #expect(vm.filteredExercises.count == 2)
    }

    @Test func filteredExercisesByMuscleGroup() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Bench Press", muscleGroup: .chest)
        let e2 = Exercise(name: "Squat", muscleGroup: .legs)
        let e3 = Exercise(name: "Incline Press", muscleGroup: .chest)
        context.insert(e1)
        context.insert(e2)
        context.insert(e3)
        vm.exercises = [e1, e2, e3]

        vm.selectedMuscleGroup = .chest
        #expect(vm.filteredExercises.count == 2)
        #expect(vm.filteredExercises.allSatisfy { $0.muscleGroup == .chest })
    }

    @Test func filteredExercisesBySearchText() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Bench Press", muscleGroup: .chest)
        let e2 = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(e1)
        context.insert(e2)
        vm.exercises = [e1, e2]

        vm.searchText = "bench"
        #expect(vm.filteredExercises.count == 1)
        #expect(vm.filteredExercises.first?.name == "Bench Press")
    }

    @Test func filteredExercisesByBothFilters() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Bench Press", muscleGroup: .chest)
        let e2 = Exercise(name: "Incline Press", muscleGroup: .chest)
        let e3 = Exercise(name: "Bench Row", muscleGroup: .back)
        context.insert(e1)
        context.insert(e2)
        context.insert(e3)
        vm.exercises = [e1, e2, e3]

        vm.selectedMuscleGroup = .chest
        vm.searchText = "bench"
        #expect(vm.filteredExercises.count == 1)
        #expect(vm.filteredExercises.first?.name == "Bench Press")
    }

    @Test func filteredExercisesCaseInsensitive() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(e1)
        vm.exercises = [e1]

        vm.searchText = "BENCH"
        #expect(vm.filteredExercises.count == 1)
    }

    @Test func filteredExercisesReturnsEmptyForNoMatch() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(e1)
        vm.exercises = [e1]

        vm.searchText = "xyz"
        #expect(vm.filteredExercises.isEmpty)
    }

    // MARK: Recent Exercises

    @Test func recentExercisesExcludesNeverUsed() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Bench Press", muscleGroup: .chest)
        let e2 = Exercise(name: "Squat", muscleGroup: .legs)
        e1.lastUsedDate = .now
        context.insert(e1)
        context.insert(e2)
        vm.exercises = [e1, e2]

        #expect(vm.recentExercises.count == 1)
        #expect(vm.recentExercises.first?.name == "Bench Press")
    }

    @Test func recentExercisesLimitedToFive() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        var exercises: [Exercise] = []
        for i in 0..<8 {
            let e = Exercise(name: "Exercise \(i)", muscleGroup: .chest)
            e.lastUsedDate = Date(timeIntervalSince1970: Double(i))
            context.insert(e)
            exercises.append(e)
        }
        vm.exercises = exercises

        #expect(vm.recentExercises.count == 5)
    }

    @Test func recentExercisesSortedByMostRecent() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Older", muscleGroup: .chest)
        e1.lastUsedDate = Date(timeIntervalSince1970: 100)
        let e2 = Exercise(name: "Newer", muscleGroup: .chest)
        e2.lastUsedDate = Date(timeIntervalSince1970: 200)
        context.insert(e1)
        context.insert(e2)
        vm.exercises = [e1, e2]

        #expect(vm.recentExercises.first?.name == "Newer")
    }

    // MARK: CRUD Operations

    @Test func addCustomExercise() {
        let vm = ExerciseLibraryViewModel(modelContext: makeFreshContext())
        vm.addCustomExercise(name: "My Exercise", muscleGroup: .arms)
        #expect(vm.exercises.contains { $0.name == "My Exercise" })
        #expect(vm.exercises.first { $0.name == "My Exercise" }?.isCustom == true)
    }

    @Test func deleteExerciseOnlyDeletesCustom() throws {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let builtIn = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(builtIn)
        try context.save()
        vm.fetchExercises()

        let countBefore = vm.exercises.count
        vm.deleteExercise(builtIn)
        #expect(vm.exercises.count == countBefore)
    }

    @Test func deleteCustomExercise() {
        let vm = ExerciseLibraryViewModel(modelContext: makeFreshContext())
        vm.addCustomExercise(name: "Custom Move", muscleGroup: .core)
        let custom = vm.exercises.first { $0.name == "Custom Move" }!
        vm.deleteExercise(custom)
        #expect(!vm.exercises.contains { $0.name == "Custom Move" })
    }

    // MARK: Seeding

    @Test func seedExercisesPopulatesEmptyDatabase() {
        let vm = ExerciseLibraryViewModel(modelContext: makeFreshContext())
        vm.seedExercisesIfNeeded()
        #expect(!vm.exercises.isEmpty)
    }

    // MARK: Favorites

    @Test func toggleFavoriteOnAndOff() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)
        vm.exercises = [exercise]

        #expect(!exercise.isFavorite)
        vm.toggleFavorite(exercise)
        #expect(exercise.isFavorite)
        vm.toggleFavorite(exercise)
        #expect(!exercise.isFavorite)
    }

    @Test func toggleFavoriteRespectsLimit() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        var exercises: [Exercise] = []
        for i in 0..<11 {
            let e = Exercise(name: "Exercise \(i)", muscleGroup: .chest)
            e.isFavorite = i < 10
            context.insert(e)
            exercises.append(e)
        }
        vm.exercises = exercises

        #expect(vm.favoriteCount == 10)

        let unfavorited = exercises[10]
        vm.toggleFavorite(unfavorited)
        #expect(!unfavorited.isFavorite)
        #expect(vm.favoriteCount == 10)
    }

    @Test func toggleFavoriteAllowsUnfavoriteWhenAtLimit() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        var exercises: [Exercise] = []
        for i in 0..<10 {
            let e = Exercise(name: "Exercise \(i)", muscleGroup: .chest)
            e.isFavorite = true
            context.insert(e)
            exercises.append(e)
        }
        vm.exercises = exercises

        vm.toggleFavorite(exercises[0])
        #expect(!exercises[0].isFavorite)
        #expect(vm.favoriteCount == 9)
    }
}

// MARK: - TemplateViewModel Tests

@Suite("TemplateViewModel Tests", .serialized)
@MainActor
struct TemplateViewModelTests {
    @Test func createTemplate() {
        let vm = TemplateViewModel(modelContext: makeFreshContext())
        let template = vm.createTemplate(name: "Push Day")
        #expect(template.name == "Push Day")
        #expect(vm.templates.contains { $0.name == "Push Day" })
    }

    @Test func deleteTemplate() {
        let vm = TemplateViewModel(modelContext: makeFreshContext())
        let template = vm.createTemplate(name: "To Delete")
        vm.deleteTemplate(template)
        #expect(!vm.templates.contains { $0.name == "To Delete" })
    }

    @Test func renameTemplate() {
        let vm = TemplateViewModel(modelContext: makeFreshContext())
        let template = vm.createTemplate(name: "Push Day")
        vm.renameTemplate(template, to: "Chest Day")
        #expect(template.name == "Chest Day")
    }

    @Test func addExerciseToTemplate() {
        let context = makeFreshContext()
        let vm = TemplateViewModel(modelContext: context)

        let template = vm.createTemplate(name: "Push Day")
        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)

        vm.addExercise(exercise, to: template)
        #expect(template.exercises.count == 1)
    }

    @Test func addCardioExerciseDefaultsToOneSet() {
        let context = makeFreshContext()
        let vm = TemplateViewModel(modelContext: context)

        let template = vm.createTemplate(name: "Cardio")
        let cardio = Exercise(name: "Running", muscleGroup: .cardio, isCardio: true)
        context.insert(cardio)

        vm.addExercise(cardio, to: template)
        #expect(template.exercises.first?.setCount == 1)
    }

    @Test func addNonCardioExerciseDefaultsToThreeSets() {
        let context = makeFreshContext()
        let vm = TemplateViewModel(modelContext: context)

        let template = vm.createTemplate(name: "Push")
        let exercise = Exercise(name: "Bench", muscleGroup: .chest)
        context.insert(exercise)

        vm.addExercise(exercise, to: template)
        #expect(template.exercises.first?.setCount == 3)
    }

    @Test func removeExerciseReordersRemaining() {
        let context = makeFreshContext()
        let vm = TemplateViewModel(modelContext: context)

        let template = vm.createTemplate(name: "Full Body")
        let e1 = Exercise(name: "Bench", muscleGroup: .chest)
        let e2 = Exercise(name: "Squat", muscleGroup: .legs)
        let e3 = Exercise(name: "Row", muscleGroup: .back)
        context.insert(e1)
        context.insert(e2)
        context.insert(e3)

        vm.addExercise(e1, to: template)
        vm.addExercise(e2, to: template)
        vm.addExercise(e3, to: template)

        let middleExercise = template.sortedExercises[1]
        vm.removeExercise(middleExercise, from: template)

        let remaining = template.sortedExercises
        #expect(remaining.count == 2)
        #expect(remaining[0].order == 0)
        #expect(remaining[1].order == 1)
    }

    @Test func updateSetCountClampsToMinimumOne() {
        let context = makeFreshContext()
        let vm = TemplateViewModel(modelContext: context)

        let template = vm.createTemplate(name: "Test")
        let exercise = Exercise(name: "Bench", muscleGroup: .chest)
        context.insert(exercise)
        vm.addExercise(exercise, to: template)

        guard let te = template.exercises.first else {
            Issue.record("No template exercise found")
            return
        }

        vm.updateSetCount(te, count: 0)
        #expect(te.setCount == 1)

        vm.updateSetCount(te, count: -5)
        #expect(te.setCount == 1)

        vm.updateSetCount(te, count: 10)
        #expect(te.setCount == 10)
    }

    @Test func createTemplateFromWorkout() throws {
        let context = makeFreshContext()
        let vm = TemplateViewModel(modelContext: context)

        let workout = Workout()
        context.insert(workout)

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)

        let we = WorkoutExercise(order: 0, exercise: exercise)
        we.workout = workout

        let set1 = ExerciseSet(order: 0, weight: 135, reps: 10)
        set1.isCompleted = true
        set1.workoutExercise = we

        let set2 = ExerciseSet(order: 1, weight: 155, reps: 8)
        set2.isCompleted = true
        set2.workoutExercise = we

        workout.endDate = .now
        try context.save()

        let template = vm.createTemplate(from: workout, name: "From Workout")
        #expect(template.name == "From Workout")
        #expect(template.exercises.count == 1)

        let te = template.exercises.first
        #expect(te?.setCount == 2)
        #expect(te?.defaultWeight == 155)
        #expect(te?.defaultReps == 8)
    }
}

// MARK: - Relationship-Based Model Tests

@Suite("WorkoutExercise Relationship Tests", .serialized)
@MainActor
struct WorkoutExerciseRelationshipTests {
    @Test func sortedSetsReturnsOrderedSets() throws {
        let context = makeFreshContext()

        let we = WorkoutExercise(order: 0)
        context.insert(we)

        let set3 = ExerciseSet(order: 2, weight: 200, reps: 3)
        let set1 = ExerciseSet(order: 0, weight: 135, reps: 10)
        let set2 = ExerciseSet(order: 1, weight: 185, reps: 5)

        set3.workoutExercise = we
        set1.workoutExercise = we
        set2.workoutExercise = we
        try context.save()

        let sorted = we.sortedSets
        #expect(sorted.count == 3)
        #expect(sorted[0].order == 0)
        #expect(sorted[1].order == 1)
        #expect(sorted[2].order == 2)
    }
}

@Suite("WorkoutTemplate Relationship Tests", .serialized)
@MainActor
struct WorkoutTemplateRelationshipTests {
    @Test func sortedExercisesReturnsOrderedExercises() throws {
        let context = makeFreshContext()

        let template = WorkoutTemplate(name: "Test")
        context.insert(template)

        let e1 = Exercise(name: "First", muscleGroup: .chest)
        let e2 = Exercise(name: "Second", muscleGroup: .legs)
        context.insert(e1)
        context.insert(e2)

        let te2 = TemplateExercise(order: 1, exercise: e2)
        let te1 = TemplateExercise(order: 0, exercise: e1)
        te2.template = template
        te1.template = template
        try context.save()

        let sorted = template.sortedExercises
        #expect(sorted[0].exercise?.name == "First")
        #expect(sorted[1].exercise?.name == "Second")
    }

    @Test func exerciseCountReflectsExercises() throws {
        let context = makeFreshContext()

        let template = WorkoutTemplate(name: "Test")
        context.insert(template)

        let e1 = Exercise(name: "Bench", muscleGroup: .chest)
        context.insert(e1)

        let te = TemplateExercise(order: 0, exercise: e1)
        te.template = template
        try context.save()

        #expect(template.exerciseCount == 1)
    }

    @Test func muscleGroupsReturnsUniqueGroupsInOrder() throws {
        let context = makeFreshContext()

        let template = WorkoutTemplate(name: "Test")
        context.insert(template)

        let e1 = Exercise(name: "Bench", muscleGroup: .chest)
        let e2 = Exercise(name: "Squat", muscleGroup: .legs)
        let e3 = Exercise(name: "Flyes", muscleGroup: .chest)
        context.insert(e1)
        context.insert(e2)
        context.insert(e3)

        let te1 = TemplateExercise(order: 0, exercise: e1)
        let te2 = TemplateExercise(order: 1, exercise: e2)
        let te3 = TemplateExercise(order: 2, exercise: e3)
        te1.template = template
        te2.template = template
        te3.template = template
        try context.save()

        let groups = template.muscleGroups
        #expect(groups.count == 2)
        #expect(groups[0] == .chest)
        #expect(groups[1] == .legs)
    }
}
