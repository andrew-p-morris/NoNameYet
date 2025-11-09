import SwiftUI

struct AchievementsSectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData
    @State private var unlockedAchievement: Int?
    @State private var selectedAchievement: Achievement?
    
    static let achievements: [Achievement] = [
        // Distance Traveled (10)
        Achievement(id: 1, category: .distance, name: "FIRST MILE", description: "Travel 1 mile", threshold: 1),
        Achievement(id: 2, category: .distance, name: "10 MILES", description: "Travel 10 miles", threshold: 10),
        Achievement(id: 3, category: .distance, name: "QUARTER CENTURY", description: "Travel 25 miles", threshold: 25),
        Achievement(id: 4, category: .distance, name: "HALF CENTURY", description: "Travel 50 miles", threshold: 50),
        Achievement(id: 5, category: .distance, name: "CENTURY", description: "Travel 100 miles", threshold: 100),
        Achievement(id: 6, category: .distance, name: "DISTANCE WARRIOR", description: "Travel 250 miles", threshold: 250),
        Achievement(id: 7, category: .distance, name: "ULTRA RUNNER", description: "Travel 500 miles", threshold: 500),
        Achievement(id: 8, category: .distance, name: "COAST TO COAST", description: "Travel 1000 miles", threshold: 1000),
        Achievement(id: 9, category: .distance, name: "CROSS COUNTRY", description: "Travel 2000 miles", threshold: 2000),
        Achievement(id: 10, category: .distance, name: "WORLD TRAVELER", description: "Travel 5000 miles", threshold: 5000),
        
        // App Usage Streaks (10)
        Achievement(id: 11, category: .streak, name: "WEEK STREAK", description: "Use app 7 days in a row", threshold: 7),
        Achievement(id: 12, category: .streak, name: "TWO WEEK STREAK", description: "Use app 14 days in a row", threshold: 14),
        Achievement(id: 13, category: .streak, name: "MONTH STREAK", description: "Use app 30 days in a row", threshold: 30),
        Achievement(id: 14, category: .streak, name: "TWO MONTH STREAK", description: "Use app 60 days in a row", threshold: 60),
        Achievement(id: 15, category: .streak, name: "QUARTER YEAR", description: "Use app 90 days in a row", threshold: 90),
        Achievement(id: 16, category: .streak, name: "HALF YEAR", description: "Use app 180 days in a row", threshold: 180),
        Achievement(id: 17, category: .streak, name: "THREE QUARTERS", description: "Use app 270 days in a row", threshold: 270),
        Achievement(id: 18, category: .streak, name: "YEAR STREAK", description: "Use app 365 days in a row", threshold: 365),
        Achievement(id: 19, category: .streak, name: "500 DAY LEGEND", description: "Use app 500 days in a row", threshold: 500),
        Achievement(id: 20, category: .streak, name: "UNBREAKABLE", description: "Use app 730 days in a row", threshold: 730),
        
        // Weight Goals (10)
        Achievement(id: 21, category: .weight, name: "GOAL WEIGHT", description: "Reach your target weight", threshold: 1),
        Achievement(id: 22, category: .weight, name: "FIRST WEIGH IN", description: "Record your first weight", threshold: 1),
        Achievement(id: 23, category: .weight, name: "WEEK LOGGER", description: "5 consecutive weigh-ins", threshold: 5),
        Achievement(id: 24, category: .weight, name: "MONTH LOGGER", description: "10 consecutive weigh-ins", threshold: 10),
        Achievement(id: 25, category: .weight, name: "QUARTER LOGGER", description: "15 consecutive weigh-ins", threshold: 15),
        Achievement(id: 26, category: .weight, name: "HALF YEAR LOGGER", description: "25 consecutive weigh-ins", threshold: 25),
        Achievement(id: 27, category: .weight, name: "YEAR LOGGER", description: "52 consecutive weigh-ins", threshold: 52),
        Achievement(id: 28, category: .weight, name: "NEVER MISS", description: "100 consecutive weigh-ins", threshold: 100),
        Achievement(id: 29, category: .weight, name: "DEDICATED TRACKER", description: "150 consecutive weigh-ins", threshold: 150),
        Achievement(id: 30, category: .weight, name: "SCALE MASTER", description: "200 consecutive weigh-ins", threshold: 200),
        
        // Macro Goals (10)
        Achievement(id: 31, category: .macros, name: "MACRO WEEK", description: "Hit targets 7 days in a row", threshold: 7),
        Achievement(id: 32, category: .macros, name: "MACRO TWO WEEK", description: "Hit targets 14 days in a row", threshold: 14),
        Achievement(id: 33, category: .macros, name: "MACRO THREE WEEK", description: "Hit targets 21 days in a row", threshold: 21),
        Achievement(id: 34, category: .macros, name: "MACRO MONTH", description: "Hit targets 30 days in a row", threshold: 30),
        Achievement(id: 35, category: .macros, name: "MACRO 45", description: "Hit targets 45 days in a row", threshold: 45),
        Achievement(id: 36, category: .macros, name: "MACRO 60", description: "Hit targets 60 days in a row", threshold: 60),
        Achievement(id: 37, category: .macros, name: "MACRO QUARTER", description: "Hit targets 90 days in a row", threshold: 90),
        Achievement(id: 38, category: .macros, name: "MACRO 120", description: "Hit targets 120 days in a row", threshold: 120),
        Achievement(id: 39, category: .macros, name: "MACRO 150", description: "Hit targets 150 days in a row", threshold: 150),
        Achievement(id: 40, category: .macros, name: "MACRO MASTER", description: "Hit targets 180 days in a row", threshold: 180),
        
        // Workouts (10)
        Achievement(id: 41, category: .workouts, name: "FIRST WORKOUT", description: "Complete 1 workout", threshold: 1),
        Achievement(id: 42, category: .workouts, name: "WORKOUT 5", description: "Complete 5 workouts", threshold: 5),
        Achievement(id: 43, category: .workouts, name: "WORKOUT 10", description: "Complete 10 workouts", threshold: 10),
        Achievement(id: 44, category: .workouts, name: "WORKOUT 30", description: "Complete 30 workouts", threshold: 30),
        Achievement(id: 45, category: .workouts, name: "WORKOUT 50", description: "Complete 50 workouts", threshold: 50),
        Achievement(id: 46, category: .workouts, name: "WORKOUT 75", description: "Complete 75 workouts", threshold: 75),
        Achievement(id: 47, category: .workouts, name: "WORKOUT 100", description: "Complete 100 workouts", threshold: 100),
        Achievement(id: 48, category: .workouts, name: "WORKOUT 125", description: "Complete 125 workouts", threshold: 125),
        Achievement(id: 49, category: .workouts, name: "WORKOUT 150", description: "Complete 150 workouts", threshold: 150),
        Achievement(id: 50, category: .workouts, name: "WORKOUT 175", description: "Complete 175 workouts", threshold: 175),
        
        // Water Goals (10)
        Achievement(id: 51, category: .water, name: "WATER WEEK", description: "Hit water goal 7 days", threshold: 7),
        Achievement(id: 52, category: .water, name: "WATER 14", description: "Hit water goal 14 days", threshold: 14),
        Achievement(id: 53, category: .water, name: "WATER MONTH", description: "Hit water goal 30 days", threshold: 30),
        Achievement(id: 54, category: .water, name: "WATER 45", description: "Hit water goal 45 days", threshold: 45),
        Achievement(id: 55, category: .water, name: "WATER 60", description: "Hit water goal 60 days", threshold: 60),
        Achievement(id: 56, category: .water, name: "WATER QUARTER", description: "Hit water goal 90 days", threshold: 90),
        Achievement(id: 57, category: .water, name: "WATER 120", description: "Hit water goal 120 days", threshold: 120),
        Achievement(id: 58, category: .water, name: "WATER 150", description: "Hit water goal 150 days", threshold: 150),
        Achievement(id: 59, category: .water, name: "WATER HALF YEAR", description: "Hit water goal 180 days", threshold: 180),
        Achievement(id: 60, category: .water, name: "WATER MASTER", description: "Hit water goal 210 days", threshold: 210),
    ]
    
    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private var achievementsByCategory: [AchievementCategory: [Achievement]] {
        Dictionary(grouping: Self.achievements, by: { $0.category })
    }
    
    var body: some View {
        ZStack {
            simpleBackground()
            
            VStack(alignment: .leading, spacing: 32) {
                header
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        categorySection(category: .distance)
                        categorySection(category: .streak)
                        categorySection(category: .weight)
                        categorySection(category: .macros)
                        categorySection(category: .workouts)
                        categorySection(category: .water)
                    }
                    .padding(.vertical, 20)
                }
            }
            .padding(.top, 60)
        }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(achievement: achievement)
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
    
    private func categorySection(category: AchievementCategory) -> some View {
        let categoryAchievements = achievementsByCategory[category] ?? []
        let earnedCount = categoryAchievements.filter { onboardingData.earnedAchievements.contains($0.id) }.count
        
        return VStack(alignment: .leading, spacing: 16) {
            // Category header
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(SimplePalette.retroRed)
                
                Text(category.rawValue.uppercased())
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)
                
                Spacer()
                
                Text("(\(earnedCount)/\(categoryAchievements.count))")
                    .font(SimplePalette.retroFont(size: 14, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            }
            .padding(.horizontal, 24)
            
            // Grid of achievements for this category
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(categoryAchievements) { achievement in
                    achievementCoin(achievement: achievement)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func achievementCoin(achievement: Achievement) -> some View {
        VStack(spacing: 12) {
            StaticAchievementIcon(
                icon: achievement.icon,
                isLocked: !onboardingData.earnedAchievements.contains(achievement.id)
            )
            
            Text(achievement.name)
                .font(SimplePalette.retroFont(size: 11, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            // Show details for locked achievements
            if !onboardingData.earnedAchievements.contains(achievement.id) {
                selectedAchievement = achievement
            }
        }
        .onLongPressGesture(minimumDuration: 1.0) {
            // Testing feature: Long press to manually unlock
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                unlockedAchievement = achievement.id
                onboardingData.earnedAchievements.insert(achievement.id)
            }
        }
    }
}

enum AchievementCategory: String {
    case distance = "Distance Traveled"
    case streak = "App Streaks"
    case weight = "Weight Goals"
    case macros = "Macro Goals"
    case workouts = "Workouts"
    case water = "Water Goals"
    
    var icon: String {
        switch self {
        case .distance: return "ruler"
        case .streak: return "calendar.badge.checkmark"
        case .weight: return "scalemass"
        case .macros: return "flame"
        case .workouts: return "figure.run"
        case .water: return "drop.fill"
        }
    }
}

struct Achievement: Identifiable {
    let id: Int
    let category: AchievementCategory
    let name: String
    let description: String
    let threshold: Double
    
    var icon: String {
        return category.icon
    }
}

struct StaticAchievementIcon: View {
    let icon: String
    let isLocked: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isLocked ? Color.gray.opacity(0.3) : SimplePalette.retroYellow.opacity(0.8))
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(isLocked ? SimplePalette.cardBorder : SimplePalette.retroBlack, lineWidth: 3)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 0, x: 3, y: 3)
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
            }
        }
    }
}

