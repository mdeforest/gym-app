import SwiftUI
import SwiftData

// MARK: - Gym Profiles section (NavigationLink row)

private struct GymProfilesSectionView: View {
    @AppStorage("activeGymProfileId") private var activeGymProfileId: String = ""
    @AppStorage("gymProfiles") private var gymProfilesData: Data = Data()

    private var activeProfileName: String? {
        guard !activeGymProfileId.isEmpty else { return nil }
        let profiles = (try? JSONDecoder().decode([GymProfile].self, from: gymProfilesData)) ?? []
        return profiles.first(where: { $0.id.uuidString == activeGymProfileId })?.name
    }

    var body: some View {
        Section {
            NavigationLink(destination: GymProfilesView()) {
                HStack {
                    Label("Gym Profiles", systemImage: "mappin.and.ellipse")
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Spacer()
                    if let name = activeProfileName {
                        Text(name)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Settings root view

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SettingsViewModel?

    var body: some View {
        NavigationStack {
            List {
                ProfileSectionView()
                GymProfilesSectionView()
                if let viewModel {
                    DataManagementSectionView(viewModel: viewModel)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(modelContext: modelContext)
            }
        }
    }
}
