import SwiftUI

struct FitnessGoalsView: View {
    private enum Route: Hashable {
        case dietaryRestrictions
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData

    @State private var selectedGoals: Set<Int> = []
    @State private var jiggleGoal: Int?
    @State private var navigateForward = false

    private let goals = Array(1...7)
    private let gridColumns = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]

    var body: some View {
        ZStack {
            simpleBackground()

            VStack(alignment: .leading, spacing: 32) {
                header

                SimpleCardPane {
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        ForEach(goals, id: \.self) { goal in
                            goalBubble(for: goal)
                        }
                    }
                    .padding(.vertical, 32)
                    .simpleCardPadding()
                }

                Spacer()

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
                    .opacity(selectedGoals.isEmpty ? 0.4 : 1)
                    .disabled(selectedGoals.isEmpty)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
        }
        .navigationDestination(isPresented: $navigateForward) {
            DietaryRestrictionsView()
        }
        .onAppear {
            selectedGoals = Set(onboardingData.goals)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
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

            Text("WHAT ARE YOUR FITNESS GOALS")
                .font(SimplePalette.retroFont(size: 26, weight: .bold))
                .foregroundStyle(SimplePalette.textPrimary)
        }
    }

    private func goalBubble(for goal: Int) -> some View {
        let isSelected = selectedGoals.contains(goal)
        let goalName = onboardingData.goalDescription(for: goal)

        return Button {
            toggle(goal: goal)
        } label: {
            Text(goalName.uppercased())
                .font(SimplePalette.retroFont(size: 14, weight: .bold))
                .foregroundStyle(isSelected ? SimplePalette.retroWhite : SimplePalette.cardTextPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? SimplePalette.retroRed : SimplePalette.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(SimplePalette.retroBlack, lineWidth: 3)
                        )
                        .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(jiggleGoal == goal ? 1.08 : 1)
        .animation(.spring(response: 0.32, dampingFraction: 0.55, blendDuration: 0.1), value: jiggleGoal)
    }

    private func toggle(goal: Int) {
        if selectedGoals.contains(goal) {
            selectedGoals.remove(goal)
        } else {
            guard selectedGoals.count < 5 else { triggerJiggle(for: goal); return }
            selectedGoals.insert(goal)
            triggerJiggle(for: goal)
        }

        onboardingData.goals = selectedGoals.sorted()
    }

    private func triggerJiggle(for goal: Int) {
        jiggleGoal = goal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if jiggleGoal == goal {
                jiggleGoal = nil
            }
        }
    }

    private func proceed() {
        onboardingData.goals = selectedGoals.sorted()
        navigateForward = true
    }
}

#Preview {
    NavigationStack {
        FitnessGoalsView()
    }
    .environmentObject(OnboardingData())
}


