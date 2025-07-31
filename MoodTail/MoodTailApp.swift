//
//  MoodTailApp.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import SwiftUI
import UserNotifications

@main
struct MoodTailApp: App {
    let persistenceController = PersistenceController.shared
    let notificationManager = NotificationManager()
    let themeManager = ThemeManager()
    @StateObject private var onboardingViewModel = OnboardingViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingViewModel.shouldShowOnboarding {
                    OnboardingView()
                        .environmentObject(onboardingViewModel)
                        .environmentObject(themeManager)
                } else {
                    TabView {
                        MoodLoggerView()
                            .tabItem {
                                Image(systemName: "plus.circle.fill")
                                Text("Добавить")
                            }
                        
                        HistoryView()
                            .tabItem {
                                Image(systemName: "chart.bar.fill")
                                Text("История")
                            }
                        
                        SettingsView()
                            .tabItem {
                                Image(systemName: "gear")
                                Text("Настройки")
                            }
                    }
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(themeManager)
                    .environmentObject(notificationManager)
                    .onAppear {
                        setupNotifications()
                    }
                }
            }
            .environmentObject(themeManager)
        }
    }
    
    private func setupNotifications() {
        // Устанавливаем делегат для обработки уведомлений
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // Проверяем статус уведомлений при запуске
        notificationManager.checkNotificationStatus()
        
        // Подключаем к хранилищу настроений для умных уведомлений
        let moodStorage = CoreDataMoodStorage(container: persistenceController.container)
        notificationManager.setMoodStorage(moodStorage)
        
        // Автоматически планируем уведомления при запуске
        Task {
            await autoScheduleReminders()
        }
        
        print("📱 App launched - notification setup completed")
    }
    
    private func autoScheduleReminders() async {
        // Проверяем разрешения
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        print("🔔 Notification settings:")
        print("  - Authorization status: \(settings.authorizationStatus.rawValue)")
        print("  - Alert setting: \(settings.alertSetting.rawValue)")
        print("  - Sound setting: \(settings.soundSetting.rawValue)")
        print("  - Badge setting: \(settings.badgeSetting.rawValue)")
        
        if settings.authorizationStatus == .authorized {
            print("✅ Notifications authorized - scheduling reminders...")
            await notificationManager.scheduleAllReminders()
            
            // Отладочная информация
            await notificationManager.printPendingNotifications()
        } else {
            print("❌ Notifications not authorized - requesting permission...")
            let granted = await notificationManager.requestAuthorization()
            if granted {
                print("✅ Permission granted - scheduling reminders...")
                await notificationManager.scheduleAllReminders()
                await notificationManager.printPendingNotifications()
            } else {
                print("❌ Permission denied")
            }
        }
    }
}
