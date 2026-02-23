import Foundation

enum Equipment: String, Codable, CaseIterable, Identifiable {
    case barbell
    case dumbbell
    case cable
    case machine
    case bodyweight
    case kettlebell
    case bands
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .barbell:    "Barbell"
        case .dumbbell:   "Dumbbell"
        case .cable:      "Cable"
        case .machine:    "Machine"
        case .bodyweight: "Bodyweight"
        case .kettlebell: "Kettlebell"
        case .bands:      "Bands"
        case .other:      "Other"
        }
    }
}
