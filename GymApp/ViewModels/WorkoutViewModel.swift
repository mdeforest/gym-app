import Foundation
import SwiftData
import Observation

@Observable
final class WorkoutViewModel {
    var activeWorkout: Workout?
    var showingAddExercise = false
    var showingFinishConfirmation = false
    var showingDiscardConfirmation = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchActiveWorkout()
    }

    // MARK: - Workout Lifecycle

    func startWorkout() {
        let workout = Workout()
        modelContext.insert(workout)
        activeWorkout = workout
        save()
    }

    @discardableResult
    func finishWorkout() -> Workout? {
        guard let workout = activeWorkout else { return nil }

        // Remove incomplete sets and exercises with no completed sets
        for exercise in workout.exercises {
            for set in exercise.sets where !set.isCompleted {
                modelContext.delete(set)
            }
            // Remove exercise if it has no completed sets (and isn't cardio)
            let hasCompletedSets = exercise.sets.contains { $0.isCompleted }
            if !hasCompletedSets && !(exercise.exercise?.isCardio ?? false) {
                modelContext.delete(exercise)
            }
        }

        workout.endDate = .now
        activeWorkout = nil
        save()
        return workout
    }

    func discardWorkout() {
        guard let activeWorkout else { return }
        modelContext.delete(activeWorkout)
        self.activeWorkout = nil
        save()
    }

    // MARK: - Exercises

    func addExercise(_ exercise: Exercise) {
        guard let activeWorkout else { return }
        let order = activeWorkout.exercises.count
        let workoutExercise = WorkoutExercise(order: order, exercise: exercise)
        workoutExercise.workout = activeWorkout

        if exercise.isCardio {
            // Prefill cardio fields from last session
            if let lastSession = fetchLastSession(for: exercise) {
                workoutExercise.durationSeconds = lastSession.durationSeconds
                workoutExercise.distanceMeters = lastSession.distanceMeters
            }
        } else {
            // Add one default set pre-filled from last session
            let defaultSet = ExerciseSet(order: 0)
            if let lastSession = fetchLastSession(for: exercise) {
                if let lastSet = lastSession.sortedSets.first {
                    defaultSet.weight = lastSet.weight
                    defaultSet.reps = lastSet.reps
                }
            }
            defaultSet.workoutExercise = workoutExercise
        }

        exercise.lastUsedDate = .now
        save()
    }

    func removeExercise(_ workoutExercise: WorkoutExercise) {
        modelContext.delete(workoutExercise)
        save()
    }

    // MARK: - Sets

    func addSet(to workoutExercise: WorkoutExercise) {
        let order = workoutExercise.sets.count
        let newSet = ExerciseSet(order: order)

        // Pre-fill from previous set in this exercise
        if let lastSet = workoutExercise.sortedSets.last {
            newSet.weight = lastSet.weight
            newSet.reps = lastSet.reps
        }

        newSet.workoutExercise = workoutExercise
        save()
    }

    func completeSet(_ exerciseSet: ExerciseSet) {
        exerciseSet.isCompleted.toggle()
        save()
    }

    func deleteSet(_ exerciseSet: ExerciseSet, from workoutExercise: WorkoutExercise) {
        let deletedOrder = exerciseSet.order
        modelContext.delete(exerciseSet)

        // Reorder remaining sets
        for set in workoutExercise.sets where set.order > deletedOrder {
            set.order -= 1
        }
        save()
    }

    func propagateValues(from changedSet: ExerciseSet, in workoutExercise: WorkoutExercise) {
        let sorted = workoutExercise.sortedSets
        guard let changedIndex = sorted.firstIndex(where: { $0.id == changedSet.id }) else { return }

        // Only propagate to sets after the changed one that haven't been completed
        for index in (changedIndex + 1)..<sorted.count {
            let set = sorted[index]
            guard !set.isCompleted else { continue }
            set.weight = changedSet.weight
            set.reps = changedSet.reps
        }
        save()
    }

    // MARK: - Last Session Reference

    func fetchLastSession(for exercise: Exercise) -> WorkoutExercise? {
        let exerciseID = exercise.id
        let descriptor = FetchDescriptor<WorkoutExercise>(
            predicate: #Predicate<WorkoutExercise> { workoutExercise in
                workoutExercise.exercise?.id == exerciseID &&
                workoutExercise.workout?.endDate != nil
            },
            sortBy: [SortDescriptor(\WorkoutExercise.workout?.startDate, order: .reverse)]
        )

        return try? modelContext.fetch(descriptor).first
    }

    // MARK: - Private

    private func fetchActiveWorkout() {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.endDate == nil }
        )
        activeWorkout = try? modelContext.fetch(descriptor).first
    }

    private func save() {
        try? modelContext.save()
    }
}
