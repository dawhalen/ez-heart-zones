import SwiftUI

struct ZoneBreakdownListView: View {
    let breakdown: ZoneBreakdown

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("By Zone")
                .font(.system(size: 12, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(AppColors.secondaryText)
                .textCase(.uppercase)
                .padding(.bottom, 8)

            ForEach(HeartRateZone.allCases) { zone in
                ZoneRow(zone: zone, minutes: breakdown.minutes(for: zone), points: breakdown.points(for: zone))
                if zone != .five {
                    Divider().overlay(AppColors.divider)
                }
            }
        }
    }
}

private struct ZoneRow: View {
    let zone: HeartRateZone
    let minutes: Int
    let points: Int

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Circle()
                    .fill(zone.color)
                    .frame(width: 11, height: 11)
                Text("Zone \(zone.rawValue)")
                    .font(.system(size: 15, weight: .semibold))
                Text(zone.qualifier)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            HStack(spacing: 0) {
                Text("\(minutes) min")
                    .font(.system(size: 14))
                    .monospacedDigit()
                    .foregroundStyle(AppColors.secondaryText)
                    .frame(width: 54, alignment: .leading)
                Text("\(points) pts")
                    .font(.system(size: 15, weight: zone == .one ? .regular : .bold))
                    .monospacedDigit()
                    .foregroundStyle(points == 0 ? AppColors.secondaryText : AppColors.primaryText)
                    .frame(width: 58, alignment: .trailing)
            }
        }
        .padding(.vertical, 9)
        .opacity(zone == .one ? 0.55 : 1)
    }
}

#Preview {
    ZoneBreakdownListView(breakdown: ZoneBreakdown(minutesByZone: [.one: 6, .three: 10, .four: 8]))
        .padding()
}
