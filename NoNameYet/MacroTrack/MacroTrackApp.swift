import SwiftUI

@main
struct MacroTrackApp: App {
    @StateObject private var onboardingData = OnboardingData()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // Onboarding flow: SignUpView -> FitnessGoalsView -> DietaryRestrictionsView -> HealthPlanView
                SignUpView()

                // For testing: launch directly on main health plan
                // HealthPlanView()
                //     .onAppear {
                //         if onboardingData.generatedPlan == nil {
                //             seedMockData()
                //         }
                //     }
            }
            .environmentObject(onboardingData)
        }
    }

    private func seedMockData() {
        onboardingData.username = "Drew"
        onboardingData.age = 27
        onboardingData.weight = 175
        onboardingData.weightUnit = .pounds
        onboardingData.heightFeet = 6
        onboardingData.heightInches = 0
        onboardingData.heightCentimeters = 183
        onboardingData.heightUnit = .imperial
        onboardingData.gender = .male
        onboardingData.activityLevel = .moderatelyActive
        onboardingData.goals = [1, 3, 6]
        onboardingData.dietaryRestrictions = []
        onboardingData.generatePlanWithMifflinStJeor()
    }
}

