import SwiftUI

struct CircularActionButton: View {
    let icon: String
    var style: Style = .primary
    let action: () -> Void

    enum Style {
        case primary
        case secondary
        case destructive
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(
                    width: AppTheme.Layout.circularButtonSize,
                    height: AppTheme.Layout.circularButtonSize
                )
                .background(backgroundColor)
                .clipShape(Circle())
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: AppTheme.Colors.accent
        case .secondary: AppTheme.Colors.surfaceTertiary
        case .destructive: AppTheme.Colors.destructive
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        CircularActionButton(icon: "minus", style: .secondary) {}
        CircularActionButton(icon: "plus", style: .primary) {}
        CircularActionButton(icon: "xmark", style: .destructive) {}
    }
    .padding()
    .background(AppTheme.Colors.background)
}
