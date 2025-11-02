import SwiftUI

@main
struct MacroTrackApp: App {
    @StateObject private var onboardingData = OnboardingData()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SignUpView()
            }
            .environmentObject(onboardingData)
        }
    }
}

