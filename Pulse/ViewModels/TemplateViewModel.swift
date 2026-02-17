import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class TemplateViewModel {
    var templates: [WorkoutTemplate] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchTemplates()
    }

    func fetchTemplates() {
        let descriptor = FetchDescriptor<WorkoutTemplate>(
            sortBy: [
                SortDescriptor(\.lastUsedDate, order: .reverse),
                SortDescriptor(\.createdDate, order: .reverse),
            ]
        )
        templates = (try? modelContext.fetch(descriptor)) ?? []
    }

    @discardableResult
    func createTemplate(name: String) -> WorkoutTemplate {
        let template = WorkoutTemplate(name: name)
        modelContext.insert(template)
        save()
        fetchTemplates()
        return template
    }

    @discardableResult
    func createTemplate(from workout: Workout, name: String) -> WorkoutTemplate {
        let template = WorkoutTemplate(name: name)
        modelContext.insert(template)

        // Map workout superset group IDs to new template group IDs
        var supersetMapping: [UUID: UUID] = [:]

        let sortedExercises = workout.exercises.sorted { $0.order < $1.order }
        for (index, workoutExercise) in sortedExercises.enumerated() {
            guard let exercise = workoutExercise.exercise else { continue }

            let completedSets = workoutExercise.sets
                .filter { $0.isCompleted }
                .sorted { $0.order < $1.order }

            let warmupCount = completedSets.filter { $0.setType == .warmup }.count
            let normalCount = completedSets.filter { $0.setType == .normal }.count
            let setCount = exercise.isCardio ? 1 : max(normalCount, 1)

            let lastCompletedNormalSet = completedSets.last { $0.setType == .normal }
            let lastCompletedSet = lastCompletedNormalSet ?? completedSets.last

            // Preserve superset grouping
            var templateSupersetGroupId: UUID?
            if let wGroupId = workoutExercise.supersetGroupId {
                if let existing = supersetMapping[wGroupId] {
                    templateSupersetGroupId = existing
                } else {
                    let newId = UUID()
                    supersetMapping[wGroupId] = newId
                    templateSupersetGroupId = newId
                }
            }

            let templateExercise = TemplateExercise(
                order: index,
                exercise: exercise,
                setCount: setCount,
                defaultWeight: lastCompletedSet?.weight ?? 0,
                defaultReps: lastCompletedSet?.reps ?? 0,
                warmupSetCount: exercise.isCardio ? 0 : warmupCount,
                supersetGroupId: templateSupersetGroupId
            )

            if exercise.isCardio {
                templateExercise.defaultDurationSeconds = workoutExercise.durationSeconds
                templateExercise.defaultDistanceMeters = workoutExercise.distanceMeters
            }

            templateExercise.template = template
        }

        save()
        fetchTemplates()
        return template
    }

    func deleteTemplate(_ template: WorkoutTemplate) {
        modelContext.delete(template)
        save()
        fetchTemplates()
    }

    func addExercise(_ exercise: Exercise, to template: WorkoutTemplate) {
        let order = template.exercises.count
        let templateExercise = TemplateExercise(
            order: order,
            exercise: exercise,
            setCount: exercise.isCardio ? 1 : 3
        )
        templateExercise.template = template
        save()
    }

    func removeExercise(_ templateExercise: TemplateExercise, from template: WorkoutTemplate) {
        let deletedOrder = templateExercise.order
        modelContext.delete(templateExercise)

        for exercise in template.exercises where exercise.order > deletedOrder {
            exercise.order -= 1
        }
        save()
    }

    func moveExercises(template: WorkoutTemplate, from source: IndexSet, to destination: Int) {
        var sorted = template.sortedExercises
        sorted.move(fromOffsets: source, toOffset: destination)
        for (index, exercise) in sorted.enumerated() {
            exercise.order = index
        }
        save()
    }

    func updateSetCount(_ templateExercise: TemplateExercise, count: Int) {
        templateExercise.setCount = max(1, count)
        save()
    }

    func renameTemplate(_ template: WorkoutTemplate, to name: String) {
        template.name = name
        save()
    }

    // MARK: - Template Supersets

    func linkTemplateExercisesAsSuperset(_ exerciseA: TemplateExercise, _ exerciseB: TemplateExercise) {
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

    func removeTemplateExerciseFromSuperset(_ exercise: TemplateExercise, in template: WorkoutTemplate) {
        guard let groupId = exercise.supersetGroupId else { return }
        exercise.supersetGroupId = nil

        let remaining = template.exercises.filter { $0.supersetGroupId == groupId }
        if remaining.count == 1 {
            remaining.first?.supersetGroupId = nil
        }
        save()
    }

    private func save() {
        try? modelContext.save()
    }
}
