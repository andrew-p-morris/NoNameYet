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

    private let goals = Array(1...10)
    private let gridColumns = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]

    var body: some View {
        ZStack {
            liquidGlassBackground()

            VStack(alignment: .leading, spacing: 32) {
                header

                LiquidGlassPane {
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        ForEach(goals, id: \.self) { goal in
                            goalBubble(for: goal)
                        }
                    }
                    .padding(.vertical, 32)
                    .liquidGlassPanePadding()
                }

                Spacer()

                HStack {
                    Spacer()

                    Button(action: proceed) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(LiquidGlassPalette.textPrimary)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [LiquidGlassPalette.glassTop, LiquidGlassPalette.glassBottom.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(LiquidGlassPalette.glassBorder, lineWidth: 1)
                                    )
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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LiquidGlassPalette.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [LiquidGlassPalette.glassTop, LiquidGlassPalette.glassBottom.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(LiquidGlassPalette.glassBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)

            Text("What are your fitness goals")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(LiquidGlassPalette.textPrimary)
        }
    }

    private func goalBubble(for goal: Int) -> some View {
        let isSelected = selectedGoals.contains(goal)

        return Button {
            toggle(goal: goal)
        } label: {
            Text("Goal \(goal)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? LiquidGlassPalette.textPrimary : LiquidGlassPalette.textPrimary.opacity(0.85))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    Capsule()
                        .fill(goalGradient(isSelected: isSelected))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? LiquidGlassPalette.accentBright.opacity(0.6) : LiquidGlassPalette.glassBorder, lineWidth: 1.2)
                        )
                        .shadow(color: isSelected ? LiquidGlassPalette.accentBright.opacity(0.35) : .clear, radius: 12, y: 8)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(jiggleGoal == goal ? 1.08 : 1)
        .animation(.spring(response: 0.32, dampingFraction: 0.55, blendDuration: 0.1), value: jiggleGoal)
    }

    private func goalGradient(isSelected: Bool) -> LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [LiquidGlassPalette.accentSoft.opacity(0.65), LiquidGlassPalette.accentBright.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [LiquidGlassPalette.glassTop, LiquidGlassPalette.glassBottom.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
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


