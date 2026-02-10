import SwiftUI

struct FeaturedStatCard: View {
    let value: String
    let label: String
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            if let icon {
                HStack {
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            Spacer()

            Text(value)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: AppTheme.Layout.statCardMinHeight)
        .padding(AppTheme.Layout.cardPadding)
        .background(
            LinearGradient(
                colors: [AppTheme.Colors.featuredSurface, AppTheme.Colors.featuredGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.featuredCardRadius))
    }
}

#Preview {
    FeaturedStatCard(value: "12,450", label: "LBS LIFTED", icon: "flame.fill")
        .frame(width: 200)
        .padding(AppTheme.Layout.screenEdgePadding)
        .background(AppTheme.Colors.background)
}
