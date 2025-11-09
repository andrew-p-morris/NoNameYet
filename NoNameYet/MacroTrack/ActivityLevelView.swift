import SwiftUI

struct ActivityLevelView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData

    @State private var selectedLevel: ActivityLevel?
    @State private var navigateToPlanGeneration = false

    var body: some View {
        ZStack {
            simpleBackground()

            VStack(alignment: .leading, spacing: 32) {
                header

                SimpleCardPane {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(ActivityLevel.allCases) { level in
                            activityLevelButton(level: level)
                        }
                    }
                    .padding(.vertical, 32)
                    .simpleCardPadding()
                }

                Spacer(minLength: 0)

                bottomArrow
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
        }
        .onAppear(perform: configureFromData)
        .navigationDestination(isPresented: $navigateToPlanGeneration) {
            PlanGenerationView()
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(SimplePalette.retroWhite)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(SimplePalette.retroBlack, lineWidth: 3)
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                    )
            }
            .buttonStyle(.plain)

            Text("ACTIVITY LEVEL")
                .font(SimplePalette.retroFont(size: 26, weight: .bold))
                .foregroundStyle(SimplePalette.textPrimary)
        }
    }

    private func activityLevelButton(level: ActivityLevel) -> some View {
        let isSelected = selectedLevel == level

        return Button(action: {
            selectedLevel = level
            onboardingData.activityLevel = level
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(level.rawValue.uppercased())
                        .font(SimplePalette.retroFont(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(SimplePalette.retroRed)
                    }
                }
                
                Text(level.description.uppercased())
                    .font(SimplePalette.retroFont(size: 14, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? SimplePalette.retroRed.opacity(0.2) : SimplePalette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isSelected ? SimplePalette.retroRed : SimplePalette.cardBorder, lineWidth: 3)
                    )
                    .shadow(color: isSelected ? Color.black.opacity(0.3) : Color.clear, radius: 0, x: 2, y: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var bottomArrow: some View {
        HStack {
            Spacer()

            Button(action: proceed) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(SimplePalette.retroWhite)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(SimplePalette.retroBlack, lineWidth: 3)
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                    )
            }
            .buttonStyle(.plain)
            .opacity(selectedLevel == nil ? 0.4 : 1)
            .disabled(selectedLevel == nil)
        }
    }

    private func proceed() {
        navigateToPlanGeneration = true
    }

    private func configureFromData() {
        if let storedLevel = onboardingData.activityLevel {
            selectedLevel = storedLevel
        }
    }
}

#Preview {
    NavigationStack {
        ActivityLevelView()
    }
    .environmentObject(OnboardingData())
}

