import SwiftUI

struct NumberInputField: View {
    let label: String
    @Binding var value: String

    var body: some View {
        TextField(label, text: $value)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .font(.callout.weight(.medium))
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .padding(.horizontal, AppTheme.Spacing.xs)
            .frame(height: AppTheme.Layout.minTouchTarget)
            .background(AppTheme.Colors.surfaceTertiary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }
}

#Preview {
    NumberInputField(label: "lbs", value: .constant("135"))
        .frame(width: 80)
        .padding()
        .background(AppTheme.Colors.background)
}
