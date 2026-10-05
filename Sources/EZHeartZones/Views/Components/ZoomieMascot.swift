import SwiftUI

/// "Zoomie" — the five-pointed gold star mascot show in the goal card's celebration state.
/// All coordinates below are in the reference 80x90 viewBox from DESIGN.md §8.
struct ZoomieMascot: View {
    private static let canvasSize = CGSize(width: 80, height: 90)

    private enum BodyPhase: CaseIterable {
        case rest, raised, dipped

        var rotationDegrees: Double {
            switch self {
            case .rest: -10
            case .raised: 12
            case .dipped: -4
            }
        }

        var scale: Double {
            switch self {
            case .rest: 1.0
            case .raised: 1.08
            case .dipped: 0.95
            }
        }

        var animation: Animation {
            switch self {
            case .rest: .easeInOut(duration: 0.9 * 0.4)
            case .raised: .easeInOut(duration: 0.9 * 0.3)
            case .dipped: .easeInOut(duration: 0.9 * 0.3)
            }
        }
    }

    @State private var limbSwing = false

    private static let starPath = Path { path in
        path.move(to: CGPoint(x: 40, y: 4))
        path.addLine(to: CGPoint(x: 49, y: 28))
        path.addLine(to: CGPoint(x: 75, y: 28))
        path.addLine(to: CGPoint(x: 54, y: 44))
        path.addLine(to: CGPoint(x: 62, y: 70))
        path.addLine(to: CGPoint(x: 40, y: 54))
        path.addLine(to: CGPoint(x: 18, y: 70))
        path.addLine(to: CGPoint(x: 26, y: 44))
        path.addLine(to: CGPoint(x: 5, y: 28))
        path.addLine(to: CGPoint(x: 31, y: 28))
        path.closeSubpath()
    }

    private static let smilePath = Path { path in
        path.move(to: CGPoint(x: 31, y: 51))
        path.addQuadCurve(to: CGPoint(x: 49, y: 51), control: CGPoint(x: 40, y: 58))
    }

    var body: some View {
        // Limbs live inside the body's rotate/scale so they stay attached to the star's points;
        // their own swing is layered on top, pivoting at those points.
        PhaseAnimator(BodyPhase.allCases) { phase in
            ZStack {
                limbs
                starAndFace
            }
            .rotationEffect(.degrees(phase.rotationDegrees), anchor: unitAnchor(CGPoint(x: 40, y: 40)))
            .scaleEffect(phase.scale, anchor: unitAnchor(CGPoint(x: 40, y: 40)))
        } animation: { phase in
            phase.animation
        }
        .frame(width: Self.canvasSize.width, height: Self.canvasSize.height)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.375).repeatForever(autoreverses: true)) {
                limbSwing = true
            }
        }
    }

    private var limbs: some View {
        ZStack {
            limb(from: CGPoint(x: 18, y: 70), toPoint: CGPoint(x: 10, y: 88), color: AppColors.mascotGoldDark)
                .rotationEffect(.degrees(limbSwing ? -18 : 14), anchor: unitAnchor(CGPoint(x: 18, y: 70)))
            limb(from: CGPoint(x: 62, y: 70), toPoint: CGPoint(x: 70, y: 88), color: AppColors.mascotGoldDark)
                .rotationEffect(.degrees(limbSwing ? 18 : -14), anchor: unitAnchor(CGPoint(x: 62, y: 70)))

            limb(from: CGPoint(x: 5, y: 28), toPoint: CGPoint(x: -14, y: 10), color: AppColors.mascotGold)
                .rotationEffect(.degrees(limbSwing ? 30 : -16), anchor: unitAnchor(CGPoint(x: 5, y: 28)))
            limb(from: CGPoint(x: 75, y: 28), toPoint: CGPoint(x: 94, y: 10), color: AppColors.mascotGold)
                .rotationEffect(.degrees(limbSwing ? -30 : 16), anchor: unitAnchor(CGPoint(x: 75, y: 28)))
        }
    }

    private var starAndFace: some View {
        ZStack {
            Self.starPath.fill(AppColors.mascotGold)

            Circle().fill(.white).frame(width: 11, height: 11).position(x: 30, y: 38)
            Circle().fill(AppColors.primaryText).frame(width: 4.8, height: 4.8).position(x: 31, y: 39)
            Circle().fill(.white).frame(width: 11, height: 11).position(x: 50, y: 38)
            Circle().fill(AppColors.primaryText).frame(width: 4.8, height: 4.8).position(x: 51, y: 39)

            Ellipse().fill(AppColors.mascotBlush.opacity(0.9)).frame(width: 12, height: 6.8).position(x: 25, y: 48)
            Ellipse().fill(AppColors.mascotBlush.opacity(0.9)).frame(width: 12, height: 6.8).position(x: 55, y: 48)

            Self.smilePath.stroke(AppColors.primaryText, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        }
        .frame(width: Self.canvasSize.width, height: Self.canvasSize.height)
    }

    private func limb(from: CGPoint, toPoint: CGPoint, color: Color) -> some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: toPoint)
        }
        .stroke(color, style: StrokeStyle(lineWidth: 9, lineCap: .round))
        .frame(width: Self.canvasSize.width, height: Self.canvasSize.height)
    }

    private func unitAnchor(_ point: CGPoint) -> UnitPoint {
        UnitPoint(x: point.x / Self.canvasSize.width, y: point.y / Self.canvasSize.height)
    }
}

#Preview {
    ZoomieMascot()
        .padding(60)
        .background(AppColors.background)
}
