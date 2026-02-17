import SwiftUI

enum AppTheme {
    // MARK: - Colors
    enum Colors {
        static let accent = Color(hex: 0xFF6A3D)
        static let accentMuted = Color(hex: 0xFF6A3D, opacity: 0.2)
        static let background = Color(hex: 0x000000)
        static let surface = Color(hex: 0x1C1C1E)
        static let surfaceTertiary = Color(hex: 0x2C2C2E)
        static let featuredSurface = Color(hex: 0xFF6A3D)
        static let featuredGradientEnd = Color(hex: 0xE8552B)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.6)
        static let destructive = Color(hex: 0xFF453A)
        static let success = Color(hex: 0x30D158)
        static let warning = Color(hex: 0xFFB340)
        static let chartActive = Color(hex: 0xFF6A3D)
        static let chartInactive = Color(hex: 0x3D2A1F)
        static let chartPurple = Color(hex: 0x5E5CE6)
        static let supersetAccent = chartPurple
        static let chartBlue = Color(hex: 0x64D2FF)
        static let chartPink = Color(hex: 0xFF6482)
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
        static let xxxl: CGFloat = 40
    }

    // MARK: - Layout
    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let featuredCardRadius: CGFloat = 20
        static let pillButtonRadius: CGFloat = 26
        static let buttonHeight: CGFloat = 52
        static let circularButtonSize: CGFloat = 64
        static let minTouchTarget: CGFloat = 44
        static let cardPadding: CGFloat = 20
        static let cardSpacing: CGFloat = 12
        static let screenEdgePadding: CGFloat = 20
        static let statCardMinHeight: CGFloat = 100
        static let statGridSpacing: CGFloat = 12
        static let sectionSpacing: CGFloat = 32
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
