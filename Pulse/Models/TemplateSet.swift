import Foundation
import SwiftData

@Model
final class TemplateSet {
    var id: UUID
    var order: Int
    var weight: Double
    var reps: Int
    var setTypeRaw: String = "normal"
    var templateExercise: TemplateExercise?

    var setType: SetType {
        get { SetType(rawValue: setTypeRaw) ?? .normal }
        set { setTypeRaw = newValue.rawValue }
    }

    init(order: Int, weight: Double = 0, reps: Int = 0, setType: SetType = .normal) {
        self.id = UUID()
        self.order = order
        self.weight = weight
        self.reps = reps
        self.setTypeRaw = setType.rawValue
    }
}
