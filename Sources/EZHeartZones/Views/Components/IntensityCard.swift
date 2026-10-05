import SwiftUI

struct IntensityCard: View {
    let mediumPoints: Int
    let highPoints: Int

    private var totalPoints: Int {
        mediumPoints + highPoints
    }

    private func percent(_ points: Int) -> Int {
        guard totalPoints > 0 else { return 0 }
        return Int((Double(points) / Double(totalPoints) * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Moderate vs High Intensity")
                .font(.system(size: 12, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(AppColors.secondaryText)
                .textCase(.uppercase)

            HStack {
                legendLabel(level: .medium, points: mediumPoints)
                Spacer()
                legendLabel(level: .high, points: highPoints)
            }
            .font(.system(size: 14))

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(IntensityLevel.medium.color)
                        .frame(width: totalPoints > 0 ? geometry.size
                            .width * CGFloat(mediumPoints) / CGFloat(totalPoints) : 0)
                    Rectangle()
                        .fill(IntensityLevel.high.color)
                }
            }
            .frame(height: 13)
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .padding(13)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.cardBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func legendLabel(level: IntensityLevel, points: Int) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(level.color)
                .frame(width: 9, height: 9)
            Text("\(level.label) · \(points) pts (\(percent(points))%)")
        }
    }
}

#Preview {
    IntensityCard(mediumPoints: 10, highPoints: 16)
        .padding()
}
