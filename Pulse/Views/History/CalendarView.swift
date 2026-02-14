import SwiftUI

struct CalendarView: View {
    let viewModel: HistoryViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            monthHeader
            weekdayHeader
            calendarGrid
        }
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button { viewModel.goToPreviousMonth() } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.accent)
                    .frame(width: AppTheme.Layout.minTouchTarget, height: AppTheme.Layout.minTouchTarget)
            }
            .buttonStyle(.borderless)

            Spacer()

            Text(viewModel.formattedMonthYear(viewModel.displayedMonth))
                .font(.title3.bold())
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Spacer()

            Button { viewModel.goToNextMonth() } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(viewModel.canGoToNextMonth ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary.opacity(0.3))
                    .frame(width: AppTheme.Layout.minTouchTarget, height: AppTheme.Layout.minTouchTarget)
            }
            .buttonStyle(.borderless)
            .disabled(!viewModel.canGoToNextMonth)
        }
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let days = viewModel.daysInMonth()

        return LazyVGrid(columns: columns, spacing: AppTheme.Spacing.xs) {
            ForEach(days) { day in
                CalendarDayCell(
                    day: day,
                    isSelected: isSelected(day),
                    action: { viewModel.selectDate(day.date) }
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.displayedMonth)
    }

    private func isSelected(_ day: CalendarDay) -> Bool {
        guard let selected = viewModel.selectedDate else { return false }
        return Calendar.current.isDate(day.date, inSameDayAs: selected)
    }
}
