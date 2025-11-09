import SwiftUI

enum MenuDestination: String, CaseIterable, Identifiable {
    case workout = "Workout"
    case nutrition = "Nutrition"
    case calendar = "Calendar"
    case data = "Data"
    case achievements = "Achievements"
    case weight = "Weight"
    case settings = "Settings"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .workout: return "figure.run"
        case .nutrition: return "fork.knife"
        case .calendar: return "calendar"
        case .data: return "chart.bar.fill"
        case .achievements: return "trophy.fill"
        case .weight: return "scalemass"
        case .settings: return "gearshape"
        }
    }
}

struct SideMenuView: View {
    @Binding var isOpen: Bool
    let onSelectDestination: (MenuDestination) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MENU")
                .font(SimplePalette.retroFont(size: 28, weight: .bold))
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
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(SimplePalette.retroRed)
                            .frame(width: 32)

                        Text(destination.rawValue.uppercased())
                            .font(SimplePalette.retroFont(size: 17, weight: .bold))
                            .foregroundStyle(SimplePalette.textPrimary)

                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(SimplePalette.retroWhite.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(SimplePalette.retroBlack, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
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

