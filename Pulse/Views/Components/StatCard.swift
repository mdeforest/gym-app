import SwiftUI

struct StatCard: View {
    let value: String
    let label: String
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            if let icon {
                HStack {
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }

            Spacer()

            Text(value)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: AppTheme.Layout.statCardMinHeight)
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }
}

#Preview {
    HStack(spacing: AppTheme.Layout.statGridSpacing) {
        StatCard(value: "45", label: "MIN", icon: "clock")
        StatCard(value: "6", label: "EXERCISES")
    }
    .padding(AppTheme.Layout.screenEdgePadding)
    .background(AppTheme.Colors.background)
}
