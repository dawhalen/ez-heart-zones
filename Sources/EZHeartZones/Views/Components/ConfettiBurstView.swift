import SwiftUI

/// A single ~1.6s confetti burst, fired once per change in `burstID` (not a looping animation —
/// DESIGN.md §8 explicitly calls out that the mockup's `infinite` CSS loop is a demo-only
/// convenience, and the real app should fire a short one-shot burst instead).
struct ConfettiBurstView: View {
    let burstID: Int

    private struct Particle {
        let offsetX: CGFloat
        let offsetY: CGFloat
        let size: CGFloat
        let isCircle: Bool
        let color: Color
        let delay: Double
        let maxRotation: Double
    }

    private static let particles: [Particle] = [
        Particle(
            offsetX: -34,
            offsetY: -6,
            size: 8,
            isCircle: true,
            color: AppColors.goalAccent,
            delay: 0,
            maxRotation: 180
        ),
        Particle(
            offsetX: -14,
            offsetY: 6,
            size: 6,
            isCircle: false,
            color: AppColors.mascotGold,
            delay: 0.3,
            maxRotation: 160
        ),
        Particle(
            offsetX: 14,
            offsetY: -12,
            size: 7,
            isCircle: true,
            color: HeartRateZone.two.color,
            delay: 0.55,
            maxRotation: 200
        ),
        Particle(
            offsetX: 40,
            offsetY: 2,
            size: 6,
            isCircle: false,
            color: AppColors.confettiPink,
            delay: 0.8,
            maxRotation: 170
        ),
        Particle(
            offsetX: 66,
            offsetY: 12,
            size: 7,
            isCircle: true,
            color: AppColors.mascotGold,
            delay: 0.2,
            maxRotation: 190
        ),
        Particle(
            offsetX: 90,
            offsetY: -10,
            size: 6,
            isCircle: false,
            color: AppColors.goalAccent,
            delay: 0.65,
            maxRotation: 200
        )
    ]

    var body: some View {
        ZStack {
            ForEach(Array(Self.particles.enumerated()), id: \.offset) { _, particle in
                ParticleView(particle: particle, burstID: burstID)
            }
        }
    }

    private struct ParticleView: View {
        let particle: Particle
        let burstID: Int

        @State private var opacity: Double = 0
        @State private var travel: CGFloat = 0
        @State private var rotation: Double = 0

        private static let lifetime = 1.6

        var body: some View {
            shape
                .fill(particle.color)
                .frame(width: particle.size, height: particle.size)
                .opacity(opacity)
                .offset(x: particle.offsetX, y: particle.offsetY - travel)
                .rotationEffect(.degrees(rotation))
                .task(id: burstID) {
                    guard burstID > 0 else { return }
                    opacity = 0
                    travel = 0
                    rotation = 0
                    try? await Task.sleep(for: .seconds(particle.delay))
                    withAnimation(.easeIn(duration: Self.lifetime * 0.18)) {
                        opacity = 1
                    }
                    withAnimation(.easeInOut(duration: Self.lifetime)) {
                        travel = 50
                        rotation = particle.maxRotation
                    }
                    try? await Task.sleep(for: .seconds(Self.lifetime * 0.82))
                    withAnimation(.easeOut(duration: Self.lifetime * 0.18)) {
                        opacity = 0
                    }
                }
        }

        private var shape: AnyShape {
            if particle.isCircle {
                AnyShape(Circle())
            } else {
                AnyShape(RoundedRectangle(cornerRadius: 2))
            }
        }
    }
}

#Preview {
    ConfettiBurstView(burstID: 1)
        .frame(width: 200, height: 200)
        .background(AppColors.background)
}
