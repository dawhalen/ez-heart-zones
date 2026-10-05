import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published private(set) var authorizationStatusDescription = "Not requested"

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationStatusDescription = "Health data not available on this device"
            return
        }

        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            authorizationStatusDescription = "Heart rate type unavailable"
            return
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: [heartRateType])
            authorizationStatusDescription = "Authorization requested"
        } catch {
            authorizationStatusDescription = "Authorization failed: \(error.localizedDescription)"
        }
    }
}
