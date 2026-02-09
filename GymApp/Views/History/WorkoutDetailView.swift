import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    let viewModel: HistoryViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                // Workout summary header
                HStack(spacing: AppTheme.Spacing.xl) {
                    VStack {
                        Text(viewModel.formattedDuration(workout))
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
                        let totalSets = workout.exercises.reduce(0) { $0 + $1.sets.count }
                        Text("\(totalSets)")
                            .font(.title2.bold())
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Text("Sets")
                            .font(.caption)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.vertical, AppTheme.Spacing.md)

                // Exercise details
                ForEach(workout.exercises.sorted(by: { $0.order < $1.order })) { workoutExercise in
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(workoutExercise.exercise?.name ?? "Unknown")
                            .font(.headline)
                            .foregroundStyle(AppTheme.Colors.accent)
                            .padding(.horizontal, AppTheme.Layout.cardPadding)

                        ForEach(workoutExercise.sortedSets) { exerciseSet in
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
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                    .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
                }
            }
        }
        .navigationTitle(viewModel.formattedDate(workout.startDate))
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.Colors.background)
    }
}
