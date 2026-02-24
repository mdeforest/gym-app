import Foundation

struct GymProfile: Identifiable, Equatable {
    let id: UUID
    var name: String
    var equipmentRaw: String  // sorted comma-separated Equipment rawValues, "" = all
    var machinesRaw: String   // sorted comma-separated MachineType rawValues, "" = all machines

    init(id: UUID = UUID(), name: String, equipmentRaw: String = "", machinesRaw: String = "") {
        self.id = id
        self.name = name
        self.equipmentRaw = equipmentRaw
        self.machinesRaw = machinesRaw
    }
}

// MARK: - Codable (manual for backward compatibility)

extension GymProfile: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, equipmentRaw, machinesRaw
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        equipmentRaw = try c.decode(String.self, forKey: .equipmentRaw)
        machinesRaw = try c.decodeIfPresent(String.self, forKey: .machinesRaw) ?? ""
    }
}

// MARK: - Equipment helpers

extension GymProfile {
    var equipmentSet: Set<Equipment> {
        guard !equipmentRaw.isEmpty else { return [] }
        return Set(equipmentRaw.split(separator: ",").compactMap { Equipment(rawValue: String($0)) })
    }

    var machineTypeSet: Set<MachineType> {
        guard !machinesRaw.isEmpty else { return [] }
        return Set(machinesRaw.split(separator: ",").compactMap { MachineType(rawValue: String($0)) })
    }

    /// Encodes an equipment set to sorted comma-separated rawValues. Full set → "".
    static func encode(equipment: Set<Equipment>) -> String {
        if equipment.count == Equipment.allCases.count { return "" }
        return equipment.map(\.rawValue).sorted().joined(separator: ",")
    }

    /// Encodes a machine type set to sorted comma-separated rawValues. Full set → "".
    static func encode(machines: Set<MachineType>) -> String {
        if machines.count == MachineType.allCases.count { return "" }
        return machines.map(\.rawValue).sorted().joined(separator: ",")
    }
}

// MARK: - Built-in templates

extension GymProfile {
    static var commercialGym: GymProfile {
        GymProfile(name: "Commercial Gym", equipmentRaw: "", machinesRaw: "")
    }

    static var homeGym: GymProfile {
        GymProfile(
            name: "Home Gym",
            equipmentRaw: encode(equipment: [.barbell, .dumbbell, .kettlebell, .bands, .bodyweight, .other]),
            machinesRaw: ""
        )
    }

    static var travel: GymProfile {
        GymProfile(
            name: "Travel",
            equipmentRaw: encode(equipment: [.bodyweight, .bands, .dumbbell, .other]),
            machinesRaw: ""
        )
    }

    static var builtInTemplates: [GymProfile] {
        [commercialGym, homeGym, travel]
    }
}

// MARK: - UserDefaults persistence

extension GymProfile {
    private static let storageKey = "gymProfiles"

    static func loadAll() -> [GymProfile] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([GymProfile].self, from: data)) ?? []
    }

    static func saveAll(_ profiles: [GymProfile]) {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
