import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WorkoutViewModel?
    @State private var contentVisible = false

    var splashFinished: Bool = true
    @Binding var pendingTemplate: WorkoutTemplate?
    var onWorkoutFinished: ((Workout) -> Void)?
    var onBrowseTemplates: (() -> Void)?

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
        .onChange(of: pendingTemplate) { _, template in
            if let template {
                viewModel?.startWorkout(from: template)
                pendingTemplate = nil
            }
        }
    }

    private var startWorkoutView: some View {
        VStack {
            Spacer()
            VStack(spacing: AppTheme.Spacing.xxl) {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)

                    Text("Ready to Train?")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .opacity(contentVisible ? 1 : 0)
                }

                VStack(spacing: AppTheme.Spacing.sm) {
                    PrimaryButton(title: "Start Empty Workout") {
                        viewModel?.startWorkout()
                    }

                    SecondaryButton(title: "Browse Templates") {
                        onBrowseTemplates?()
                    }
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
    WorkoutView(pendingTemplate: .constant(nil))
        .modelContainer(for: [
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            Exercise.self,
            WorkoutTemplate.self,
            TemplateExercise.self,
        ], inMemory: true)
}
