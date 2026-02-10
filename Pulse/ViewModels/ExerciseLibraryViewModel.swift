import Foundation
import SwiftData
import Observation

@Observable
final class ExerciseLibraryViewModel {
    var exercises: [Exercise] = []
    var searchText = ""
    var selectedMuscleGroup: MuscleGroup?

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchExercises()
    }

    var filteredExercises: [Exercise] {
        var result = exercises

        if let selectedMuscleGroup {
            result = result.filter { $0.muscleGroup == selectedMuscleGroup }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var recentExercises: [Exercise] {
        exercises
            .filter { $0.lastUsedDate != nil }
            .sorted { ($0.lastUsedDate ?? .distantPast) > ($1.lastUsedDate ?? .distantPast) }
            .prefix(5)
            .map { $0 }
    }

    func fetchExercises() {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        exercises = (try? modelContext.fetch(descriptor)) ?? []
    }

    func addCustomExercise(name: String, muscleGroup: MuscleGroup) {
        let exercise = Exercise(name: name, muscleGroup: muscleGroup, isCustom: true)
        modelContext.insert(exercise)
        save()
        fetchExercises()
    }

    func deleteExercise(_ exercise: Exercise) {
        guard exercise.isCustom else { return }
        modelContext.delete(exercise)
        save()
        fetchExercises()
    }

    func seedExercisesIfNeeded() {
        let descriptor = FetchDescriptor<Exercise>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        for definition in ExerciseSeedData.exercises {
            let exercise = Exercise(
                name: definition.name,
                muscleGroup: definition.muscleGroup,
                isCardio: definition.isCardio,
                exerciseDescription: definition.description,
                instructions: definition.instructions,
                defaultRestSeconds: definition.defaultRestSeconds
            )
            modelContext.insert(exercise)
        }
        save()
        fetchExercises()
    }

    private func save() {
        try? modelContext.save()
    }
}
