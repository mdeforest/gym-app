import SwiftUI

struct StatGrid<Content: View>: View {
    @ViewBuilder let content: Content

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Layout.statGridSpacing),
        GridItem(.flexible(), spacing: AppTheme.Layout.statGridSpacing),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppTheme.Layout.statGridSpacing) {
            content
        }
    }
}

#Preview {
    StatGrid {
        FeaturedStatCard(value: "12,450", label: "LBS LIFTED", icon: "flame.fill")
        StatCard(value: "45", label: "MIN", icon: "clock")
        StatCard(value: "6", label: "EXERCISES")
        StatCard(value: "24", label: "SETS")
    }
    .padding(AppTheme.Layout.screenEdgePadding)
    .background(AppTheme.Colors.background)
}
