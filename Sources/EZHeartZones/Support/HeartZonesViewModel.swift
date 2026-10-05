import Foundation

@MainActor
final class HeartZonesViewModel: ObservableObject {
    @Published private(set) var week: WeekData
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let healthKitManager: HealthKitManager
    private let settings: SettingsStore
    private var cachedAge: Int?

    init(healthKitManager: HealthKitManager, settings: SettingsStore) {
        self.healthKitManager = healthKitManager
        self.settings = settings

        let (start, days) = WeekData.dateRange(weekOffset: 0, firstWeekday: settings.weekStartDay.rawValue)
        week = WeekData(
            weekStartDate: start,
            days: days.map { DayEntry(date: $0, breakdown: ZoneBreakdown()) },
            weeklyGoal: settings.weeklyGoal
        )
    }

    func load(weekOffset: Int) async {
        isLoading = true
        defer { isLoading = false }

        let (start, dates) = WeekData.dateRange(weekOffset: weekOffset, firstWeekday: settings.weekStartDay.rawValue)

        if cachedAge == nil {
            cachedAge = healthKitManager.fetchAge()
        }
        let boundaries = settings.effectiveBoundaries(age: cachedAge)

        do {
            let breakdowns = try await healthKitManager.fetchZoneBreakdowns(weekStart: start, boundaries: boundaries)
            let entries = zip(dates, breakdowns).map { DayEntry(date: $0, breakdown: $1) }
            week = WeekData(weekStartDate: start, days: entries, weeklyGoal: settings.weeklyGoal)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
