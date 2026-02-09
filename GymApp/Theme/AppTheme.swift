import SwiftUI

enum AppTheme {
    // MARK: - Colors
    enum Colors {
        static let accent = Color(hex: 0x30D158)
        static let background = Color(hex: 0x000000)
        static let surface = Color(hex: 0x1C1C1E)
        static let surfaceTertiary = Color(hex: 0x2C2C2E)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.6)
        static let destructive = Color(hex: 0xFF453A)
        static let success = Color(hex: 0x30D158)
        static let warning = Color(hex: 0xFF9F0A)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Layout
    enum Layout {
        static let cornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 50
        static let minTouchTarget: CGFloat = 44
        static let cardPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 8
        static let screenEdgePadding: CGFloat = 16
    }
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
