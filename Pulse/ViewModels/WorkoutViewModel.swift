import Foundation
import SwiftUI
import SwiftData
import Observation
import UserNotifications
import AudioToolbox
import UIKit

@MainActor
@Observable
final class WorkoutViewModel {
    var activeWorkout: Workout?
    var showingAddExercise = false
    var showingFinishConfirmation = false
    var showingDiscardConfirmation = false

    // MARK: - PR Toast State
    var recentPRTypes: [PRType] = []
    var showingPRToast = false
    private var prToastDismissTask: Task<Void, Never>?

    // MARK: - Rest Timer State
    var restTimerActive = false
    var restTimerRunning = false
    var restTimerDuration: Int = 0
    var restTimeRemaining: Int = 0
    var restTimerExpanded = false
    var restTimerExerciseName: String?
    var restTimerCompleted = false
    private var timerTask: Task<Void, Never>?
    private var timerEndDate: Date?
    private var notificationPermissionRequested = false
    private static let notificationIdentifier = "restTimerComplete"

    var restTimerProgress: Double {
        guard restTimerDuration > 0 else { return 0 }
        return Double(restTimerDuration - restTimeRemaining) / Double(restTimerDuration)
    }

    var restTimerDisplayText: String {
        let minutes = restTimeRemaining / 60
        let seconds = restTimeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchActiveWorkout()
    }

    nonisolated deinit {
        // Timer task and pending notifications are cleaned up
        // when the workout is discarded or finished via skipRestTimer()
    }

    // MARK: - Workout Lifecycle

    func startWorkout() {
        let workout = Workout()
        modelContext.insert(workout)
        activeWorkout = workout
        save()
    }

    func startWorkout(from template: WorkoutTemplate) {
        let workout = Workout()
        modelContext.insert(workout)

        for templateExercise in template.sortedExercises {
            guard let exercise = templateExercise.exercise else { continue }

            let workoutExercise = WorkoutExercise(order: templateExercise.order, exercise: exercise, supersetGroupId: templateExercise.supersetGroupId)
            workoutExercise.workout = workout

            if exercise.isCardio {
                let lastSession = fetchLastSession(for: exercise)
                workoutExercise.durationSeconds = templateExercise.defaultDurationSeconds
                    ?? lastSession?.durationSeconds
                workoutExercise.distanceMeters = templateExercise.defaultDistanceMeters
                    ?? lastSession?.distanceMeters
            } else if templateExercise.hasMigratedSets {
                // Copy individual template sets directly
                for templateSet in templateExercise.sortedSets {
                    let set = ExerciseSet(
                        order: templateSet.order,
                        weight: templateSet.weight,
                        reps: templateSet.reps,
                        setType: templateSet.setType
                    )
                    set.workoutExercise = workoutExercise
                }
            } else {
                // Legacy fallback for unmigrated templates
                let lastSession = fetchLastSession(for: exercise)
                let lastNormalSet = lastSession?.sortedSets.first { $0.setType == .normal }
                    ?? lastSession?.sortedSets.first

                let workingWeight = templateExercise.defaultWeight > 0
                    ? templateExercise.defaultWeight
                    : (lastNormalSet?.weight ?? 0)
                let workingReps = templateExercise.defaultReps > 0
                    ? templateExercise.defaultReps
                    : (lastNormalSet?.reps ?? 0)

                for warmupIndex in 0..<templateExercise.warmupSetCount {
                    let set = ExerciseSet(order: warmupIndex, setType: .warmup)
                    set.weight = (workingWeight * 0.5).rounded()
                    set.reps = workingReps
                    set.workoutExercise = workoutExercise
                }

                let warmupCount = templateExercise.warmupSetCount
                for setIndex in 0..<templateExercise.setCount {
                    let set = ExerciseSet(order: warmupCount + setIndex)
                    set.weight = workingWeight
                    set.reps = workingReps
                    set.workoutExercise = workoutExercise
                }
            }

            exercise.lastUsedDate = .now
        }

        template.lastUsedDate = .now
        activeWorkout = workout
        save()
    }

    @discardableResult
    func finishWorkout() -> Workout? {
        skipRestTimer()
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

        // Sync to Apple Health if enabled
        let healthService = HealthKitService.shared
        if healthService.isEnabled {
            Task {
                await healthService.saveWorkout(workout)
            }
        }

        return workout
    }

