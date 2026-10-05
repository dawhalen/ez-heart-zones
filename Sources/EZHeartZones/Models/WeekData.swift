import Foundation

struct DayEntry: Identifiable {
    let id = UUID()
    let date: Date
    let breakdown: ZoneBreakdown

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

struct WeekData {
    let weekStartDate: Date
    let days: [DayEntry]
    var weeklyGoal: Int = 150

    var totalBreakdown: ZoneBreakdown {
        days.reduce(ZoneBreakdown()) { $0 + $1.breakdown }
    }

    var maxDayPoints: Int {
        days.map(\.breakdown.totalPoints).max() ?? 0
    }

    var dateRangeDescription: String {
        guard let weekEndDate = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) else {
            return ""
        }

        let startMonth = monthFormatter.string(from: weekStartDate)
        let endMonth = monthFormatter.string(from: weekEndDate)
        let startDay = dayFormatter.string(from: weekStartDate)
        let endDay = dayFormatter.string(from: weekEndDate)

        if startMonth == endMonth {
            return "\(startMonth) \(startDay) – \(endDay)"
        }
        return "\(startMonth) \(startDay) – \(endMonth) \(endDay)"
    }

    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    /// Dates for the 7 days of the given week offset (0 = this week), starting on `firstWeekday`
    /// (Calendar's 1 = Sunday ... 7 = Saturday numbering).
    static func dateRange(weekOffset: Int, firstWeekday: Int) -> (start: Date, days: [Date]) {
        var calendar = Calendar.current
        calendar.firstWeekday = firstWeekday

        let today = calendar.startOfDay(for: Date())
        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let weekStart = calendar.date(byAdding: .day, value: weekOffset * 7, to: thisWeekStart) ?? thisWeekStart

        let days = (0 ..< 7).map { dayIndex in
            calendar.date(byAdding: .day, value: dayIndex, to: weekStart) ?? weekStart
        }

        return (weekStart, days)
    }
}
