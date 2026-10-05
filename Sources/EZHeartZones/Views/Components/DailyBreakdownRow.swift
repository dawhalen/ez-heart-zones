import SwiftUI

struct DailyBreakdownRow: View {
    let day: DayEntry
    let maxDayPoints: Int

    private var abbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: day.date)
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: day.date)
    }

    private var barFraction: CGFloat {
        guard maxDayPoints > 0 else { return 0 }
        return CGFloat(day.breakdown.totalPoints) / CGFloat(maxDayPoints)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text(abbreviation)
                    .font(.system(size: 16, weight: day.isToday ? .bold : .semibold))
                    .foregroundStyle(day.isToday ? AppColors.goalAccent : AppColors.primaryText)
                Text(day.isToday ? "Today" : dayNumber)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.secondaryText)
            }
            .frame(width: 46, alignment: .leading)

            if day.breakdown.hasAnyPoints {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        let mediumFraction = CGFloat(day.breakdown.mediumPoints) / CGFloat(day.breakdown.totalPoints)
                        Rectangle()
                            .fill(IntensityLevel.medium.color)
                            .frame(width: geometry.size.width * barFraction * mediumFraction)
                        Rectangle()
                            .fill(IntensityLevel.high.color)
                            .frame(width: geometry.size.width * barFraction * (1 - mediumFraction))
                    }
                }
                .frame(height: 16)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("\(day.breakdown.totalPoints) pts")
                    .font(.system(size: 16, weight: .semibold))
                    .monospacedDigit()
                    .frame(width: 60, alignment: .trailing)
            } else {
                Text("(no points)")
                    .font(.system(size: 14))
                    .italic()
                    .foregroundStyle(AppColors.chevronMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer().frame(width: 60)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.chevronMuted)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, day.isToday ? 10 : 2)
        .background(day.isToday ? AppColors.todayRowBackground : Color.clear)
        .overlay(alignment: .leading) {
            if day.isToday {
                Rectangle()
                    .fill(AppColors.goalAccent)
                    .frame(width: 4)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: day.isToday ? 10 : 0))
        .overlay(alignment: .bottom) {
            if !day.isToday {
                Rectangle()
                    .fill(AppColors.divider)
                    .frame(height: 1)
            }
        }
    }
}

#Preview {
    VStack {
        DailyBreakdownRow(
            day: DayEntry(date: Date(), breakdown: ZoneBreakdown(minutesByZone: [.two: 15])),
            maxDayPoints: 26
        )
        DailyBreakdownRow(day: DayEntry(date: Date(), breakdown: ZoneBreakdown()), maxDayPoints: 26)
    }
    .padding()
}
