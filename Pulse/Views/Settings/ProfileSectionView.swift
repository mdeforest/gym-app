import SwiftUI

struct ProfileSectionView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("bodyWeight") private var bodyWeight: Double = 0
    @AppStorage("weightUnit") private var weightUnit: String = "lbs"

    var body: some View {
        Section {
            HStack {
                Label("Name", systemImage: "person.fill")
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                TextField("Your Name", text: $userName)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            HStack {
                Label("Body Weight", systemImage: "scalemass.fill")
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                TextField("0", value: $bodyWeight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(weightUnit)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            Picker("Weight Unit", selection: $weightUnit) {
                Text("lbs").tag("lbs")
                Text("kg").tag("kg")
            }
            .foregroundStyle(AppTheme.Colors.textPrimary)
        } header: {
            Text("Profile")
        }
    }
}
