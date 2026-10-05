import Charts
import SwiftUI

struct HourlyPointsChart: View {
    let hourlyBreakdowns: [ZoneBreakdown]

    private struct DataPoint: Identifiable {
        let id = UUID()
        let hour: Int
        let level: IntensityLevel
        let points: Int
    }

    private var dataPoints: [DataPoint] {
        hourlyBreakdowns.indices.flatMap { hour in
            let breakdown = hourlyBreakdowns[hour]
            return [
                DataPoint(hour: hour, level: .medium, points: breakdown.mediumPoints),
                DataPoint(hour: hour, level: .high, points: breakdown.highPoints)
            ]
        }
    }

    private var hasAnyPoints: Bool {
        hourlyBreakdowns.contains { $0.hasAnyPoints }
    }

    var body: some View {
        if hasAnyPoints {
            Chart(dataPoints) { point in
                BarMark(
                    x: .value("Hour", point.hour),
                    y: .value("Points", point.points)
                )
                .foregroundStyle(point.level.color)
                .position(by: .value("Intensity", point.level.label))
            }
            .chartXAxis {
                AxisMarks(values: Array(stride(from: 0, through: 20, by: 4))) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let hour = value.as(Int.self) {
                            Text(Self.hourLabel(hour))
                        }
                    }
                }
            }
            .frame(height: 190)
        } else {
            Text("No hourly data yet")
                .font(.system(size: 13))
                .italic()
                .foregroundStyle(AppColors.chevronMuted)
                .frame(maxWidth: .infinity, minHeight: 190, alignment: .center)
        }
    }

    private static func hourLabel(_ hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: date).lowercased()
    }
}

#Preview {
    var breakdowns = Array(repeating: ZoneBreakdown(), count: 24)
    breakdowns[8] = ZoneBreakdown(minutesByZone: [.two: 15])
    breakdowns[9] = ZoneBreakdown(minutesByZone: [.three: 10, .four: 8])
    return HourlyPointsChart(hourlyBreakdowns: breakdowns)
        .padding()
}
