import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class ExerciseLibraryViewModel {
    var exercises: [Exercise] = [] {
        didSet { updateDerivedData() }
    }
    var searchText = "" {
        didSet { updateDerivedData() }
    }
    var selectedMuscleGroup: MuscleGroup? {
        didSet { updateDerivedData() }
    }
    var selectedEquipment: Equipment? {
        didSet { updateDerivedData() }
    }
    private(set) var filteredExercises: [Exercise] = []
    private(set) var recentExercises: [Exercise] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchExercises()
    }

    private func updateDerivedData() {
        var result = exercises

        if let selectedMuscleGroup {
            result = result.filter { $0.muscleGroup == selectedMuscleGroup }
        }

        if let selectedEquipment {
            result = result.filter { $0.equipment == selectedEquipment }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        filteredExercises = result
        recentExercises = exercises
            .filter { $0.lastUsedDate != nil }
            .sorted { ($0.lastUsedDate ?? .distantPast) > ($1.lastUsedDate ?? .distantPast) }
            .prefix(5)
            .map { $0 }
    }

    func fetchExercises() {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        do {
            exercises = try modelContext.fetch(descriptor)
        } catch {
            print("[ExerciseLibraryViewModel] fetchExercises failed: \(error)")
            exercises = []
        }
    }

    func addCustomExercise(name: String, muscleGroup: MuscleGroup, equipment: Equipment = .other) {
        let exercise = Exercise(name: name, muscleGroup: muscleGroup, isCustom: true, equipment: equipment)
        modelContext.insert(exercise)
        save()
        fetchExercises()
    }

    var favoriteCount: Int {
        exercises.filter(\.isFavorite).count
    }

    func toggleFavorite(_ exercise: Exercise) {
        if !exercise.isFavorite && favoriteCount >= 10 { return }
        exercise.isFavorite.toggle()
        save()
    }

    func deleteExercise(_ exercise: Exercise) {
        guard exercise.isCustom else { return }
        modelContext.delete(exercise)
        save()
        fetchExercises()
    }

    func seedExercisesIfNeeded() {
        let descriptor = FetchDescriptor<Exercise>()
        let count: Int
        do {
            count = try modelContext.fetchCount(descriptor)
        } catch {
            print("[ExerciseLibraryViewModel] fetchCount failed: \(error)")
            return
        }

        // Fast path: fresh install — insert everything without name lookup
        if count == 0 {
            for definition in ExerciseSeedData.exercises {
                modelContext.insert(makeExercise(from: definition))
            }
            save()
            fetchExercises()
            return
        }

        // Additive path: existing install — insert new exercises and repair nil equipment
        let all: [Exercise]
        do {
            all = try modelContext.fetch(descriptor)
        } catch {
            print("[ExerciseLibraryViewModel] fetch for additive seed failed: \(error)")
            return
        }

        let existingNames = Set(all.map(\.name))
        let definitionsByName = Dictionary(
            ExerciseSeedData.exercises.map { ($0.name, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        // Insert exercises that don't exist yet
        var added = 0
        for definition in ExerciseSeedData.exercises where !existingNames.contains(definition.name) {
            modelContext.insert(makeExercise(from: definition))
            added += 1
        }

        // Repair nil equipment on existing non-custom exercises (SwiftData migration leaves NULL)
        var repaired = 0
        for exercise in all where !exercise.isCustom && exercise.equipment == nil {
            if let definition = definitionsByName[exercise.name] {
                exercise.equipment = definition.equipment
                repaired += 1
            }
        }

        if added > 0 || repaired > 0 {
            save()
            fetchExercises()
        }
    }

    private func makeExercise(from definition: ExerciseSeedData.ExerciseDefinition) -> Exercise {
        Exercise(
            name: definition.name,
            muscleGroup: definition.muscleGroup,
            isCardio: definition.isCardio,
            exerciseDescription: definition.description,
            instructions: definition.instructions,
            defaultRestSeconds: definition.defaultRestSeconds,
            equipment: definition.equipment,
            machineType: ExerciseSeedData.machineTypeMap[definition.name]
        )
    }

    /// Stamps machineType on any seeded machine exercise that's missing it (one-time backfill).
    func backfillMachineTypesIfNeeded() {
        let descriptor = FetchDescriptor<Exercise>()
        guard let all = try? modelContext.fetch(descriptor) else { return }
        var changed = false
        for exercise in all where !exercise.isCustom && exercise.equipment == .machine && exercise.machineType == nil {
            if let type_ = ExerciseSeedData.machineTypeMap[exercise.name] {
                exercise.machineType = type_
                changed = true
            }
        }
        if changed { save() }
    }

    private func save() {
        try? modelContext.save()
    }
}
