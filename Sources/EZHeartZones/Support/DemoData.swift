#if DEBUG
import Foundation

/// Fabricated zone minutes for App Store screenshots and simulator demos, where Health has no real
/// heart rate samples. Debug builds only; enable by launching with `-demoData YES`. Combine with
/// `-settings.weeklyGoal "<integer>N</integer>"` (plist syntax, so it reads back as an Int) to show
/// either the in-progress or the goal-reached Home state.
enum DemoData {
    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "demoData")
    }

    /// Workout sessions keyed by `Calendar` weekday (1 = Sunday), as hour-of-day → minutes per zone.
    /// Keyed by weekday rather than week position so Home and Day Detail agree whatever the week-start
    /// setting is. A full week totals 216 points.
    private static let sessionsByWeekday: [Int: [Int: [HeartRateZone: Int]]] = [
        1: [10: [.one: 25, .two: 12, .three: 3]],
        2: [7: [.one: 6, .two: 8, .three: 14, .four: 4]],
        3: [12: [.one: 18, .two: 4]],
        4: [6: [.one: 5, .two: 6, .three: 12, .four: 10, .five: 2], 18: [.one: 10, .two: 3]],
        5: [17: [.one: 12, .two: 10, .three: 8]],
        6: [7: [.one: 4, .three: 16, .four: 8]],
        7: [9: [.one: 8, .two: 10, .three: 20, .four: 14, .five: 4], 15: [.one: 20, .two: 6]],
    ]

    static func hourlyBreakdowns(day: Date) -> [ZoneBreakdown] {
        let weekday = Calendar.current.component(.weekday, from: day)
        let sessions = sessionsByWeekday[weekday] ?? [:]
        return (0..<24).map { hour in
            ZoneBreakdown(minutesByZone: sessions[hour] ?? [:])
        }
    }

    static func weekBreakdowns(weekStart: Date) -> [ZoneBreakdown] {
        (0..<7).map { offset in
            let day = Calendar.current.date(byAdding: .day, value: offset, to: weekStart) ?? weekStart
            return hourlyBreakdowns(day: day).reduce(ZoneBreakdown(), +)
        }
    }
}
#endif
