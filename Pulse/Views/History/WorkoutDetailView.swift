import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    let viewModel: HistoryViewModel

    @State private var isEditing = false
    @State private var showingAddExercise = false
    @State private var editedStartDate: Date
    @State private var editedEndDate: Date

    init(workout: Workout, viewModel: HistoryViewModel) {
        self.workout = workout
        self.viewModel = viewModel
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

                ForEach(workout.exercises.sorted(by: { $0.order < $1.order })) { workoutExercise in
                    if isEditing {
                        editableExerciseCard(workoutExercise)
                    } else {
                        readOnlyExerciseCard(workoutExercise)
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        viewModel.updateDates(for: workout, startDate: editedStartDate, endDate: editedEndDate)
                    } else {
                        editedStartDate = workout.startDate
                        editedEndDate = workout.endDate ?? .now
                    }
                    isEditing.toggle()
                }
                .fontWeight(isEditing ? .semibold : .regular)
                .foregroundStyle(AppTheme.Colors.accent)
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView { exercise in
                viewModel.addExercise(exercise, to: workout)
            }
        }
    }

    // MARK: - Date Editing

    private var dateEditSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            DatePicker("Start", selection: $editedStartDate)
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

    private func readOnlyExerciseCard(_ workoutExercise: WorkoutExercise) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(workoutExercise.exercise?.name ?? "Unknown")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.accent)
                .padding(.horizontal, AppTheme.Layout.cardPadding)

            if workoutExercise.exercise?.isCardio ?? false {
                readOnlyCardioDetails(workoutExercise)
            } else {
                ForEach(workoutExercise.sortedSets.filter(\.isCompleted)) { exerciseSet in
                    HStack {
                        Text("Set \(exerciseSet.order + 1)")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                            .frame(width: 50, alignment: .leading)
                        Text("\(String(format: "%g", exerciseSet.weight)) lbs")
                            .font(.body)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Text("x")
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                        Text("\(exerciseSet.reps) reps")
                            .font(.body)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.Layout.cardPadding)
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
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

    private func editableExerciseCard(_ workoutExercise: WorkoutExercise) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
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

            if workoutExercise.exercise?.isCardio ?? false {
                editableCardioInputs(workoutExercise)
            } else {
                editableStrengthInputs(workoutExercise)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
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
                    } : nil
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
