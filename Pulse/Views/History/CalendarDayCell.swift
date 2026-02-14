import SwiftUI

struct CalendarDayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xxs) {
                Text("\(day.dayNumber)")
                    .font(.system(size: 16, weight: day.isToday ? .bold : .regular))
                    .foregroundStyle(foregroundColor)
                    .frame(width: 36, height: 36)
                    .background(backgroundCircle)

                Circle()
                    .fill(showDot ? AppTheme.Colors.accent : .clear)
                    .frame(width: 5, height: 5)
            }
        }
        .buttonStyle(.borderless)
        .disabled(!day.isCurrentMonth || day.isFuture)
    }

    private var foregroundColor: Color {
        if !day.isCurrentMonth || day.isFuture {
            return AppTheme.Colors.textSecondary.opacity(0.3)
        }
        if isSelected {
            return .white
        }
        return AppTheme.Colors.textPrimary
    }

    @ViewBuilder
    private var backgroundCircle: some View {
        if isSelected && day.isCurrentMonth {
            Circle().fill(AppTheme.Colors.accent)
        } else if day.isToday && day.isCurrentMonth {
            Circle().fill(AppTheme.Colors.accentMuted)
        } else {
            Color.clear
        }
    }

    private var showDot: Bool {
        day.hasWorkout && day.isCurrentMonth && !isSelected
    }
}
