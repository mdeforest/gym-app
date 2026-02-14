import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HistoryViewModel?
    @Binding var navigateToWorkout: Workout?
    @State private var navigationPath = NavigationPath()
    @State private var selectedSegment: HistorySegment = .workouts

    enum HistorySegment: String, CaseIterable {
        case workouts = "Workouts"
        case progress = "Progress"
    }

    init(navigateToWorkout: Binding<Workout?> = .constant(nil)) {
        _navigateToWorkout = navigateToWorkout
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedSegment) {
                    ForEach(HistorySegment.allCases, id: \.self) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
                .padding(.bottom, AppTheme.Spacing.sm)

                Group {
                    switch selectedSegment {
                    case .workouts:
                        if let viewModel {
                            if viewModel.workouts.isEmpty {
                                emptyState
                            } else {
                                workoutList(viewModel: viewModel)
                            }
                        } else {
                            SwiftUI.ProgressView()
                        }
                    case .progress:
                        ProgressChartsView()
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .navigationTitle("History")
            .navigationDestination(for: Workout.self) { workout in
                if let viewModel {
                    WorkoutDetailView(workout: workout, viewModel: viewModel)
                }
            }
            .background(AppTheme.Colors.background)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HistoryViewModel(modelContext: modelContext)
            }
            viewModel?.fetchWorkouts()
        }
        .onChange(of: navigateToWorkout) { _, workout in
            if let workout {
                viewModel?.fetchWorkouts()
                selectedSegment = .workouts
                navigationPath.append(workout)
                navigateToWorkout = nil
            }
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
                NavigationLink(value: workout) {
                    workoutRow(workout, viewModel: viewModel)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: AppTheme.Spacing.sm,
                    leading: AppTheme.Spacing.xl,
                    bottom: AppTheme.Spacing.sm,
                    trailing: AppTheme.Spacing.xl
                ))
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
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(viewModel.formattedDate(workout.startDate))
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack(spacing: AppTheme.Spacing.md) {
                Label(viewModel.formattedDuration(workout), systemImage: "clock")
                Label("\(workout.exercises.count) exercises", systemImage: "figure.strengthtraining.traditional")
            }
            .font(.subheadline)
            .foregroundStyle(AppTheme.Colors.textSecondary)

            Rectangle()
                .fill(AppTheme.Colors.surfaceTertiary)
                .frame(height: 0.5)
                .padding(.top, AppTheme.Spacing.xs)
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Workout.self, WorkoutExercise.self, ExerciseSet.self, Exercise.self], inMemory: true)
}
