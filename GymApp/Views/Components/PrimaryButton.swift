import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.Layout.buttonHeight)
                .background(AppTheme.Colors.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        }
    }
}

#Preview {
    PrimaryButton(title: "Start Workout") {}
        .padding()
        .background(AppTheme.Colors.background)
}
