import Foundation

enum ExportService {

    static func exportCSV(workouts: [Workout]) -> String {
        var csv = "Date,Duration (min),Exercise,Muscle Group,Type,Set #,Weight (lbs),Reps,Duration (s),Distance (km)\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        for workout in workouts {
            let dateStr = dateFormatter.string(from: workout.startDate)
            let durationMin = workout.duration.map { Int($0) / 60 } ?? 0

            for workoutExercise in workout.exercises.sorted(by: { $0.order < $1.order }) {
                let exerciseName = workoutExercise.exercise?.name ?? "Unknown"
                let muscleGroup = workoutExercise.exercise?.muscleGroup.displayName ?? ""
                let isCardio = workoutExercise.exercise?.isCardio ?? false

                if isCardio {
                    let durSec = workoutExercise.durationSeconds ?? 0
                    let distKm = (workoutExercise.distanceMeters ?? 0) / 1000.0
                    csv += "\(dateStr),\(durationMin),\(exerciseName),\(muscleGroup),cardio,,,\(durSec),\(String(format: "%.2f", distKm))\n"
                } else {
                    for set in workoutExercise.sortedSets where set.isCompleted {
                        csv += "\(dateStr),\(durationMin),\(exerciseName),\(muscleGroup),strength,\(set.order + 1),\(String(format: "%g", set.weight)),\(set.reps),,\n"
                    }
                }
            }
        }

        return csv
    }

    static func exportJSON(workouts: [Workout]) -> Data {
        let dateFormatter = ISO8601DateFormatter()

        var workoutDicts: [[String: Any]] = []

        for workout in workouts {
            var dict: [String: Any] = [
                "date": dateFormatter.string(from: workout.startDate),
                "durationMinutes": workout.duration.map { Int($0) / 60 } ?? 0,
            ]

            if let endDate = workout.endDate {
                dict["endDate"] = dateFormatter.string(from: endDate)
            }

            var exercisesList: [[String: Any]] = []
            for we in workout.exercises.sorted(by: { $0.order < $1.order }) {
                var exDict: [String: Any] = [
                    "name": we.exercise?.name ?? "Unknown",
                    "muscleGroup": we.exercise?.muscleGroup.rawValue ?? "",
                ]

                if we.exercise?.isCardio == true {
                    exDict["type"] = "cardio"
                    exDict["durationSeconds"] = we.durationSeconds ?? 0
                    exDict["distanceMeters"] = we.distanceMeters ?? 0
                } else {
                    exDict["type"] = "strength"
                    exDict["sets"] = we.sortedSets.filter(\.isCompleted).map { set in
                        [
                            "setNumber": set.order + 1,
                            "weight": set.weight,
                            "reps": set.reps,
                        ] as [String: Any]
                    }
                }

                exercisesList.append(exDict)
            }
            dict["exercises"] = exercisesList
            workoutDicts.append(dict)
        }

        let payload: [String: Any] = [
            "exportDate": dateFormatter.string(from: Date()),
            "workouts": workoutDicts,
        ]

        return (try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])) ?? Data()
    }

    static func writeToTemporaryFile(data: Data, filename: String) -> URL? {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
}
