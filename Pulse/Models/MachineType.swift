import Foundation

enum MachineType: String, Codable, CaseIterable, Identifiable {
    case smithMachine       = "smith_machine"
    case legPress           = "leg_press"
    case legExtensionCurl   = "leg_extension_curl"
    case hackSquat          = "hack_squat"
    case calfMachine        = "calf_machine"
    case cardioMachine      = "cardio_machine"
    case chestMachine       = "chest_machine"
    case rowMachine         = "row_machine"
    case shoulderMachine    = "shoulder_machine"
    case leverageMachine    = "leverage_machine"
    case armMachine         = "arm_machine"
    case otherMachine       = "other_machine"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .smithMachine:     "Smith Machine"
        case .legPress:         "Leg Press"
        case .legExtensionCurl: "Leg Extension / Curl"
        case .hackSquat:        "Hack Squat"
        case .calfMachine:      "Calf Machine"
        case .cardioMachine:    "Cardio Machines"
        case .chestMachine:     "Chest / Fly Machine"
        case .rowMachine:       "Row Machine"
        case .shoulderMachine:  "Shoulder Press Machine"
        case .leverageMachine:  "Leverage / Plate Machine"
        case .armMachine:       "Arm Machine"
        case .otherMachine:     "Other Machines"
        }
    }

    var icon: String {
        switch self {
        case .smithMachine:     "figure.strengthtraining.traditional"
        case .legPress:         "arrow.down.to.line"
        case .legExtensionCurl: "figure.cooldown"
        case .hackSquat:        "figure.squats"
        case .calfMachine:      "shoeprints.fill"
        case .cardioMachine:    "figure.run"
        case .chestMachine:     "figure.arms.open"
        case .rowMachine:       "figure.rowing"
        case .shoulderMachine:  "arrow.up.circle.fill"
        case .leverageMachine:  "scalemass.fill"
        case .armMachine:       "dumbbell.fill"
        case .otherMachine:     "gearshape.fill"
        }
    }
}
