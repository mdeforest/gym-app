import Foundation

enum ExerciseSeedData {
    struct ExerciseDefinition {
        let name: String
        let muscleGroup: MuscleGroup
    }

    static let exercises: [ExerciseDefinition] = [
        // Chest
        ExerciseDefinition(name: "Barbell Bench Press", muscleGroup: .chest),
        ExerciseDefinition(name: "Incline Barbell Bench Press", muscleGroup: .chest),
        ExerciseDefinition(name: "Dumbbell Bench Press", muscleGroup: .chest),
        ExerciseDefinition(name: "Incline Dumbbell Press", muscleGroup: .chest),
        ExerciseDefinition(name: "Dumbbell Fly", muscleGroup: .chest),
        ExerciseDefinition(name: "Cable Fly", muscleGroup: .chest),
        ExerciseDefinition(name: "Push-Up", muscleGroup: .chest),
        ExerciseDefinition(name: "Chest Dip", muscleGroup: .chest),

        // Back
        ExerciseDefinition(name: "Barbell Row", muscleGroup: .back),
        ExerciseDefinition(name: "Dumbbell Row", muscleGroup: .back),
        ExerciseDefinition(name: "Pull-Up", muscleGroup: .back),
        ExerciseDefinition(name: "Chin-Up", muscleGroup: .back),
        ExerciseDefinition(name: "Lat Pulldown", muscleGroup: .back),
        ExerciseDefinition(name: "Seated Cable Row", muscleGroup: .back),
        ExerciseDefinition(name: "T-Bar Row", muscleGroup: .back),
        ExerciseDefinition(name: "Deadlift", muscleGroup: .back),

        // Shoulders
        ExerciseDefinition(name: "Overhead Press", muscleGroup: .shoulders),
        ExerciseDefinition(name: "Dumbbell Shoulder Press", muscleGroup: .shoulders),
        ExerciseDefinition(name: "Lateral Raise", muscleGroup: .shoulders),
        ExerciseDefinition(name: "Front Raise", muscleGroup: .shoulders),
        ExerciseDefinition(name: "Face Pull", muscleGroup: .shoulders),
        ExerciseDefinition(name: "Reverse Fly", muscleGroup: .shoulders),
        ExerciseDefinition(name: "Arnold Press", muscleGroup: .shoulders),

        // Arms
        ExerciseDefinition(name: "Barbell Curl", muscleGroup: .arms),
        ExerciseDefinition(name: "Dumbbell Curl", muscleGroup: .arms),
        ExerciseDefinition(name: "Hammer Curl", muscleGroup: .arms),
        ExerciseDefinition(name: "Preacher Curl", muscleGroup: .arms),
        ExerciseDefinition(name: "Tricep Pushdown", muscleGroup: .arms),
        ExerciseDefinition(name: "Overhead Tricep Extension", muscleGroup: .arms),
        ExerciseDefinition(name: "Skull Crusher", muscleGroup: .arms),
        ExerciseDefinition(name: "Close-Grip Bench Press", muscleGroup: .arms),

        // Legs
        ExerciseDefinition(name: "Barbell Squat", muscleGroup: .legs),
        ExerciseDefinition(name: "Front Squat", muscleGroup: .legs),
        ExerciseDefinition(name: "Leg Press", muscleGroup: .legs),
        ExerciseDefinition(name: "Romanian Deadlift", muscleGroup: .legs),
        ExerciseDefinition(name: "Leg Curl", muscleGroup: .legs),
        ExerciseDefinition(name: "Leg Extension", muscleGroup: .legs),
        ExerciseDefinition(name: "Bulgarian Split Squat", muscleGroup: .legs),
        ExerciseDefinition(name: "Calf Raise", muscleGroup: .legs),
        ExerciseDefinition(name: "Hip Thrust", muscleGroup: .legs),
        ExerciseDefinition(name: "Lunge", muscleGroup: .legs),

        // Core
        ExerciseDefinition(name: "Plank", muscleGroup: .core),
        ExerciseDefinition(name: "Hanging Leg Raise", muscleGroup: .core),
        ExerciseDefinition(name: "Cable Crunch", muscleGroup: .core),
        ExerciseDefinition(name: "Ab Wheel Rollout", muscleGroup: .core),
        ExerciseDefinition(name: "Russian Twist", muscleGroup: .core),

        // Cardio
        ExerciseDefinition(name: "Running", muscleGroup: .cardio),
        ExerciseDefinition(name: "Cycling", muscleGroup: .cardio),
        ExerciseDefinition(name: "Rowing", muscleGroup: .cardio),
        ExerciseDefinition(name: "Elliptical", muscleGroup: .cardio),
        ExerciseDefinition(name: "Stair Climber", muscleGroup: .cardio),
        ExerciseDefinition(name: "Jump Rope", muscleGroup: .cardio),
    ]
}
