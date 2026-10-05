import SwiftUI

struct WeekDetailView: View {
    let week: WeekData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                DetailHeader(title: "This Week", subtitle: week.dateRangeDescription)

                IntensityCard(
                    mediumPoints: week.totalBreakdown.mediumPoints,
                    highPoints: week.totalBreakdown.highPoints
                )

                ZoneRingView(breakdown: week.totalBreakdown, diameter: 175, lineWidth: 18)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                ZoneBreakdownListView(breakdown: week.totalBreakdown)
            }
            .padding(.horizontal, 22)
            .padding(.top, 26)
            .padding(.bottom, 26)
        }
        .background(AppColors.background)
        .navigationBarHidden(true)
    }
}

#Preview {
    let (start, dates) = WeekData.dateRange(weekOffset: 0, firstWeekday: 2)
    let days = dates.map { DayEntry(date: $0, breakdown: ZoneBreakdown(minutesByZone: [.two: 15])) }
    WeekDetailView(week: WeekData(weekStartDate: start, days: days, weeklyGoal: 150))
}
