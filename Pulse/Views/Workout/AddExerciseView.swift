import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Query(sort: \Exercise.name) private var allExercises: [Exercise]
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup?
    @AppStorage("availableEquipment") private var availableEquipmentRaw: String = ""
    @AppStorage("availableMachines") private var availableMachinesRaw: String = ""

    let onSelect: (Exercise) -> Void

    private var availableEquipment: Set<Equipment> {
        guard !availableEquipmentRaw.isEmpty else { return [] }
        return Set(availableEquipmentRaw.split(separator: ",").compactMap { Equipment(rawValue: String($0)) })
    }

    private var availableMachines: Set<MachineType> {
        guard !availableMachinesRaw.isEmpty else { return [] }
        return Set(availableMachinesRaw.split(separator: ",").compactMap { MachineType(rawValue: String($0)) })
    }

    private func exercisePasses(_ exercise: Exercise) -> Bool {
        guard let eq = exercise.equipment else { return true }
        if eq == .other { return true }
        if !availableEquipment.isEmpty && !availableEquipment.contains(eq) { return false }
        if eq == .machine && !availableMachines.isEmpty {
            guard let mt = exercise.machineType else { return true }
            return availableMachines.contains(mt)
        }
        return true
    }

    private var filteredExercises: [Exercise] {
        var result = allExercises.filter { exercisePasses($0) }

        if let selectedMuscleGroup {
            result = result.filter { $0.muscleGroup == selectedMuscleGroup }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    private var recentExercises: [Exercise] {
        return allExercises.filter { exercisePasses($0) }
            .filter { $0.lastUsedDate != nil }
            .sorted { ($0.lastUsedDate ?? .distantPast) > ($1.lastUsedDate ?? .distantPast) }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        categoryTab(title: "All", isSelected: selectedMuscleGroup == nil) {
                            selectedMuscleGroup = nil
                        }
                        ForEach(MuscleGroup.allCases) { group in
                            categoryTab(
                                title: group.displayName,
                                isSelected: selectedMuscleGroup == group
                            ) {
                                selectedMuscleGroup = group
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.screenEdgePadding)
                    .padding(.vertical, AppTheme.Spacing.xs)
                }

                List {
                    // Recent exercises section
                    if searchText.isEmpty && selectedMuscleGroup == nil {
                        let recent = recentExercises
                        if !recent.isEmpty {
                            Section("Recent") {
                                ForEach(recent) { exercise in
                                    exerciseRow(exercise)
                                }
                            }
                        }
                    }

                    // All exercises
                    Section(selectedMuscleGroup?.displayName ?? "All Exercises") {
                        ForEach(filteredExercises) { exercise in
                            exerciseRow(exercise)
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search exercises")
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
