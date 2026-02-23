import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExerciseDetailViewModel?

    let exercise: Exercise

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    contentView(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !exercise.isCardio {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            exercise.isFavorite.toggle()
                            try? modelContext.save()
                        } label: {
                            Image(systemName: exercise.isFavorite ? "star.fill" : "star")
                                .foregroundStyle(exercise.isFavorite ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .background(AppTheme.Colors.background)
        }
        .onAppear {
            if viewModel == nil {
                let vm = ExerciseDetailViewModel(modelContext: modelContext)
                vm.fetchHistory(for: exercise)
                vm.fetchRecords(for: exercise)
                viewModel = vm
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func contentView(viewModel: ExerciseDetailViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                headerSection

                if !exercise.isCardio {
                    recordsSection(viewModel: viewModel)
                }

                howToSection

                if !exercise.isCardio {
                    restTimerSection
                }

                historySection(viewModel: viewModel)
            }
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Text(exercise.muscleGroup.displayName)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xxs)
                .foregroundStyle(.white)
                .background(AppTheme.Colors.accent)
                .clipShape(Capsule())

            if exercise.isCustom {
                Text("Custom")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xxs)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .background(AppTheme.Colors.surfaceTertiary)
                    .clipShape(Capsule())
            }

            Spacer()
        }
    }

    // MARK: - Personal Records

    @ViewBuilder
    private func recordsSection(viewModel: ExerciseDetailViewModel) -> some View {
        if let records = viewModel.exerciseRecords, records.bestWeight > 0 {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("Personal Records")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .padding(.horizontal, AppTheme.Layout.cardPadding)

                HStack(spacing: AppTheme.Layout.cardSpacing) {
                    recordItem(
                        icon: "scalemass.fill",
                        label: "Weight",
                        value: "\(String(format: "%g", records.bestWeight)) lbs"
                    )
                    recordItem(
                        icon: "bolt.fill",
                        label: "Est. 1RM",
                        value: "\(Int(records.bestEstimated1RM)) lbs"
                    )
                    recordItem(
                        icon: "chart.bar.fill",
                        label: "Volume",
                        value: "\(Int(records.bestVolume)) lbs"
                    )
                }
                .padding(.horizontal, AppTheme.Layout.cardPadding)
            }
            .padding(.vertical, AppTheme.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        }
    }

    private func recordItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: AppTheme.Spacing.xxs) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppTheme.Colors.warning)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Recent History

    @ViewBuilder
    private func historySection(viewModel: ExerciseDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Recent History")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(.horizontal, AppTheme.Layout.cardPadding)

            if viewModel.historyEntries.isEmpty {
                Text("No workout history yet")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.lg)
                    .padding(.horizontal, AppTheme.Layout.cardPadding)
            } else {
                ForEach(viewModel.historyEntries) { entry in
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(viewModel.formattedDate(entry.workoutDate))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.Colors.accent)
                            .padding(.horizontal, AppTheme.Layout.cardPadding)

                        if exercise.isCardio {
                            cardioRow(entry: entry)
                        } else {
                            ForEach(entry.sets) { set in
                                HStack {
                                    Text("Set \(set.order + 1)")
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                        .frame(width: 50, alignment: .leading)
                                    Text("\(String(format: "%g", set.weight)) lbs")
                                        .font(.body)
                                        .foregroundStyle(AppTheme.Colors.textPrimary)
                                    Text("x")
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                    Text("\(set.reps) reps")
                                        .font(.body)
                                        .foregroundStyle(AppTheme.Colors.textPrimary)

                                    if !set.prTypes.isEmpty {
                                        PRBadgeView(prTypes: set.prTypes, style: .compact)
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, AppTheme.Layout.cardPadding)
                            }
                        }
                    }
                    .padding(.vertical, AppTheme.Spacing.xs)
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }

    @ViewBuilder
    private func cardioRow(entry: ExerciseDetailViewModel.ExerciseHistoryEntry) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            if let seconds = entry.durationSeconds {
                let minutes = seconds / 60
                Label("\(minutes) min", systemImage: "clock")
                    .font(.body)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
            if let meters = entry.distanceMeters {
                let km = meters / 1000
                Label(String(format: "%.1f km", km), systemImage: "figure.run")
                    .font(.body)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
            if entry.durationSeconds == nil && entry.distanceMeters == nil {
                Text("No details recorded")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, AppTheme.Layout.cardPadding)
    }

    // MARK: - Rest Timer Setting

    private var restTimerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Rest Timer")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(.horizontal, AppTheme.Layout.cardPadding)

            Text("Auto-starts when you complete a set")
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Layout.cardPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    restTimePill(label: "Off", seconds: nil)
                    restTimePill(label: "30s", seconds: 30)
                    restTimePill(label: "60s", seconds: 60)
                    restTimePill(label: "90s", seconds: 90)
                    restTimePill(label: "2m", seconds: 120)
                    restTimePill(label: "3m", seconds: 180)
                }
                .padding(.horizontal, AppTheme.Layout.cardPadding)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }

    private func restTimePill(label: String, seconds: Int?) -> some View {
        let isSelected = exercise.defaultRestSeconds == seconds
        return Button {
            exercise.defaultRestSeconds = seconds
            try? modelContext.save()
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

    // MARK: - How To Perform

    @ViewBuilder
    private var howToSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("How to Perform")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(.horizontal, AppTheme.Layout.cardPadding)

            if let info = ExerciseInstructions.info(for: exercise.name) {
                Text(info.description)
                    .font(.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .padding(.horizontal, AppTheme.Layout.cardPadding)

                HStack(spacing: AppTheme.Spacing.xxs) {
                    Text("Muscles:")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(info.primaryMuscles.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.accent)
                }
                .padding(.horizontal, AppTheme.Layout.cardPadding)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    ForEach(Array(info.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: AppTheme.Spacing.xs) {
                            Text("\(index + 1).")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.Colors.accent)
                                .frame(width: 24, alignment: .leading)
                            Text(step)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Layout.cardPadding)
            } else if !exercise.instructions.isEmpty {
                if !exercise.exerciseDescription.isEmpty {
                    Text(exercise.exerciseDescription)
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .padding(.horizontal, AppTheme.Layout.cardPadding)
                }
                Text(exercise.instructions)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .padding(.horizontal, AppTheme.Layout.cardPadding)
            } else {
                Text("No instructions available.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.lg)
                    .padding(.horizontal, AppTheme.Layout.cardPadding)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }
}

#Preview {
    ExerciseDetailView(
        exercise: Exercise(
            name: "Barbell Bench Press",
            muscleGroup: .chest
        )
    )
    .modelContainer(for: [Exercise.self, WorkoutExercise.self, ExerciseSet.self, Workout.self], inMemory: true)
}
