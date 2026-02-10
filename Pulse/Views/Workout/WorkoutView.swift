import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WorkoutViewModel?
    @State private var contentVisible = false

    var splashFinished: Bool = true
    var onWorkoutFinished: ((Workout) -> Void)?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel, viewModel.activeWorkout != nil {
                    ActiveWorkoutView(viewModel: viewModel, onWorkoutFinished: onWorkoutFinished)
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
        .onChange(of: splashFinished) { _, finished in
            if finished {
                withAnimation(.easeOut(duration: 0.6)) {
                    contentVisible = true
                }
            }
        }
    }

    private var startWorkoutView: some View {
        VStack {
            Spacer()
            VStack(spacing: AppTheme.Spacing.md) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)

                Text("Ready to Train?")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .opacity(contentVisible ? 1 : 0)

                Text("Start a workout to begin logging your exercises and sets.")
                    .font(.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(contentVisible ? 1 : 0)

                PrimaryButton(title: "Start Workout") {
                    viewModel?.startWorkout()
                }
                .padding(.horizontal, AppTheme.Spacing.xxl)
                .opacity(contentVisible ? 1 : 0)
            }
            .padding(AppTheme.Layout.screenEdgePadding)
            Spacer()
        }
    }
}

#Preview {
    WorkoutView()
        .modelContainer(for: [Workout.self, WorkoutExercise.self, ExerciseSet.self, Exercise.self], inMemory: true)
}
