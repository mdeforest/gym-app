import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name) private var allExercises: [Exercise]
    @State private var viewModel: ExerciseLibraryViewModel?
    @State private var showingAddExercise = false
    @State private var selectedExercise: Exercise?
    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var selectedEquipment: Equipment?
    @State private var showingFilters = false
    @State private var showFavoritesOnly = false
    @AppStorage("availableEquipment") private var availableEquipmentRaw: String = ""

    private var availableEquipment: Set<Equipment> {
        guard !availableEquipmentRaw.isEmpty else { return [] }
        return Set(availableEquipmentRaw.split(separator: ",").compactMap { Equipment(rawValue: String($0)) })
    }

    private var activeFilterCount: Int {
        (selectedMuscleGroup != nil ? 1 : 0) + (selectedEquipment != nil ? 1 : 0)
    }

    private var totalActiveFilterCount: Int {
        activeFilterCount + (showFavoritesOnly ? 1 : 0)
    }

    private var isAnyFilterActive: Bool {
        showFavoritesOnly || selectedMuscleGroup != nil || selectedEquipment != nil
    }

    private var filteredExercises: [Exercise] {
        var result = allExercises

        if !availableEquipment.isEmpty {
            result = result.filter { exercise in
                guard let eq = exercise.equipment else { return true }
                return eq == .other || availableEquipment.contains(eq)
            }
        }

        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        if let selectedMuscleGroup {
            result = result.filter { $0.muscleGroup == selectedMuscleGroup }
        }

        if let selectedEquipment {
            result = result.filter { $0.equipment == selectedEquipment }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredExercises) { exercise in
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
                            if !exercise.isCardio {
                                Button {
                                    viewModel?.toggleFavorite(exercise)
                                } label: {
                                    Image(systemName: exercise.isFavorite ? "star.fill" : "star")
                                        .font(.body)
                                        .foregroundStyle(exercise.isFavorite ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)
                                }
                                .buttonStyle(.plain)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let exercise = filteredExercises[index]
                        viewModel?.deleteExercise(exercise)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search exercises")
            .safeAreaInset(edge: .top, spacing: 0) {
                if isAnyFilterActive {
                    activeFiltersRow
                        .background(AppTheme.Colors.background)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isAnyFilterActive)
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showFavoritesOnly.toggle()
                            }
                        } label: {
                            Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                                .font(.system(size: 18))
                                .foregroundStyle(showFavoritesOnly ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)
                        }

                        Button {
                            showingFilters = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(activeFilterCount > 0 ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)
                                if activeFilterCount > 0 {
                                    Circle()
                                        .fill(AppTheme.Colors.accent)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 3, y: -3)
                                }
                            }
                        }

                        Button {
                            showingAddExercise = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.Colors.surfaceTertiary)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(AppTheme.Colors.accent)
                            }
                        }
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
            .sheet(isPresented: $showingFilters) {
                ExerciseFilterSheet(
                    selectedMuscleGroup: $selectedMuscleGroup,
                    selectedEquipment: $selectedEquipment
                )
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

    // MARK: - Active Filters Row

    @ViewBuilder
    private var activeFiltersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.xs) {
                if showFavoritesOnly {
                    activeChip(title: "Favorites") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showFavoritesOnly = false
                        }
                    }
                }
                if let group = selectedMuscleGroup {
                    activeChip(title: group.displayName) {
                        selectedMuscleGroup = nil
                    }
                }
                if let eq = selectedEquipment {
                    activeChip(title: eq.displayName) {
                        selectedEquipment = nil
                    }
                }
                if totalActiveFilterCount > 1 {
                    Button("Clear All") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showFavoritesOnly = false
                        }
                        selectedMuscleGroup = nil
                        selectedEquipment = nil
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .padding(.leading, AppTheme.Spacing.xxs)
                }
            }
            .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
            .padding(.vertical, AppTheme.Spacing.xs)
        }
    }

    private func activeChip(title: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.medium))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .foregroundStyle(.white)
        .background(AppTheme.Colors.accent)
        .clipShape(Capsule())
    }
}

#Preview {
    ExerciseLibraryView()
        .modelContainer(for: [Exercise.self], inMemory: true)
}