// Keep SpinningCoinView for backward compatibility in home page
struct SpinningCoinView: View {
    let isLocked: Bool
    let icon: String?
    
    init(isLocked: Bool, icon: String? = nil) {
        self.isLocked = isLocked
        self.icon = icon
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isLocked ? Color.gray.opacity(0.3) : SimplePalette.retroYellow.opacity(0.8))
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(isLocked ? SimplePalette.cardBorder : SimplePalette.retroBlack, lineWidth: 3)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 0, x: 3, y: 3)
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            } else if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
            } else {
                Text("$")
                    .font(SimplePalette.retroFont(size: 32, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
            }
        }
    }
}

struct AchievementDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let achievement: Achievement
    
    var body: some View {
        ZStack {
            SimplePalette.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Achievement icon (large)
                StaticAchievementIcon(icon: achievement.icon, isLocked: true)
                    .scaleEffect(1.5)
                
                // Achievement name
                Text(achievement.name)
                    .font(SimplePalette.retroFont(size: 24, weight: .bold))
                    .foregroundStyle(SimplePalette.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(achievement.description)
                    .font(SimplePalette.retroFont(size: 16, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Threshold info
                VStack(spacing: 8) {
                    Text("REQUIREMENT")
                        .font(SimplePalette.retroFont(size: 12, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                    
                    Text(thresholdText(for: achievement))
                        .font(SimplePalette.retroFont(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(SimplePalette.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(SimplePalette.cardBorder, lineWidth: 2)
                        )
                )
                
                Spacer()
                
                // Close button
                Button(action: { dismiss() }) {
                    Text("CLOSE")
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(SimplePalette.retroBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(SimplePalette.retroWhite)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(SimplePalette.retroBlack, lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 48)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.medium])
    }
    
    private func thresholdText(for achievement: Achievement) -> String {
        switch achievement.category {
        case .distance:
            return "\(Int(achievement.threshold)) MILES"
        case .streak:
            return "\(Int(achievement.threshold)) DAYS IN A ROW"
        case .weight:
            if achievement.id == 21 {
                return "REACH TARGET WEIGHT"
            } else if achievement.id == 22 {
                return "RECORD FIRST WEIGHT"
            } else {
                return "\(Int(achievement.threshold)) CONSECUTIVE WEIGH-INS"
            }
        case .macros:
            return "\(Int(achievement.threshold)) DAYS IN A ROW"
        case .workouts:
            return "\(Int(achievement.threshold)) WORKOUTS"
        case .water:
            return "\(Int(achievement.threshold)) DAYS"
        }
    }
}

#Preview {
    NavigationStack {
        AchievementsSectionView()
    }
    .environmentObject(OnboardingData())
}

