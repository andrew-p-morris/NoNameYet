import SwiftUI

struct CalendarSectionView: View {
    var body: some View {
        ZStack {
            simpleBackground()

            SimpleCardPane {
                VStack(spacing: 16) {
                    Text("Calendar")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(SimplePalette.textPrimary)

                    Text("Placeholder for scheduling and progress calendar.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(SimplePalette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .simpleCardPadding()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Calendar")
    }
}

#Preview {
    NavigationStack {
        CalendarSectionView()
    }
}

