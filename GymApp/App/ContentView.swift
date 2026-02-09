import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var completedWorkout: Workout?

    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutView(onWorkoutFinished: { workout in
                completedWorkout = workout
                selectedTab = 1
            })
            .tabItem {
                Label("Workout", systemImage: "dumbbell.fill")
            }
            .tag(0)

            HistoryView(navigateToWorkout: $completedWorkout)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)

            ExerciseLibraryView()
                .tabItem {
                    Label("Exercises", systemImage: "list.bullet")
                }
                .tag(2)
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
