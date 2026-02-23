import SwiftUI

struct RPEChartView: View {
    @AppStorage("weightUnit") private var weightUnit: String = "lbs"
    @State private var oneRMInput: String = ""

    private var oneRM: Double? {
        guard let value = Double(oneRMInput), value > 0 else { return nil }
        return value
    }

    private var rpeData: [(rpe: String, description: String, rir: String, percent: Double)] {
        [
            ("10",   "Maximum",    "0 RIR",   1.00),
            ("9.5",  "Near max",   "0–1 RIR", 0.97),
            ("9",    "Very hard",  "1 RIR",   0.92),
            ("8.5",  "Hard+",      "1–2 RIR", 0.89),
            ("8",    "Hard",       "2 RIR",   0.86),
            ("7.5",  "Moderate+",  "2–3 RIR", 0.83),
            ("7",    "Moderate",   "3 RIR",   0.80),
            ("6.5",  "Light+",     "3–4 RIR", 0.77),
            ("6",    "Light",      "4+ RIR",  0.74),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // 1RM input
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("YOUR 1RM")
                        .font(.system(size: 13, weight: .medium))
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    HStack(spacing: AppTheme.Spacing.sm) {
                        NumberInputField(label: weightUnit, value: $oneRMInput)
                        Text(weightUnit)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(AppTheme.Layout.cardPadding)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))

                rpeTable
            }
            .padding(AppTheme.Layout.screenEdgePadding)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("RPE Chart")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - RPE Table

    private var rpeTable: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("RPE")
                    .frame(width: 44, alignment: .leading)
                Text("%")
                    .frame(width: 56, alignment: .trailing)
                if oneRM != nil {
                    Text("Weight")
                        .frame(width: 70, alignment: .trailing)
                }
                Spacer()
                Text("RIR")
                    .frame(width: 60, alignment: .trailing)
            }
            .font(.system(size: 13, weight: .medium))
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .padding(.bottom, AppTheme.Spacing.sm)

            ForEach(rpeData, id: \.rpe) { row in
                HStack {
                    rpeLabel(row.rpe)
                        .frame(width: 44, alignment: .leading)

                    Text("\(Int(row.percent * 100))%")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .frame(width: 56, alignment: .trailing)

                    if let max = oneRM {
                        Text(formatWeight(max * row.percent))
                            .font(.headline)
                            .foregroundStyle(AppTheme.Colors.accent)
                            .frame(width: 70, alignment: .trailing)
                    }

                    Spacer()

                    Text(row.rir)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(width: 60, alignment: .trailing)
                }
                .padding(.vertical, AppTheme.Spacing.sm)

                if row.rpe != rpeData.last?.rpe {
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
        let rounded = (value * 2).rounded() / 2
        return rounded.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(rounded))"
            : String(format: "%.1f", rounded)
    }
}

#Preview {
    NavigationStack {
        RPEChartView()
    }
}
