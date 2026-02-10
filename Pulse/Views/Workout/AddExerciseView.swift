import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExerciseLibraryViewModel?

    let onSelect: (Exercise) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    exerciseList(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .background(AppTheme.Colors.background)
        }
        .onAppear {
            if viewModel == nil {
                let vm = ExerciseLibraryViewModel(modelContext: modelContext)
                vm.seedExercisesIfNeeded()
                viewModel = vm
            }
        }
    }

    @ViewBuilder
    private func exerciseList(viewModel: ExerciseLibraryViewModel) -> some View {
        VStack(spacing: 0) {
            // Category filter tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    categoryTab(title: "All", isSelected: viewModel.selectedMuscleGroup == nil) {
                        viewModel.selectedMuscleGroup = nil
                    }
                    ForEach(MuscleGroup.allCases) { group in
                        categoryTab(
                            title: group.displayName,
                            isSelected: viewModel.selectedMuscleGroup == group
                        ) {
                            viewModel.selectedMuscleGroup = group
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
                .padding(.vertical, AppTheme.Spacing.xs)
            }

            List {
                // Recent exercises section
                if viewModel.searchText.isEmpty && viewModel.selectedMuscleGroup == nil {
                    let recent = viewModel.recentExercises
                    if !recent.isEmpty {
                        Section("Recent") {
                            ForEach(recent) { exercise in
                                exerciseRow(exercise)
                            }
                        }
                    }
                }

                // All exercises
                Section(viewModel.selectedMuscleGroup?.displayName ?? "All Exercises") {
                    ForEach(viewModel.filteredExercises) { exercise in
                        exerciseRow(exercise)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.searchText = $0 }
            ), prompt: "Search exercises")
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        Button {
            onSelect(exercise)
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(exercise.muscleGroup.displayName)
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                Spacer()
            }
        }
    }

    private func categoryTab(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .foregroundStyle(isSelected ? .white : AppTheme.Colors.textSecondary)
                .background(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.surfaceTertiary)
                .clipShape(Capsule())
        }
    }
}
