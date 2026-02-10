import Foundation
import SwiftData

enum DataService {
    /// Creates a configured ModelContainer for the app's data models.
    static func createModelContainer() throws -> ModelContainer {
        let schema = Schema([
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            Exercise.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Creates an in-memory ModelContainer for previews and testing.
    static func createPreviewContainer() throws -> ModelContainer {
        let schema = Schema([
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            Exercise.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
