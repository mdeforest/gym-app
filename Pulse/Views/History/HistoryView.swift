import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HistoryViewModel?
    @Binding var navigateToWorkout: Workout?
    @State private var navigationPath = NavigationPath()
    @State private var selectedSegment: HistorySegment = .workouts
    @State private var backdatedWorkout: Workout?

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
                    WorkoutDetailView(
                        workout: workout,
                        viewModel: viewModel,
                        initiallyEditing: workout === backdatedWorkout
                    )
                    .onAppear {
                        if workout === backdatedWorkout {
                            backdatedWorkout = nil
                        }
                    }
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
            Section {
                workoutListHeader(viewModel: viewModel)
            }
            .listRowInsets(EdgeInsets(
                top: AppTheme.Spacing.xs,
                leading: AppTheme.Layout.screenEdgePadding,
                bottom: AppTheme.Spacing.xxs,
                trailing: AppTheme.Layout.screenEdgePadding
            ))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            Section {
                CalendarView(viewModel: viewModel)
            }
            .listRowInsets(EdgeInsets(
                top: AppTheme.Spacing.xxs,
                leading: AppTheme.Layout.screenEdgePadding,
                bottom: AppTheme.Spacing.xs,
                trailing: AppTheme.Layout.screenEdgePadding
            ))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            if viewModel.selectedDate != nil && viewModel.filteredWorkouts.isEmpty {
                Section {
                    addWorkoutPrompt(viewModel: viewModel)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: AppTheme.Spacing.xxxl,
                    leading: AppTheme.Layout.screenEdgePadding,
                    bottom: 0,
                    trailing: AppTheme.Layout.screenEdgePadding
                ))
                .listRowBackground(Color.clear)
            }

            ForEach(viewModel.filteredWorkouts) { workout in
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
                let filtered = viewModel.filteredWorkouts
                for index in indexSet {
                    viewModel.deleteWorkout(filtered[index])
                }
            }

            if viewModel.selectedDate != nil && !viewModel.filteredWorkouts.isEmpty {
                Section {
                    addWorkoutButton(viewModel: viewModel)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: AppTheme.Spacing.md,
                    leading: AppTheme.Layout.screenEdgePadding,
                    bottom: 0,
                    trailing: AppTheme.Layout.screenEdgePadding
                ))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }

    private func workoutListHeader(viewModel: HistoryViewModel) -> some View {
        HStack {
            if let selectedDate = viewModel.selectedDate {
                Text(viewModel.formattedDate(selectedDate))
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Spacer()

                PillButton(title: "Clear", icon: "xmark", style: .primary) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.clearDateSelection()
                    }
                }
            } else {
                Text("All Workouts")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Spacer()
            }
        }
    }

    private func addWorkoutPrompt(viewModel: HistoryViewModel) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("No workouts on this day")
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            addWorkoutButton(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity)
    }

    private func addWorkoutButton(viewModel: HistoryViewModel) -> some View {
        SecondaryButton(title: "+ Add Workout") {
            if let date = viewModel.selectedDate {
                let workout = viewModel.createBackdatedWorkout(on: date)
                backdatedWorkout = workout
                navigationPath.append(workout)
            }
        }
    }

    private func workoutRow(_ workout: Workout, viewModel: HistoryViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(viewModel.formattedDate(workout.startDate))
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack(spacing: AppTheme.Spacing.md) {
                Label {
                    Text(viewModel.formattedDuration(workout))
                } icon: {
                    Image(systemName: "clock")
                        .foregroundStyle(AppTheme.Colors.accent)
                }
                Label {
                    Text("\(workout.exercises.count) exercises")
                } icon: {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundStyle(AppTheme.Colors.accent)
                }
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
