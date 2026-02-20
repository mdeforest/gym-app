import Foundation
import SwiftData

enum SetType: String, Codable, CaseIterable, Sendable {
    case normal
    case warmup
}

enum PRType: String, CaseIterable, Sendable {
    case weight
    case estimated1RM
    case volume

    var displayName: String {
        switch self {
        case .weight: return "Weight"
        case .estimated1RM: return "Est. 1RM"
        case .volume: return "Volume"
        }
    }

    var icon: String {
        switch self {
        case .weight: return "scalemass.fill"
        case .estimated1RM: return "bolt.fill"
        case .volume: return "chart.bar.fill"
        }
    }
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

    // Personal record flags
    var isWeightPR: Bool = false
    var isEstimated1RMPR: Bool = false
    var isVolumePR: Bool = false

    var setType: SetType {
        get { SetType(rawValue: setTypeRaw) ?? .normal }
        set { setTypeRaw = newValue.rawValue }
    }

    var isAnyPR: Bool {
        isWeightPR || isEstimated1RMPR || isVolumePR
    }

    var prTypes: [PRType] {
        var types: [PRType] = []
        if isWeightPR { types.append(.weight) }
        if isEstimated1RMPR { types.append(.estimated1RM) }
        if isVolumePR { types.append(.volume) }
        return types
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
