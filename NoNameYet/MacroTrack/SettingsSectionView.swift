import SwiftUI

struct SettingsSectionView: View {
    var body: some View {
        ZStack {
            simpleBackground()

            SimpleCardPane {
                VStack(spacing: 16) {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(SimplePalette.textPrimary)

                    Text("Placeholder for user preferences and app configuration.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(SimplePalette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .simpleCardPadding()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsSectionView()
    }
}

