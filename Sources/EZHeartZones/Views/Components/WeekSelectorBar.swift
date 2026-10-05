import SwiftUI

struct WeekSelectorBar: View {
    @Binding var weekOffset: Int
    let dateRangeDescription: String

    var body: some View {
        HStack {
            Button {
                weekOffset -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: 34, height: 34)
            }

            Spacer()

            VStack(spacing: 1) {
                Text(weekOffset == 0 ? "This Week" : "\(-weekOffset) week\(weekOffset == -1 ? "" : "s") ago")
                    .font(.system(size: 15, weight: .semibold))
                Text(dateRangeDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            Button {
                weekOffset += 1
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(weekOffset >= 0 ? AppColors.chevronMuted : AppColors.primaryText)
                    .frame(width: 34, height: 34)
            }
            .disabled(weekOffset >= 0)
        }
    }
}

#Preview {
    WeekSelectorBar(weekOffset: .constant(0), dateRangeDescription: "Sep 21 – 27")
        .padding()
}
