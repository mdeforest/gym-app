import Foundation
import SwiftData

enum SetType: String, Codable, CaseIterable, Sendable {
    case normal
    case warmup
}

@Model
final class ExerciseSet {
    var id: UUID
    var order: Int
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var setTypeRaw: String = "normal"
    var rpe: Double?
    var workoutExercise: WorkoutExercise?

    var setType: SetType {
        get { SetType(rawValue: setTypeRaw) ?? .normal }
        set { setTypeRaw = newValue.rawValue }
    }

    init(order: Int, weight: Double = 0, reps: Int = 0, setType: SetType = .normal) {
        self.id = UUID()
        self.order = order
        self.weight = weight
        self.reps = reps
        self.isCompleted = false
        self.setTypeRaw = setType.rawValue
    }
}
