import SwiftUI
import Charts

struct StrengthProgressionChart: View {
    let data: [StrengthDataPoint]
    let exerciseName: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Strength Progression")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Estimated 1RM")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            if data.count < 2 {
                insufficientDataView
            } else {
                chart
            }
        }
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
    }

    private var yDomain: ClosedRange<Double> {
        let values = data.map(\.estimatedOneRepMax)
        let minVal = values.min() ?? 0
        let maxVal = values.max() ?? 0
        let padding = max((maxVal - minVal) * 0.15, 10)
        return max(0, minVal - padding)...(maxVal + padding)
    }

    private var chart: some View {
        Chart(data) { point in
            AreaMark(
                x: .value("Date", point.date),
                y: .value("Est. 1RM", point.estimatedOneRepMax)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        AppTheme.Colors.chartActive.opacity(0.3),
                        AppTheme.Colors.chartActive.opacity(0.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.monotone)

            LineMark(
                x: .value("Date", point.date),
                y: .value("Est. 1RM", point.estimatedOneRepMax)
            )
            .foregroundStyle(AppTheme.Colors.chartActive)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
            .interpolationMethod(.monotone)

            PointMark(
                x: .value("Date", point.date),
                y: .value("Est. 1RM", point.estimatedOneRepMax)
            )
            .foregroundStyle(rpeColor(for: point.averageRPE))
            .symbolSize(30)
        }
        .chartXAxis {
            AxisMarks { _ in
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
        .chartYScale(domain: yDomain)
        .frame(height: 200)
    }

    private func rpeColor(for rpe: Double?) -> Color {
        guard let rpe else { return AppTheme.Colors.chartActive }
        return RPEBadgeView.rpeColor(for: rpe)
    }

    private var insufficientDataView: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            if data.count == 1 {
                Text("\(Int(data[0].estimatedOneRepMax)) lbs")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text("Est. 1RM for \(exerciseName)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                Text("Complete more sessions to see trends")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            } else {
                Text("No data for \(exerciseName)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}
