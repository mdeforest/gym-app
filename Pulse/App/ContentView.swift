import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    var splashFinished: Bool = true

    @State private var selectedTab = 0
    @State private var completedWorkout: Workout?
    @State private var pendingTemplate: WorkoutTemplate?
    @State private var hasSeedRun = false

    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutView(
                splashFinished: splashFinished,
                pendingTemplate: $pendingTemplate,
                onWorkoutFinished: { workout in
                    completedWorkout = workout
                    selectedTab = 1
                },
                onBrowseTemplates: {
                    selectedTab = 3
                }
            )
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

            TemplatesView { template in
                pendingTemplate = template
                selectedTab = 0
            }
            .tabItem {
                Label("Templates", systemImage: "doc.on.doc")
            }
            .tag(3)
        }
        .tint(AppTheme.Colors.accent)
        .onAppear {
            if !hasSeedRun {
                hasSeedRun = true
                let vm = ExerciseLibraryViewModel(modelContext: modelContext)
                vm.seedExercisesIfNeeded()
            }
        }
    }
}

#Preview {
    ContentView(splashFinished: true)
        .modelContainer(for: [
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            Exercise.self,
            WorkoutTemplate.self,
            TemplateExercise.self,
            TemplateSet.self,
        ], inMemory: true)
}
