import Foundation
import SwiftData

@Model
final class TemplateExercise {
    var id: UUID
    var order: Int
    var template: WorkoutTemplate?
    var exercise: Exercise?
    var setCount: Int
    var defaultWeight: Double
    var defaultReps: Int
    var defaultDurationSeconds: Int?
    var defaultDistanceMeters: Double?
    var warmupSetCount: Int = 0
    var supersetGroupId: UUID?

    init(order: Int, exercise: Exercise? = nil, setCount: Int = 3, defaultWeight: Double = 0, defaultReps: Int = 0, warmupSetCount: Int = 0, supersetGroupId: UUID? = nil) {
        self.id = UUID()
        self.order = order
        self.exercise = exercise
        self.setCount = setCount
        self.defaultWeight = defaultWeight
        self.defaultReps = defaultReps
        self.warmupSetCount = warmupSetCount
        self.supersetGroupId = supersetGroupId
    }
}
