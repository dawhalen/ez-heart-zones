import SwiftUI

struct ZoneRingView: View {
    let breakdown: ZoneBreakdown
    var diameter: CGFloat = 190
    var lineWidth: CGFloat = 20

    private var totalPoints: Int {
        breakdown.totalPoints
    }

    var body: some View {
        ZStack {
            if totalPoints == 0 {
                Circle()
                    .stroke(AppColors.divider, style: StrokeStyle(lineWidth: lineWidth))
            } else {
                ForEach(arcs, id: \.zone) { arc in
                    Circle()
                        .trim(from: arc.start, to: arc.end)
                        .stroke(arc.zone.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                }
            }

            VStack(spacing: 0) {
                Text("\(totalPoints)")
                    .font(.system(size: diameter * 0.2, weight: .bold))
                    .monospacedDigit()
                Text("points")
                    .font(.system(size: diameter * 0.08))
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .frame(width: diameter, height: diameter)
        // `.stroke()` paints centered on the circle's path, bleeding lineWidth/2 past the frame on
        // every side — without this, that overflow silently overlaps whatever sits next to this view.
        .padding(lineWidth / 2)
    }

    private var arcs: [ZoneArc] {
        guard totalPoints > 0 else { return [] }

        var cursor: CGFloat = 0
        return HeartRateZone.allCases.map { zone in
            let fraction = CGFloat(breakdown.points(for: zone)) / CGFloat(totalPoints)
            let start = cursor
            cursor += fraction
            return ZoneArc(zone: zone, start: start, end: cursor)
        }
    }
}

private struct ZoneArc {
    let zone: HeartRateZone
    let start: CGFloat
    let end: CGFloat
}

#Preview {
    ZoneRingView(breakdown: ZoneBreakdown(minutesByZone: [.one: 6, .three: 10, .four: 8]))
}
