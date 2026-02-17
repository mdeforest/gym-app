import SwiftUI

struct RPEBadgeView: View {
    let rpe: Double?
    let onTap: () -> Void

    private var displayText: String {
        guard let rpe else { return "RPE" }
        return rpe.formatted(.number.precision(.fractionLength(0...1)))
    }

    private var badgeColor: Color {
        guard let rpe else { return AppTheme.Colors.surfaceTertiary }
        return Self.rpeColor(for: rpe)
    }

    private var textColor: Color {
        rpe == nil ? AppTheme.Colors.textSecondary : .white
    }

    var body: some View {
        Button(action: onTap) {
            Text(displayText)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(textColor)
                .padding(.horizontal, AppTheme.Spacing.xs)
                .padding(.vertical, 3)
                .background(badgeColor.opacity(rpe == nil ? 0.5 : 1.0))
                .clipShape(Capsule())
        }
        .buttonStyle(.borderless)
    }

    static func rpeColor(for value: Double) -> Color {
        switch value {
        case ...7.0:    return AppTheme.Colors.success
        case 7.5...8.5: return AppTheme.Colors.warning
        default:         return AppTheme.Colors.destructive
        }
    }
}
