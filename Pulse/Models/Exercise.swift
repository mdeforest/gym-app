import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var muscleGroup: MuscleGroup
    var isCustom: Bool
    var isCardio: Bool
    var exerciseDescription: String
    var instructions: String
    var lastUsedDate: Date?
    var defaultRestSeconds: Int?
    var isFavorite: Bool = false
    var equipment: Equipment?
    var machineType: MachineType?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.exercise)
    var workoutExercises: [WorkoutExercise] = []

    @Relationship(deleteRule: .nullify, inverse: \TemplateExercise.exercise)
    var templateExercises: [TemplateExercise] = []

    init(
        name: String,
        muscleGroup: MuscleGroup,
        isCustom: Bool = false,
        isCardio: Bool = false,
        exerciseDescription: String = "",
        instructions: String = "",
        defaultRestSeconds: Int? = nil,
        equipment: Equipment = .other,
        machineType: MachineType? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.muscleGroup = muscleGroup
        self.isCustom = isCustom
        self.isCardio = isCardio
        self.exerciseDescription = exerciseDescription
        self.instructions = instructions
        self.defaultRestSeconds = defaultRestSeconds
        self.equipment = equipment
        self.machineType = machineType
    }
}
