import SwiftUI

struct DestructiveButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.Layout.buttonHeight)
                .background(AppTheme.Colors.destructive)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        }
    }
}

#Preview {
    DestructiveButton(title: "Delete Workout") {}
        .padding()
        .background(AppTheme.Colors.background)
}
