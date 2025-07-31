import Foundation

struct MoodStatistics {
    let totalEntries: Int
    let averageIntensity: Double
    let mostCommonEmotion: String?
    let entriesThisWeek: Int
    let entriesThisMonth: Int
    
    static let empty = MoodStatistics(
        totalEntries: 0,
        averageIntensity: 0,
        mostCommonEmotion: nil,
        entriesThisWeek: 0,
        entriesThisMonth: 0
    )
    
    static func calculate(from entries: [MoodEntry]) -> MoodStatistics {
        guard !entries.isEmpty else { return .empty }
        
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        // Подсчет записей за неделю и месяц
        let entriesThisWeek = entries.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return timestamp >= weekAgo
        }.count
        
        let entriesThisMonth = entries.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return timestamp >= monthAgo
        }.count
        
        // Средняя интенсивность
        let totalIntensity = entries.reduce(0) { $0 + Int($1.intensity) }
        let averageIntensity = entries.count > 0 ? Double(totalIntensity) / Double(entries.count) : 0.0
        let safeAverageIntensity = averageIntensity.isNaN ? 0.0 : averageIntensity
        
        // Самая частая эмоция
        let emotionCounts: [String: Int] = entries.reduce(into: [:]) { counts, entry in
            if let emotion = entry.emotion {
                counts[emotion, default: 0] += 1
            }
        }
        let mostCommonEmotion = emotionCounts.max(by: { $0.value < $1.value })?.key
        
        return MoodStatistics(
            totalEntries: entries.count,
            averageIntensity: safeAverageIntensity,
            mostCommonEmotion: mostCommonEmotion,
            entriesThisWeek: entriesThisWeek,
            entriesThisMonth: entriesThisMonth
        )
    }
} 