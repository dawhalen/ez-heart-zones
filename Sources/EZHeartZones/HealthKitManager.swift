import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private var heartRateObserverQuery: HKObserverQuery?

    @Published private(set) var authorizationStatusDescription = "Not requested"

    /// A sample-to-sample gap larger than this contributes zero zone time — not a capped-but-nonzero
    /// amount. Apple Watch samples every few seconds during an active Workout, but also takes sparse
    /// ambient readings all day long unrelated to any workout, often many minutes or hours apart. Since
    /// the query pulls every same-day sample, capping (rather than zeroing) a huge gap would let two
    /// unrelated ambient readings that happen to clear the Zone 1 floor each phantom-credit up to the
    /// cap's worth of time — this threshold instead requires a gap tight enough to imply continuous
    /// monitoring (a workout, or Watch's automatic faster sampling during sustained elevated HR).
    private static let maxAttributableGapSeconds: TimeInterval = 60

    private var heartRateType: HKQuantityType? {
        HKObjectType.quantityType(forIdentifier: .heartRate)
    }

    private var dateOfBirthType: HKCharacteristicType? {
        HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
    }

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationStatusDescription = "Health data not available on this device"
            return
        }

        guard let heartRateType, let dateOfBirthType else {
            authorizationStatusDescription = "Heart rate type unavailable"
            return
        }

        let readTypes: Set<HKObjectType> = [heartRateType, dateOfBirthType]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            authorizationStatusDescription = "Authorization requested"
        } catch {
            authorizationStatusDescription = "Authorization failed: \(error.localizedDescription)"
        }
    }

    /// Starts watching for new heart rate samples so the UI can refresh itself without the user
    /// having to relaunch the app — HealthKit calls `onChange` whenever matching data is written,
    /// including while the app is already open in the foreground.
    func startObservingHeartRateChanges(onChange: @escaping () -> Void) {
        guard let heartRateType else { return }
        stopObservingHeartRateChanges()

        let query = HKObserverQuery(sampleType: heartRateType,
                                    predicate: nil) { [weak self] _, completionHandler, error in
            defer { completionHandler() }
            guard self != nil, error == nil else { return }
            Task { @MainActor in
                onChange()
            }
        }
        heartRateObserverQuery = query
        healthStore.execute(query)
    }

    func stopObservingHeartRateChanges() {
        if let heartRateObserverQuery {
            healthStore.stop(heartRateObserverQuery)
        }
        heartRateObserverQuery = nil
    }

    /// Reads age from the Health app's Date of Birth characteristic. Returns `nil` if unset
    /// (common on a fresh simulator) so callers can fall back to a default age.
    func fetchAge() -> Int? {
        guard let components = try? healthStore.dateOfBirthComponents(),
              let birthDate = Calendar.current.date(from: components)
        else {
            return nil
        }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }

    /// Fetches heart rate samples for the week starting at `weekStart` and buckets the time
    /// between consecutive samples into the zone of the earlier sample, returning one
    /// `ZoneBreakdown` per day (index 0 = `weekStart`).
    func fetchZoneBreakdowns(
        weekStart: Date,
        boundaries: [HeartRateZone: ZoneBoundary]
    ) async throws -> [ZoneBreakdown] {
        guard let heartRateType else {
            return Array(repeating: ZoneBreakdown(), count: 7)
        }

        let calendar = Calendar.current
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
            return Array(repeating: ZoneBreakdown(), count: 7)
        }

        let samples = try await heartRateSamples(type: heartRateType, start: weekStart, end: weekEnd)

        let secondsByBucket = Self
            .bucketedZoneSeconds(samples: samples, bucketCount: 7, boundaries: boundaries) { sampleDate in
                calendar.dateComponents([.day], from: weekStart, to: calendar.startOfDay(for: sampleDate)).day
            }

        return secondsByBucket.map { zoneSeconds in
            ZoneBreakdown(minutesByZone: zoneSeconds.mapValues { Int(($0 / 60).rounded()) })
        }
    }

    /// Fetches heart rate samples for the single calendar day containing `day` and buckets the time
    /// between consecutive samples into the zone of the earlier sample, returning one `ZoneBreakdown`
    /// per hour of that day (index 0 = midnight, index 23 = 11pm).
    func fetchHourlyZoneBreakdowns(
        day: Date,
        boundaries: [HeartRateZone: ZoneBoundary]
    ) async throws -> [ZoneBreakdown] {
        guard let heartRateType else {
            return Array(repeating: ZoneBreakdown(), count: 24)
        }

        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: day)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return Array(repeating: ZoneBreakdown(), count: 24)
        }

        let samples = try await heartRateSamples(type: heartRateType, start: dayStart, end: dayEnd)

        let secondsByBucket = Self
            .bucketedZoneSeconds(samples: samples, bucketCount: 24, boundaries: boundaries) { sampleDate in
                calendar.dateComponents([.hour], from: dayStart, to: sampleDate).hour
            }

        return secondsByBucket.map { zoneSeconds in
            ZoneBreakdown(minutesByZone: zoneSeconds.mapValues { Int(($0 / 60).rounded()) })
        }
    }

    /// Shared bucketing core for both the per-day (weekly) and per-hour (daily) breakdowns: accumulates
    /// whole seconds per zone per bucket, and only converts to minutes once at the call site — rounding
    /// each individual sample gap would silently drop sub-30-second gaps, which is most gaps given how
    /// frequently Apple Watch samples during a workout.
    private static func bucketedZoneSeconds(
        samples: [HKQuantitySample],
        bucketCount: Int,
        boundaries: [HeartRateZone: ZoneBoundary],
        bucketIndex: (Date) -> Int?
    ) -> [[HeartRateZone: TimeInterval]] {
        let unit = HKUnit.count().unitDivided(by: .minute())
        var secondsByBucket: [[HeartRateZone: TimeInterval]] = Array(repeating: [:], count: bucketCount)

        for index in samples.indices {
            guard let nextSample = samples[safe: index + 1] else { continue }
            let sample = samples[index]

            let gapSeconds = nextSample.startDate.timeIntervalSince(sample.startDate)
            guard gapSeconds > 0, gapSeconds <= maxAttributableGapSeconds else { continue }

            guard let bucket = bucketIndex(sample.startDate), bucket >= 0, bucket < bucketCount else { continue }

            let bpm = sample.quantity.doubleValue(for: unit)
            guard let zone = ZoneClassifier.zone(forBPM: bpm, boundaries: boundaries) else { continue }

            secondsByBucket[bucket][zone, default: 0] += gapSeconds
        }

        return secondsByBucket
    }

    private func heartRateSamples(type: HKQuantityType, start: Date, end: Date) async throws -> [HKQuantitySample] {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (results as? [HKQuantitySample]) ?? [])
            }
            healthStore.execute(query)
        }
    }
}
