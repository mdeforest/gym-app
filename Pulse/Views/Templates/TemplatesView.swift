import SwiftUI
import SwiftData

struct TemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var templateViewModel: TemplateViewModel?
    @State private var showingCreateTemplate = false
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var templateToEdit: WorkoutTemplate?
    @State private var templateToDelete: WorkoutTemplate?

    var onStartWorkout: ((WorkoutTemplate) -> Void)?

    var body: some View {
        NavigationStack {
            Group {
                if let templateViewModel {
                    if templateViewModel.templates.isEmpty {
                        emptyState
                    } else {
                        templateList(templateViewModel)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Templates")
            .background(AppTheme.Colors.background)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showingCreateTemplate = true
            } label: {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.surfaceTertiary)
                        .frame(width: 40, height: 40)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
            .buttonStyle(.plain)
            .padding(.trailing, AppTheme.Layout.screenEdgePadding)
            .padding(.top, 54)
        }
        .onAppear {
            if templateViewModel == nil {
                templateViewModel = TemplateViewModel(modelContext: modelContext)
            } else {
                templateViewModel?.fetchTemplates()
            }
        }
        .sheet(isPresented: $showingCreateTemplate) {
            CreateTemplateView()
                .environment(\.modelContext, modelContext)
                .onDisappear { templateViewModel?.fetchTemplates() }
        }
        .sheet(item: $selectedTemplate) { template in
            TemplateDetailView(template: template) { selected in
                onStartWorkout?(selected)
            }
            .environment(\.modelContext, modelContext)
            .onDisappear { templateViewModel?.fetchTemplates() }
        }
        .sheet(item: $templateToEdit) { template in
            CreateTemplateView(existingTemplate: template)
                .environment(\.modelContext, modelContext)
                .onDisappear { templateViewModel?.fetchTemplates() }
        }
        .alert("Delete Template?", isPresented: Binding(
            get: { templateToDelete != nil },
            set: { if !$0 { templateToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let template = templateToDelete {
                    templateViewModel?.deleteTemplate(template)
                }
                templateToDelete = nil
            }
            Button("Cancel", role: .cancel) { templateToDelete = nil }
        } message: {
            if let template = templateToDelete {
                Text("This will permanently delete \"\(template.name)\".")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "doc.on.doc",
                title: "No Templates Yet",
                message: "Save your favorite routines for quick access.",
                buttonTitle: "Create Template"
            ) {
                showingCreateTemplate = true
            }
            Spacer()
        }
    }

    // MARK: - Template List

    private func templateList(_ templateVM: TemplateViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.sm) {
                ForEach(templateVM.templates) { template in
                    TemplateCardView(template: template) {
                        selectedTemplate = template
                    }
                    .contextMenu {
                        Button {
                            selectedTemplate = template
                        } label: {
                            Label("View Details", systemImage: "eye")
                        }
                        Button {
                            onStartWorkout?(template)
                        } label: {
                            Label("Start Workout", systemImage: "play.fill")
                        }
                        Button {
                            templateToEdit = template
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            templateToDelete = template
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }
}

#Preview {
    TemplatesView()
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
