import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.Layout.buttonHeight)
                .background(AppTheme.Colors.surfaceTertiary)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        }
    }
}

#Preview {
    SecondaryButton(title: "Add Exercise") {}
        .padding()
        .background(AppTheme.Colors.background)
}
