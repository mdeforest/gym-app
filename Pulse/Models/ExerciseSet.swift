import Foundation
import SwiftData

@Model
final class ExerciseSet {
    var id: UUID
    var order: Int
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var workoutExercise: WorkoutExercise?

    init(order: Int, weight: Double = 0, reps: Int = 0) {
        self.id = UUID()
        self.order = order
        self.weight = weight
        self.reps = reps
        self.isCompleted = false
    }
}
