import SwiftUI

struct GymProfilesView: View {
    @AppStorage("gymProfiles") private var gymProfilesData: Data = Data()
    @AppStorage("activeGymProfileId") private var activeGymProfileId: String = ""
    @AppStorage("availableEquipment") private var availableEquipmentRaw: String = ""
    @AppStorage("availableMachines") private var availableMachinesRaw: String = ""

    @State private var showingAddProfile = false
    @State private var editingProfile: GymProfile?
    @State private var profileToDelete: GymProfile?
    @State private var showingDeleteConfirmation = false

    private var profiles: [GymProfile] {
        (try? JSONDecoder().decode([GymProfile].self, from: gymProfilesData)) ?? []
    }

    var body: some View {
        List {
            Section {
                ForEach(profiles) { profile in
                    profileRow(profile)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                profileToDelete = profile
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                editingProfile = profile
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(AppTheme.Colors.accent)
                        }
                }
            }

        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background)
        .navigationTitle("Gym Profiles")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { createDefaultProfileIfNeeded() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddProfile = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingAddProfile) {
            GymProfileEditView(mode: .add) { newProfile in
                var current = profiles
                current.append(newProfile)
                GymProfile.saveAll(current)
            }
        }
        .sheet(item: $editingProfile) { profile in
            GymProfileEditView(mode: .edit(profile)) { updated in
                var current = profiles
                if let idx = current.firstIndex(where: { $0.id == updated.id }) {
                    current[idx] = updated
                }
                GymProfile.saveAll(current)
            }
        }
        .alert(
            "Delete \"\(profileToDelete?.name ?? "")\"?",
            isPresented: $showingDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                if let p = profileToDelete { deleteProfile(p) }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Row views

    private func profileRow(_ profile: GymProfile) -> some View {
        let isActive = activeGymProfileId == profile.id.uuidString
        return Button {
            applyProfile(profile)
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(isActive ? AppTheme.Colors.accent : AppTheme.Colors.surfaceTertiary)
                        .frame(width: 32, height: 32)
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.name)
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(equipmentSummary(profile))
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                Spacer()

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func equipmentSummary(_ profile: GymProfile) -> String {
        if profile.equipmentRaw.isEmpty { return "All Equipment" }
        let items = profile.equipmentRaw
            .split(separator: ",")
            .compactMap { Equipment(rawValue: String($0))?.displayName }
        if items.count <= 3 {
            return items.joined(separator: ", ")
        }
        return items.prefix(2).joined(separator: ", ") + " +\(items.count - 2)"
    }

    private func applyProfile(_ profile: GymProfile) {
        availableEquipmentRaw = profile.equipmentRaw
        availableMachinesRaw = profile.machinesRaw
        activeGymProfileId = profile.id.uuidString
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func deleteProfile(_ profile: GymProfile) {
        let wasActive = activeGymProfileId == profile.id.uuidString
        var current = profiles
        current.removeAll { $0.id == profile.id }
        GymProfile.saveAll(current)
        if wasActive {
            if let next = current.first {
                applyProfile(next)
            } else {
                createDefaultProfileIfNeeded()
            }
        }
    }

    private func createDefaultProfileIfNeeded() {
        guard profiles.isEmpty else { return }
        let defaultProfile = GymProfile(name: "My Gym", equipmentRaw: "")
        GymProfile.saveAll([defaultProfile])
        applyProfile(defaultProfile)
    }
}
