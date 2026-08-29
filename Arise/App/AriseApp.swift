import SwiftUI

@main
struct AriseApp: App {
    @StateObject private var hunterVM = HunterViewModel()
    @StateObject private var questVM = QuestViewModel()
    @StateObject private var storeVM = StoreViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(hunterVM)
                    .environmentObject(questVM)
                    .environmentObject(storeVM)
                    .preferredColorScheme(.dark)
            } else {
                OnboardingView()
                    .environmentObject(hunterVM)
                    .environmentObject(storeVM)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
