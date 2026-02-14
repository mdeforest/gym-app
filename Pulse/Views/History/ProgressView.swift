import SwiftUI

struct ProgressChartsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ProgressViewModel?

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.totalWorkouts == 0 && viewModel.totalWorkoutsThisMonth == 0 {
                    emptyState
                } else {
                    chartsContent(viewModel: viewModel)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ProgressViewModel(modelContext: modelContext)
            }
            viewModel?.fetchData()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "chart.bar.xaxis",
                title: "No Data Yet",
                message: "Complete a few workouts to see your progress charts."
            )
            Spacer()
        }
    }

    // MARK: - Charts Content

    private func chartsContent(viewModel: ProgressViewModel) -> some View {
        ScrollView {
            VStack(spacing: AppTheme.Layout.sectionSpacing) {
                timeRangeFilter(viewModel: viewModel)
                summaryStats(viewModel: viewModel)
                WorkoutFrequencyChart(data: viewModel.weeklyFrequencyData)
                MuscleGroupChart(data: viewModel.muscleGroupData)
                strengthSection(viewModel: viewModel)
            }
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Time Range Filter

    private func timeRangeFilter(viewModel: ProgressViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.xs) {
                ForEach(TimeRange.allCases) { range in
                    PillButton(
                        title: range.rawValue,
                        style: viewModel.selectedTimeRange == range ? .primary : .secondary
                    ) {
                        viewModel.updateTimeRange(range)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
        }
    }

    // MARK: - Summary Stats

    private func summaryStats(viewModel: ProgressViewModel) -> some View {
        StatGrid {
            FeaturedStatCard(
                value: "\(viewModel.totalWorkoutsThisMonth)",
                label: "This Month",
                icon: "flame.fill"
            )
            StatCard(
                value: viewModel.formattedVolume(viewModel.totalVolume),
                label: "Lbs Lifted",
                icon: "scalemass"
            )
            StatCard(
                value: "\(viewModel.currentStreak)",
                label: "Day Streak",
                icon: "trophy.fill"
            )
            StatCard(
                value: "\(viewModel.personalRecordCount)",
                label: "Records",
                icon: "star.fill"
            )
        }
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
    }

    // MARK: - Strength Progression Section

    private func strengthSection(viewModel: ProgressViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            if !viewModel.availableExercises.isEmpty {
                exercisePicker(viewModel: viewModel)
            }

            StrengthProgressionChart(
                data: viewModel.strengthProgressionData,
                exerciseName: viewModel.selectedExercise?.name ?? "Exercise"
            )
        }
    }

    private func exercisePicker(viewModel: ProgressViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.xs) {
                ForEach(viewModel.availableExercises) { exercise in
                    let isSelected = viewModel.selectedExercise?.persistentModelID == exercise.persistentModelID
                    PillButton(
                        title: exercise.name,
                        style: isSelected ? .primary : .secondary
                    ) {
                        viewModel.updateSelectedExercise(exercise)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
        }
    }
}

#Preview {
    ProgressChartsView()
        .modelContainer(for: [Workout.self, WorkoutExercise.self, ExerciseSet.self, Exercise.self], inMemory: true)
        .background(AppTheme.Colors.background)
}
