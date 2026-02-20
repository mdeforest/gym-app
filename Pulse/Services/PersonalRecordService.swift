import Foundation
import SwiftData

struct PersonalRecordResult {
    let isWeightPR: Bool
    let isEstimated1RMPR: Bool
    let isVolumePR: Bool

    var isAnyPR: Bool { isWeightPR || isEstimated1RMPR || isVolumePR }

    var prTypes: [PRType] {
        var types: [PRType] = []
        if isWeightPR { types.append(.weight) }
        if isEstimated1RMPR { types.append(.estimated1RM) }
        if isVolumePR { types.append(.volume) }
        return types
    }
}

struct ExerciseRecords {
    let bestWeight: Double
    let bestWeightDate: Date?
    let bestEstimated1RM: Double
    let bestEstimated1RMDate: Date?
    let bestVolume: Double
    let bestVolumeDate: Date?
}

enum PersonalRecordService {

    // MARK: - Formulas

    static func estimatedOneRepMax(weight: Double, reps: Int) -> Double {
        guard weight > 0, reps > 0 else { return 0 }
        return reps > 1 ? weight * (1 + Double(reps) / 30.0) : weight
    }

    static func setVolume(weight: Double, reps: Int) -> Double {
        weight * Double(reps)
    }

    // MARK: - Real-Time PR Check

    static func checkForPR(
        set: ExerciseSet,
        exercise: Exercise,
        modelContext: ModelContext
    ) -> PersonalRecordResult {
        guard !exercise.isCardio,
              set.isCompleted,
              set.setType == .normal,
              set.weight > 0,
              set.reps > 0 else {
            return PersonalRecordResult(isWeightPR: false, isEstimated1RMPR: false, isVolumePR: false)
        }

        let records = fetchAllTimeRecords(for: exercise, excluding: set, modelContext: modelContext)

        let setE1RM = estimatedOneRepMax(weight: set.weight, reps: set.reps)
        let setVol = setVolume(weight: set.weight, reps: set.reps)

        return PersonalRecordResult(
            isWeightPR: set.weight > records.bestWeight,
            isEstimated1RMPR: setE1RM > records.bestEstimated1RM,
            isVolumePR: setVol > records.bestVolume
        )
    }

    // MARK: - All-Time Records

    static func fetchAllTimeRecords(
        for exercise: Exercise,
        excluding excludedSet: ExerciseSet? = nil,
        modelContext: ModelContext
    ) -> ExerciseRecords {
        let exerciseID = exercise.id
        let descriptor = FetchDescriptor<WorkoutExercise>(
            predicate: #Predicate<WorkoutExercise> { we in
                we.exercise?.id == exerciseID
            }
        )

        let workoutExercises = (try? modelContext.fetch(descriptor)) ?? []

        var bestWeight: Double = 0
        var bestWeightDate: Date?
        var bestE1RM: Double = 0
        var bestE1RMDate: Date?
        var bestVolume: Double = 0
        var bestVolumeDate: Date?

        let excludedID = excludedSet?.id

        for we in workoutExercises {
            let date = we.workout?.startDate ?? .distantPast
            for s in we.sets where s.isCompleted && s.setType == .normal && s.weight > 0 && s.reps > 0 {
                if let excludedID, s.id == excludedID { continue }

                if s.weight > bestWeight {
                    bestWeight = s.weight
                    bestWeightDate = date
                }
                let e1rm = estimatedOneRepMax(weight: s.weight, reps: s.reps)
                if e1rm > bestE1RM {
                    bestE1RM = e1rm
                    bestE1RMDate = date
                }
                let vol = setVolume(weight: s.weight, reps: s.reps)
                if vol > bestVolume {
                    bestVolume = vol
                    bestVolumeDate = date
                }
            }
        }

        return ExerciseRecords(
            bestWeight: bestWeight,
            bestWeightDate: bestWeightDate,
            bestEstimated1RM: bestE1RM,
            bestEstimated1RMDate: bestE1RMDate,
            bestVolume: bestVolume,
            bestVolumeDate: bestVolumeDate
        )
    }

    // MARK: - Backfill Historical PRs

    static func backfillPRFlags(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        guard let workouts = try? modelContext.fetch(descriptor) else { return }

        var bestWeight: [PersistentIdentifier: Double] = [:]
        var bestE1RM: [PersistentIdentifier: Double] = [:]
        var bestVolume: [PersistentIdentifier: Double] = [:]

        for workout in workouts {
            for we in workout.exercises {
                guard let exercise = we.exercise, !exercise.isCardio else { continue }
                let eid = exercise.persistentModelID

                for s in we.sortedSets where s.isCompleted && s.setType == .normal && s.weight > 0 && s.reps > 0 {
                    if s.weight > (bestWeight[eid] ?? 0) {
                        s.isWeightPR = true
                        bestWeight[eid] = s.weight
                    } else {
                        s.isWeightPR = false
                    }

                    let e1rm = estimatedOneRepMax(weight: s.weight, reps: s.reps)
                    if e1rm > (bestE1RM[eid] ?? 0) {
                        s.isEstimated1RMPR = true
                        bestE1RM[eid] = e1rm
                    } else {
                        s.isEstimated1RMPR = false
                    }

                    let vol = setVolume(weight: s.weight, reps: s.reps)
                    if vol > (bestVolume[eid] ?? 0) {
                        s.isVolumePR = true
                        bestVolume[eid] = vol
                    } else {
                        s.isVolumePR = false
                    }
                }
            }
        }

        try? modelContext.save()
    }
}
