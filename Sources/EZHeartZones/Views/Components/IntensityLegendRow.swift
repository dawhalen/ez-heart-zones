import SwiftUI

struct IntensityLegendRow: View {
    var body: some View {
        HStack(spacing: 16) {
            legendItem(level: .medium)
            legendItem(level: .high)
        }
        .font(.system(size: 11))
        .foregroundStyle(AppColors.secondaryText)
    }

    private func legendItem(level: IntensityLevel) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(level.color)
                .frame(width: 7, height: 7)
            Text("\(level.label) Intensity · \(level.multiplierLabel)")
        }
    }
}

#Preview {
    IntensityLegendRow()
        .padding()
}
