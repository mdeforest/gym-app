import SwiftUI

struct HealthSectionView: View {
    @State private var healthService = HealthKitService.shared
    @AppStorage("weightUnit") private var weightUnit: String = "lbs"

    var body: some View {
        if healthService.isAvailable {
            Section {
                Toggle(isOn: Binding(
                    get: { healthService.isEnabled },
                    set: { newValue in
                        healthService.isEnabled = newValue
                        if newValue {
                            Task {
                                await healthService.requestAuthorization()
                            }
                        }
                    }
                )) {
                    Label("Apple Health", systemImage: "heart.fill")
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
                .tint(AppTheme.Colors.accent)

                if healthService.isEnabled {
                    HStack {
                        Text("Status")
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Spacer()
                        Text(healthService.authorizationStatus.rawValue)
                            .foregroundStyle(statusColor)
                    }

                    if healthService.authorizationStatus == .denied {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Open Settings to Grant Access", systemImage: "gear")
                                .font(.footnote)
                        }
                    }
                }
            } header: {
                Text("Health")
            }
            .onAppear {
                if healthService.isEnabled {
                    Task {
                        await healthService.fetchLatestBodyWeight(unit: weightUnit)
                    }
                }
            }
        }
    }

    private var statusColor: Color {
        switch healthService.authorizationStatus {
        case .authorized: AppTheme.Colors.success
        case .denied: AppTheme.Colors.destructive
        case .notRequested: AppTheme.Colors.textSecondary
        }
    }
}
