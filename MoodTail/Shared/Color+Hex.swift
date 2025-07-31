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