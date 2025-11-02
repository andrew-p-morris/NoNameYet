import SwiftUI

enum MenuDestination: String, CaseIterable, Identifiable {
    case workout = "Workout"
    case nutrition = "Nutrition"
    case calendar = "Calendar"
    case data = "Data"
    case settings = "Settings"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .workout: return "figure.run"
        case .nutrition: return "fork.knife"
        case .calendar: return "calendar"
        case .data: return "chart.bar.fill"
        case .settings: return "gearshape"
        }
    }
}

struct SideMenuView: View {
    @Binding var isOpen: Bool
    let onSelectDestination: (MenuDestination) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Menu")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(SimplePalette.textPrimary)
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)

            ForEach(MenuDestination.allCases) { destination in
                Button {
                    onSelectDestination(destination)
                    isOpen = false
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: destination.iconName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(SimplePalette.accentBlue)
                            .frame(width: 32)

                        Text(destination.rawValue)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(SimplePalette.textPrimary)

                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(SimplePalette.cardBackground.opacity(0.8))
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .frame(width: 280)
        .background(SimplePalette.background)
    }
}

