import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var viewModel: WorkoutViewModel
    var onWorkoutFinished: ((Workout) -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: AppTheme.Spacing.md) {
                    if viewModel.activeWorkout != nil {
                        let groups = viewModel.groupedExercises()
                        ForEach(Array(groups.enumerated()), id: \.offset) { groupIndex, group in
                            VStack(spacing: 0) {
                                if group.count > 1 {
                                    SupersetGroupView(
                                        exercises: group,
                                        viewModel: viewModel,
                                        onMoveUp: groupIndex > 0 ? {
                                            withAnimation { viewModel.moveExerciseGroup(from: groupIndex, to: groupIndex - 1) }
                                        } : nil,
                                        onMoveDown: groupIndex < groups.count - 1 ? {
                                            withAnimation { viewModel.moveExerciseGroup(from: groupIndex, to: groupIndex + 1) }
                                        } : nil
                                    )
                                } else if let single = group.first {
                                    WorkoutExerciseSection(
                                        workoutExercise: single,
                                        viewModel: viewModel,
                                        onMoveUp: groupIndex > 0 ? {
                                            withAnimation { viewModel.moveExerciseGroup(from: groupIndex, to: groupIndex - 1) }
                                        } : nil,
                                        onMoveDown: groupIndex < groups.count - 1 ? {
                                            withAnimation { viewModel.moveExerciseGroup(from: groupIndex, to: groupIndex + 1) }
                                        } : nil
                                    )
                                }

                                // Link button between groups
                                if groupIndex < groups.count - 1 {
                                    Button {
                                        if let lastOfCurrent = group.last,
                                           let firstOfNext = groups[groupIndex + 1].first {
                                            viewModel.linkAsSuperset(lastOfCurrent, firstOfNext)
                                        }
                                    } label: {
                                        SupersetLinkLabel()
                                    }
                                }
                            }
                        }
                    }

                    SecondaryButton(title: "+ Add Exercise") {
                        viewModel.showingAddExercise = true
                    }
                    .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
                }
                .padding(.vertical, AppTheme.Spacing.md)
                .padding(.bottom, viewModel.restTimerActive ? 60 : 0)
            }

            if viewModel.restTimerActive {
                RestTimerView(viewModel: viewModel)
            }
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
    var onMoveUp: (() -> Void)?
    var onMoveDown: (() -> Void)?
    @State private var showingRestPicker = false
    @State private var showingRPEPickerForSet: UUID?

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

                if !isCardio, let restSeconds = workoutExercise.exercise?.defaultRestSeconds {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingRestPicker.toggle()
                        }
                    } label: {
                        Text(formatRestTime(restSeconds))
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, AppTheme.Spacing.xs)
                            .padding(.vertical, 2)
                            .foregroundStyle(AppTheme.Colors.accent)
                            .background(AppTheme.Colors.accentMuted)
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                if onMoveUp != nil || onMoveDown != nil {
                    HStack(spacing: AppTheme.Spacing.xxs) {
                        Button {
                            withAnimation { onMoveUp?() }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundStyle(onMoveUp != nil ? AppTheme.Colors.textSecondary : AppTheme.Colors.surfaceTertiary)
                        }
                        .disabled(onMoveUp == nil)

                        Button {
                            withAnimation { onMoveDown?() }
                        } label: {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundStyle(onMoveDown != nil ? AppTheme.Colors.textSecondary : AppTheme.Colors.surfaceTertiary)
                        }
                        .disabled(onMoveDown == nil)
                    }
                }

                Button {
                    viewModel.removeExercise(workoutExercise)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)

            if showingRestPicker, !isCardio {
                restTimePickerRow
            }

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

    // MARK: - Rest Time Picker

    private var restTimePickerRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.xs) {
                restTimePill(label: "Off", seconds: nil)
                restTimePill(label: "30s", seconds: 30)
                restTimePill(label: "60s", seconds: 60)
                restTimePill(label: "90s", seconds: 90)
                restTimePill(label: "2m", seconds: 120)
                restTimePill(label: "3m", seconds: 180)
            }
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func restTimePill(label: String, seconds: Int?) -> some View {
        let isSelected = workoutExercise.exercise?.defaultRestSeconds == seconds
        return Button {
            workoutExercise.exercise?.defaultRestSeconds = seconds
        } label: {
            Text(label)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .foregroundStyle(isSelected ? .white : AppTheme.Colors.textSecondary)
                .background(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.surfaceTertiary)
                .clipShape(Capsule())
        }
    }

    private func formatRestTime(_ seconds: Int) -> String {
        if seconds >= 60 {
            let min = seconds / 60
            let sec = seconds % 60
            return sec > 0 ? "\(min)m \(sec)s" : "\(min)m"
        }
        return "\(seconds)s"
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
                        rpe: exerciseSet.setType == .warmup ? nil : Binding(
                            get: { exerciseSet.rpe },
                            set: { exerciseSet.rpe = $0 }
                        ),
                        onRPETap: exerciseSet.setType == .warmup ? nil : {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingRPEPickerForSet = showingRPEPickerForSet == exerciseSet.id ? nil : exerciseSet.id
                            }
                        }
                    )

                    if showingRPEPickerForSet == exerciseSet.id, exerciseSet.setType != .warmup {
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
