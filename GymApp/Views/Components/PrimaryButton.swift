import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(.headline)

                if let icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Layout.buttonHeight)
            .background(AppTheme.Colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.pillButtonRadius))
        }
    }
}

#Preview {
    PrimaryButton(title: "Start Workout", icon: "chevron.right") {}
        .padding()
        .background(AppTheme.Colors.background)
}
