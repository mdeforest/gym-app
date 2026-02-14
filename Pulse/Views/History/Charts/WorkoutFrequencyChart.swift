import SwiftUI
import Charts

struct WorkoutFrequencyChart: View {
    let data: [WeeklyFrequency]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Workout Frequency")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            if data.isEmpty {
                noDataView
            } else {
                chart
            }
        }
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
    }

    private var chart: some View {
        Chart(data) { entry in
            BarMark(
                x: .value("Week", entry.weekStartDate, unit: .weekOfYear),
                y: .value("Workouts", entry.count)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [AppTheme.Colors.chartActive, AppTheme.Colors.featuredGradientEnd],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear, count: maxXAxisStride)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(AppTheme.Colors.surfaceTertiary)
                AxisValueLabel()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .chartYScale(domain: 0 ... maxY)
        .frame(height: 200)
    }

    private var noDataView: some View {
        Text("No workouts in this period")
            .font(.subheadline)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 120)
    }

    private var maxY: Int {
        max((data.map(\.count).max() ?? 1) + 1, 2)
    }

    private var maxXAxisStride: Int {
        let count = data.count
        if count <= 6 { return 1 }
        if count <= 14 { return 2 }
        return 4
    }
}
