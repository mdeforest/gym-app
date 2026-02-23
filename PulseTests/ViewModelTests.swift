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

    @Test func propagateValuesSkipsDifferentSetType() {
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

        // Add a second set, then mark set 0 as warm-up
        vm.addSet(to: workoutExercise)
        let sets = workoutExercise.sortedSets
        sets[0].setType = .warmup
        sets[0].weight = 95
        sets[0].reps = 12

        // Working set has different values
        sets[1].weight = 185
        sets[1].reps = 5

        // Propagating from warmup set should NOT overwrite the normal (working) set
        vm.propagateValues(from: sets[0], in: workoutExercise)

        #expect(sets[1].weight == 185)
        #expect(sets[1].reps == 5)
    }

    @Test func propagateValuesOnlyWithinSameSetType() {
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

        // 3 sets: warmup, normal, normal
        vm.addSet(to: workoutExercise)
        vm.addSet(to: workoutExercise)
        let sets = workoutExercise.sortedSets
        sets[0].setType = .warmup
        sets[0].weight = 95; sets[0].reps = 10
        sets[1].weight = 225; sets[1].reps = 5
        sets[2].weight = 0;   sets[2].reps = 0

        // Propagating from the first working set should fill the second working set
        vm.propagateValues(from: sets[1], in: workoutExercise)
        #expect(sets[2].weight == 225)
        #expect(sets[2].reps == 5)
        // Warmup is before the changed set, so it shouldn't be touched regardless
        #expect(sets[0].weight == 95)
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

// MARK: - Calendar Tests

@Suite("Calendar Tests", .serialized)
@MainActor
struct CalendarTests {

    @Test func daysInMonthReturnsMultipleOfSeven() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let days = vm.daysInMonth()
        #expect(days.count % 7 == 0)
        #expect(!days.isEmpty)
    }

    @Test func daysInMonthMarksToday() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let days = vm.daysInMonth()
        let todayCells = days.filter { $0.isToday }
        #expect(todayCells.count == 1)
        #expect(todayCells.first?.isCurrentMonth == true)
    }

    @Test func daysInMonthMarksOutOfMonthDays() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        // January 2026 starts on Thursday, so there will be leading days from December
        vm.displayedMonth = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let days = vm.daysInMonth()

        let currentMonthDays = days.filter { $0.isCurrentMonth }
        let outOfMonthDays = days.filter { !$0.isCurrentMonth }
        #expect(currentMonthDays.count == 31)
        #expect(!outOfMonthDays.isEmpty)
    }

    @Test func hasWorkoutReturnsTrueForWorkoutDates() {
        let context = makeFreshContext()
        let vm = HistoryViewModel(modelContext: context)

        let workout = Workout(startDate: Date())
        workout.endDate = Date()
        context.insert(workout)
        try? context.save()
        vm.fetchWorkouts()

        #expect(vm.hasWorkout(on: Date()))
    }

    @Test func hasWorkoutReturnsFalseForEmptyDates() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        vm.fetchWorkouts()

        let distantPast = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        #expect(!vm.hasWorkout(on: distantPast))
    }

    @Test func selectDateTogglesSelection() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let date = Date()

        #expect(vm.selectedDate == nil)

        vm.selectDate(date)
        #expect(vm.selectedDate != nil)

        vm.selectDate(date)
        #expect(vm.selectedDate == nil)
    }

    @Test func selectDifferentDateChangesSelection() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        vm.selectDate(today)
        #expect(Calendar.current.isDate(vm.selectedDate!, inSameDayAs: today))

        vm.selectDate(yesterday)
        #expect(Calendar.current.isDate(vm.selectedDate!, inSameDayAs: yesterday))
    }

    @Test func clearDateSelectionResetsToNil() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        vm.selectDate(Date())
        #expect(vm.selectedDate != nil)

        vm.clearDateSelection()
        #expect(vm.selectedDate == nil)
    }

    @Test func filteredWorkoutsReturnsAllWhenNoSelection() {
        let context = makeFreshContext()
        let vm = HistoryViewModel(modelContext: context)

        let w1 = Workout(startDate: Date())
        w1.endDate = Date()
        let w2 = Workout(startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        w2.endDate = Date()
        context.insert(w1)
        context.insert(w2)
        try? context.save()
        vm.fetchWorkouts()

        #expect(vm.filteredWorkouts.count == vm.workouts.count)
    }

    @Test func filteredWorkoutsFiltersWhenDateSelected() {
        let context = makeFreshContext()
        let vm = HistoryViewModel(modelContext: context)

        // Use distant past dates to avoid collisions with other test data
        let dateA = Calendar.current.date(from: DateComponents(year: 2020, month: 6, day: 15))!
        let dateB = Calendar.current.date(from: DateComponents(year: 2020, month: 6, day: 16))!

        let w1 = Workout(startDate: dateA)
        w1.endDate = dateA
        let w2 = Workout(startDate: dateB)
        w2.endDate = dateB
        context.insert(w1)
        context.insert(w2)
        try? context.save()
        vm.fetchWorkouts()

        vm.selectDate(dateA)
        let filtered = vm.filteredWorkouts
        let matchingCount = filtered.filter { Calendar.current.isDate($0.startDate, inSameDayAs: dateA) }.count
        #expect(matchingCount == 1)
    }

    @Test func goToPreviousMonthChangesMonth() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let originalMonth = Calendar.current.component(.month, from: vm.displayedMonth)

        vm.goToPreviousMonth()
        let newMonth = Calendar.current.component(.month, from: vm.displayedMonth)

        let expected = originalMonth == 1 ? 12 : originalMonth - 1
        #expect(newMonth == expected)
    }

    @Test func goToNextMonthChangesMonth() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        // Navigate to a past month so canGoToNextMonth is always true
        let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: vm.displayedMonth)!
        vm.displayedMonth = twoMonthsAgo
        let originalMonth = Calendar.current.component(.month, from: vm.displayedMonth)

        vm.goToNextMonth()
        let newMonth = Calendar.current.component(.month, from: vm.displayedMonth)

        let expected = originalMonth == 12 ? 1 : originalMonth + 1
        #expect(newMonth == expected)
    }

    @Test func formattedMonthYearFormat() {
        let vm = HistoryViewModel(modelContext: makeFreshContext())
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 1))!
        let result = vm.formattedMonthYear(date)
        #expect(result == "February 2026")
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

    @Test func filteredExercisesByEquipment() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let barbell = Exercise(name: "Barbell Row", muscleGroup: .back, equipment: .barbell)
        let dumbbell = Exercise(name: "Dumbbell Curl", muscleGroup: .arms, equipment: .dumbbell)
        let bw = Exercise(name: "Pull-up", muscleGroup: .back, equipment: .bodyweight)
        context.insert(barbell)
        context.insert(dumbbell)
        context.insert(bw)
        vm.exercises = [barbell, dumbbell, bw]

        vm.selectedEquipment = .barbell
        #expect(vm.filteredExercises.count == 1)
        #expect(vm.filteredExercises.first?.name == "Barbell Row")
    }

    @Test func filteredExercisesEquipmentAndMuscleGroup() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Barbell Bench Press", muscleGroup: .chest, equipment: .barbell)
        let e2 = Exercise(name: "Dumbbell Bench Press", muscleGroup: .chest, equipment: .dumbbell)
        let e3 = Exercise(name: "Barbell Row", muscleGroup: .back, equipment: .barbell)
        context.insert(e1)
        context.insert(e2)
        context.insert(e3)
        vm.exercises = [e1, e2, e3]

        vm.selectedMuscleGroup = .chest
        vm.selectedEquipment = .barbell
        #expect(vm.filteredExercises.count == 1)
        #expect(vm.filteredExercises.first?.name == "Barbell Bench Press")
    }

    @Test func filteredExercisesEquipmentAndSearch() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Barbell Bench Press", muscleGroup: .chest, equipment: .barbell)
        let e2 = Exercise(name: "Barbell Row", muscleGroup: .back, equipment: .barbell)
        let e3 = Exercise(name: "Dumbbell Bench Press", muscleGroup: .chest, equipment: .dumbbell)
        context.insert(e1)
        context.insert(e2)
        context.insert(e3)
        vm.exercises = [e1, e2, e3]

        vm.selectedEquipment = .barbell
        vm.searchText = "bench"
        #expect(vm.filteredExercises.count == 1)
        #expect(vm.filteredExercises.first?.name == "Barbell Bench Press")
    }

    @Test func clearingEquipmentFilterReturnsAll() {
        let context = makeFreshContext()
        let vm = ExerciseLibraryViewModel(modelContext: context)

        let e1 = Exercise(name: "Barbell Squat", muscleGroup: .legs, equipment: .barbell)
        let e2 = Exercise(name: "Leg Press", muscleGroup: .legs, equipment: .machine)
        context.insert(e1)
        context.insert(e2)
        vm.exercises = [e1, e2]

        vm.selectedEquipment = .machine
        #expect(vm.filteredExercises.count == 1)

        vm.selectedEquipment = nil
        #expect(vm.filteredExercises.count == 2)
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

    @Test func addCustomExerciseWithEquipment() {
        let vm = ExerciseLibraryViewModel(modelContext: makeFreshContext())
        vm.addCustomExercise(name: "Custom Cable Fly", muscleGroup: .chest, equipment: .cable)
        let added = vm.exercises.first { $0.name == "Custom Cable Fly" }
        #expect(added != nil)
        #expect(added?.equipment == .cable)
        #expect(added?.isCustom == true)
    }

    @Test func addCustomExerciseDefaultsEquipmentToOther() {
        let vm = ExerciseLibraryViewModel(modelContext: makeFreshContext())
        vm.addCustomExercise(name: "Mystery Move", muscleGroup: .core)
        let added = vm.exercises.first { $0.name == "Mystery Move" }
        #expect(added?.equipment == .other)
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

    @Test func addTemplateSetIncreasesCount() throws {
        let context = makeFreshContext()
        let vm = TemplateViewModel(modelContext: context)

        let template = vm.createTemplate(name: "Test")
        let exercise = Exercise(name: "Bench", muscleGroup: .chest)
        context.insert(exercise)
        vm.addExercise(exercise, to: template)
        try context.save()

        guard let te = template.exercises.first else {
            Issue.record("No template exercise found")
            return
        }

        vm.migrateToSetsIfNeeded(te)
        let countBefore = te.sets.count
        vm.addTemplateSet(to: te)
        #expect(te.sets.count == countBefore + 1)
    }

    @Test func deleteTemplateSetDecreasesCount() throws {
        let context = makeFreshContext()
        let vm = TemplateViewModel(modelContext: context)

        let template = vm.createTemplate(name: "Test")
        let exercise = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(exercise)
        vm.addExercise(exercise, to: template)
        try context.save()

        guard let te = template.exercises.first else {
            Issue.record("No template exercise found")
            return
        }

        vm.migrateToSetsIfNeeded(te)
        vm.addTemplateSet(to: te)
        let countBefore = te.sets.count

        if let setToDelete = te.sortedSets.last {
            vm.deleteTemplateSet(setToDelete, from: te)
            #expect(te.sets.count == countBefore - 1)
        }
    }

    @Test func syncLegacyFieldsClampsSetsToMinimumOne() throws {
        let context = makeFreshContext()
        let vm = TemplateViewModel(modelContext: context)

        let template = vm.createTemplate(name: "Test")
        let exercise = Exercise(name: "Row", muscleGroup: .back)
        context.insert(exercise)
        vm.addExercise(exercise, to: template)
        try context.save()

        guard let te = template.exercises.first else {
            Issue.record("No template exercise found")
            return
        }

        vm.migrateToSetsIfNeeded(te)
        // Delete all but one set; setCount should never drop below 1
        while te.sets.count > 1, let last = te.sortedSets.last {
            vm.deleteTemplateSet(last, from: te)
        }
        #expect(te.setCount >= 1)
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

// MARK: - Isolated Context Helper

/// Creates a fully fresh in-memory store — used by tests that need clean state
/// so they are unaffected by data inserted by other tests in sharedContainer.
@MainActor
private func makeIsolatedContext() -> ModelContext {
    let container = try! DataService.createPreviewContainer()
    return ModelContext(container)
}

// MARK: - ExerciseDetailViewModel Tests

@Suite("ExerciseDetailViewModel Tests", .serialized)
@MainActor
struct ExerciseDetailViewModelTests {

    @Test func formattedDateToday() {
        let vm = ExerciseDetailViewModel(modelContext: makeIsolatedContext())
        #expect(vm.formattedDate(.now) == "Today")
    }

    @Test func formattedDateYesterday() {
        let vm = ExerciseDetailViewModel(modelContext: makeIsolatedContext())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        #expect(vm.formattedDate(yesterday) == "Yesterday")
    }

    @Test func formattedDateOtherDate() {
        let vm = ExerciseDetailViewModel(modelContext: makeIsolatedContext())
        let oldDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 15))!
        let result = vm.formattedDate(oldDate)
        #expect(result != "Today")
        #expect(result != "Yesterday")
        #expect(!result.isEmpty)
    }

    @Test func fetchRecordsNilForCardio() {
        let context = makeIsolatedContext()
        let vm = ExerciseDetailViewModel(modelContext: context)
        let cardio = Exercise(name: "Running", muscleGroup: .cardio, isCardio: true)
        context.insert(cardio)
        vm.fetchRecords(for: cardio)
        #expect(vm.exerciseRecords == nil)
    }

    @Test func fetchRecordsNonNilForStrengthExercise() throws {
        let context = makeIsolatedContext()
        let vm = ExerciseDetailViewModel(modelContext: context)
        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)
        try context.save()
        vm.fetchRecords(for: exercise)
        #expect(vm.exerciseRecords != nil)
    }

    @Test func fetchHistoryEmptyForNewExercise() {
        let context = makeIsolatedContext()
        let vm = ExerciseDetailViewModel(modelContext: context)
        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)
        vm.fetchHistory(for: exercise)
        #expect(vm.historyEntries.isEmpty)
    }

    @Test func fetchHistoryReturnsCompletedWorkouts() throws {
        let context = makeIsolatedContext()
        let vm = ExerciseDetailViewModel(modelContext: context)

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)

        let workout = Workout(startDate: Date())
        workout.endDate = Date()
        context.insert(workout)

        let we = WorkoutExercise(order: 0, exercise: exercise)
        we.workout = workout
        try context.save()

        vm.fetchHistory(for: exercise)
        #expect(vm.historyEntries.count == 1)
    }

    @Test func fetchHistoryExcludesActiveWorkouts() throws {
        let context = makeIsolatedContext()
        let vm = ExerciseDetailViewModel(modelContext: context)

        let exercise = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(exercise)

        let active = Workout(startDate: Date())
        // No endDate — still active
        context.insert(active)

        let we = WorkoutExercise(order: 0, exercise: exercise)
        we.workout = active
        try context.save()

        vm.fetchHistory(for: exercise)
        #expect(vm.historyEntries.isEmpty)
    }

    @Test func fetchHistoryLimitedToFiveEntries() throws {
        let context = makeIsolatedContext()
        let vm = ExerciseDetailViewModel(modelContext: context)

        let exercise = Exercise(name: "Deadlift", muscleGroup: .back)
        context.insert(exercise)

        for i in 0..<8 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let workout = Workout(startDate: date)
            workout.endDate = date
            context.insert(workout)
            let we = WorkoutExercise(order: 0, exercise: exercise)
            we.workout = workout
        }
        try context.save()

        vm.fetchHistory(for: exercise)
        #expect(vm.historyEntries.count <= 5)
    }
}

