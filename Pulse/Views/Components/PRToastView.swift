import SwiftUI

struct PRToastView: View {
    let prTypes: [PRType]

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: "trophy.fill")
                .font(.title3)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text("New PR!")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Text(prTypes.map(\.displayName).joined(separator: " + "))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.warning.gradient)
        .clipShape(Capsule())
        .shadow(color: AppTheme.Colors.warning.opacity(0.3), radius: 8, y: 4)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
