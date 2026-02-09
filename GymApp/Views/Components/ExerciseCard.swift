import SwiftUI

struct ExerciseCard: View {
    let name: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
            Text(name)
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }
}

#Preview {
    ExerciseCard(name: "Bench Press", subtitle: "Last: 185 lbs x 8 reps")
        .padding()
        .background(AppTheme.Colors.background)
}
