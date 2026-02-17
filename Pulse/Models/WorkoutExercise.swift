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

    // Superset grouping
    var supersetGroupId: UUID?

    var sortedSets: [ExerciseSet] {
        sets.sorted { $0.order < $1.order }
    }

    var isInSuperset: Bool {
        supersetGroupId != nil
    }

    init(order: Int, exercise: Exercise? = nil, supersetGroupId: UUID? = nil) {
        self.id = UUID()
        self.order = order
        self.exercise = exercise
        self.supersetGroupId = supersetGroupId
    }
}
