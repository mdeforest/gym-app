import Foundation
import SwiftData
import Observation

@Observable
final class HistoryViewModel {
    var workouts: [Workout] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchWorkouts() {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        workouts = (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteWorkout(_ workout: Workout) {
        modelContext.delete(workout)
        try? modelContext.save()
        fetchWorkouts()
    }

    func formattedDuration(_ workout: Workout) -> String {
        guard let duration = workout.duration else { return "--" }
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}
