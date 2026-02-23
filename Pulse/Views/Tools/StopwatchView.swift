import SwiftUI

struct StopwatchView: View {
    @State private var elapsedTime: TimeInterval = 0
    @State private var startDate: Date?
    @State private var isRunning = false
    @State private var lapTimes: [TimeInterval] = []
    @State private var timer: Timer?
    @State private var now: Date = Date()

    private var displayTime: TimeInterval {
        if isRunning, let start = startDate {
            return elapsedTime + now.timeIntervalSince(start)
        }
        return elapsedTime
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Time display
                Text(formattedTime(displayTime))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .contentTransition(.numericText())
                    .padding(.bottom, AppTheme.Spacing.xxl)

                // Controls
                HStack(spacing: AppTheme.Spacing.lg) {
                    // Left button: Lap (running) or Reset (stopped with time)
                    if isRunning {
                        controlButton(title: "Lap", icon: "flag.fill", style: .secondary) {
                            recordLap()
                        }
                    } else if elapsedTime > 0 {
                        controlButton(title: "Reset", icon: "arrow.counterclockwise", style: .secondary) {
                            reset()
                        }
                    } else {
                        // Placeholder to keep layout stable
                        controlButton(title: "Reset", icon: "arrow.counterclockwise", style: .disabled) {}
                            .disabled(true)
                    }

                    // Right button: Start / Pause
                    if isRunning {
                        controlButton(title: "Pause", icon: "pause.fill", style: .warning) {
                            pause()
                        }
                    } else {
                        controlButton(title: "Start", icon: "play.fill", style: .primary) {
                            start()
                        }
                    }
                }

                Spacer()

                // Lap list
                if !lapTimes.isEmpty {
                    lapList
                }
            }
            .padding(AppTheme.Layout.screenEdgePadding)
        }
        .navigationTitle("Stopwatch")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Controls

    private enum ButtonStyle {
        case primary, secondary, warning, disabled
    }

    private func controlButton(title: String, icon: String, style: ButtonStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .frame(width: 80, height: 80)
            .foregroundStyle(foregroundColor(style))
            .background(backgroundColor(style))
            .clipShape(Circle())
        }
    }

    private func foregroundColor(_ style: ButtonStyle) -> Color {
        switch style {
        case .primary: return .white
        case .secondary: return AppTheme.Colors.textPrimary
        case .warning: return .white
        case .disabled: return AppTheme.Colors.textSecondary.opacity(0.4)
        }
    }

    private func backgroundColor(_ style: ButtonStyle) -> Color {
        switch style {
        case .primary: return AppTheme.Colors.accent
        case .secondary: return AppTheme.Colors.surfaceTertiary
        case .warning: return AppTheme.Colors.warning
        case .disabled: return AppTheme.Colors.surfaceTertiary.opacity(0.4)
        }
    }

    // MARK: - Lap List

    private var lapList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("LAPS")
                .font(.system(size: 13, weight: .medium))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .padding(.bottom, AppTheme.Spacing.sm)

            ForEach(Array(lapTimes.enumerated().reversed()), id: \.offset) { index, cumulative in
                let split = index == 0 ? cumulative : cumulative - lapTimes[index - 1]
                HStack {
                    Text("Lap \(index + 1)")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Spacer()

                    Text(formattedTime(split))
                        .font(.callout.weight(.medium).monospacedDigit())
                        .foregroundStyle(AppTheme.Colors.accent)

                    Text(formattedTime(cumulative))
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(width: 90, alignment: .trailing)
                }
                .padding(.vertical, AppTheme.Spacing.xs)

                if index != 0 {
                    Divider()
                        .overlay(AppTheme.Colors.surfaceTertiary)
                }
            }
        }
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }

    // MARK: - Actions

    private func start() {
        startDate = Date()
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            DispatchQueue.main.async {
                now = Date()
            }
        }
    }

    private func pause() {
        if let start = startDate {
            elapsedTime += Date().timeIntervalSince(start)
        }
        startDate = nil
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func reset() {
        elapsedTime = 0
        startDate = nil
        isRunning = false
        lapTimes = []
        timer?.invalidate()
        timer = nil
    }

    private func recordLap() {
        lapTimes.append(displayTime)
    }

    // MARK: - Formatting

    private func formattedTime(_ interval: TimeInterval) -> String {
        let totalCentiseconds = Int(interval * 100)
        let minutes = totalCentiseconds / 6000
        let seconds = (totalCentiseconds % 6000) / 100
        let centiseconds = totalCentiseconds % 100
        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }
}

#Preview {
    NavigationStack {
        StopwatchView()
    }
}
