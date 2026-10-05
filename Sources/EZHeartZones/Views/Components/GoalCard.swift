import SwiftUI

struct GoalCard: View {
    let points: Int
    let goal: Int
    var confettiBurstID: Int = 0

    private var isCelebrating: Bool {
        goal > 0 && points >= goal
    }

    private var overage: Int {
        max(points - goal, 0)
    }

    private var fraction: Double {
        guard goal > 0 else { return 0 }
        return min(Double(points) / Double(goal), 1)
    }

    private var remaining: Int {
        max(goal - points, 0)
    }

    /// Unclamped, unlike `fraction` (which caps at 1 so the bar never overdraws its container) —
    /// the celebration state shows the true percentage, e.g. 108%.
    private var displayPercent: Int {
        guard goal > 0 else { return 0 }
        return Int((Double(points) / Double(goal) * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("Weekly Cardio Goal")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(AppColors.secondaryText)
                    .textCase(.uppercase)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.chevronMuted)
            }

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("\(points)")
                    .font(.system(size: 30, weight: .bold))
                    .monospacedDigit()
                Text("/ \(goal) pts")
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.secondaryText)
                if isCelebrating, overage > 0 {
                    Text("+\(overage)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(AppColors.goalAccent))
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppColors.goalTrack)
                    Capsule()
                        .fill(AppColors.goalAccent)
                        .frame(width: geometry.size.width * fraction)
                        .overlay {
                            if isCelebrating {
                                ShimmerOverlay()
                                    .clipShape(Capsule())
                            }
                        }
                }
            }
            .frame(height: 10)

            HStack {
                if isCelebrating {
                    Text("Goal reached — nice work!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.goalAccent)
                } else {
                    Text("\(remaining) pts to go")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.goalAccent)
                }
                Spacer()
                Text("\(displayPercent)%")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .padding(12)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.cardBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .topTrailing) {
            if isCelebrating {
                ZStack {
                    ConfettiBurstView(burstID: confettiBurstID)
                        .offset(x: -30, y: -70)
                    ZoomieMascot()
                        .offset(x: 6, y: -46)
                }
            }
        }
    }
}

private struct ShimmerOverlay: View {
    @State private var xFraction: CGFloat = -0.4

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .frame(width: geometry.size.width * 0.3)
                .rotationEffect(.degrees(-20))
                .offset(x: geometry.size.width * xFraction)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.1).repeatForever(autoreverses: false)) {
                        xFraction = 1.2
                    }
                }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        GoalCard(points: 110, goal: 150)
        GoalCard(points: 162, goal: 150, confettiBurstID: 1)
    }
    .padding()
    .padding(.top, 60)
}
