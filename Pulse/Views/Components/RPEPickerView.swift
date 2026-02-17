import SwiftUI

struct RPEPickerView: View {
    @Binding var selectedRPE: Double?
    let onDismiss: () -> Void

    private let rpeValues: [Double] = [6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10]

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("Rate of Perceived Exertion")
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.Colors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    ForEach(rpeValues, id: \.self) { value in
                        rpePill(
                            label: value.formatted(.number.precision(.fractionLength(0...1))),
                            value: value
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xs)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surfaceTertiary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func rpePill(label: String, value: Double) -> some View {
        let isSelected = selectedRPE == value
        let color = RPEBadgeView.rpeColor(for: value)
        return Button {
            selectedRPE = value
            onDismiss()
        } label: {
            Text(label)
                .font(.caption.weight(.medium))
                .frame(minWidth: 32)
                .padding(.vertical, AppTheme.Spacing.xs)
                .padding(.horizontal, AppTheme.Spacing.xxs)
                .foregroundStyle(.white)
                .background(color.opacity(isSelected ? 1.0 : 0.4))
                .clipShape(Capsule())
                .overlay(
                    isSelected ? Capsule().stroke(Color.white, lineWidth: 2) : nil
                )
        }
        .buttonStyle(.borderless)
    }
}
