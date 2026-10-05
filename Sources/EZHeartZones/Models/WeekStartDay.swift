import Foundation

enum WeekStartDay: Int, CaseIterable, Identifiable, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int {
        rawValue
    }

    var name: String {
        Calendar.current.weekdaySymbols[rawValue - 1]
    }
}
