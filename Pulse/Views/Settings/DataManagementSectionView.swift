import SwiftUI

struct DataManagementSectionView: View {
    var viewModel: SettingsViewModel?
    @State private var selectedFormat: ExportFormat = .csv
    @State private var exportFileURL: URL?
    @State private var showingShareSheet = false

    enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var body: some View {
        Section {
            Picker("Format", selection: $selectedFormat) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .foregroundStyle(AppTheme.Colors.textPrimary)

            Button {
                exportData()
            } label: {
                Label("Export Workout Data", systemImage: "square.and.arrow.up")
            }
        } header: {
            Text("Export Data")
        }

        Section {
            HStack {
                Label("Version", systemImage: "info.circle")
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                Text("\(appVersion) (\(buildNumber))")
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            Button(role: .destructive) {
                viewModel?.showingClearDataConfirmation = true
            } label: {
                Label("Clear All Data", systemImage: "trash")
                    .foregroundStyle(AppTheme.Colors.destructive)
            }
        }
        .alert("Clear All Data?", isPresented: Binding(
            get: { viewModel?.showingClearDataConfirmation ?? false },
            set: { viewModel?.showingClearDataConfirmation = $0 }
        )) {
            Button("Clear Everything", role: .destructive) {
                viewModel?.clearAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all workouts, templates, and custom exercises. This cannot be undone.")
        }
        .alert("Data Cleared", isPresented: Binding(
            get: { viewModel?.showingClearDataSuccess ?? false },
            set: { viewModel?.showingClearDataSuccess = $0 }
        )) {
            Button("OK") {}
        } message: {
            Text("All workout data has been removed.")
        }
        .sheet(isPresented: $showingShareSheet) {
            if let exportFileURL {
                ShareSheet(activityItems: [exportFileURL])
            }
        }
    }

    private func exportData() {
        guard let viewModel else { return }
        let workouts = viewModel.generateExportData()

        let data: Data
        let filename: String

        switch selectedFormat {
        case .csv:
            let csvString = ExportService.exportCSV(workouts: workouts)
            data = Data(csvString.utf8)
            filename = "pulse_workouts.csv"
        case .json:
            data = ExportService.exportJSON(workouts: workouts)
            filename = "pulse_workouts.json"
        }

        if let url = ExportService.writeToTemporaryFile(data: data, filename: filename) {
            exportFileURL = url
            showingShareSheet = true
        }
    }
}

// MARK: - Helper Views

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
