# 🎨 Система тем MoodTail

## 📁 Структура файлов

```
MoodTail/
├── Core/
│   └── ThemeManager.swift
├── Shared/
│   └── Color+Hex.swift
└── UI/Components/
    ├── ThemeableView.swift
    └── ThemeSelectionView.swift
```

---

## 🔧 Core/ThemeManager.swift

```swift
import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light: return "Светлая"
        case .dark: return "Темная"
        case .system: return "Системная"
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "gear"
        }
    }
}

@MainActor
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .system
    @Published var isDarkMode: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    
    init() {
        loadTheme()
        updateDarkMode()
        setupSystemThemeObserver()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        saveTheme()
        updateDarkMode()
    }
    
    private func loadTheme() {
        if let savedTheme = userDefaults.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
    
    private func saveTheme() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
    }
    
    private func updateDarkMode() {
        switch currentTheme {
        case .light:
            isDarkMode = false
        case .dark:
            isDarkMode = true
        case .system:
            // Определяем системную тему
            let interfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
            isDarkMode = interfaceStyle == .dark
        }
    }
    
    private func setupSystemThemeObserver() {
        // Наблюдаем за изменениями системной темы
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("traitCollectionDidChange"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                if self?.currentTheme == .system {
                    self?.updateDarkMode()
                }
            }
        }
    }
}
```

---

## 🎨 Shared/Color+Hex.swift

```swift
import SwiftUI

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Предопределенные цвета для MoodTail
extension Color {
    /// Цвета эмоций для приложения MoodTail
    static let moodColors = MoodColors()
    
    struct MoodColors {
        // Основные цвета эмоций
        let happy = Color(hex: "#FFD700")      // Золотой для счастья
        let excited = Color(hex: "#FF6B6B")    // Красный для возбуждения
        let calm = Color(hex: "#4ECDC4")       // Бирюзовый для спокойствия
        let anxious = Color(hex: "#FFA500")    // Оранжевый для тревоги
        let sad = Color(hex: "#6C5CE7")        // Фиолетовый для грусти
        let playful = Color(hex: "#A8E6CF")    // Мятный для игривости
        let tired = Color(hex: "#9B59B6")      // Сиреневый для усталости
        let aggressive = Color(hex: "#E74C3C") // Красный для агрессии
        
        // Дополнительные цвета
        let background = Color(hex: "#F8F9FA") // Светло-серый фон
        let text = Color(hex: "#2C3E50")       // Темно-серый текст
        let secondary = Color(hex: "#95A5A6")  // Серый для второстепенного текста
    }
}

// MARK: - Light Theme Colors (вдохновлено лучшими приложениями)
extension Color {
    // Основные цвета светлой темы
    static let lightBackground = Color(hex: "#FFFFFF")
    static let lightSecondaryBackground = Color(hex: "#F8F9FA")
    static let lightCardBackground = Color(hex: "#FFFFFF")
    static let lightBorder = Color(hex: "#E9ECEF")
    
    // Текст
    static let lightPrimaryText = Color(hex: "#212529")
    static let lightSecondaryText = Color(hex: "#6C757D")
    static let lightTertiaryText = Color(hex: "#ADB5BD")
    
    // Акценты
    static let lightAccent = Color(hex: "#007AFF")
    static let lightAccentSecondary = Color(hex: "#5856D6")
    static let lightSuccess = Color(hex: "#34C759")
    static let lightWarning = Color(hex: "#FF9500")
    static let lightError = Color(hex: "#FF3B30")
    
    // Градиенты
    static let lightGradientStart = Color(hex: "#667eea")
    static let lightGradientEnd = Color(hex: "#764ba2")
    
    // Тени
    static let lightShadow = Color(hex: "#000000").opacity(0.1)
    static let lightShadowStrong = Color(hex: "#000000").opacity(0.15)
    
    // Эмоции для светлой темы (обновленные цвета)
    static let lightHappy = Color(hex: "#FFD93D")      // Яркий желтый
    static let lightExcited = Color(hex: "#FF6B6B")    // Коралловый
    static let lightCalm = Color(hex: "#4ECDC4")       // Бирюзовый
    static let lightAnxious = Color(hex: "#FFA500")    // Оранжевый
    static let lightSad = Color(hex: "#6C5CE7")        // Фиолетовый
    static let lightPlayful = Color(hex: "#A8E6CF")    // Мятный
    static let lightTired = Color(hex: "#9B59B6")      // Сиреневый
    static let lightAggressive = Color(hex: "#E74C3C") // Красный
}

// MARK: - Dark Theme Colors (iOS Dark Mode)
extension Color {
    // Основные цвета темной темы
    static let darkBackground = Color(hex: "#000000")
    static let darkSecondaryBackground = Color(hex: "#1C1C1E")
    static let darkCardBackground = Color(hex: "#2C2C2E")
    static let darkBorder = Color(hex: "#38383A")
    
    // Текст
    static let darkPrimaryText = Color(hex: "#FFFFFF")
    static let darkSecondaryText = Color(hex: "#EBEBF5")
    static let darkTertiaryText = Color(hex: "#EBEBF599")
    
    // Акценты
    static let darkAccent = Color(hex: "#0A84FF")
    static let darkAccentSecondary = Color(hex: "#5E5CE6")
    static let darkSuccess = Color(hex: "#30D158")
    static let darkWarning = Color(hex: "#FF9F0A")
    static let darkError = Color(hex: "#FF453A")
    
    // Градиенты
    static let darkGradientStart = Color(hex: "#667eea")
    static let darkGradientEnd = Color(hex: "#764ba2")
    
    // Тени
    static let darkShadow = Color(hex: "#000000").opacity(0.3)
    static let darkShadowStrong = Color(hex: "#000000").opacity(0.5)
    
    // Эмоции для темной темы (адаптированные цвета)
    static let darkHappy = Color(hex: "#FFD93D")      // Желтый (остается ярким)
    static let darkExcited = Color(hex: "#FF6B6B")    // Коралловый
    static let darkCalm = Color(hex: "#4ECDC4")       // Бирюзовый
    static let darkAnxious = Color(hex: "#FFA500")    // Оранжевый
    static let darkSad = Color(hex: "#6C5CE7")        // Фиолетовый
    static let darkPlayful = Color(hex: "#A8E6CF")    // Мятный
    static let darkTired = Color(hex: "#9B59B6")      // Сиреневый
    static let darkAggressive = Color(hex: "#E74C3C") // Красный
}
```

