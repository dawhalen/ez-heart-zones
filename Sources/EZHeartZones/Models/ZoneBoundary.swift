import Foundation

struct ZoneBoundary: Codable, Equatable {
    var minBPM: Int
    var maxBPM: Int
}

enum ZoneClassifier {
    /// Percentage-of-max-heart-rate cut points per the README formula (220 - age): 50/60/70/80/90%,
    /// plus a generously high ceiling for Zone 5 since real effort can exceed the estimated max.
    /// Consecutive zones share a cut point (e.g. Zone 1's max == Zone 2's min) so there's never a
    /// gap or overlap between them — this is the same representation used for user-edited custom
    /// zones, where a single shared breakpoint is what's editable between two adjacent zones.
    private static let automaticPercentCutPoints: [Double] = [0.50, 0.60, 0.70, 0.80, 0.90, 1.50]

    static func automaticBreakpoints(age: Int) -> [Int] {
        let maxHeartRate = Double(220 - age)
        return automaticPercentCutPoints.map { Int((maxHeartRate * $0).rounded()) }
    }

    /// Converts 6 breakpoints (b0...b5) into the 5 zone ranges [b0,b1], [b1,b2], ... [b4,b5].
    static func boundaries(fromBreakpoints breakpoints: [Int]) -> [HeartRateZone: ZoneBoundary] {
        var result: [HeartRateZone: ZoneBoundary] = [:]
        for zone in HeartRateZone.allCases {
            let lowerIndex = zone.rawValue - 1
            guard breakpoints.indices.contains(lowerIndex), breakpoints.indices.contains(lowerIndex + 1) else {
                continue
            }
            result[zone] = ZoneBoundary(minBPM: breakpoints[lowerIndex], maxBPM: breakpoints[lowerIndex + 1])
        }
        return result
    }

    static func automaticBoundaries(age: Int) -> [HeartRateZone: ZoneBoundary] {
        boundaries(fromBreakpoints: automaticBreakpoints(age: age))
    }

    static func zone(forBPM bpm: Double, boundaries: [HeartRateZone: ZoneBoundary]) -> HeartRateZone? {
        HeartRateZone.allCases.first { zone in
            guard let range = boundaries[zone] else { return false }
            return bpm >= Double(range.minBPM) && bpm <= Double(range.maxBPM)
        }
    }
}
