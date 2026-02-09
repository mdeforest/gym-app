import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var muscleGroup: MuscleGroup
    var isCustom: Bool
    var isCardio: Bool
    var lastUsedDate: Date?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.exercise)
    var workoutExercises: [WorkoutExercise] = []

    init(
        name: String,
        muscleGroup: MuscleGroup,
        isCustom: Bool = false,
        isCardio: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.muscleGroup = muscleGroup
        self.isCustom = isCustom
        self.isCardio = isCardio
    }
}
