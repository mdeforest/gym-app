import SwiftUI

struct OneRMCalculatorView: View {
    @AppStorage("weightUnit") private var weightUnit: String = "lbs"
    @State private var weightInput: String = ""
    @State private var repsInput: String = ""

    private var estimated1RM: Double? {
        guard let weight = Double(weightInput), weight > 0,
              let reps = Int(repsInput), reps > 0 else { return nil }
        return PersonalRecordService.estimatedOneRepMax(weight: weight, reps: reps)
    }

    private var percentageRows: [(percent: Int, rpe: String)] {
        [
            (100, "10"),
            (97, "9.5"),
            (92, "9"),
            (89, "8.5"),
            (86, "8"),
            (83, "7.5"),
            (80, "7"),
            (77, "6.5"),
            (74, "6"),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                inputSection

                if let max = estimated1RM {
                    FeaturedStatCard(
                        value: formatWeight(max),
                        label: "ESTIMATED 1RM (\(weightUnit))",
                        icon: "trophy.fill"
                    )

                    percentageTable(max)
                }
            }
            .padding(AppTheme.Layout.screenEdgePadding)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("1RM Calculator")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Input

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("ENTER YOUR LIFT")
                .font(.system(size: 13, weight: .medium))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.sm) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text("Weight")
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    HStack(spacing: AppTheme.Spacing.xs) {
                        NumberInputField(label: weightUnit, value: $weightInput)
                        Text(weightUnit)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    NumberInputField(label: "reps", value: $repsInput)
                }
            }

            if let reps = Int(repsInput), reps > 12 {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    Image(systemName: "info.circle")
                    Text("Accuracy decreases beyond 12 reps")
                }
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.warning)
            }
        }
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }

    // MARK: - Percentage Table

    private func percentageTable(_ max: Double) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ESTIMATED RPE")
                .font(.system(size: 13, weight: .medium))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .padding(.bottom, AppTheme.Spacing.sm)

            ForEach(percentageRows, id: \.percent) { row in
                HStack {
                    rpeLabel(row.rpe)

                    Text("\(row.percent)%")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(width: 40, alignment: .trailing)

                    Spacer()

                    Text(formatWeight(max * Double(row.percent) / 100))
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text(weightUnit)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .padding(.vertical, AppTheme.Spacing.sm)

                if row.percent != percentageRows.last?.percent {
                    Divider()
                        .overlay(AppTheme.Colors.surfaceTertiary)
                }
            }
        }
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }

    private func rpeLabel(_ value: String) -> some View {
        let numericValue = Double(value) ?? 0
        let color = RPEBadgeView.rpeColor(for: numericValue)
        return Text(value)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .frame(minWidth: 32)
            .padding(.vertical, 3)
            .background(color)
            .clipShape(Capsule())
    }

    private func formatWeight(_ value: Double) -> String {
        let rounded = (value * 2).rounded() / 2 // Round to nearest 0.5
        return rounded.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(rounded))"
            : String(format: "%.1f", rounded)
    }
}

#Preview {
    NavigationStack {
        OneRMCalculatorView()
    }
}