    func discardWorkout() {
        skipRestTimer()
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
        if workoutExercise.isInSuperset {
            removeFromSuperset(workoutExercise)
        }
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
        let wasCompleted = exerciseSet.isCompleted
        exerciseSet.isCompleted.toggle()
        save()

        // Clear PR flags when un-completing a set
        if wasCompleted && !exerciseSet.isCompleted {
            exerciseSet.isWeightPR = false
            exerciseSet.isEstimated1RMPR = false
            exerciseSet.isVolumePR = false
            save()
            return
        }

        guard !wasCompleted, exerciseSet.isCompleted else { return }

        // Check for PR on completed normal sets
        if let exercise = exerciseSet.workoutExercise?.exercise,
           exerciseSet.setType == .normal,
           !exercise.isCardio {
            let result = PersonalRecordService.checkForPR(
                set: exerciseSet,
                exercise: exercise,
                modelContext: modelContext
            )
            exerciseSet.isWeightPR = result.isWeightPR
            exerciseSet.isEstimated1RMPR = result.isEstimated1RMPR
            exerciseSet.isVolumePR = result.isVolumePR
            save()

            if result.isAnyPR {
                showPRToast(types: result.prTypes)
            }
        }

        let workoutExercise = exerciseSet.workoutExercise

        // Superset-aware rest timer: only fire after the last exercise in the superset
        if let groupId = workoutExercise?.supersetGroupId,
           let workout = activeWorkout {
            let supersetExercises = workout.exercises
                .filter { $0.supersetGroupId == groupId }
                .sorted { $0.order < $1.order }
            let isLastInSuperset = supersetExercises.last?.id == workoutExercise?.id

            if isLastInSuperset {
                // Use the max rest time from all exercises in the superset
                let maxRest = supersetExercises.compactMap { $0.exercise?.defaultRestSeconds }.max()
                if let restSeconds = maxRest, restSeconds > 0 {
                    startRestTimer(seconds: restSeconds, exerciseName: "Superset")
                }
            }
        } else {
            // Normal (non-superset) behavior
            if let exercise = workoutExercise?.exercise,
               let restSeconds = exercise.defaultRestSeconds,
               restSeconds > 0 {
                startRestTimer(seconds: restSeconds, exerciseName: exercise.name)
            }
        }
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
        // and share the same set type (warm-up values don't overwrite working sets)
        for index in (changedIndex + 1)..<sorted.count {
            let set = sorted[index]
            guard !set.isCompleted else { continue }
            guard set.setType == changedSet.setType else { continue }
            set.weight = changedSet.weight
            set.reps = changedSet.reps
        }
        save()
    }

    func toggleSetType(_ exerciseSet: ExerciseSet) {
        exerciseSet.setType = (exerciseSet.setType == .normal) ? .warmup : .normal
        if exerciseSet.setType == .warmup {
            exerciseSet.rpe = nil
        }
        save()
    }

    // MARK: - Supersets

    func linkAsSuperset(_ exerciseA: WorkoutExercise, _ exerciseB: WorkoutExercise) {
        if let existingGroup = exerciseA.supersetGroupId {
            exerciseB.supersetGroupId = existingGroup
        } else if let existingGroup = exerciseB.supersetGroupId {
            exerciseA.supersetGroupId = existingGroup
        } else {
            let groupId = UUID()
            exerciseA.supersetGroupId = groupId
            exerciseB.supersetGroupId = groupId
        }
        save()
    }

    func removeFromSuperset(_ workoutExercise: WorkoutExercise) {
        guard let groupId = workoutExercise.supersetGroupId,
              let workout = activeWorkout else { return }

        workoutExercise.supersetGroupId = nil

        // Dissolve group if only 1 exercise remains
        let remaining = workout.exercises.filter { $0.supersetGroupId == groupId }
        if remaining.count == 1 {
            remaining.first?.supersetGroupId = nil
        }
        save()
    }

    func groupedExercises() -> [[WorkoutExercise]] {
        guard let workout = activeWorkout else { return [] }
        return Self.groupExercises(workout.exercises)
    }

    func moveExerciseGroup(from source: Int, to destination: Int) {
        var groups = groupedExercises()
        guard source != destination, source < groups.count, destination < groups.count else { return }
        let moved = groups.remove(at: source)
        groups.insert(moved, at: destination)
        Self.reassignOrders(groups)
        save()
    }

