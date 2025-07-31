import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var sections: [SettingSection] = []
    
    init() {
        setupSections()
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
                        iconColor: .orange,
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
                        iconColor: .blue,
                        accessory: .toggle(true)
                    )
                ]
            ),
            SettingSection(
                title: "Внешний вид",
                items: [
                    SettingItem(
                        type: .theme,
                        title: "Тема",
                        subtitle: "Светлая / Темная",
                        icon: "moon.fill",
                        iconColor: .purple,
                        accessory: .toggle(false)
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
                        iconColor: .green,
                        accessory: .chevron
                    )
                ]
            )
        ]
    }
    
    func toggleNotifications() {
        // TODO: Реализовать логику уведомлений
        print("Toggle notifications")
    }
    
    func toggleTheme() {
        // TODO: Реализовать переключение темы
        print("Toggle theme")
    }
}

// MARK: - Models

struct SettingSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [SettingItem]
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