import SwiftUI
import SwiftData

struct CreateTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var templateName: String
    @State private var templateViewModel: TemplateViewModel?
    @State private var showingAddExercise = false

    let existingTemplate: WorkoutTemplate?
    let fromWorkout: Workout?

    init(existingTemplate: WorkoutTemplate? = nil, fromWorkout: Workout? = nil) {
        self.existingTemplate = existingTemplate
        self.fromWorkout = fromWorkout
        _templateName = State(initialValue: existingTemplate?.name ?? "")
    }

    private var template: WorkoutTemplate? {
        existingTemplate ?? createdTemplate
    }

    @State private var createdTemplate: WorkoutTemplate?

    private var canSave: Bool {
        !templateName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    nameField
                    exerciseList
                    addExerciseButton
                }
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .navigationTitle(existingTemplate != nil ? "Edit Template" : "New Template")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppTheme.Colors.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.accent)
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView { exercise in
                    if let template, let templateViewModel {
                        templateViewModel.addExercise(exercise, to: template)
                    }
                }
                .environment(\.modelContext, modelContext)
            }
        }
        .onAppear {
            if templateViewModel == nil {
                templateViewModel = TemplateViewModel(modelContext: modelContext)
            }
            if existingTemplate == nil && createdTemplate == nil {
                initializeTemplate()
            }
        }
    }

    // MARK: - Name Field

    private var nameField: some View {
        TextField("Template name", text: $templateName)
            .font(.headline)
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .padding(AppTheme.Layout.cardPadding)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            if let template {
                ForEach(template.sortedExercises) { templateExercise in
                    templateExerciseRow(templateExercise)
                }
            }
        }
    }

    private func templateExerciseRow(_ templateExercise: TemplateExercise) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Header: name + remove button
            HStack {
                Text(templateExercise.exercise?.name ?? "Deleted Exercise")
                    .font(.headline)
                    .foregroundStyle(templateExercise.exercise != nil
                        ? AppTheme.Colors.accent
                        : AppTheme.Colors.textSecondary)

                Spacer()

                Button {
                    if let template, let templateViewModel {
                        templateViewModel.removeExercise(templateExercise, from: template)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }

            if templateExercise.exercise?.isCardio ?? false {
                cardioInputs(templateExercise)
            } else {
                strengthInputs(templateExercise)
            }
        }
        .padding(AppTheme.Layout.cardPadding)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
        .onAppear {
            if let templateViewModel, !(templateExercise.exercise?.isCardio ?? false) {
                templateViewModel.migrateToSetsIfNeeded(templateExercise)
            }
        }
    }

    // MARK: - Strength Inputs

    private func strengthInputs(_ templateExercise: TemplateExercise) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
            // Column headers
            HStack(spacing: AppTheme.Spacing.sm) {
                Text("SET")
                    .frame(width: 28)
                Text("LBS")
                    .frame(maxWidth: .infinity)
                Text("")
                    .frame(width: 14)
                Text("REPS")
                    .frame(maxWidth: .infinity)
            }
            .font(.caption)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.md)

            // Per-set rows
            ForEach(templateExercise.sortedSets) { templateSet in
                templateSetRow(templateSet, in: templateExercise)
            }

            // Add set button
            Button {
                templateViewModel?.addTemplateSet(to: templateExercise)
            } label: {
                Text("+ Add Set")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.accent)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .padding(.horizontal, AppTheme.Spacing.md)
            }
            .buttonStyle(.borderless)
        }
    }

    private func templateSetRow(_ templateSet: TemplateSet, in templateExercise: TemplateExercise) -> some View {
        SetRowView(
            setNumber: templateSet.order + 1,
            setType: templateSet.setType,
            weight: Binding(
                get: { templateSet.weight > 0 ? String(format: "%g", templateSet.weight) : "" },
                set: { templateSet.weight = Double($0) ?? 0 }
            ),
            reps: Binding(
                get: { templateSet.reps > 0 ? "\(templateSet.reps)" : "" },
                set: { templateSet.reps = Int($0) ?? 0 }
            ),
            isCompleted: false,
            onDelete: templateExercise.sets.count > 1 ? {
                templateViewModel?.deleteTemplateSet(templateSet, from: templateExercise)
            } : nil,
            onToggleSetType: {
                templateViewModel?.toggleTemplateSetType(templateSet)
            }
        )
    }

    // MARK: - Cardio Inputs

    private func cardioInputs(_ templateExercise: TemplateExercise) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "clock")
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .frame(width: 20)

            NumberInputField(
                label: "min",
                value: Binding(
                    get: {
                        if let seconds = templateExercise.defaultDurationSeconds, seconds > 0 {
                            return "\(seconds / 60)"
                        }
                        return ""
                    },
                    set: {
                        if let minutes = Int($0) {
                            templateExercise.defaultDurationSeconds = minutes * 60
                        } else {
                            templateExercise.defaultDurationSeconds = nil
                        }
                    }
                )
            )

            Text("min")
                .font(.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Spacer().frame(width: AppTheme.Spacing.xs)

            Image(systemName: "figure.run")
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .frame(width: 20)

            NumberInputField(
                label: "km",
                value: Binding(
                    get: {
                        if let meters = templateExercise.defaultDistanceMeters, meters > 0 {
                            return String(format: "%g", meters / 1000)
                        }
                        return ""
                    },
                    set: {
                        if let km = Double($0) {
                            templateExercise.defaultDistanceMeters = km * 1000
                        } else {
                            templateExercise.defaultDistanceMeters = nil
                        }
                    }
                )
            )

            Text("km")
                .font(.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    // MARK: - Add Exercise

    private var addExerciseButton: some View {
        SecondaryButton(title: "+ Add Exercise") {
            showingAddExercise = true
        }
        .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
    }

    // MARK: - Actions

    private func initializeTemplate() {
        guard let templateViewModel else { return }

        if let fromWorkout {
            createdTemplate = templateViewModel.createTemplate(from: fromWorkout, name: "")
        } else {
            createdTemplate = templateViewModel.createTemplate(name: "")
        }
    }

    private func saveTemplate() {
        guard let template, let templateViewModel else { return }
        templateViewModel.renameTemplate(template, to: templateName.trimmingCharacters(in: .whitespaces))
    }
}
