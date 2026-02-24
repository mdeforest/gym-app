import Foundation

enum ExerciseSeedData {
    struct ExerciseDefinition: Decodable {
        let name: String
        let muscleGroup: MuscleGroup
        let isCardio: Bool
        let defaultRestSeconds: Int?
        let description: String
        let instructions: String
        let equipment: Equipment
    }

    static let exercises: [ExerciseDefinition] = {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ExerciseDefinition].self, from: data) else {
            return []
        }
        return decoded
    }()

    // MARK: - Machine type mapping

    static let machineTypeMap: [String: MachineType] = [
        // Smith Machine
        "Decline Smith Press":                      .smithMachine,
        "Smith Machine Behind the Back Shrug":      .smithMachine,
        "Smith Machine Bench Press":                .smithMachine,
        "Smith Machine Bent Over Row":              .smithMachine,
        "Smith Machine Calf Raise":                 .smithMachine,
        "Smith Machine Close-Grip Bench Press":     .smithMachine,
        "Smith Machine Decline Press":              .smithMachine,
        "Smith Machine Hang Power Clean":           .smithMachine,
        "Smith Machine Hip Raise":                  .smithMachine,
        "Smith Machine Incline Bench Press":        .smithMachine,
        "Smith Machine Leg Press":                  .smithMachine,
        "Smith Machine One-Arm Upright Row":        .smithMachine,
        "Smith Machine Overhead Shoulder Press":    .smithMachine,
        "Smith Machine Pistol Squat":               .smithMachine,
        "Smith Machine Reverse Calf Raises":        .smithMachine,
        "Smith Machine Squat":                      .smithMachine,
        "Smith Machine Stiff-Legged Deadlift":      .smithMachine,
        "Smith Machine Upright Row":                .smithMachine,
        "Smith Single-Leg Split Squat":             .smithMachine,

        // Leg Press
        "Leg Press":                                .legPress,
        "Narrow Stance Leg Press":                  .legPress,
        "Calf Press On The Leg Press Machine":      .legPress,

        // Leg Extension / Curl
        "Leg Extensions":                           .legExtensionCurl,
        "Single-Leg Leg Extension":                 .legExtensionCurl,
        "Lying Leg Curls":                          .legExtensionCurl,
        "Seated Leg Curl":                          .legExtensionCurl,
        "Standing Leg Curl":                        .legExtensionCurl,

        // Hack Squat
        "Hack Squat":                               .hackSquat,
        "Narrow Stance Hack Squats":                .hackSquat,
        "Lying Machine Squat":                      .hackSquat,

        // Calf Machine
        "Calf Press":                               .calfMachine,
        "Calf-Machine Shoulder Shrug":              .calfMachine,
        "Seated Calf Raise":                        .calfMachine,
        "Standing Calf Raises":                     .calfMachine,

        // Cardio Machines
        "Bicycling, Stationary":                    .cardioMachine,
        "Elliptical Trainer":                       .cardioMachine,
        "Jogging, Treadmill":                       .cardioMachine,
        "Recumbent Bike":                           .cardioMachine,
        "Rowing, Stationary":                       .cardioMachine,
        "Running, Treadmill":                       .cardioMachine,
        "Stairmaster":                              .cardioMachine,
        "Step Mill":                                .cardioMachine,
        "Walking, Treadmill":                       .cardioMachine,

        // Chest / Fly Machine
        "Butterfly":                                .chestMachine,
        "Leverage Chest Press":                     .chestMachine,
        "Leverage Decline Chest Press":             .chestMachine,
        "Leverage Incline Chest Press":             .chestMachine,
        "Machine Bench Press":                      .chestMachine,
        "Reverse Machine Flyes":                    .chestMachine,

        // Row Machine
        "Leverage High Row":                        .rowMachine,
        "Leverage Iso Row":                         .rowMachine,
        "Lying T-Bar Row":                          .rowMachine,

        // Shoulder Press Machine
        "Leverage Shoulder Press":                  .shoulderMachine,
        "Machine Shoulder (Military) Press":        .shoulderMachine,

        // Leverage / Plate Machine
        "Leverage Deadlift":                        .leverageMachine,
        "Leverage Shrug":                           .leverageMachine,

        // Arm Machines
        "Dip Machine":                              .armMachine,
        "Machine Bicep Curl":                       .armMachine,
        "Machine Preacher Curls":                   .armMachine,
        "Machine Triceps Extension":                .armMachine,

        // Other Machines
        "Ab Crunch Machine":                        .otherMachine,
        "Chair Squat":                              .otherMachine,
        "Lunge Sprint":                             .otherMachine,
        "Reverse Hyperextension":                   .otherMachine,
        "Thigh Abductor":                           .otherMachine,
        "Thigh Adductor":                           .otherMachine,
    ]
}
