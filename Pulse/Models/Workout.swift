import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var notes: String?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var exercises: [WorkoutExercise] = []

    var duration: TimeInterval? {
        guard let endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }

    var isActive: Bool {
        endDate == nil
    }

    init(startDate: Date = .now) {
        self.id = UUID()
        self.startDate = startDate
    }
}
