import SwiftUI

struct SplashView: View {
    var onComplete: () -> Void

    @State private var logoOpacity: Double = 0
    @State private var transitioning = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
                .opacity(transitioning ? 0 : 1)

            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: transitioning ? 180 : 320)
                .offset(y: transitioning ? -60 : 0)
                .opacity(logoOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                logoOpacity = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.spring(response: 0.9, dampingFraction: 0.85)) {
                    transitioning = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        logoOpacity = 0
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    SplashView(onComplete: {})
}
