import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let workout: Workout
    let viewModel: HistoryViewModel

    @State private var isEditing = false
    @State private var showingAddExercise = false
    @State private var showingSaveAsTemplate = false
    @State private var editedStartDate: Date
    @State private var editedEndDate: Date

    init(workout: Workout, viewModel: HistoryViewModel, initiallyEditing: Bool = false) {
        self.workout = workout
        self.viewModel = viewModel
        _isEditing = State(initialValue: initiallyEditing)
        _editedStartDate = State(initialValue: workout.startDate)
        _editedEndDate = State(initialValue: workout.endDate ?? .now)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                if isEditing {
                    dateEditSection
                }

                summaryHeader

                let groups = viewModel.groupedExercises(for: workout)
                ForEach(Array(groups.enumerated()), id: \.offset) { groupIndex, group in
                    VStack(spacing: 0) {
                        if group.count > 1 {
                            // Superset group
                            HStack(alignment: .top, spacing: 0) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppTheme.Colors.chartPurple)
                                    .frame(width: 4)
                                    .padding(.vertical, AppTheme.Spacing.sm)

                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Text("SUPERSET")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(AppTheme.Colors.chartPurple)
                                            .kerning(1)
                                        Spacer()

                                        if isEditing, groups.count > 1 {
                                            HStack(spacing: AppTheme.Spacing.xxs) {
                                                Button {
                                                    withAnimation { viewModel.moveExerciseGroup(from: groupIndex, to: groupIndex - 1, in: workout) }
                                                } label: {
                                                    Image(systemName: "arrow.up.circle.fill")
                                                        .foregroundStyle(groupIndex > 0 ? AppTheme.Colors.textSecondary : AppTheme.Colors.surfaceTertiary)
                                                }
                                                .disabled(groupIndex == 0)

                                                Button {
                                                    withAnimation { viewModel.moveExerciseGroup(from: groupIndex, to: groupIndex + 1, in: workout) }
                                                } label: {
                                                    Image(systemName: "arrow.down.circle.fill")
                                                        .foregroundStyle(groupIndex < groups.count - 1 ? AppTheme.Colors.textSecondary : AppTheme.Colors.surfaceTertiary)
                                                }
                                                .disabled(groupIndex == groups.count - 1)
                                            }
                                            .buttonStyle(.borderless)
                                        }
                                    }
                                    .padding(.horizontal, AppTheme.Spacing.md)
                                    .padding(.top, AppTheme.Spacing.sm)
                                    .padding(.bottom, AppTheme.Spacing.xs)

                                    ForEach(group.sorted(by: { $0.order < $1.order })) { workoutExercise in
                                        if isEditing {
                                            editableExerciseCard(workoutExercise, inSuperset: true)
                                        } else {
                                            readOnlyExerciseCard(workoutExercise, inSuperset: true)
                                        }
                                    }
                                }
                            }
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
                        } else if let single = group.first {
                            if isEditing {
                                editableExerciseCard(
                                    single,
                                    onMoveUp: groupIndex > 0 ? {
                                        withAnimation { viewModel.moveExerciseGroup(from: groupIndex, to: groupIndex - 1, in: workout) }
                                    } : nil,
                                    onMoveDown: groupIndex < groups.count - 1 ? {
                                        withAnimation { viewModel.moveExerciseGroup(from: groupIndex, to: groupIndex + 1, in: workout) }
                                    } : nil
                                )
                            } else {
                                readOnlyExerciseCard(single)
                            }
                        }

                        // Link button between groups (edit mode only)
                        if isEditing, groupIndex < groups.count - 1 {
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

                if isEditing {
                    SecondaryButton(title: "+ Add Exercise") {
                        showingAddExercise = true
                    }
                    .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
                }
            }
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .navigationTitle(viewModel.formattedDate(workout.startDate))
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.Colors.background)
        .toolbar {
            if !isEditing {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSaveAsTemplate = true
                    } label: {
                        Image(systemName: "rectangle.stack.badge.plus")
                    }
                    .foregroundStyle(AppTheme.Colors.accent)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if isEditing {
                        viewModel.updateDates(for: workout, startDate: editedStartDate, endDate: editedEndDate)
                    } else {
                        editedStartDate = workout.startDate
                        editedEndDate = workout.endDate ?? .now
                    }
                    isEditing.toggle()
                } label: {
                    Text(isEditing ? "Done" : "Edit")
                        .fontWeight(isEditing ? .semibold : .regular)
                }
                .foregroundStyle(AppTheme.Colors.accent)
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView { exercise in
                viewModel.addExercise(exercise, to: workout)
            }
            .environment(\.modelContext, modelContext)
        }
        .sheet(isPresented: $showingSaveAsTemplate) {
            CreateTemplateView(fromWorkout: workout)
                .environment(\.modelContext, modelContext)
        }
    }

    // MARK: - Date Editing

    private var dateEditSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            DatePicker("Start", selection: $editedStartDate, in: ...editedEndDate)
                .datePickerStyle(.compact)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            DatePicker("End", selection: $editedEndDate, in: editedStartDate...)
                .datePickerStyle(.compact)
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
        .tint(AppTheme.Colors.accent)
        .padding(.horizontal, AppTheme.Layout.cardPadding)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
    }

    // MARK: - Summary Header

    private var summaryHeader: some View {
        HStack(spacing: AppTheme.Spacing.xl) {
            VStack {
                Text(displayDuration)
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Duration")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            VStack {
                Text("\(workout.exercises.count)")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Exercises")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            VStack {
                let totalSets = workout.exercises.reduce(0) { $0 + $1.sets.filter(\.isCompleted).count }
                Text("\(totalSets)")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Sets")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(.vertical, AppTheme.Spacing.md)
    }

    private var displayDuration: String {
        if isEditing {
            let duration = editedEndDate.timeIntervalSince(editedStartDate)
            let minutes = Int(duration) / 60
            if minutes < 60 { return "\(minutes) min" }
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return viewModel.formattedDuration(workout)
    }

    // MARK: - Read-Only Exercise Card

    private func readOnlyExerciseCard(_ workoutExercise: WorkoutExercise, inSuperset: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(workoutExercise.exercise?.name ?? "Unknown")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.accent)
                .padding(.horizontal, inSuperset ? AppTheme.Spacing.md : AppTheme.Layout.cardPadding)

            if workoutExercise.exercise?.isCardio ?? false {
                readOnlyCardioDetails(workoutExercise)
            } else {
                ForEach(workoutExercise.sortedSets.filter(\.isCompleted)) { exerciseSet in
                    HStack {
                        Text(exerciseSet.setType == .warmup ? "W" : "Set \(exerciseSet.order + 1)")
                            .font(.subheadline)
                            .foregroundStyle(exerciseSet.setType == .warmup ? AppTheme.Colors.warning : AppTheme.Colors.textSecondary)
                            .frame(width: 50, alignment: .leading)
                        Text("\(String(format: "%g", exerciseSet.weight)) lbs")
                            .font(.body)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Text("x")
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                        Text("\(exerciseSet.reps) reps")
                            .font(.body)
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        if let rpe = exerciseSet.rpe {
                            Text("RPE \(rpe.formatted(.number.precision(.fractionLength(0...1))))")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppTheme.Spacing.xs)
                                .padding(.vertical, 3)
                                .background(RPEBadgeView.rpeColor(for: rpe))
                                .clipShape(Capsule())
                        }

                        Spacer()
                    }
                    .padding(.horizontal, inSuperset ? AppTheme.Spacing.md : AppTheme.Layout.cardPadding)
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(inSuperset ? Color.clear : AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: inSuperset ? 0 : AppTheme.Layout.cornerRadius))
        .padding(.horizontal, inSuperset ? 0 : AppTheme.Layout.screenEdgePadding)
    }

    private func readOnlyCardioDetails(_ workoutExercise: WorkoutExercise) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            if let seconds = workoutExercise.durationSeconds, seconds > 0 {
                Label("\(seconds / 60) min", systemImage: "clock")
            }
            if let meters = workoutExercise.distanceMeters, meters > 0 {
                Label(String(format: "%g km", meters / 1000), systemImage: "figure.run")
            }
        }
        .font(.body)
        .foregroundStyle(AppTheme.Colors.textPrimary)
        .padding(.horizontal, AppTheme.Layout.cardPadding)
    }

    // MARK: - Editable Exercise Card

    private func editableExerciseCard(_ workoutExercise: WorkoutExercise, inSuperset: Bool = false, onMoveUp: (() -> Void)? = nil, onMoveDown: (() -> Void)? = nil) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                Text(workoutExercise.exercise?.name ?? "Unknown Exercise")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.accent)

                if inSuperset {
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
                }

                Button {
                    viewModel.removeExercise(workoutExercise)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, inSuperset ? AppTheme.Spacing.md : AppTheme.Layout.screenEdgePadding)

            if workoutExercise.exercise?.isCardio ?? false {
                editableCardioInputs(workoutExercise)
            } else {
                editableStrengthInputs(workoutExercise)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(inSuperset ? Color.clear : AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: inSuperset ? 0 : AppTheme.Layout.cornerRadius))
        .padding(.horizontal, inSuperset ? 0 : AppTheme.Layout.screenEdgePadding)
    }

    // MARK: - Editable Strength Inputs

    private func editableStrengthInputs(_ workoutExercise: WorkoutExercise) -> some View {
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
            }
            .font(.caption)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.md)

            ForEach(workoutExercise.sortedSets) { exerciseSet in
                SetRowView(
                    setNumber: exerciseSet.order + 1,
                    setType: exerciseSet.setType,
                    weight: Binding(
                        get: { String(format: "%g", exerciseSet.weight) },
                        set: { exerciseSet.weight = Double($0) ?? 0 }
                    ),
                    reps: Binding(
                        get: { "\(exerciseSet.reps)" },
                        set: { exerciseSet.reps = Int($0) ?? 0 }
                    ),
                    isCompleted: true,
                    onDelete: workoutExercise.sets.count > 1 ? {
                        viewModel.deleteSet(exerciseSet, from: workoutExercise)
                    } : nil,
                    onToggleSetType: { viewModel.toggleSetType(exerciseSet) }
                )
            }

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

    // MARK: - Editable Cardio Inputs

    private func editableCardioInputs(_ workoutExercise: WorkoutExercise) -> some View {
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
}
