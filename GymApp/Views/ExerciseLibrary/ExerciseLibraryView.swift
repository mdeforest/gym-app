import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ExerciseLibraryViewModel?
    @State private var showingAddExercise = false
    @State private var selectedExercise: Exercise?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    exerciseList(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddExercise = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                if let viewModel {
                    AddCustomExerciseView(viewModel: viewModel)
                }
            }
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailView(exercise: exercise)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
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
            // Muscle group filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    filterChip(title: "All", isSelected: viewModel.selectedMuscleGroup == nil) {
                        viewModel.selectedMuscleGroup = nil
                    }
                    ForEach(MuscleGroup.allCases) { group in
                        filterChip(
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
                ForEach(viewModel.filteredExercises) { exercise in
                    Button {
                        selectedExercise = exercise
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
                            if exercise.isCustom {
                                Text("Custom")
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.Colors.accent)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let exercise = viewModel.filteredExercises[index]
                        viewModel.deleteExercise(exercise)
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

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
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

#Preview {
    ExerciseLibraryView()
        .modelContainer(for: [Exercise.self], inMemory: true)
}
