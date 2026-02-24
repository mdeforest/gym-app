import SwiftUI

struct EquipmentSectionView: View {
    @AppStorage("availableEquipment") private var availableEquipmentRaw: String = ""

    private var selectedEquipment: Set<Equipment> {
        if availableEquipmentRaw.isEmpty { return Set(Equipment.allCases) }
        return Set(availableEquipmentRaw.split(separator: ",").compactMap { Equipment(rawValue: String($0)) })
    }

    var body: some View {
        Section {
            ForEach(Equipment.allCases) { eq in
                equipmentRow(eq)
            }
        } header: {
            HStack {
                Text("Available Equipment")
                Spacer()
                if !availableEquipmentRaw.isEmpty {
                    Button("Reset") {
                        availableEquipmentRaw = ""
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.accent)
                    .textCase(.none)
                }
            }
        } footer: {
            Text("Exercises requiring unavailable equipment will be hidden.")
        }
    }

    private func equipmentRow(_ eq: Equipment) -> some View {
        let isSelected = selectedEquipment.contains(eq)
        return Button { toggle(eq) } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.surfaceTertiary)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon(for: eq))
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

    private func icon(for eq: Equipment) -> String {
        switch eq {
        case .barbell:    "figure.strengthtraining.traditional" // overhead barbell press
        case .dumbbell:   "dumbbell.fill"                       // direct match
        case .cable:      "arrow.up.and.down.circle.fill"       // cable pulley motion
        case .machine:    "gearshape.fill"                      // mechanical equipment
        case .bodyweight: "person.fill"                         // body = bodyweight
        case .kettlebell: "scalemass.fill"                      // weighted mass
        case .bands:      "arrow.left.and.right"                // resistance pull motion
        case .other:      "ellipsis.circle"                     // catch-all
        }
    }

    private func toggle(_ eq: Equipment) {
        var current = selectedEquipment
        if current.contains(eq) {
            current.remove(eq)
        } else {
            current.insert(eq)
        }
        if current.count == Equipment.allCases.count {
            availableEquipmentRaw = ""
        } else {
            availableEquipmentRaw = current.map(\.rawValue).sorted().joined(separator: ",")
        }
    }
}
