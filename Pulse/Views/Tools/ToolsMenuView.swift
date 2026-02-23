import SwiftUI

struct ToolsMenuView: View {
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Layout.statGridSpacing),
        GridItem(.flexible(), spacing: AppTheme.Layout.statGridSpacing)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: AppTheme.Layout.statGridSpacing) {
                    NavigationLink(destination: PlateCalculatorView()) {
                        ToolCard(
                            icon: "scalemass.fill",
                            title: "Plate Calculator",
                            subtitle: "Load the bar"
                        )
                    }

                    NavigationLink(destination: OneRMCalculatorView()) {
                        ToolCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "1RM Calculator",
                            subtitle: "Estimate your max"
                        )
                    }

                    NavigationLink(destination: RPEChartView()) {
                        ToolCard(
                            icon: "chart.bar.fill",
                            title: "RPE Chart",
                            subtitle: "Training intensity"
                        )
                    }

                    NavigationLink(destination: StopwatchView()) {
                        ToolCard(
                            icon: "stopwatch.fill",
                            title: "Stopwatch",
                            subtitle: "Track time"
                        )
                    }
                }
                .padding(AppTheme.Layout.screenEdgePadding)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
        }
    }
}

// MARK: - Tool Card

private struct ToolCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.accent)

            Spacer()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Layout.cardPadding)
        .frame(minHeight: 130)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }
}

#Preview {
    ToolsMenuView()
}
