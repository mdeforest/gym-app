import SwiftUI

struct SupersetGroupView: View {
    let exercises: [WorkoutExercise]
    let viewModel: WorkoutViewModel
    var onMoveUp: (() -> Void)?
    var onMoveDown: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Purple bracket on the left
            RoundedRectangle(cornerRadius: 2)
                .fill(AppTheme.Colors.chartPurple)
                .frame(width: 4)
                .padding(.vertical, AppTheme.Spacing.sm)

            VStack(alignment: .leading, spacing: 0) {
                // Superset label
                HStack {
                    Text("SUPERSET")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.Colors.chartPurple)
                        .kerning(1)
                    Spacer()

                    if onMoveUp != nil || onMoveDown != nil {
                        HStack(spacing: AppTheme.Spacing.xxs) {
                            Button {
                                onMoveUp?()
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundStyle(onMoveUp != nil ? AppTheme.Colors.textSecondary : AppTheme.Colors.surfaceTertiary)
                            }
                            .disabled(onMoveUp == nil)

                            Button {
                                onMoveDown?()
                            } label: {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundStyle(onMoveDown != nil ? AppTheme.Colors.textSecondary : AppTheme.Colors.surfaceTertiary)
                            }
                            .disabled(onMoveDown == nil)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.xs)

                let sorted = exercises.sorted { $0.order < $1.order }
                ForEach(Array(sorted.enumerated()), id: \.element.id) { index, workoutExercise in
                    SupersetExerciseSection(
                        workoutExercise: workoutExercise,
                        viewModel: viewModel
                    )

                    if index < sorted.count - 1 {
                        Divider()
                            .background(AppTheme.Colors.surfaceTertiary)
                            .padding(.horizontal, AppTheme.Spacing.md)
                    }
                }

                Spacer().frame(height: AppTheme.Spacing.xs)
            }
        }
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
    }
}

// MARK: - Superset Exercise Section (simplified, no outer padding/background)

private struct SupersetExerciseSection: View {
    let workoutExercise: WorkoutExercise
    let viewModel: WorkoutViewModel
    @State private var showingRPEPickerForSet: UUID?

    private var isCardio: Bool {
        workoutExercise.exercise?.isCardio ?? false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            // Header
            HStack {
                Text(workoutExercise.exercise?.name ?? "Unknown Exercise")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.accent)

                if workoutExercise.isInSuperset {
                    Menu {
                        Button("Remove from Superset", role: .destructive) {
                            viewModel.removeFromSuperset(workoutExercise)
                        }
                    } label: {
                        Image(systemName: "link")
                            .font(.caption)
                            .foregroundStyle(AppTheme.Colors.chartPurple)
                    }
                }

                Spacer()

                Button {
                    viewModel.removeExercise(workoutExercise)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)

            if !isCardio {
                strengthInputs
            }
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }

    private var strengthInputs: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
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
            .padding(.horizontal, AppTheme.Spacing.md)

            ForEach(workoutExercise.sortedSets) { exerciseSet in
                VStack(spacing: 0) {
                    SetRowView(
                        setNumber: exerciseSet.order + 1,
                        setType: exerciseSet.setType,
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
                        } : nil,
                        onToggleSetType: { viewModel.toggleSetType(exerciseSet) },
                        rpe: Binding(
                            get: { exerciseSet.rpe },
                            set: { exerciseSet.rpe = $0 }
                        ),
                        onRPETap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingRPEPickerForSet = showingRPEPickerForSet == exerciseSet.id ? nil : exerciseSet.id
                            }
                        }
                    )

                    if showingRPEPickerForSet == exerciseSet.id {
                        RPEPickerView(
                            selectedRPE: Binding(
                                get: { exerciseSet.rpe },
                                set: { exerciseSet.rpe = $0 }
                            ),
                            onDismiss: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingRPEPickerForSet = nil
                                }
                            }
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }

            Button {
                viewModel.addSet(to: workoutExercise)
            } label: {
                Text("+ Add Set")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.accent)
                    .padding(.vertical, AppTheme.Spacing.xs)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }
}
