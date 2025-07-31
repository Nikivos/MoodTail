import SwiftUI
import UserNotifications

@MainActor
class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentPage: Int = 0
    @Published var notificationsGranted: Bool = false
    @Published var shouldShowOnboarding: Bool = true
    
    // MARK: - Constants
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "onboardingCompleted"
    
    // MARK: - Initialization
    init() {
        checkOnboardingStatus()
    }
    
    // MARK: - Onboarding Status
    func checkOnboardingStatus() {
        let isCompleted = userDefaults.bool(forKey: onboardingCompletedKey)
        shouldShowOnboarding = !isCompleted
        print("🔍 Onboarding status check: completed=\(isCompleted), shouldShow=\(shouldShowOnboarding)")
        checkNotificationStatus()
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsGranted = settings.authorizationStatus == .authorized
                print("🔔 Notification status: \(settings.authorizationStatus.rawValue)")
            }
        }
    }
    
    // MARK: - Permission Requests
    func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            await MainActor.run {
                self.notificationsGranted = granted
            }
            
            if granted {
                print("✅ Notification permission granted during onboarding")
            } else {
                print("❌ Notification permission denied during onboarding")
            }
        } catch {
            print("❌ Error requesting notification permission: \(error)")
        }
    }
    
    // MARK: - Onboarding Completion
    func completeOnboarding() {
        print("🎯 Completing onboarding...")
        userDefaults.set(true, forKey: onboardingCompletedKey)
        userDefaults.synchronize() // Принудительно сохраняем
        shouldShowOnboarding = false
        print("✅ Onboarding completed - shouldShowOnboarding set to false")
        
        // Дополнительная проверка
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let savedValue = self.userDefaults.bool(forKey: self.onboardingCompletedKey)
            print("🔍 Verification: saved value = \(savedValue), shouldShow = \(self.shouldShowOnboarding)")
        }
    }
    
    // MARK: - Reset Onboarding (for testing)
    func resetOnboarding() {
        userDefaults.set(false, forKey: onboardingCompletedKey)
        userDefaults.synchronize()
        shouldShowOnboarding = true
        currentPage = 0
        print("🔄 Onboarding reset")
    }
} 