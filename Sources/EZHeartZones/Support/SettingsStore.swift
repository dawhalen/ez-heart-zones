import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    static let defaultAge = 35

    @Published var weeklyGoal: Int {
        didSet { UserDefaults.standard.set(weeklyGoal, forKey: Keys.weeklyGoal) }
    }

    @Published var weekStartDay: WeekStartDay {
        didSet { UserDefaults.standard.set(weekStartDay.rawValue, forKey: Keys.weekStartDay) }
    }

    @Published var useCustomZones: Bool {
        didSet { UserDefaults.standard.set(useCustomZones, forKey: Keys.useCustomZones) }
    }

    /// 6 shared breakpoints (b0...b5) defining the 5 zone ranges: [b0,b1], [b1,b2], ... [b4,b5].
    /// Editing breakpoint i moves the shared border between zone i and zone i+1 — there is exactly
    /// one value to edit per border, so a gap or overlap between zones is structurally impossible.
    @Published var customZoneBreakpoints: [Int] {
        didSet { UserDefaults.standard.set(customZoneBreakpoints, forKey: Keys.customZoneBreakpoints) }
    }

    private enum Keys {
        static let weeklyGoal = "settings.weeklyGoal"
        static let weekStartDay = "settings.weekStartDay"
        static let useCustomZones = "settings.useCustomZones"
        static let customZoneBreakpoints = "settings.customZoneBreakpoints"
    }

    init() {
        let defaults = UserDefaults.standard

        weeklyGoal = defaults.object(forKey: Keys.weeklyGoal) as? Int ?? 150

        weekStartDay = (defaults.object(forKey: Keys.weekStartDay) as? Int)
            .flatMap(WeekStartDay.init(rawValue:)) ?? .monday

        useCustomZones = defaults.bool(forKey: Keys.useCustomZones)

        if let stored = defaults.array(forKey: Keys.customZoneBreakpoints) as? [Int], stored.count == 6 {
            customZoneBreakpoints = stored
        } else {
            customZoneBreakpoints = ZoneClassifier.automaticBreakpoints(age: SettingsStore.defaultAge)
        }
    }

    func effectiveBoundaries(age: Int?) -> [HeartRateZone: ZoneBoundary] {
        if useCustomZones {
            return ZoneClassifier.boundaries(fromBreakpoints: customZoneBreakpoints)
        }
        return ZoneClassifier.automaticBoundaries(age: age ?? SettingsStore.defaultAge)
    }
}
