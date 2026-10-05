import SwiftUI

struct DetailHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        HStack(spacing: 12) {
            BackButton()
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            Spacer()
        }
    }
}

private struct BackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)
                .frame(width: 38, height: 38)
                .background(AppColors.backButtonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    DetailHeader(title: "This Week", subtitle: "Sep 21 – 27")
        .padding()
}
