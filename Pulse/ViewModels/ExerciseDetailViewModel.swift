import Foundation
import SwiftData
import Observation

@Observable
final class ExerciseDetailViewModel {
    var historyEntries: [ExerciseHistoryEntry] = []

    private let modelContext: ModelContext
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - History

    struct ExerciseHistoryEntry: Identifiable {
        let id: UUID
        let workoutDate: Date
        let sets: [SetSummary]
        let durationSeconds: Int?
        let distanceMeters: Double?
    }

    struct SetSummary: Identifiable {
        let id: UUID
        let order: Int
        let weight: Double
        let reps: Int
    }

    func fetchHistory(for exercise: Exercise, limit: Int = 5) {
        let exerciseID = exercise.id
        var descriptor = FetchDescriptor<WorkoutExercise>(
            predicate: #Predicate<WorkoutExercise> { workoutExercise in
                workoutExercise.exercise?.id == exerciseID &&
                workoutExercise.workout?.endDate != nil
            },
            sortBy: [SortDescriptor(\WorkoutExercise.workout?.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        let results = (try? modelContext.fetch(descriptor)) ?? []
        historyEntries = results.map { workoutExercise in
            ExerciseHistoryEntry(
                id: workoutExercise.id,
                workoutDate: workoutExercise.workout?.startDate ?? .distantPast,
                sets: workoutExercise.sortedSets.map { exerciseSet in
                    SetSummary(
                        id: exerciseSet.id,
                        order: exerciseSet.order,
                        weight: exerciseSet.weight,
                        reps: exerciseSet.reps
                    )
                },
                durationSeconds: workoutExercise.durationSeconds,
                distanceMeters: workoutExercise.distanceMeters
            )
        }
    }

    // MARK: - Formatting

    func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return Self.dateFormatter.string(from: date)
        }
    }
}
