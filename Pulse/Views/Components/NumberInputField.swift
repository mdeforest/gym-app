import SwiftUI

struct NumberInputField: View {
    let label: String
    @Binding var value: String

    @State private var localText = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(label, text: $localText)
            .focused($isFocused)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .font(.callout.weight(.medium))
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .padding(.horizontal, AppTheme.Spacing.xs)
            .frame(height: AppTheme.Layout.minTouchTarget)
            .background(AppTheme.Colors.surfaceTertiary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Spacing.sm))
            .onAppear { localText = value }
            .onChange(of: localText) { _, newValue in value = newValue }
            .onChange(of: value) { _, newValue in
                if !isFocused { localText = newValue }
            }
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { notification in
                (notification.object as? UITextField)?.selectAll(nil)
            }
    }
}

#Preview {
    NumberInputField(label: "lbs", value: .constant("135"))
        .frame(width: 80)
        .padding()
        .background(AppTheme.Colors.background)
}
