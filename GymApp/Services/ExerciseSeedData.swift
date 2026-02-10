import Foundation

enum ExerciseSeedData {
    struct ExerciseDefinition: Decodable {
        let name: String
        let muscleGroup: MuscleGroup
        let isCardio: Bool
        let defaultRestSeconds: Int?
        let description: String
        let instructions: String
    }

    static let exercises: [ExerciseDefinition] = {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ExerciseDefinition].self, from: data) else {
            return []
        }
        return decoded
    }()
}
