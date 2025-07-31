import SwiftUI

extension Color {
    /// Инициализатор для создания цвета из hex-строки
    /// - Parameter hex: Hex-строка в формате "#FFA500" или "FFA500"
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RRGGBB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // AARRGGBB
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
    
    /// Создает цвет из hex-строки с альфа-каналом
    /// - Parameters:
    ///   - hex: Hex-строка цвета
    ///   - alpha: Альфа-канал (0.0 - 1.0)
    init(hex: String, alpha: Double) {
        let color = Color(hex: hex)
        self.init(color.opacity(alpha))
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

// MARK: - Dark Theme Colors (Apple HIG + Pet Wellness Style)
extension Color {
    // 🧱 Основные цвета темной темы (мягкие, не абсолютно черные)
    static let darkBackground = Color(hex: "#121212")           // Мягкий темно-серый
    static let darkSecondaryBackground = Color(hex: "#1E1E1E") // Вторичный фон
    static let darkCardBackground = Color(hex: "#2A2A2A")      // Фон карточек
    static let darkBorder = Color(hex: "#3A3A3C")              // Границы
    
    // 📝 Текст (высокая контрастность для WCAG AAA)
    static let darkPrimaryText = Color(hex: "#FFFFFF")          // Основной текст
    static let darkSecondaryText = Color(hex: "#C7C7CC")       // Вторичный текст
    static let darkTertiaryText = Color(hex: "#8E8E93")        // Третичный текст
    
    // 🎨 Акценты (мягкие, не агрессивные)
    static let darkAccent = Color(hex: "#64AFFF")              // Мягкий синий
    static let darkAccentSecondary = Color(hex: "#5E5CE6")     // Вторичный акцент
    static let darkSuccess = Color(hex: "#30D158")             // Успех
    static let darkWarning = Color(hex: "#FF9F0A")             // Предупреждение
    static let darkError = Color(hex: "#FF453A")               // Ошибка
    
    // 🌈 Градиенты (адаптированные для темной темы)
    static let darkGradientStart = Color(hex: "#667eea")
    static let darkGradientEnd = Color(hex: "#764ba2")
    
    // 💡 Тени (светлые в темной теме)
    static let darkShadow = Color.white.opacity(0.03)           // Мягкая тень
    static let darkShadowStrong = Color.white.opacity(0.06)     // Сильная тень
    
    // 🐕 Эмоции для темной темы (адаптированные, не ядовитые)
    static let darkHappy = Color(hex: "#FFE066")               // Мягкий желтый
    static let darkExcited = Color(hex: "#FF6B6B", alpha: 0.85) // Приглушенный коралловый
    static let darkCalm = Color(hex: "#4ECDC4")                // Бирюзовый
    static let darkAnxious = Color(hex: "#FFB347")             // Мягкий оранжевый
    static let darkSad = Color(hex: "#B39DDB")                 // Приглушенный фиолетовый
    static let darkPlayful = Color(hex: "#B2F2BB")             // Мягкий зеленый
    static let darkTired = Color(hex: "#B39BC8")               // Приглушенный сиреневый
    static let darkAggressive = Color(hex: "#FF4C4C")          // Приглушенный красный
    
    // 🎯 Дополнительные цвета для иконок и элементов
    static let darkIconColor = Color.white.opacity(0.9)         // Цвет иконок
    static let darkIconBackground = Color.white.opacity(0.05)   // Фон иконок
    static let darkOverlay = Color.black.opacity(0.4)           // Оверлей
    static let darkSeparator = Color.white.opacity(0.1)         // Разделители
} 