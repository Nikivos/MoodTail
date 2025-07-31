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
        case .dark: return .darkIconColor
        case .system: return themeManager.isDarkMode ? .darkIconColor : .orange
        }
    }
    
    private var iconBackground: Color {
        switch theme {
        case .light: return .orange.opacity(0.1)
        case .dark: return .darkIconBackground
        case .system: return themeManager.isDarkMode ? .darkIconBackground : .orange.opacity(0.1)
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