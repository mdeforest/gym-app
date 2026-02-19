import Foundation
import HealthKit
import Observation

@MainActor
@Observable
final class HealthKitService {
    static let shared = HealthKitService()

    var isAvailable: Bool
    var authorizationStatus: AuthorizationStatus = .notRequested
    var latestBodyWeight: Double?
    var latestBodyWeightDate: Date?

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "healthKitEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "healthKitEnabled") }
    }

    private let healthStore: HKHealthStore?

    enum AuthorizationStatus: String {
        case notRequested = "Not Requested"
        case authorized = "Connected"
        case denied = "Denied"
    }

    private init() {
        let available = HKHealthStore.isHealthDataAvailable()
        self.isAvailable = available
        self.healthStore = available ? HKHealthStore() : nil

        if available && UserDefaults.standard.bool(forKey: "healthKitEnabled") {
            updateAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        guard let healthStore else { return false }

        let typesToShare: Set<HKSampleType> = [
            HKQuantityType.workoutType()
        ]

        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.bodyMass)
        ]

        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            updateAuthorizationStatus()
            if authorizationStatus == .authorized {
                let unit = UserDefaults.standard.string(forKey: "weightUnit") ?? "lbs"
                await fetchLatestBodyWeight(unit: unit)
            }
            return authorizationStatus == .authorized
        } catch {
            authorizationStatus = .denied
            return false
        }
    }

    // MARK: - Save Workout

    func saveWorkout(_ workout: Workout) async {
        guard let healthStore, isEnabled else { return }

        let startDate = workout.startDate
        guard let endDate = workout.endDate else { return }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor

        do {
            let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
            try await builder.beginCollection(at: startDate)
            try await builder.endCollection(at: endDate)

            // Add metadata
            var metadata: [String: Any] = [
                HKMetadataKeyWorkoutBrandName: "Pulse"
            ]

            let exerciseCount = workout.exercises.count
            if exerciseCount > 0 {
                metadata["ExerciseCount"] = exerciseCount
            }

            // Calculate total volume (weight × reps for all completed normal sets)
            let totalVolume = workout.exercises.reduce(0.0) { total, exercise in
                total + exercise.sets
                    .filter { $0.isCompleted && $0.setType == .normal }
                    .reduce(0.0) { $0 + $1.weight * Double($1.reps) }
            }
            if totalVolume > 0 {
                metadata["TotalVolume"] = totalVolume
            }

            try await builder.addMetadata(metadata)
            try await builder.finishWorkout()
        } catch {
            // Silently fail — workout is saved locally regardless
        }
    }

    // MARK: - Body Weight

    func fetchLatestBodyWeight(unit: String) async {
        guard let healthStore else { return }

        let bodyMassType = HKQuantityType(.bodyMass)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: bodyMassType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }

            let hkUnit: HKUnit = unit == "kg" ? .gramUnit(with: .kilo) : .pound()
            let weight = sample.quantity.doubleValue(for: hkUnit)
            let date = sample.startDate

            Task { @MainActor [weak self] in
                self?.latestBodyWeight = weight
                self?.latestBodyWeightDate = date
                UserDefaults.standard.set(weight, forKey: "bodyWeight")
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Private

    private func updateAuthorizationStatus() {
        guard let healthStore else {
            authorizationStatus = .notRequested
            return
        }

        let workoutType = HKQuantityType.workoutType()
        let status = healthStore.authorizationStatus(for: workoutType)

        switch status {
        case .sharingAuthorized:
            authorizationStatus = .authorized
        case .sharingDenied:
            authorizationStatus = .denied
        default:
            authorizationStatus = .notRequested
        }
    }
}