---

## 🎨 UI/Components/ThemeableView.swift

```swift
import SwiftUI

// MARK: - Themeable View Modifier
struct ThemeableViewModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .foregroundColor(textColor)
    }
    
    private var backgroundColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightBackground
        case .dark:
            return .darkBackground
        case .system:
            return themeManager.isDarkMode ? .darkBackground : .lightBackground
        }
    }
    
    private var textColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightPrimaryText
        case .dark:
            return .darkPrimaryText
        case .system:
            return themeManager.isDarkMode ? .darkPrimaryText : .lightPrimaryText
        }
    }
}

// MARK: - Themeable Card Modifier
struct ThemeableCardModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(cardBackground)
            .cornerRadius(12)
            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
    }
    
    private var cardBackground: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightCardBackground
        case .dark:
            return .darkCardBackground
        case .system:
            return themeManager.isDarkMode ? .darkCardBackground : .lightCardBackground
        }
    }
    
    private var shadowColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightShadow
        case .dark:
            return .darkShadow
        case .system:
            return themeManager.isDarkMode ? .darkShadow : .lightShadow
        }
    }
}

// MARK: - View Extensions
extension View {
    func themeable() -> some View {
        modifier(ThemeableViewModifier())
    }
    
    func themeableCard() -> some View {
        modifier(ThemeableCardModifier())
    }
}
```

---

## 🎨 UI/Components/ThemeSelectionView.swift

