import SwiftUI

struct ExerciseFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMuscleGroup: MuscleGroup?
    @Binding var selectedEquipment: Equipment?

    // 4 cols × 8 muscle chips = 2 rows exactly
    private let muscleColumns = Array(repeating: GridItem(.flexible(), spacing: AppTheme.Spacing.xs), count: 4)
    // 3 cols × 9 equipment chips = 3 rows exactly
    private let equipmentColumns = Array(repeating: GridItem(.flexible(), spacing: AppTheme.Spacing.xs), count: 3)

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                filterSection("Muscle Group") {
                    LazyVGrid(columns: muscleColumns, spacing: AppTheme.Spacing.xs) {
                        chip(title: "All", isSelected: selectedMuscleGroup == nil) {
                            selectedMuscleGroup = nil
                        }
                        ForEach(MuscleGroup.allCases) { group in
                            chip(title: group.displayName, isSelected: selectedMuscleGroup == group) {
                                selectedMuscleGroup = selectedMuscleGroup == group ? nil : group
                            }
                        }
                    }
                }

                filterSection("Equipment") {
                    LazyVGrid(columns: equipmentColumns, spacing: AppTheme.Spacing.xs) {
                        chip(title: "Any", isSelected: selectedEquipment == nil) {
                            selectedEquipment = nil
                        }
                        ForEach(Equipment.allCases) { eq in
                            chip(title: eq.displayName, isSelected: selectedEquipment == eq) {
                                selectedEquipment = selectedEquipment == eq ? nil : eq
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(AppTheme.Layout.screenEdgePadding)
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear All") {
                        selectedMuscleGroup = nil
                        selectedEquipment = nil
                    }
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .disabled(selectedMuscleGroup == nil && selectedEquipment == nil)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
            .background(AppTheme.Colors.background)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func filterSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            content()
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.xs)
                .foregroundStyle(isSelected ? .white : AppTheme.Colors.textSecondary)
                .background(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.surfaceTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
