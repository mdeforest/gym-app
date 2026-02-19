import SwiftUI
import SwiftData

struct TemplateDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let template: WorkoutTemplate
    let onStartWorkout: (WorkoutTemplate) -> Void

    @State private var templateViewModel: TemplateViewModel?
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    exerciseList

                    PrimaryButton(title: "Start Workout", icon: "chevron.right") {
                        onStartWorkout(template)
                        dismiss()
                    }
                    .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
                }
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .navigationTitle(template.name)
            .navigationBarTitleDisplayMode(.inline)
            .background(AppTheme.Colors.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(AppTheme.Colors.accent)
                    }
                }
            }
            .alert("Delete Template?", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    templateViewModel?.deleteTemplate(template)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete \"\(template.name)\".")
            }
            .sheet(isPresented: $showingEditSheet) {
                CreateTemplateView(existingTemplate: template)
                    .environment(\.modelContext, modelContext)
            }
        }
        .onAppear {
            if templateViewModel == nil {
                templateViewModel = TemplateViewModel(modelContext: modelContext)
            }
        }
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            let groups = groupedTemplateExercises()
            ForEach(Array(groups.enumerated()), id: \.offset) { _, group in
                if group.count > 1 {
                    // Superset group
                    HStack(alignment: .top, spacing: 0) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppTheme.Colors.chartPurple)
                            .frame(width: 4)
                            .padding(.vertical, AppTheme.Spacing.sm)

                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("SUPERSET")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.Colors.chartPurple)
                                .kerning(1)
                                .padding(.top, AppTheme.Spacing.sm)

                            ForEach(group.sorted(by: { $0.order < $1.order })) { templateExercise in
                                exerciseRow(templateExercise, inSuperset: true)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                    }
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                    .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
                } else if let single = group.first {
                    exerciseRow(single)
                }
            }
        }
    }

    private func groupedTemplateExercises() -> [[TemplateExercise]] {
        let sorted = template.sortedExercises
        var groups: [[TemplateExercise]] = []
        var currentGroup: [TemplateExercise] = []
        var currentGroupId: UUID?

        for exercise in sorted {
            if let gid = exercise.supersetGroupId {
                if gid == currentGroupId {
                    currentGroup.append(exercise)
                } else {
                    if !currentGroup.isEmpty { groups.append(currentGroup) }
                    currentGroup = [exercise]
                    currentGroupId = gid
                }
            } else {
                if !currentGroup.isEmpty { groups.append(currentGroup) }
                currentGroup = [exercise]
                currentGroupId = nil
            }
        }
        if !currentGroup.isEmpty { groups.append(currentGroup) }
        return groups
    }

    private func exerciseRow(_ templateExercise: TemplateExercise, inSuperset: Bool = false) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(templateExercise.exercise?.name ?? "Deleted Exercise")
                    .font(.headline)
                    .foregroundStyle(templateExercise.exercise != nil
                        ? AppTheme.Colors.accent
                        : AppTheme.Colors.textSecondary)

                if templateExercise.exercise?.isCardio ?? false {
                    cardioSummary(templateExercise)
                } else {
                    strengthSummary(templateExercise)
                }
            }
            Spacer()
        }
        .padding(inSuperset ? AppTheme.Spacing.xs : AppTheme.Layout.cardPadding)
        .background(inSuperset ? Color.clear : AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: inSuperset ? 0 : AppTheme.Layout.cornerRadius))
        .padding(.horizontal, inSuperset ? 0 : AppTheme.Layout.screenEdgePadding)
    }

    private func strengthSummary(_ templateExercise: TemplateExercise) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if templateExercise.hasMigratedSets {
                ForEach(templateExercise.sortedSets) { templateSet in
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(templateSet.setType == .warmup ? "W" : "\(templateSet.order + 1)")
                            .frame(width: 20, alignment: .leading)
                            .foregroundStyle(
                                templateSet.setType == .warmup
                                    ? AppTheme.Colors.warning
                                    : AppTheme.Colors.textSecondary
                            )
                        if templateSet.weight > 0 {
                            Text("\(String(format: "%g", templateSet.weight)) lbs")
                        }
                        if templateSet.reps > 0 {
                            Text("× \(templateSet.reps)")
                        }
                    }
                }
            } else {
                HStack(spacing: AppTheme.Spacing.xs) {
                    if templateExercise.warmupSetCount > 0 {
                        Text("\(templateExercise.warmupSetCount)W + \(templateExercise.setCount) sets")
                    } else {
                        Text("\(templateExercise.setCount) sets")
                    }
                    if templateExercise.defaultWeight > 0 {
                        Text("·")
                        Text("\(String(format: "%g", templateExercise.defaultWeight)) lbs")
                    }
                    if templateExercise.defaultReps > 0 {
                        Text("·")
                        Text("\(templateExercise.defaultReps) reps")
                    }
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(AppTheme.Colors.textSecondary)
    }

    private func cardioSummary(_ templateExercise: TemplateExercise) -> some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            if let seconds = templateExercise.defaultDurationSeconds, seconds > 0 {
                Label("\(seconds / 60) min", systemImage: "clock")
            }
            if let meters = templateExercise.defaultDistanceMeters, meters > 0 {
                Label(String(format: "%g km", meters / 1000), systemImage: "figure.run")
            }
            if templateExercise.defaultDurationSeconds == nil && templateExercise.defaultDistanceMeters == nil {
                Text("Cardio")
            }
        }
        .font(.subheadline)
        .foregroundStyle(AppTheme.Colors.textSecondary)
    }
}