```swift
import SwiftUI

struct ThemeSelectionView: View {
    @ObservedObject var themeManager: ThemeManager
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
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    themeOptionsSection
                    previewSection
                }
                .padding()
            }
            .background(backgroundColor)
            .navigationTitle("Тема приложения")
            .navigationBarTitleDisplayMode(.large)
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
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "paintbrush.fill")
                .font(.system(size: 40))
                .foregroundColor(accentColor)
            
            Text("Выберите тему")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(primaryTextColor)
            
            Text("Персонализируйте внешний вид приложения")
                .font(.body)
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Theme Options Section
    private var themeOptionsSection: some View {
        VStack(spacing: 16) {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                ThemeOptionCard(
                    theme: theme,
                    isSelected: themeManager.currentTheme == theme,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            themeManager.setTheme(theme)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Предварительный просмотр")
                .font(.headline)
                .foregroundColor(primaryTextColor)
            
            ThemePreviewCard()
        }
    }
}

// MARK: - Theme Option Card
struct ThemeOptionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
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
    
    private var cardBackground: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightCardBackground
        case .dark:
            return .darkCardBackground
        case .system:
            return themeManager.isDarkMode ? .darkCardBackground : .lightCardBackground
        }
    }
    
    private var borderColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightBorder
        case .dark:
            return .darkBorder
        case .system:
            return themeManager.isDarkMode ? .darkBorder : .lightBorder
        }
    }
    
    private var shadowColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightShadow
        case .dark:
            return .darkShadow
        case .system:
            return themeManager.isDarkMode ? .darkShadow : .lightShadow
        }
    }
    
    private var shadowStrongColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightShadowStrong
        case .dark:
            return .darkShadowStrong
        case .system:
            return themeManager.isDarkMode ? .darkShadowStrong : .lightShadowStrong
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Иконка темы
                Image(systemName: theme.icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconBackground)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.headline)
                        .foregroundColor(primaryTextColor)
                    
                    Text(themeDescription)
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                }
                
                Spacer()
                
                // Индикатор выбора
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(accentColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? accentColor : borderColor, lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? shadowStrongColor : shadowColor, radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconColor: Color {
        switch theme {
        case .light: return .orange
        case .dark: return .purple
        case .system: return accentColor
        }
    }
    
    private var iconBackground: Color {
        switch theme {
        case .light: return .orange.opacity(0.1)
        case .dark: return .purple.opacity(0.1)
        case .system: return accentColor.opacity(0.1)
        }
    }
    
    private var themeDescription: String {
        switch theme {
        case .light: return "Яркие цвета и чистый дизайн"
        case .dark: return "Темные тона для комфортного использования"
        case .system: return "Следует настройкам системы"
        }
    }
}

// MARK: - Theme Preview Card
struct ThemePreviewCard: View {
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
    
    private var cardBackground: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightCardBackground
        case .dark:
            return .darkCardBackground
        case .system:
            return themeManager.isDarkMode ? .darkCardBackground : .lightCardBackground
        }
    }
    
    private var shadowColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightShadow
        case .dark:
            return .darkShadow
        case .system:
            return themeManager.isDarkMode ? .darkShadow : .lightShadow
        }
    }
    
    private var excitedColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightExcited
        case .dark:
            return .darkExcited
        case .system:
            return themeManager.isDarkMode ? .darkExcited : .lightExcited
        }
    }
    
    private var errorColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightError
        case .dark:
            return .darkError
        case .system:
            return themeManager.isDarkMode ? .darkError : .lightError
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Заголовок карточки
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(excitedColor)
                Text("Счастлив")
                    .font(.headline)
                    .foregroundColor(primaryTextColor)
                Spacer()
                Text("14:30")
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
            }
            
            Divider()
            
            // Содержимое карточки
            HStack {
                Text("Интенсивность: 8/10")
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "trash")
                        .foregroundColor(errorColor)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(12)
        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ThemeSelectionView(themeManager: ThemeManager())
}
```

---

## 🔧 Интеграция в MoodTailApp.swift

```swift
import SwiftUI
import UserNotifications

@main
struct MoodTailApp: App {
    let persistenceController = PersistenceController.shared
    let notificationManager = NotificationManager()
    let themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
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
                
                SettingsView(notificationManager: notificationManager)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Настройки")
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(themeManager) // 🔑 Ключевая строка для интеграции
            .onAppear {
                setupNotifications()
            }
        }
    }
    
    private func setupNotifications() {
        // Устанавливаем делегат для обработки уведомлений
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // Проверяем статус уведомлений при запуске
        notificationManager.checkNotificationStatus()
        
        print("📱 App launched - notification setup completed")
    }
}
```

