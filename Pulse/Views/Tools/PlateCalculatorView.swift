import SwiftUI

struct PlateCalculatorView: View {
    @AppStorage("weightUnit") private var weightUnit: String = "lbs"
    @State private var targetWeight: String = ""
    @State private var selectedBarWeight: Double = 45
    @State private var useCustomBar: Bool = false
    @State private var customBarWeight: String = ""

    private var barWeightOptions: [Double] {
        weightUnit == "kg" ? [20, 15] : [45, 35, 25]
    }

    private var effectiveBarWeight: Double {
        if useCustomBar {
            return Double(customBarWeight) ?? 0
        }
        return selectedBarWeight
    }

    private var breakdown: PlateCalculatorService.PlateBreakdown? {
        guard let target = Double(targetWeight), target > effectiveBarWeight, effectiveBarWeight > 0 else { return nil }
        return PlateCalculatorService.calculatePlates(
            targetWeight: target,
            barWeight: effectiveBarWeight,
            unit: weightUnit
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                inputSection
                if let breakdown, !breakdown.plates.isEmpty {
                    resultsSection(breakdown)
                } else if let target = Double(targetWeight), target > 0, target <= effectiveBarWeight {
                    hintCard("Target must exceed bar weight")
                }
            }
            .padding(AppTheme.Layout.screenEdgePadding)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Plate Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: weightUnit) { _, newUnit in
            selectedBarWeight = newUnit == "kg" ? 20 : 45
            useCustomBar = false
            customBarWeight = ""
            targetWeight = ""
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Target weight
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("TARGET WEIGHT")
                    .font(.system(size: 13, weight: .medium))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                HStack(spacing: AppTheme.Spacing.sm) {
                    NumberInputField(label: weightUnit, value: $targetWeight)

                    Text(weightUnit)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }

            // Bar weight
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("BAR WEIGHT")
                    .font(.system(size: 13, weight: .medium))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                HStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(barWeightOptions, id: \.self) { weight in
                        barWeightPill(weight)
                    }
                    customBarPill
                }

                if useCustomBar {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        NumberInputField(label: weightUnit, value: $customBarWeight)
                        Text(weightUnit)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
            }
        }
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }

    private func barWeightPill(_ weight: Double) -> some View {
        let isSelected = !useCustomBar && selectedBarWeight == weight
        let label = weight.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(weight)) \(weightUnit)"
            : "\(String(format: "%g", weight)) \(weightUnit)"

        return Button {
            useCustomBar = false
            selectedBarWeight = weight
        } label: {
            Text(label)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .foregroundStyle(isSelected ? .white : AppTheme.Colors.textSecondary)
                .background(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.surfaceTertiary)
                .clipShape(Capsule())
        }
    }

    private var customBarPill: some View {
        Button {
            useCustomBar = true
        } label: {
            Text("Custom")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .foregroundStyle(useCustomBar ? .white : AppTheme.Colors.textSecondary)
                .background(useCustomBar ? AppTheme.Colors.accent : AppTheme.Colors.surfaceTertiary)
                .clipShape(Capsule())
        }
    }

    // MARK: - Results

    private func resultsSection(_ breakdown: PlateCalculatorService.PlateBreakdown) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Per-side label
            Text("PER SIDE")
                .font(.system(size: 13, weight: .medium))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            // Bar visualization
            HStack(alignment: .center, spacing: 3) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppTheme.Colors.textSecondary.opacity(0.4))
                    .frame(width: 40, height: 12)

                ForEach(flatPlates(breakdown), id: \.self) { weight in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(plateColor(weight))
                        .frame(width: plateWidth(weight), height: plateHeight(weight))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, AppTheme.Spacing.sm)

            // Plate breakdown list
            ForEach(breakdown.plates, id: \.weight) { plate in
                HStack(spacing: AppTheme.Spacing.sm) {
                    plateChip(plate.weight)

                    Text("\(plate.count) ×")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.accent)

                    Text("\(formatWeight(plate.weight)) \(weightUnit)")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Spacer()
                }
                .padding(.vertical, AppTheme.Spacing.xxs)
            }

            if breakdown.remainder > 0.01 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(AppTheme.Colors.warning)
                    Text("\(formatWeight(breakdown.remainder)) \(weightUnit) cannot be loaded")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.warning)
                }
                .padding(.top, AppTheme.Spacing.xs)
            }
        }
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }

    // MARK: - Helpers

    private func flatPlates(_ breakdown: PlateCalculatorService.PlateBreakdown) -> [Double] {
        var result: [Double] = []
        for plate in breakdown.plates {
            for _ in 0..<plate.count {
                result.append(plate.weight)
            }
        }
        return result
    }

    private func plateHeight(_ weight: Double) -> CGFloat {
        let maxPlate = weightUnit == "kg" ? 25.0 : 45.0
        let minHeight: CGFloat = 40
        let maxHeight: CGFloat = 100
        let ratio = weight / maxPlate
        return minHeight + (maxHeight - minHeight) * ratio
    }

    private func plateWidth(_ weight: Double) -> CGFloat {
        let maxPlate = weightUnit == "kg" ? 25.0 : 45.0
        let minWidth: CGFloat = 14
        let maxWidth: CGFloat = 24
        let ratio = weight / maxPlate
        return minWidth + (maxWidth - minWidth) * ratio
    }

    private func plateColor(_ weight: Double) -> Color {
        let plateSizes = weightUnit == "kg"
            ? PlateCalculatorService.plateSizesKg
            : PlateCalculatorService.plateSizesLbs
        guard let index = plateSizes.firstIndex(of: weight) else {
            return AppTheme.Colors.accent
        }
        let colors: [Color] = [
            AppTheme.Colors.accent,
            AppTheme.Colors.success,
            AppTheme.Colors.chartPurple,
            AppTheme.Colors.chartBlue,
            AppTheme.Colors.chartPink,
            AppTheme.Colors.warning,
            AppTheme.Colors.textSecondary,
        ]
        return colors[index % colors.count]
    }

    private func plateChip(_ weight: Double) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(plateColor(weight))
            .frame(width: 16, height: 28)
    }

    private func hintCard(_ message: String) -> some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(AppTheme.Layout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }

    private func formatWeight(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(value))"
            : String(format: "%g", value)
    }
}

#Preview {
    NavigationStack {
        PlateCalculatorView()
    }
}
