import SwiftUI

struct SetRowView: View {
    let setNumber: Int
    @Binding var weight: String
    @Binding var reps: String
    let isCompleted: Bool
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text("\(setNumber)")
                .font(.callout.weight(.medium))
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .frame(width: 28)

            NumberInputField(label: "lbs", value: $weight)

            Text("x")
                .font(.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            NumberInputField(label: "reps", value: $reps)

            Button(action: onComplete) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)
            }
            .frame(width: AppTheme.Layout.minTouchTarget, height: AppTheme.Layout.minTouchTarget)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}

#Preview {
    SetRowView(
        setNumber: 1,
        weight: .constant("135"),
        reps: .constant("8"),
        isCompleted: false,
        onComplete: {}
    )
    .background(AppTheme.Colors.surface)
}
