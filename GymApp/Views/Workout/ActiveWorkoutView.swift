import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var viewModel: WorkoutViewModel
    var onWorkoutFinished: ((Workout) -> Void)?

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
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    viewModel.showingDiscardConfirmation = true
                }
                .foregroundStyle(AppTheme.Colors.destructive)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish") {
                    viewModel.showingFinishConfirmation = true
                }
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.accent)
            }
        }
        .alert("Finish Workout?", isPresented: $viewModel.showingFinishConfirmation) {
            Button("Finish") {
                if let workout = viewModel.finishWorkout() {
                    onWorkoutFinished?(workout)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will save your workout to history.")
        }
        .alert("Discard Workout?", isPresented: $viewModel.showingDiscardConfirmation) {
            Button("Discard", role: .destructive) {
                viewModel.discardWorkout()
            }
            Button("Keep Training", role: .cancel) {}
        } message: {
            Text("This will delete all exercises and sets from this workout.")
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

    private var isCardio: Bool {
        workoutExercise.exercise?.isCardio ?? false
    }

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

            if isCardio {
                cardioInputs
            } else {
                strengthInputs
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
    }

    // MARK: - Cardio Inputs

    private var cardioInputs: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "clock")
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(width: 28)

                NumberInputField(
                    label: "min",
                    value: Binding(
                        get: {
                            if let seconds = workoutExercise.durationSeconds, seconds > 0 {
                                return "\(seconds / 60)"
                            }
                            return ""
                        },
                        set: { newValue in
                            if let minutes = Int(newValue) {
                                workoutExercise.durationSeconds = minutes * 60
                            } else {
                                workoutExercise.durationSeconds = nil
                            }
                        }
                    )
                )

                Text("min")
                    .font(.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "figure.run")
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(width: 28)

                NumberInputField(
                    label: "km",
                    value: Binding(
                        get: {
                            if let meters = workoutExercise.distanceMeters, meters > 0 {
                                let km = meters / 1000
                                return String(format: "%g", km)
                            }
                            return ""
                        },
                        set: { newValue in
                            if let km = Double(newValue) {
                                workoutExercise.distanceMeters = km * 1000
                            } else {
                                workoutExercise.distanceMeters = nil
                            }
                        }
                    )
                )

                Text("km")
                    .font(.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
        .padding(.vertical, AppTheme.Spacing.xs)
    }

    // MARK: - Strength Inputs

    private var strengthInputs: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
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
                        set: { newValue in
                            exerciseSet.weight = Double(newValue) ?? 0
                            viewModel.propagateValues(from: exerciseSet, in: workoutExercise)
                        }
                    ),
                    reps: Binding(
                        get: { "\(exerciseSet.reps)" },
                        set: { newValue in
                            exerciseSet.reps = Int(newValue) ?? 0
                            viewModel.propagateValues(from: exerciseSet, in: workoutExercise)
                        }
                    ),
                    isCompleted: exerciseSet.isCompleted,
                    onComplete: { viewModel.completeSet(exerciseSet) },
                    onDelete: workoutExercise.sets.count > 1 ? {
                        viewModel.deleteSet(exerciseSet, from: workoutExercise)
                    } : nil
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
    }
}
