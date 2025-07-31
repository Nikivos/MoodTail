import Foundation
import CoreData

extension MoodEntry {
    
    /// Безопасный ID, который никогда не будет nil
    var safeID: UUID {
        return id ?? UUID()
    }
    
    /// Проверяет, валидна ли запись для отображения
    var isValid: Bool {
        // Проверяем только базовые условия - запись не удалена и имеет ID
        return !isDeleted && id != nil
    }
    
    /// Безопасное получение эмоции с fallback
    var safeEmotion: String {
        return emotion ?? "unknown"
    }
    
    /// Безопасное получение интенсивности с fallback
    var safeIntensity: Int16 {
        return intensity
    }
    
    /// Безопасное получение заметки
    var safeNote: String? {
        return note?.isEmpty == false ? note : nil
    }
    
    /// Безопасное получение timestamp с fallback
    var safeTimestamp: Date {
        return timestamp ?? Date()
    }
} 