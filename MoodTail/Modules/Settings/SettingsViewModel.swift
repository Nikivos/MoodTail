import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var sections: [SettingSection] = []
    
    private var notificationManager: NotificationManager
    private var themeManager: ThemeManager
    private var cancellables = Set<AnyCancellable>()
    
    init(notificationManager: NotificationManager, themeManager: ThemeManager) {
        self.notificationManager = notificationManager
        self.themeManager = themeManager
        
        setupSections()
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
        // Подписываемся на изменения статуса уведомлений
        notificationManager.$isAuthorized
            .combineLatest(notificationManager.$isAnyReminderEnabled, notificationManager.$reminders)
            .sink { [weak self] _, _, _ in
                self?.updateNotificationSection()
            }
            .store(in: &cancellables)
        
        // Подписываемся на изменения темы
        themeManager.$currentTheme
            .sink { [weak self] _ in
                self?.updateThemeSection()
            }
            .store(in: &cancellables)
    }
    
    private func setupSections() {
        sections = [
            SettingSection(
                title: "Профиль",
                items: [
                    SettingItem(
                        type: .petProfile,
                        title: "Профиль питомца",
                        subtitle: "Изменить имя и фото",
                        icon: "pawprint.fill",
                        iconColor: getIconColor(for: .petProfile),
                        accessory: .chevron
                    )
                ]
            ),
            SettingSection(
                title: "Уведомления",
                items: [
                    SettingItem(
                        type: .notifications,
                        title: "Напоминания",
                        subtitle: "Ежедневные напоминания о записи настроения",
                        icon: "bell.fill",
                        iconColor: getIconColor(for: .notifications),
                        accessory: .chevron
                    )
                ]
            ),
            SettingSection(
                title: "Внешний вид",
                items: [
                    SettingItem(
                        type: .theme,
                        title: "Тема",
                        subtitle: themeManager.currentTheme.displayName,
                        icon: "moon.fill",
                        iconColor: getIconColor(for: .theme),
                        accessory: .chevron
                    )
                ]
            ),
            SettingSection(
                title: "О приложении",
                items: [
                    SettingItem(
                        type: .aboutApp,
                        title: "О MoodTail",
                        subtitle: "Версия 1.0.0",
                        icon: "info.circle.fill",
                        iconColor: getIconColor(for: .aboutApp),
                        accessory: .chevron
                    )
                ]
            )
        ]
        updateNotificationSection() // Initial update
    }
    
    // MARK: - Icon Colors
    private func getIconColor(for type: SettingItemType) -> Color {
        switch type {
        case .petProfile:
            return .orange
        case .notifications:
            return getAccentColor()
        case .theme:
            return getAccentColor()
        case .aboutApp:
            return .green
        }
    }
    
    private func getAccentColor() -> Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightAccent
        case .dark:
            return .darkAccent
        case .system:
            return themeManager.isDarkMode ? .darkAccent : .lightAccent
        }
    }
    
    // MARK: - Toggle Notifications
    func toggleNotifications() async {
        if notificationManager.isAuthorized {
            await notificationManager.cancelAllReminders()
        } else {
            let granted = await notificationManager.requestAuthorization()
            if granted {
                await notificationManager.scheduleAllReminders()
            }
        }
    }
    
    private func updateNotificationSection() {
        // Обновляем секцию уведомлений с актуальным статусом
        if let notificationIndex = sections.firstIndex(where: { $0.title == "Уведомления" }),
           let itemIndex = sections[notificationIndex].items.firstIndex(where: { $0.type == .notifications }) {
            
            let subtitle: String
            if notificationManager.isAuthorized {
                let activeRemindersCount = notificationManager.reminders.filter { $0.isEnabled }.count
                if activeRemindersCount > 0 {
                    subtitle = "\(activeRemindersCount) активных напоминаний"
                } else {
                    subtitle = "Напоминания отключены"
                }
            } else {
                subtitle = "Разрешения не предоставлены"
            }
            
            let newItem = SettingItem(
                type: .notifications,
                title: "Напоминания",
                subtitle: subtitle,
                icon: "bell.fill",
                iconColor: getIconColor(for: .notifications),
                accessory: .chevron
            )
            
            sections[notificationIndex].items[itemIndex] = newItem
        }
    }
    
    func showThemeSelection() {
        // Будет реализовано в View
    }
    
    private func updateThemeSection() {
        // Обновляем секцию темы с актуальным статусом
        if let themeIndex = sections.firstIndex(where: { $0.title == "Внешний вид" }),
           let itemIndex = sections[themeIndex].items.firstIndex(where: { $0.type == .theme }) {
            
            let newItem = SettingItem(
                type: .theme,
                title: "Тема",
                subtitle: themeManager.currentTheme.displayName,
                icon: "moon.fill",
                iconColor: getIconColor(for: .theme),
                accessory: .chevron
            )
            
            sections[themeIndex].items[itemIndex] = newItem
        }
    }
    
    // MARK: - Dependencies Update
    
    func updateDependencies(notificationManager: NotificationManager, themeManager: ThemeManager) {
        self.notificationManager = notificationManager
        self.themeManager = themeManager
    }
}

// MARK: - Models
struct SettingSection: Identifiable {
    let id = UUID()
    let title: String
    var items: [SettingItem]
}

struct SettingItem: Identifiable {
    let id = UUID()
    let type: SettingItemType
    let title: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let accessory: SettingAccessory
    
    init(
        type: SettingItemType,
        title: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color,
        accessory: SettingAccessory
    ) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.accessory = accessory
    }
}

enum SettingItemType {
    case petProfile
    case notifications
    case theme
    case aboutApp
}

enum SettingAccessory {
    case chevron
    case toggle(Bool)
    case none
} 