// MARK: - SettingsViewModel Tests

@Suite("SettingsViewModel Tests", .serialized)
@MainActor
struct SettingsViewModelTests {

    @Test func generateExportDataReturnsOnlyCompletedWorkouts() throws {
        let context = makeIsolatedContext()
        let vm = SettingsViewModel(modelContext: context)

        let completed = Workout(startDate: Date())
        completed.endDate = Date()
        let active = Workout(startDate: Date())
        // No endDate
        context.insert(completed)
        context.insert(active)
        try context.save()

        let exported = vm.generateExportData()
        #expect(exported.allSatisfy { $0.endDate != nil })
        #expect(!exported.isEmpty)
    }

    @Test func generateExportDataEmptyWhenNoCompletedWorkouts() throws {
        let context = makeIsolatedContext()
        let vm = SettingsViewModel(modelContext: context)

        let active = Workout(startDate: Date())
        // No endDate
        context.insert(active)
        try context.save()

        let exported = vm.generateExportData()
        #expect(exported.isEmpty)
    }

    @Test func clearAllDataRemovesWorkouts() throws {
        let context = makeIsolatedContext()
        let vm = SettingsViewModel(modelContext: context)

        let workout = Workout(startDate: Date())
        workout.endDate = Date()
        context.insert(workout)
        try context.save()

        vm.clearAllData()

        let remaining = (try? context.fetch(FetchDescriptor<Workout>())) ?? []
        #expect(remaining.isEmpty)
    }

