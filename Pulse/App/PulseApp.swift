import SwiftUI
import SwiftData

@main
struct PulseApp: App {
    @State private var showSplash = true
    @State private var splashFinished = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView(splashFinished: splashFinished)
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashView {
                        withAnimation(.spring(response: 0.9, dampingFraction: 0.85)) {
                            showSplash = false
                            splashFinished = true
                        }
                    }
                }
            }
        }
        .modelContainer(for: [
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            Exercise.self,
            WorkoutTemplate.self,
            TemplateExercise.self,
            TemplateSet.self,
        ])
    }
}
