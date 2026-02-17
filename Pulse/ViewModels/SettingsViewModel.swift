import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var showingClearDataConfirmation = false
    var showingClearDataSuccess = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func generateExportData() -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func clearAllData() {
        let workouts = (try? modelContext.fetch(FetchDescriptor<Workout>())) ?? []
        for workout in workouts {
            modelContext.delete(workout)
        }

        let templates = (try? modelContext.fetch(FetchDescriptor<WorkoutTemplate>())) ?? []
        for template in templates {
            modelContext.delete(template)
        }

        let exercises = (try? modelContext.fetch(FetchDescriptor<Exercise>())) ?? []
        for exercise in exercises {
            if exercise.isCustom {
                modelContext.delete(exercise)
            } else {
                exercise.lastUsedDate = nil
                exercise.isFavorite = false
            }
        }

        save()
        showingClearDataSuccess = true
    }

    private func save() {
        try? modelContext.save()
    }
}
