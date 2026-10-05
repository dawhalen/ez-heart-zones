import XCTest
@testable import EZHeartZones

final class ZoneBreakdownTests: XCTestCase {
    func testZoneMultipliers() {
        XCTAssertEqual(HeartRateZone.one.multiplier, 0)
        XCTAssertEqual(HeartRateZone.two.multiplier, 1)
        XCTAssertEqual(HeartRateZone.three.multiplier, 1)
        XCTAssertEqual(HeartRateZone.four.multiplier, 2)
        XCTAssertEqual(HeartRateZone.five.multiplier, 2)
    }

    /// Wednesday from the DESIGN.md §7 worked example: 6 min Z1, 10 min Z3, 8 min Z4 → 26 pts.
    func testWednesdayWorkedExample() {
        let breakdown = ZoneBreakdown(minutesByZone: [.one: 6, .three: 10, .four: 8])

        XCTAssertEqual(breakdown.points(for: .one), 0)
        XCTAssertEqual(breakdown.points(for: .three), 10)
        XCTAssertEqual(breakdown.points(for: .four), 16)
        XCTAssertEqual(breakdown.totalPoints, 26)
        XCTAssertEqual(breakdown.mediumPoints, 10)
        XCTAssertEqual(breakdown.highPoints, 16)
    }

    /// Full week totals from DESIGN.md §7: 110 pts against a 150 pt goal.
    func testWeekWorkedExampleTotals() {
        let week = Self.workedExampleWeek()
        let total = week.totalBreakdown

        XCTAssertEqual(total.minutes(for: .one), 27)
        XCTAssertEqual(total.points(for: .one), 0)
        XCTAssertEqual(total.minutes(for: .two), 43)
        XCTAssertEqual(total.points(for: .two), 43)
        XCTAssertEqual(total.minutes(for: .three), 31)
        XCTAssertEqual(total.points(for: .three), 31)
        XCTAssertEqual(total.minutes(for: .four), 18)
        XCTAssertEqual(total.points(for: .four), 36)
        XCTAssertEqual(total.points(for: .five), 0)
        XCTAssertEqual(total.totalPoints, 110)
        XCTAssertEqual(total.mediumPoints, 74)
        XCTAssertEqual(total.highPoints, 36)
    }

    func testBlankDayHasNoPoints() {
        let breakdown = ZoneBreakdown()
        XCTAssertFalse(breakdown.hasAnyPoints)
        XCTAssertEqual(breakdown.totalPoints, 0)
    }

    func testMaxDayPointsIsWednesday() {
        let week = Self.workedExampleWeek()
        // Wednesday (26 pts) is the highest-scoring day in the worked example.
        XCTAssertEqual(week.maxDayPoints, 26)
    }

    /// Builds the DESIGN.md §7 worked-example week directly from its minutes-by-zone table,
    /// independent of any real HealthKit data source.
    private static func workedExampleWeek() -> WeekData {
        let dayMinutes: [[HeartRateZone: Int]] = [
            [.one: 5, .two: 15],
            [.one: 4, .two: 18],
            [.one: 6, .three: 10, .four: 8],
            [:],
            [.one: 5, .two: 10, .three: 5],
            [.one: 4, .four: 10],
            [.one: 3, .three: 16]
        ]

        let (start, dates) = WeekData.dateRange(weekOffset: 0, firstWeekday: 2)
        let days = zip(dates, dayMinutes).map { date, minutes in
            DayEntry(date: date, breakdown: ZoneBreakdown(minutesByZone: minutes))
        }
        return WeekData(weekStartDate: start, days: days, weeklyGoal: 150)
    }
}

final class ZoneClassifierTests: XCTestCase {
    func testAutomaticBoundariesForAge30() {
        // maxHR = 220 - 30 = 190. Zone 3 is 70-79% => 133-152 bpm.
        let boundaries = ZoneClassifier.automaticBoundaries(age: 30)

        XCTAssertEqual(boundaries[.three]?.minBPM, 133)
        XCTAssertEqual(boundaries[.three]?.maxBPM, 152)
    }

    func testZoneClassificationPicksCorrectZone() {
        let boundaries = ZoneClassifier.automaticBoundaries(age: 30)

        XCTAssertEqual(ZoneClassifier.zone(forBPM: 140, boundaries: boundaries), .three)
        XCTAssertNil(ZoneClassifier.zone(forBPM: 50, boundaries: boundaries))
    }
}
