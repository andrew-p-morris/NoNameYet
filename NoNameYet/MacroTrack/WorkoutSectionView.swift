import SwiftUI

struct WorkoutSectionView: View {
    var body: some View {
        ZStack {
            simpleBackground()

            SimpleCardPane {
                VStack(spacing: 16) {
                    Text("Workout Section")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(SimplePalette.textPrimary)

                    Text("Placeholder for workout tracking and history.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(SimplePalette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .simpleCardPadding()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Workout")
    }
}

#Preview {
    NavigationStack {
        WorkoutSectionView()
    }
}

