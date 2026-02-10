import Foundation
import SwiftData

@Model
final class WorkoutExercise {
    var id: UUID
    var order: Int
    var workout: Workout?
    var exercise: Exercise?

    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.workoutExercise)
    var sets: [ExerciseSet] = []

    // Cardio-specific fields
    var durationSeconds: Int?
    var distanceMeters: Double?

    var sortedSets: [ExerciseSet] {
        sets.sorted { $0.order < $1.order }
    }

    init(order: Int, exercise: Exercise? = nil) {
        self.id = UUID()
        self.order = order
        self.exercise = exercise
    }
}
