import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "dumbbell.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            ExerciseLibraryView()
                .tabItem {
                    Label("Exercises", systemImage: "list.bullet")
                }
        }
        .tint(AppTheme.Colors.accent)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            Exercise.self,
        ], inMemory: true)
}
