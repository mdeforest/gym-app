import SwiftUI

struct GymProfileEditView: View {
    enum EditMode {
        case add
        case edit(GymProfile)
    }

    let mode: EditMode
    let onSave: (GymProfile) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var selectedEquipment: Set<Equipment> = Set(Equipment.allCases)
    @State private var selectedMachines: Set<MachineType> = Set(MachineType.allCases)
    @State private var showingTemplates = false

    init(mode: EditMode, onSave: @escaping (GymProfile) -> Void) {
        self.mode = mode
        self.onSave = onSave
        if case .edit(let profile) = mode {
            _name = State(initialValue: profile.name)
            let eq = profile.equipmentSet
            _selectedEquipment = State(initialValue: eq.isEmpty ? Set(Equipment.allCases) : eq)
            let mt = profile.machineTypeSet
            _selectedMachines = State(initialValue: mt.isEmpty ? Set(MachineType.allCases) : mt)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Name") {
                    TextField("e.g. Home Gym", text: $name)
                        .submitLabel(.done)
                }

                Section {
                    ForEach(Equipment.allCases) { eq in
                        equipmentRow(eq)
                    }
                } header: {
                    HStack {
                        Text("Equipment")
                        Spacer()
                        Button("Use Template") {
                            showingTemplates = true
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .textCase(.none)
                    }
                } footer: {
                    Text("Only exercises matching selected equipment will appear.")
                }

                if selectedEquipment.contains(.machine) {
                    Section {
                        ForEach(MachineType.allCases) { type in
                            machineTypeRow(type)
                        }
                    } header: {
                        HStack {
                            Text("Machine Types")
                            Spacer()
                            if selectedMachines.count < MachineType.allCases.count {
                                Button("Select All") {
                                    selectedMachines = Set(MachineType.allCases)
                                }
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(AppTheme.Colors.accent)
                                .textCase(.none)
                            }
                        }
                    } footer: {
                        Text("Select which machines are available at this gym.")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.accent)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .confirmationDialog(
                "Start from a Template",
                isPresented: $showingTemplates,
                titleVisibility: .visible
            ) {
                ForEach(GymProfile.builtInTemplates, id: \.id) { template in
                    Button(template.name) {
                        let eq = template.equipmentSet
                        selectedEquipment = eq.isEmpty ? Set(Equipment.allCases) : eq
                        // Templates don't restrict machine types
                        selectedMachines = Set(MachineType.allCases)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your current equipment selection will be replaced.")
            }
        }
    }

    // MARK: - Private

    private var titleText: String {
        if case .edit = mode { return "Edit Profile" }
        return "New Profile"
    }

    private func equipmentRow(_ eq: Equipment) -> some View {
        let isSelected = selectedEquipment.contains(eq)
        return Button {
            if selectedEquipment.contains(eq) {
                selectedEquipment.remove(eq)
            } else {
                selectedEquipment.insert(eq)
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.surfaceTertiary)
                        .frame(width: 32, height: 32)
                    Image(systemName: equipmentIcon(for: eq))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Text(eq.displayName)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.accent)
                    .opacity(isSelected ? 1 : 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func machineTypeRow(_ type: MachineType) -> some View {
        let isSelected = selectedMachines.contains(type)
        return Button {
            if selectedMachines.contains(type) {
                selectedMachines.remove(type)
            } else {
                selectedMachines.insert(type)
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.surfaceTertiary)
                        .frame(width: 32, height: 32)
                    Image(systemName: type.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Text(type.displayName)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.accent)
                    .opacity(isSelected ? 1 : 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func equipmentIcon(for eq: Equipment) -> String {
        switch eq {
        case .barbell:    "figure.strengthtraining.traditional"
        case .dumbbell:   "dumbbell.fill"
        case .cable:      "arrow.up.and.down.circle.fill"
        case .machine:    "gearshape.fill"
        case .bodyweight: "person.fill"
        case .kettlebell: "scalemass.fill"
        case .bands:      "arrow.left.and.right"
        case .other:      "ellipsis.circle"
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let rawEquipment = GymProfile.encode(equipment: selectedEquipment)
        let rawMachines = selectedEquipment.contains(.machine)
            ? GymProfile.encode(machines: selectedMachines)
            : ""
        switch mode {
        case .add:
            onSave(GymProfile(name: trimmedName, equipmentRaw: rawEquipment, machinesRaw: rawMachines))
        case .edit(let existing):
            var updated = existing
            updated.name = trimmedName
            updated.equipmentRaw = rawEquipment
            updated.machinesRaw = rawMachines
            onSave(updated)
        }
    }
}