---

## 🔧 Интеграция в SettingsView.swift

```swift
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showingAboutApp = false
    @State private var showingThemeSelection = false
    @EnvironmentObject var themeManager: ThemeManager
    let notificationManager: NotificationManager
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
        self._viewModel = StateObject(wrappedValue: SettingsViewModel(
            notificationManager: notificationManager,
            themeManager: ThemeManager()
        ))
    }
    
    private var actualViewModel: SettingsViewModel {
        // Используем environmentObject themeManager вместо созданного в init
        return SettingsViewModel(
            notificationManager: notificationManager,
            themeManager: themeManager
        )
    }
    
    var body: some View {
        NavigationView {
            settingsList
        }
        .themeable() // 🔑 Применяем тему ко всему экрану
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var settingsList: some View {
        List {
            ForEach(actualViewModel.sections) { section in
                settingsSection(for: section)
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAboutApp) {
            AboutAppView()
        }
        .sheet(isPresented: $showingThemeSelection) {
            ThemeSelectionView(themeManager: themeManager)
        }
    }
    
    @ViewBuilder
    private func settingsSection(for section: SettingSection) -> some View {
        Section(header: Text(section.title)) {
            ForEach(section.items) { item in
                SettingsRowView(item: item, onTap: {
                    handleItemTap(item)
                }, viewModel: actualViewModel)
            }
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
        // TODO: Переход на EditPetView
        print("Pet profile tapped")
    }
    
    private func handleNotificationsTap() {
        Task {
            await actualViewModel.toggleNotifications()
        }
    }
    
    private func handleThemeTap() {
        showingThemeSelection = true
    }
    
    private func handleAboutAppTap() {
        showingAboutApp = true
    }
}
```

---

## 🎯 Как использовать

### 1. Применение темы к View:
```swift
struct MyView: View {
    var body: some View {
        VStack {
            Text("Привет, мир!")
        }
        .themeable() // Применяет фон и цвет текста
    }
}
```

### 2. Применение темы к карточке:
```swift
struct MyCardView: View {
    var body: some View {
        VStack {
            Text("Содержимое карточки")
        }
        .themeableCard() // Применяет фон карточки и тени
    }
}
```

### 3. Переключение темы:
```swift
@EnvironmentObject var themeManager: ThemeManager

// Переключить на темную тему
themeManager.setTheme(.dark)

// Переключить на светлую тему
themeManager.setTheme(.light)

// Переключить на системную тему
themeManager.setTheme(.system)
```

### 4. Проверка текущей темы:
```swift
@EnvironmentObject var themeManager: ThemeManager

if themeManager.currentTheme == .dark {
    // Темная тема активна
}

if themeManager.isDarkMode {
    // Темный режим активен (включая системную тему)
}
```

---

## 🎨 Цветовая палитра

### Светлая тема:
- **Фон**: `#FFFFFF` (белый)
- **Вторичный фон**: `#F8F9FA` (светло-серый)
- **Карточки**: `#FFFFFF` (белый)
- **Основной текст**: `#212529` (темно-серый)
- **Вторичный текст**: `#6C757D` (серый)
- **Акцент**: `#007AFF` (синий)

### Темная тема:
- **Фон**: `#000000` (черный)
- **Вторичный фон**: `#1C1C1E` (темно-серый)
- **Карточки**: `#2C2C2E` (серый)
- **Основной текст**: `#FFFFFF` (белый)
- **Вторичный текст**: `#EBEBF5` (светло-серый)
- **Акцент**: `#0A84FF` (синий)

---

## 🚀 Особенности системы

✅ **Автоматическое переключение** при смене системной темы  
✅ **Сохранение выбора** в UserDefaults  
✅ **Плавные анимации** при переключении  
✅ **Полная поддержка iOS Dark Mode**  
✅ **Модификаторы для быстрого применения**  
✅ **Централизованное управление** через ThemeManager  
✅ **Реактивные обновления** через Combine  

---

*Документ создан для проекта MoodTail* 🎨 