    @Test func clearAllDataRemovesTemplates() throws {
        let context = makeIsolatedContext()
        let vm = SettingsViewModel(modelContext: context)

        let template = WorkoutTemplate(name: "Push Day")
        context.insert(template)
        try context.save()

        vm.clearAllData()

        let remaining = (try? context.fetch(FetchDescriptor<WorkoutTemplate>())) ?? []
        #expect(remaining.isEmpty)
    }

    @Test func clearAllDataRemovesCustomExercises() throws {
        let context = makeIsolatedContext()
        let vm = SettingsViewModel(modelContext: context)

        let custom = Exercise(name: "My Custom Move", muscleGroup: .arms, isCustom: true)
        context.insert(custom)
        try context.save()

        vm.clearAllData()

        let remaining = (try? context.fetch(FetchDescriptor<Exercise>())) ?? []
        #expect(!remaining.contains { $0.isCustom })
    }

    @Test func clearAllDataResetsNonCustomExercises() throws {
        let context = makeIsolatedContext()
        let vm = SettingsViewModel(modelContext: context)

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        exercise.isFavorite = true
        exercise.lastUsedDate = Date()
        context.insert(exercise)
        try context.save()

        vm.clearAllData()

        let remaining = (try? context.fetch(FetchDescriptor<Exercise>())) ?? []
        let bench = remaining.first { $0.name == "Bench Press" }
        #expect(bench != nil)
        #expect(bench?.isFavorite == false)
        #expect(bench?.lastUsedDate == nil)
    }

