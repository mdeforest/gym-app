import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WorkoutViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel, viewModel.activeWorkout != nil {
                    ActiveWorkoutView(viewModel: viewModel)
                } else {
                    startWorkoutView
                }
            }
            .navigationTitle("Workout")
            .background(AppTheme.Colors.background)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = WorkoutViewModel(modelContext: modelContext)
            }
        }
    }

    private var startWorkoutView: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "figure.strengthtraining.traditional",
                title: "Ready to Train?",
                message: "Start a workout to begin logging your exercises and sets.",
                buttonTitle: "Start Workout"
            ) {
                viewModel?.startWorkout()
            }
            Spacer()
        }
    }
}

#Preview {
    WorkoutView()
        .modelContainer(for: [Workout.self, WorkoutExercise.self, ExerciseSet.self, Exercise.self], inMemory: true)
}
