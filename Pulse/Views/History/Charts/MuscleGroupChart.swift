import SwiftUI
import Charts

struct MuscleGroupChart: View {
    let data: [MuscleGroupSplit]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Muscle Groups")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            if data.isEmpty {
                noDataView
            } else {
                chartWithLegend
            }
        }
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
    }

    private var chartWithLegend: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Chart(data) { entry in
                SectorMark(
                    angle: .value("Count", entry.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(colorFor(entry.muscleGroup))
                .cornerRadius(4)
            }
            .frame(height: 200)

            legend
        }
    }

    private var legend: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: AppTheme.Spacing.xs) {
            ForEach(data) { entry in
                HStack(spacing: AppTheme.Spacing.xs) {
                    Circle()
                        .fill(colorFor(entry.muscleGroup))
                        .frame(width: 10, height: 10)

                    Text(entry.muscleGroup.displayName)
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    Spacer()

                    Text("\(Int(entry.percentage))%")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
            }
        }
    }

    private var noDataView: some View {
        Text("No exercises in this period")
            .font(.subheadline)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 120)
    }

    private func colorFor(_ group: MuscleGroup) -> Color {
        switch group {
        case .chest: AppTheme.Colors.accent
        case .back: AppTheme.Colors.success
        case .shoulders: AppTheme.Colors.warning
        case .arms: AppTheme.Colors.chartPurple
        case .legs: AppTheme.Colors.chartBlue
        case .core: AppTheme.Colors.chartPink
        case .cardio: AppTheme.Colors.textSecondary
        }
    }
}