    @Test func clearAllDataSetsFlagToTrue() {
        let vm = SettingsViewModel(modelContext: makeIsolatedContext())
        #expect(!vm.showingClearDataSuccess)
        vm.clearAllData()
        #expect(vm.showingClearDataSuccess)
    }
}

// MARK: - PersonalRecordService Context Tests

@Suite("PersonalRecordService Context Tests", .serialized)
@MainActor
struct PersonalRecordServiceContextTests {

    @Test func checkForPRFalseForCardio() {
        let context = makeIsolatedContext()
        let cardio = Exercise(name: "Running", muscleGroup: .cardio, isCardio: true)
        context.insert(cardio)

        let set = ExerciseSet(order: 0, weight: 0, reps: 0)
        set.isCompleted = true
        let result = PersonalRecordService.checkForPR(set: set, exercise: cardio, modelContext: context)
        #expect(!result.isAnyPR)
    }

    @Test func checkForPRFalseWhenNotCompleted() {
        let context = makeIsolatedContext()
        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)

        let set = ExerciseSet(order: 0, weight: 100, reps: 5)
        // isCompleted = false by default
        let result = PersonalRecordService.checkForPR(set: set, exercise: exercise, modelContext: context)
        #expect(!result.isAnyPR)
    }

    @Test func checkForPRTrueForFirstLiftEver() throws {
        let context = makeIsolatedContext()
        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)
        try context.save()

        let set = ExerciseSet(order: 0, weight: 100, reps: 5)
        set.isCompleted = true

        let result = PersonalRecordService.checkForPR(set: set, exercise: exercise, modelContext: context)
        #expect(result.isWeightPR)
        #expect(result.isEstimated1RMPR)
        #expect(result.isVolumePR)
    }

    @Test func checkForPRFalseWhenNotBeatingRecord() throws {
        let context = makeIsolatedContext()
        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)

        let pastWorkout = Workout(startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        pastWorkout.endDate = pastWorkout.startDate
        context.insert(pastWorkout)

        let pastWe = WorkoutExercise(order: 0, exercise: exercise)
        pastWe.workout = pastWorkout

        let pastSet = ExerciseSet(order: 0, weight: 200, reps: 5)
        pastSet.isCompleted = true
        pastSet.workoutExercise = pastWe
        try context.save()

        let newSet = ExerciseSet(order: 0, weight: 100, reps: 5)
        newSet.isCompleted = true
        let result = PersonalRecordService.checkForPR(set: newSet, exercise: exercise, modelContext: context)
        #expect(!result.isWeightPR)
        #expect(!result.isEstimated1RMPR)
    }

    @Test func fetchAllTimeRecordsEmptyHistory() throws {
        let context = makeIsolatedContext()
        let exercise = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(exercise)
        try context.save()

        let records = PersonalRecordService.fetchAllTimeRecords(for: exercise, modelContext: context)
        #expect(records.bestWeight == 0)
        #expect(records.bestEstimated1RM == 0)
        #expect(records.bestVolume == 0)
        #expect(records.bestWeightDate == nil)
    }

    @Test func fetchAllTimeRecordsReturnsBestValues() throws {
        let context = makeIsolatedContext()
        let exercise = Exercise(name: "Deadlift", muscleGroup: .back)
        context.insert(exercise)

        let workout = Workout(startDate: Date())
        workout.endDate = Date()
        context.insert(workout)

        let we = WorkoutExercise(order: 0, exercise: exercise)
        we.workout = workout

        let set1 = ExerciseSet(order: 0, weight: 200, reps: 5)
        set1.isCompleted = true
        set1.workoutExercise = we

        let set2 = ExerciseSet(order: 1, weight: 250, reps: 3)
        set2.isCompleted = true
        set2.workoutExercise = we
        try context.save()

        let records = PersonalRecordService.fetchAllTimeRecords(for: exercise, modelContext: context)
        #expect(records.bestWeight == 250)
        #expect(records.bestVolume >= 1000)  // 200×5 = 1000
    }
}

