import SwiftUI

struct AchievementsSectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData
    @State private var unlockedAchievement: Int?
    
    private let achievements: [Achievement] = [
        Achievement(id: 1, name: "FIRST STEPS", description: "Complete your first workout"),
        Achievement(id: 2, name: "WEEK WARRIOR", description: "Complete 7 workouts in a week"),
        Achievement(id: 3, name: "MONTH MASTER", description: "Complete 30 workouts in a month"),
        Achievement(id: 4, name: "MACRO MASTER", description: "Hit all macro targets for 7 days"),
        Achievement(id: 5, name: "HYDRATION HERO", description: "Meet water goal for 14 days"),
        Achievement(id: 6, name: "PERFECT WEEK", description: "Complete all workouts and macros for 7 days"),
        Achievement(id: 7, name: "STREAK STARTER", description: "Maintain a 5-day streak"),
        Achievement(id: 8, name: "STREAK CHAMPION", description: "Maintain a 30-day streak"),
        Achievement(id: 9, name: "EARLY BIRD", description: "Complete morning workout 10 times"),
        Achievement(id: 10, name: "NIGHT OWL", description: "Complete evening workout 10 times"),
        Achievement(id: 11, name: "CARDIO KING", description: "Complete 50 cardio sessions"),
        Achievement(id: 12, name: "STRENGTH SAVAGE", description: "Complete 50 strength sessions"),
        Achievement(id: 13, name: "PROTEIN PRO", description: "Hit protein goal 30 days"),
        Achievement(id: 14, name: "CARB CONQUEROR", description: "Hit carb goal 30 days"),
        Achievement(id: 15, name: "FAT FIGHTER", description: "Hit fat goal 30 days"),
        Achievement(id: 16, name: "CALORIE CRUSHER", description: "Hit calorie goal 30 days"),
        Achievement(id: 17, name: "ZERO SUGAR", description: "Stay under sugar limit 7 days"),
        Achievement(id: 18, name: "PLAN PERFECT", description: "Follow plan for 100 days"),
        Achievement(id: 19, name: "LEGEND", description: "Unlock all achievements"),
        Achievement(id: 20, name: "DEDICATION", description: "Log activity for 365 days")
    ]
    
    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            simpleBackground()
            
            VStack(alignment: .leading, spacing: 32) {
                header
                
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 24) {
                        ForEach(achievements) { achievement in
                            achievementCoin(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
            .padding(.top, 60)
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
            
            Text("ACHIEVEMENTS")
                .font(SimplePalette.retroFont(size: 26, weight: .bold))
                .foregroundStyle(SimplePalette.textPrimary)
        }
        .padding(.horizontal, 24)
    }
    
    private func achievementCoin(achievement: Achievement) -> some View {
        Button(action: {
            // Unlock achievement with animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                unlockedAchievement = achievement.id
                onboardingData.earnedAchievements.insert(achievement.id)
            }
            
            // Navigate to home after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }) {
            VStack(spacing: 12) {
                SpinningCoinView(isLocked: !onboardingData.earnedAchievements.contains(achievement.id))
                    .scaleEffect(unlockedAchievement == achievement.id ? 1.3 : 1.0)
                
                Text(achievement.name)
                    .font(SimplePalette.retroFont(size: 11, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 32)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct Achievement: Identifiable {
    let id: Int
    let name: String
    let description: String
}

struct SpinningCoinView: View {
    let isLocked: Bool
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isLocked ? Color.gray.opacity(0.3) : Color.yellow.opacity(0.8))
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(isLocked ? SimplePalette.cardBorder : Color.yellow, lineWidth: 3)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 0, x: 3, y: 3)
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            } else {
                Text("$")
                    .font(SimplePalette.retroFont(size: 32, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
        }
        .onAppear {
            // Always spin slowly, even when locked
            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    NavigationStack {
        AchievementsSectionView()
    }
    .environmentObject(OnboardingData())
}

