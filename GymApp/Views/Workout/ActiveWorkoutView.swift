import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var viewModel: WorkoutViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                if let workout = viewModel.activeWorkout {
                    ForEach(workout.exercises.sorted(by: { $0.order < $1.order })) { workoutExercise in
                        WorkoutExerciseSection(
                            workoutExercise: workoutExercise,
                            viewModel: viewModel
                        )
                    }
                }

                SecondaryButton(title: "+ Add Exercise") {
                    viewModel.showingAddExercise = true
                }
                .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
            }
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish") {
                    viewModel.showingFinishConfirmation = true
                }
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.accent)
            }
        }
        .confirmationDialog("Finish Workout?", isPresented: $viewModel.showingFinishConfirmation) {
            Button("Finish Workout") {
                viewModel.finishWorkout()
            }
            Button("Discard Workout", role: .destructive) {
                viewModel.discardWorkout()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $viewModel.showingAddExercise) {
            AddExerciseView { exercise in
                viewModel.addExercise(exercise)
            }
        }
    }
}

// MARK: - Workout Exercise Section

private struct WorkoutExerciseSection: View {
    let workoutExercise: WorkoutExercise
    let viewModel: WorkoutViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            // Exercise name header
            HStack {
                Text(workoutExercise.exercise?.name ?? "Unknown Exercise")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.accent)

                Spacer()

                Button {
                    viewModel.removeExercise(workoutExercise)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)

            // Column headers
            HStack(spacing: AppTheme.Spacing.sm) {
                Text("SET")
                    .frame(width: 28)
                Text("LBS")
                    .frame(maxWidth: .infinity)
                Text("")
                    .frame(width: 14)
                Text("REPS")
                    .frame(maxWidth: .infinity)
                Text("")
                    .frame(width: AppTheme.Layout.minTouchTarget)
            }
            .font(.caption)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)

            // Set rows
            ForEach(workoutExercise.sortedSets) { exerciseSet in
                SetRowView(
                    setNumber: exerciseSet.order + 1,
                    weight: Binding(
                        get: { String(format: "%g", exerciseSet.weight) },
                        set: { exerciseSet.weight = Double($0) ?? 0 }
                    ),
                    reps: Binding(
                        get: { "\(exerciseSet.reps)" },
                        set: { exerciseSet.reps = Int($0) ?? 0 }
                    ),
                    isCompleted: exerciseSet.isCompleted,
                    onComplete: { viewModel.completeSet(exerciseSet) }
                )
            }

            // Add set button
            Button {
                viewModel.addSet(to: workoutExercise)
            } label: {
                Text("+ Add Set")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.accent)
                    .padding(.vertical, AppTheme.Spacing.xs)
            }
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
    }
}
