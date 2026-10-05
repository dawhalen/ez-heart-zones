import SwiftUI

enum HeartRateZone: Int, CaseIterable, Identifiable, Codable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5

    var id: Int {
        rawValue
    }

    var label: String {
        switch self {
        case .one: "Very Light"
        case .two: "Light"
        case .three: "Medium"
        case .four: "Hard"
        case .five: "Maximum"
        }
    }

    var multiplier: Int {
        switch self {
        case .one: 0
        case .two, .three: 1
        case .four, .five: 2
        }
    }

    var intensity: IntensityLevel? {
        switch self {
        case .one: nil
        case .two, .three: .medium
        case .four, .five: .high
        }
    }

    var color: Color {
        switch self {
        case .one: Color(hex: "A8B3C4")
        case .two: Color(hex: "5B9BD5")
        case .three: Color(hex: "4CAF8C")
        case .four: Color(hex: "E8934A")
        case .five: Color(hex: "D9564B")
        }
    }

    var qualifier: String {
        if self == .one {
            return "0× (not counted)"
        }
        return "\(label) · \(multiplier)×"
    }
}

enum IntensityLevel {
    case medium
    case high

    var label: String {
        switch self {
        case .medium: "Moderate"
        case .high: "High"
        }
    }

    var multiplierLabel: String {
        switch self {
        case .medium: "1×"
        case .high: "2×"
        }
    }

    var color: Color {
        switch self {
        case .medium: Color(hex: "B19CE8")
        case .high: Color(hex: "3A2C64")
        }
    }
}
