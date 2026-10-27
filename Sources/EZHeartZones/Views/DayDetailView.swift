import SwiftUI

struct DayDetailView: View {
    let date: Date
    let breakdown: ZoneBreakdown
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var settings: SettingsStore

    @State private var hourlyBreakdowns = Array(repeating: ZoneBreakdown(), count: 24)

    private var title: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 16) {
            DetailHeader(title: title)
                .padding(.horizontal, 22)
                .padding(.top, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    IntensityCard(mediumPoints: breakdown.mediumPoints, highPoints: breakdown.highPoints)

                    TabView {
                        ZoneRingView(breakdown: breakdown)
                            .padding(.top, 8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                        HourlyPointsChart(hourlyBreakdowns: hourlyBreakdowns)
                            .padding(.top, 8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 256)

                    ZoneBreakdownListView(breakdown: breakdown)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 12)
            }
        }
        .background(AppColors.background)
        .navigationBarHidden(true)
        .task(id: date) {
            let age = healthKitManager.fetchAge()
            let boundaries = settings.effectiveBoundaries(age: age)
            hourlyBreakdowns = await (try? healthKitManager.fetchHourlyZoneBreakdowns(
                day: date,
                boundaries: boundaries
            ))
                ?? Array(repeating: ZoneBreakdown(), count: 24)
        }
    }
}

#Preview {
    DayDetailView(
        date: Date(),
        breakdown: ZoneBreakdown(minutesByZone: [.one: 6, .three: 10, .four: 8]),
        healthKitManager: HealthKitManager(),
        settings: SettingsStore()
    )
}
