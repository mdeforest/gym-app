import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HistoryViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.workouts.isEmpty {
                        emptyState
                    } else {
                        workoutList(viewModel: viewModel)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("History")
            .background(AppTheme.Colors.background)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HistoryViewModel(modelContext: modelContext)
            }
            viewModel?.fetchWorkouts()
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "clock",
                title: "No Workouts Yet",
                message: "Your completed workouts will appear here."
            )
            Spacer()
        }
    }

    @ViewBuilder
    private func workoutList(viewModel: HistoryViewModel) -> some View {
        List {
            ForEach(viewModel.workouts) { workout in
                NavigationLink(destination: WorkoutDetailView(workout: workout, viewModel: viewModel)) {
                    workoutRow(workout, viewModel: viewModel)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    viewModel.deleteWorkout(viewModel.workouts[index])
                }
            }
        }
        .listStyle(.plain)
    }

    private func workoutRow(_ workout: Workout, viewModel: HistoryViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
            Text(viewModel.formattedDate(workout.startDate))
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack(spacing: AppTheme.Spacing.md) {
                Label(viewModel.formattedDuration(workout), systemImage: "clock")
                Label("\(workout.exercises.count) exercises", systemImage: "figure.strengthtraining.traditional")
            }
            .font(.subheadline)
            .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(.vertical, AppTheme.Spacing.xxs)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Workout.self, WorkoutExercise.self, ExerciseSet.self, Exercise.self], inMemory: true)
}
