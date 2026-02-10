import SwiftUI

struct PillButton: View {
    let title: String
    var icon: String? = nil
    var style: Style = .primary
    let action: () -> Void

    enum Style {
        case primary
        case secondary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xxs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                }

                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, AppTheme.Spacing.md)
            .frame(height: 36)
            .background(style == .primary ? AppTheme.Colors.accent : AppTheme.Colors.surfaceTertiary)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    HStack(spacing: AppTheme.Spacing.sm) {
        PillButton(title: "Add Set", icon: "plus") {}
        PillButton(title: "View All", style: .secondary) {}
    }
    .padding()
    .background(AppTheme.Colors.background)
}
