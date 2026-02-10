import SwiftUI

struct CircularProgressRing: View {
    let progress: Double
    var size: CGFloat = 160
    var lineWidth: CGFloat = 6

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.Colors.surfaceTertiary, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: 1 - min(max(progress, 0), 1))
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.Colors.accent, AppTheme.Colors.featuredGradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        CircularProgressRing(progress: 0.65, size: 160, lineWidth: 6)
        CircularProgressRing(progress: 0.3, size: 28, lineWidth: 3)
    }
    .padding()
    .background(AppTheme.Colors.background)
}