    nonisolated static func groupExercises(_ exercises: [WorkoutExercise]) -> [[WorkoutExercise]] {
        let sorted = exercises.sorted { $0.order < $1.order }
        var groups: [[WorkoutExercise]] = []
        var currentGroup: [WorkoutExercise] = []
        var currentGroupId: UUID?

        for exercise in sorted {
            if let gid = exercise.supersetGroupId {
                if gid == currentGroupId {
                    currentGroup.append(exercise)
                } else {
                    if !currentGroup.isEmpty { groups.append(currentGroup) }
                    currentGroup = [exercise]
                    currentGroupId = gid
                }
            } else {
                if !currentGroup.isEmpty { groups.append(currentGroup) }
                currentGroup = [exercise]
                currentGroupId = nil
            }
        }
        if !currentGroup.isEmpty { groups.append(currentGroup) }
        return groups
    }

    nonisolated static func reassignOrders(_ groups: [[WorkoutExercise]]) {
        var order = 0
        for group in groups {
            for exercise in group.sorted(by: { $0.order < $1.order }) {
                exercise.order = order
                order += 1
            }
        }
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

    // MARK: - Rest Timer

    func startRestTimer(seconds: Int, exerciseName: String? = nil) {
        stopTimerTask()
        restTimerDuration = seconds
        restTimeRemaining = seconds
        timerEndDate = Date.now.addingTimeInterval(TimeInterval(seconds))
        restTimerRunning = true
        restTimerActive = true
        restTimerCompleted = false
        restTimerExerciseName = exerciseName
        requestNotificationPermission()
        scheduleCompletionNotification(in: seconds)
        startTimerTask()
    }

    func skipRestTimer() {
        stopTimerTask()
        cancelCompletionNotification()
        timerEndDate = nil
        restTimerActive = false
        restTimerRunning = false
        restTimerExpanded = false
        restTimerCompleted = false
        restTimeRemaining = 0
        restTimerDuration = 0
        restTimerExerciseName = nil
    }

    func adjustRestTimer(by seconds: Int) {
        let newRemaining = restTimeRemaining + seconds
        restTimeRemaining = max(0, newRemaining)
        restTimerDuration = max(restTimeRemaining, restTimerDuration + seconds)
        timerEndDate = Date.now.addingTimeInterval(TimeInterval(restTimeRemaining))

        cancelCompletionNotification()

        if restTimeRemaining > 0 && !restTimerRunning {
            restTimerRunning = true
            restTimerCompleted = false
            startTimerTask()
        }

        if restTimeRemaining > 0 {
            scheduleCompletionNotification(in: restTimeRemaining)
        }

        if restTimeRemaining == 0 {
            timerDidComplete()
        }
    }

    func toggleRestTimerExpanded() {
        restTimerExpanded.toggle()
    }

    private func startTimerTask() {
        timerTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, let endDate = self.timerEndDate else { return }
                let remaining = max(0, Int(endDate.timeIntervalSinceNow.rounded(.up)))
                self.restTimeRemaining = remaining
                if remaining == 0 {
                    self.timerDidComplete()
                    return
                }
            }
        }
    }

    private func stopTimerTask() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func timerDidComplete() {
        restTimerRunning = false
        restTimerCompleted = true
        stopTimerTask()
        cancelCompletionNotification()

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Play system sound
        AudioServicesPlaySystemSound(1007)

        // Auto-dismiss after 1.5 seconds
        Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(1500))
            guard let self, self.restTimerCompleted else { return }
            self.skipRestTimer()
        }
    }

    private func requestNotificationPermission() {
        guard !notificationPermissionRequested else { return }
        notificationPermissionRequested = true
        let center = UNUserNotificationCenter.current()
        Task {
            try? await center.requestAuthorization(options: [.alert, .sound])
        }
    }

    private func scheduleCompletionNotification(in seconds: Int) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Rest Complete"
        content.body = "Time to start your next set"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(max(seconds, 1)),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: Self.notificationIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    private func cancelCompletionNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.notificationIdentifier])
    }

    // MARK: - PR Toast

    private func showPRToast(types: [PRType]) {
        prToastDismissTask?.cancel()
        recentPRTypes = types

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showingPRToast = true
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        prToastDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard let self, !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                self.showingPRToast = false
            }
        }
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
