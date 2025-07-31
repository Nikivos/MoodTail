import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var showingReminders = false
    @State private var showingThemeSelection = false
    @State private var showingAboutApp = false
    @State private var showingPetProfile = false
    
    init() {
        // Создаем временные экземпляры для инициализации, они будут обновлены в onAppear
        self._viewModel = StateObject(wrappedValue: SettingsViewModel(notificationManager: NotificationManager(), themeManager: ThemeManager()))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sections) { section in
                    Section(header: Text(section.title).font(.headline).foregroundColor(.secondary)) {
                        ForEach(section.items) { item in
                            SettingsRowView(item: item, onTap: {
                                handleItemTap(item)
                            }, viewModel: viewModel)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            // Обновляем ViewModel с правильными зависимостями
            viewModel.updateDependencies(notificationManager: notificationManager, themeManager: themeManager)
        }
        .sheet(isPresented: $showingReminders) {
            RemindersView(notificationManager: notificationManager)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingThemeSelection) {
            ThemeSelectionView(themeManager: themeManager)
        }
        .sheet(isPresented: $showingAboutApp) {
            AboutAppView()
        }
        .sheet(isPresented: $showingPetProfile) {
            PetProfileView()
        }
    }
    
    // MARK: - Actions
    
    private func handleItemTap(_ item: SettingItem) {
        switch item.type {
        case .petProfile:
            handlePetProfileTap()
        case .notifications:
            handleNotificationsTap()
        case .theme:
            handleThemeTap()
        case .aboutApp:
            handleAboutAppTap()
        }
    }
    
    private func handlePetProfileTap() {
        showingPetProfile = true
    }
    
    private func handleNotificationsTap() {
        showingReminders = true
    }
    
    private func handleThemeTap() {
        showingThemeSelection = true
    }
    
    private func handleAboutAppTap() {
        showingAboutApp = true
    }
}

struct SettingsRowView: View {
    let item: SettingItem
    let onTap: () -> Void
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    // MARK: - Computed Colors
    private var primaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightPrimaryText
        case .dark:
            return .darkPrimaryText
        case .system:
            return themeManager.isDarkMode ? .darkPrimaryText : .lightPrimaryText
        }
    }
    
    private var secondaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightSecondaryText
        case .dark:
            return .darkSecondaryText
        case .system:
            return themeManager.isDarkMode ? .darkSecondaryText : .lightSecondaryText
        }
    }
    
    private var accentColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightAccent
        case .dark:
            return .darkAccent
        case .system:
            return themeManager.isDarkMode ? .darkAccent : .lightAccent
        }
    }
    
    var body: some View {
        HStack {
            iconView
            contentView
            Spacer()
            accessoryView
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var iconView: some View {
        Image(systemName: item.icon)
            .foregroundColor(item.iconColor)
            .frame(width: 24, height: 24)
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.title)
                .font(.body)
                .foregroundColor(primaryTextColor)
            
            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
            }
        }
    }
    
    @ViewBuilder
    private var accessoryView: some View {
        switch item.accessory {
        case .chevron:
            chevronAccessory
        case .toggle(let isOn):
            toggleAccessory(isOn: isOn)
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var chevronAccessory: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(secondaryTextColor)
            .font(.caption)
    }
    
    @ViewBuilder
    private func toggleAccessory(isOn: Bool) -> some View {
        Toggle("", isOn: Binding(
            get: { 
                if case .toggle(let value) = item.accessory {
                    return value
                }
                return false
            },
            set: { _ in
                if item.type == .notifications {
                    Task {
                        await viewModel.toggleNotifications()
                    }
                }
            }
        ))
        .labelsHidden()
        .tint(accentColor)
    }
}

struct AboutAppView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Computed Colors
    private var backgroundColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightSecondaryBackground
        case .dark:
            return .darkSecondaryBackground
        case .system:
            return themeManager.isDarkMode ? .darkSecondaryBackground : .lightSecondaryBackground
        }
    }
    
    private var primaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightPrimaryText
        case .dark:
            return .darkPrimaryText
        case .system:
            return themeManager.isDarkMode ? .darkPrimaryText : .lightPrimaryText
        }
    }
    
    private var secondaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightSecondaryText
        case .dark:
            return .darkSecondaryText
        case .system:
            return themeManager.isDarkMode ? .darkSecondaryText : .lightSecondaryText
        }
    }
    
    private var accentColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightAccent
        case .dark:
            return .darkAccent
        case .system:
            return themeManager.isDarkMode ? .darkAccent : .lightAccent
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(accentColor)
                
                VStack(spacing: 8) {
                    Text("MoodTail")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(primaryTextColor)
                    
                    Text("Версия 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(secondaryTextColor)
                }
                
                VStack(spacing: 16) {
                    Text("Приложение для отслеживания настроения вашей собаки")
                        .font(.body)
                        .foregroundColor(primaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Разработано с ❤️ для заботливых владельцев")
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                }
                
                // Debug section
                VStack(spacing: 12) {
                    Text("Для разработчиков")
                        .font(.headline)
                        .foregroundColor(primaryTextColor)
                    
                    Button("Сбросить Onboarding") {
                        UserDefaults.standard.set(false, forKey: "onboardingCompleted")
                        dismiss()
                    }
                    .foregroundColor(.red)
                    .font(.caption)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .background(backgroundColor)
            .navigationTitle("О приложении")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
} 