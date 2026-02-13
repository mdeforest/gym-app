import SwiftUI

struct TemplateCardView: View {
    let template: WorkoutTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(template.name)
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text("\(template.exerciseCount) exercises")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                if !template.muscleGroups.isEmpty {
                    HStack(spacing: AppTheme.Spacing.xxs) {
                        ForEach(template.muscleGroups) { group in
                            Text(group.displayName)
                                .font(.caption2.weight(.medium))
                                .padding(.horizontal, AppTheme.Spacing.xs)
                                .padding(.vertical, 2)
                                .foregroundStyle(AppTheme.Colors.accent)
                                .background(AppTheme.Colors.accentMuted)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppTheme.Layout.cardPadding)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        }
    }
}
