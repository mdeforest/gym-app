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

        let sortedExercises = workout.exercises.sorted { $0.order < $1.order }
        for (index, workoutExercise) in sortedExercises.enumerated() {
            guard let exercise = workoutExercise.exercise else { continue }

            let completedSetCount = workoutExercise.sets.filter { $0.isCompleted }.count
            let setCount = exercise.isCardio ? 1 : max(completedSetCount, 1)

            let completedSets = workoutExercise.sets
                .filter { $0.isCompleted }
                .sorted { $0.order < $1.order }
            let lastCompletedSet = completedSets.last

            let templateExercise = TemplateExercise(
                order: index,
                exercise: exercise,
                setCount: setCount,
                defaultWeight: lastCompletedSet?.weight ?? 0,
                defaultReps: lastCompletedSet?.reps ?? 0
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

    private func save() {
        try? modelContext.save()
    }
}
