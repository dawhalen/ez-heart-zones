import Foundation

struct ZoneBreakdown {
    private var minutesByZone: [HeartRateZone: Int]

    init(minutesByZone: [HeartRateZone: Int] = [:]) {
        self.minutesByZone = minutesByZone
    }

    func minutes(for zone: HeartRateZone) -> Int {
        minutesByZone[zone] ?? 0
    }

    func points(for zone: HeartRateZone) -> Int {
        minutes(for: zone) * zone.multiplier
    }

    var totalMinutes: Int {
        HeartRateZone.allCases.reduce(0) { $0 + minutes(for: $1) }
    }

    var totalPoints: Int {
        HeartRateZone.allCases.reduce(0) { $0 + points(for: $1) }
    }

    var hasAnyPoints: Bool {
        totalPoints > 0
    }

    var mediumPoints: Int {
        points(for: .two) + points(for: .three)
    }

    var highPoints: Int {
        points(for: .four) + points(for: .five)
    }

    static func + (lhs: ZoneBreakdown, rhs: ZoneBreakdown) -> ZoneBreakdown {
        var merged = lhs.minutesByZone
        for zone in HeartRateZone.allCases {
            merged[zone, default: 0] += rhs.minutes(for: zone)
        }
        return ZoneBreakdown(minutesByZone: merged)
    }
}
