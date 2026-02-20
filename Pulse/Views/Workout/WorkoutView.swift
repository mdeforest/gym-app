import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WorkoutViewModel?
    @State private var contentVisible = false
    @State private var showingSettings = false
    @AppStorage("userName") private var userName: String = ""

    var splashFinished: Bool = true
    @Binding var pendingTemplate: WorkoutTemplate?
    var onWorkoutFinished: ((Workout) -> Void)?
    var onBrowseTemplates: (() -> Void)?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel, viewModel.activeWorkout != nil {
                    ActiveWorkoutView(viewModel: viewModel, onWorkoutFinished: onWorkoutFinished)
                } else {
                    startWorkoutView
                }
            }
            .navigationTitle("Workout")
            .background(AppTheme.Colors.background)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .overlay(alignment: .top) {
            if viewModel?.showingPRToast == true {
                PRToastView(prTypes: viewModel?.recentPRTypes ?? [])
                    .padding(.top, 54)
            }
        }
        .overlay(alignment: .topTrailing) {
            if viewModel?.activeWorkout == nil {
                Button {
                    showingSettings = true
                } label: {
                    profileAvatar
                }
                .buttonStyle(.plain)
                .padding(.trailing, AppTheme.Layout.screenEdgePadding)
                .padding(.top, 54)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = WorkoutViewModel(modelContext: modelContext)
            }
        }
        .onChange(of: splashFinished) { _, finished in
            if finished {
                withAnimation(.easeOut(duration: 0.6)) {
                    contentVisible = true
                }
            }
        }
        .onChange(of: pendingTemplate) { _, template in
            if let template {
                viewModel?.startWorkout(from: template)
                pendingTemplate = nil
            }
        }
    }

    private var profileAvatar: some View {
        let initials = userName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()

        return ZStack {
            Circle()
                .fill(AppTheme.Colors.surfaceTertiary)
                .frame(width: 40, height: 40)

            if initials.isEmpty {
                Image(systemName: "person.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            } else {
                Text(initials.uppercased())
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
        }
    }

    private var startWorkoutView: some View {
        VStack {
            Spacer()
            VStack(spacing: AppTheme.Spacing.xxl) {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)

                    Text("Ready to Train?")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .opacity(contentVisible ? 1 : 0)
                }

                VStack(spacing: AppTheme.Spacing.sm) {
                    PrimaryButton(title: "Start Empty Workout") {
                        viewModel?.startWorkout()
                    }

                    SecondaryButton(title: "Browse Templates") {
                        onBrowseTemplates?()
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xxl)
                .opacity(contentVisible ? 1 : 0)
            }
            .padding(AppTheme.Layout.screenEdgePadding)
            Spacer()
        }
    }
}

#Preview {
    WorkoutView(pendingTemplate: .constant(nil))
        .modelContainer(for: [
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            Exercise.self,
            WorkoutTemplate.self,
            TemplateExercise.self,
            TemplateSet.self,
        ], inMemory: true)
}