// MARK: - ExportService Tests

@Suite("ExportService Tests", .serialized)
@MainActor
struct ExportServiceTests {

    @Test func exportCSVHasHeader() {
        let csv = ExportService.exportCSV(workouts: [])
        #expect(csv.hasPrefix("Date,Duration"))
    }

    @Test func exportCSVEmptyWorkoutsOnlyHeader() {
        let csv = ExportService.exportCSV(workouts: [])
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }
        #expect(lines.count == 1)
    }

    @Test func exportCSVContainsStrengthRow() throws {
        let context = makeIsolatedContext()

        let workout = Workout(startDate: Date(timeIntervalSince1970: 1_700_000_000))
        workout.endDate = Date(timeIntervalSince1970: 1_700_003_600)
        context.insert(workout)

        let exercise = Exercise(name: "Bench Press", muscleGroup: .chest)
        context.insert(exercise)

        let we = WorkoutExercise(order: 0, exercise: exercise)
        we.workout = workout

        let set = ExerciseSet(order: 0, weight: 135, reps: 8)
        set.isCompleted = true
        set.workoutExercise = we
        try context.save()

        let csv = ExportService.exportCSV(workouts: [workout])
        #expect(csv.contains("Bench Press"))
        #expect(csv.contains("135"))
    }

    @Test func exportCSVOmitsUncompletedSets() throws {
        let context = makeIsolatedContext()

        let workout = Workout(startDate: Date())
        workout.endDate = Date()
        context.insert(workout)

        let exercise = Exercise(name: "Squat", muscleGroup: .legs)
        context.insert(exercise)

        let we = WorkoutExercise(order: 0, exercise: exercise)
        we.workout = workout

        let set = ExerciseSet(order: 0, weight: 225, reps: 5)
        // isCompleted = false — should not appear in CSV
        set.workoutExercise = we
        try context.save()

        let csv = ExportService.exportCSV(workouts: [workout])
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }
        #expect(lines.count == 1)  // Only the header
    }

    @Test func exportJSONIsValidJSON() {
        let data = ExportService.exportJSON(workouts: [])
        #expect(!data.isEmpty)
        let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(parsed != nil)
    }

    @Test func exportJSONHasWorkoutsKey() {
        let data = ExportService.exportJSON(workouts: [])
        let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(parsed?["workouts"] != nil)
    }

    @Test func exportJSONEmptyWorkoutsProducesEmptyArray() {
        let data = ExportService.exportJSON(workouts: [])
        let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        let workoutsArray = parsed?["workouts"] as? [[String: Any]]
        #expect(workoutsArray?.isEmpty == true)
    }

    @Test func exportJSONHasExportDateKey() {
        let data = ExportService.exportJSON(workouts: [])
        let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(parsed?["exportDate"] != nil)
    }

    @Test func exportJSONContainsCorrectWorkoutCount() throws {
        let context = makeIsolatedContext()

        let w1 = Workout(startDate: Date())
        w1.endDate = Date()
        let w2 = Workout(startDate: Date())
        w2.endDate = Date()
        context.insert(w1)
        context.insert(w2)
        try context.save()

        let data = ExportService.exportJSON(workouts: [w1, w2])
        let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        let workoutsArray = parsed?["workouts"] as? [[String: Any]]
        #expect(workoutsArray?.count == 2)
    }
}
