import SwiftUI

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(AppTheme.Colors.surfaceTertiary)
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.accent, AppTheme.Colors.featuredGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * min(max(progress, 0), 1), height: 6)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        ProgressBar(progress: 0.0)
        ProgressBar(progress: 0.33)
        ProgressBar(progress: 0.75)
        ProgressBar(progress: 1.0)
    }
    .padding(AppTheme.Layout.screenEdgePadding)
    .background(AppTheme.Colors.background)
}
