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