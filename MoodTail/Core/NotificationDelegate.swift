import Foundation
import UserNotifications
import SwiftUI

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    // Вызывается когда приложение открыто и приходит уведомление
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Показываем уведомление даже если приложение открыто
        completionHandler([.banner, .sound, .badge])
    }
    
    // Вызывается когда пользователь нажимает на уведомление
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        
        if identifier.hasPrefix("mood-reminder-") {
            // Переходим на экран добавления настроения
            DispatchQueue.main.async {
                // Здесь можно добавить навигацию к MoodLoggerView
                print("🔔 User tapped on mood reminder notification: \(identifier)")
            }
        }
        
        completionHandler()
    }
    
    // Вызывается при запросе разрешений
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        openSettingsFor notification: UNNotification?
    ) {
        print("🔔 User opened notification settings")
    }
} 