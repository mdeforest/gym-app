import SwiftUI

struct RestTimerView: View {
    @Bindable var viewModel: WorkoutViewModel

    var body: some View {
        VStack {
            Spacer()

            if viewModel.restTimerExpanded {
                expandedTimerView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                collapsedTimerPill
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.35, bounce: 0.2), value: viewModel.restTimerActive)
        .animation(.spring(duration: 0.3, bounce: 0.15), value: viewModel.restTimerExpanded)
    }

    // MARK: - Collapsed Pill

    private var collapsedTimerPill: some View {
        Button {
            viewModel.toggleRestTimerExpanded()
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                CircularProgressRing(
                    progress: viewModel.restTimerProgress,
                    size: 28,
                    lineWidth: 3
                )

                if viewModel.restTimerCompleted {
                    Text("Rest Complete")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.success)
                } else {
                    Text(viewModel.restTimerDisplayText)
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .monospacedDigit()
                }

                if let name = viewModel.restTimerExerciseName {
                    Text(name)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    viewModel.skipRestTimer()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(
                            width: AppTheme.Layout.minTouchTarget,
                            height: AppTheme.Layout.minTouchTarget
                        )
                }
            }
            .padding(.horizontal, AppTheme.Layout.cardPadding)
            .frame(height: AppTheme.Layout.buttonHeight)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.pillButtonRadius))
            .shadow(color: .black.opacity(0.3), radius: 8, y: -2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
        .padding(.bottom, AppTheme.Spacing.xs)
    }

    // MARK: - Expanded View

    private var expandedTimerView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Drag indicator
            Capsule()
                .fill(AppTheme.Colors.textSecondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, AppTheme.Spacing.xs)
                .onTapGesture {
                    viewModel.toggleRestTimerExpanded()
                }

            // Large circular progress with countdown inside
            ZStack {
                CircularProgressRing(
                    progress: viewModel.restTimerProgress,
                    size: 160,
                    lineWidth: 6
                )

                VStack(spacing: AppTheme.Spacing.xxs) {
                    if viewModel.restTimerCompleted {
                        Text("Done")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.success)
                    } else {
                        Text(viewModel.restTimerDisplayText)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .monospacedDigit()
                    }

                    Text("REST")
                        .font(.system(size: 13, weight: .medium))
                        .textCase(.uppercase)
                        .kerning(1)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }

            // Exercise name context
            if let name = viewModel.restTimerExerciseName {
                Text(name)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            // Control buttons
            HStack(spacing: AppTheme.Spacing.lg) {
                CircularActionButton(icon: "minus", style: .secondary) {
                    viewModel.adjustRestTimer(by: -30)
                }
                .accessibilityLabel("Subtract 30 seconds")

                CircularActionButton(icon: "plus", style: .secondary) {
                    viewModel.adjustRestTimer(by: 30)
                }
                .accessibilityLabel("Add 30 seconds")

                CircularActionButton(icon: "xmark", style: .destructive) {
                    viewModel.skipRestTimer()
                }
                .accessibilityLabel("Skip rest timer")
            }

            // Labels below buttons
            HStack(spacing: AppTheme.Spacing.lg) {
                Text("-30s")
                    .frame(width: AppTheme.Layout.circularButtonSize)
                Text("+30s")
                    .frame(width: AppTheme.Layout.circularButtonSize)
                Text("Skip")
                    .frame(width: AppTheme.Layout.circularButtonSize)
            }
            .font(.caption)
            .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
        .padding(.bottom, AppTheme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.surface)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: AppTheme.Layout.featuredCardRadius,
                topTrailingRadius: AppTheme.Layout.featuredCardRadius
            )
        )
        .shadow(color: .black.opacity(0.4), radius: 12, y: -4)
    }
}
