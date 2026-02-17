import SwiftUI

struct SupersetLinkLabel: View {
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            dashedLine
            HStack(spacing: AppTheme.Spacing.xxs) {
                Image(systemName: "link")
                    .font(.caption2.weight(.semibold))
                Text("Link")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(AppTheme.Colors.chartPurple)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xxs)
            .background(AppTheme.Colors.chartPurple.opacity(0.15))
            .clipShape(Capsule())
            dashedLine
        }
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
        .padding(.vertical, AppTheme.Spacing.xxs)
    }

    private var dashedLine: some View {
        Rectangle()
            .fill(AppTheme.Colors.chartPurple.opacity(0.3))
            .frame(height: 1)
    }
}
