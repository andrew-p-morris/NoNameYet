import SwiftUI

struct DataSectionView: View {
    var body: some View {
        ZStack {
            simpleBackground()

            SimpleCardPane {
                VStack(spacing: 16) {
                    Text("Data")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(SimplePalette.textPrimary)

                    Text("Placeholder for analytics, charts, and progress tracking.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(SimplePalette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .simpleCardPadding()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Data")
    }
}

#Preview {
    NavigationStack {
        DataSectionView()
    }
}

