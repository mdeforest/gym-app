import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Text(title)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text(message)
                .font(.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            if let buttonTitle, let action {
                PrimaryButton(title: buttonTitle, action: action)
                    .padding(.horizontal, AppTheme.Spacing.xxl)
            }
        }
        .padding(AppTheme.Layout.screenEdgePadding)
    }
}

#Preview {
    EmptyStateView(
        icon: "figure.strengthtraining.traditional",
        title: "No Workouts Yet",
        message: "Start your first workout to begin tracking your progress.",
        buttonTitle: "Start Workout"
    ) {}
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(AppTheme.Colors.background)
}
