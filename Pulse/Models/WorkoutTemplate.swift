import Foundation
import SwiftData

@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    var createdDate: Date
    var lastUsedDate: Date?

    @Relationship(deleteRule: .cascade, inverse: \TemplateExercise.template)
    var exercises: [TemplateExercise] = []

    var sortedExercises: [TemplateExercise] {
        exercises.sorted { $0.order < $1.order }
    }

    var exerciseCount: Int {
        exercises.count
    }

    var muscleGroups: [MuscleGroup] {
        let groups = Set(exercises.compactMap { $0.exercise?.muscleGroup })
        return MuscleGroup.allCases.filter { groups.contains($0) }
    }

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdDate = .now
    }
}
