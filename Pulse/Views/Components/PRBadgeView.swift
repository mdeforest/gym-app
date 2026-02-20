import SwiftUI

struct PRBadgeView: View {
    let prTypes: [PRType]
    var style: Style = .compact

    enum Style {
        case compact
        case detailed
    }

    var body: some View {
        switch style {
        case .compact:
            compactBadge
        case .detailed:
            detailedBadges
        }
    }

    private var compactBadge: some View {
        Text("PR")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, AppTheme.Spacing.xs)
            .padding(.vertical, 3)
            .background(AppTheme.Colors.warning)
            .clipShape(Capsule())
    }

    private var detailedBadges: some View {
        HStack(spacing: AppTheme.Spacing.xxs) {
            ForEach(prTypes, id: \.self) { prType in
                HStack(spacing: 2) {
                    Image(systemName: prType.icon)
                        .font(.system(size: 8))
                    Text(prType.displayName)
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, AppTheme.Spacing.xs)
                .padding(.vertical, 3)
                .background(AppTheme.Colors.warning)
                .clipShape(Capsule())
            }
        }
    }
}
