import SwiftUI

struct NutritionSectionView: View {
    var body: some View {
        ZStack {
            simpleBackground()

            SimpleCardPane {
                VStack(spacing: 16) {
                    Text("Nutrition Section")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(SimplePalette.textPrimary)

                    Text("Placeholder for meal tracking and macro breakdown.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(SimplePalette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .simpleCardPadding()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Nutrition")
    }
}

#Preview {
    NavigationStack {
        NutritionSectionView()
    }
}

