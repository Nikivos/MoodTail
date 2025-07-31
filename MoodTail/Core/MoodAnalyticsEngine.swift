import Foundation
import CoreData
import SwiftUI

struct MoodAnalytics {
    let dailyIntensity: [Date: Double] // Средняя интенсивность по дням
    let emotionDistribution: [String: Int] // Распределение эмоций
    let weeklyTrend: String // Тренд недели
    let mostCommonEmotion: String? // Самая частая эмоция
    let averageIntensity: Double // Общая средняя интенсивность
    let totalEntries: Int
    let entriesThisWeek: Int
    let entriesThisMonth: Int
    
    static let empty = MoodAnalytics(
        dailyIntensity: [:],
        emotionDistribution: [:],
        weeklyTrend: "Недостаточно данных",
        mostCommonEmotion: nil,
        averageIntensity: 0,
        totalEntries: 0,
        entriesThisWeek: 0,
        entriesThisMonth: 0
    )
}

@MainActor
class MoodAnalyticsEngine {
    
    // MARK: - Основные методы анализа
    
    func analyzeMoodData(_ entries: [MoodEntry]) async -> MoodAnalytics {
        guard !entries.isEmpty else { return .empty }
        
        return await Task.detached(priority: .userInitiated) {
            let calendar = Calendar.current
            let now = Date()
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            
            // Группировка по дням для графика
            let dailyIntensity = await self.groupByDay(entries, calendar: calendar)
            
            // Распределение эмоций для pie chart
            let emotionDistribution = await self.countByEmotion(entries)
            
            // Тренд недели
            let weeklyTrend = await self.calculateWeeklyTrend(entries, weekAgo: weekAgo)
            
            // Самая частая эмоция
            let mostCommonEmotion = emotionDistribution.max(by: { $0.value < $1.value })?.key
            
            // Общая статистика
            let averageIntensity = await self.calculateAverageIntensity(entries)
            let totalEntries = entries.count
            let entriesThisWeek = entries.filter { 
                guard let timestamp = $0.timestamp else { return false }
                return timestamp >= weekAgo 
            }.count
            let entriesThisMonth = entries.filter { 
                guard let timestamp = $0.timestamp else { return false }
                return timestamp >= monthAgo 
            }.count
            
            return MoodAnalytics(
                dailyIntensity: dailyIntensity,
                emotionDistribution: emotionDistribution,
                weeklyTrend: weeklyTrend,
                mostCommonEmotion: mostCommonEmotion,
                averageIntensity: averageIntensity,
                totalEntries: totalEntries,
                entriesThisWeek: entriesThisWeek,
                entriesThisMonth: entriesThisMonth
            )
        }.value
    }
    
    // MARK: - Вспомогательные методы
    
    private func groupByDay(_ entries: [MoodEntry], calendar: Calendar) async -> [Date: Double] {
        let grouped = Dictionary(grouping: entries) { entry in
            guard let timestamp = entry.timestamp else { return Date() }
            return calendar.startOfDay(for: timestamp)
        }
        
        return grouped.mapValues { dayEntries in
            let totalIntensity = dayEntries.reduce(0) { $0 + Int($1.intensity) }
            return Double(totalIntensity) / Double(dayEntries.count)
        }
    }
    
    private func countByEmotion(_ entries: [MoodEntry]) async -> [String: Int] {
        return entries.reduce(into: [:]) { counts, entry in
            if let emotion = entry.emotion {
                counts[emotion, default: 0] += 1
            }
        }
    }
    
    private func calculateAverageIntensity(_ entries: [MoodEntry]) async -> Double {
        let totalIntensity = entries.reduce(0) { $0 + Int($1.intensity) }
        return Double(totalIntensity) / Double(entries.count)
    }
    
    private func calculateWeeklyTrend(_ entries: [MoodEntry], weekAgo: Date) async -> String {
        let weeklyEntries = entries.filter { 
            guard let timestamp = $0.timestamp else { return false }
            return timestamp >= weekAgo 
        }
        
        guard weeklyEntries.count >= 2 else { return "Недостаточно данных" }
        
        let sortedEntries = weeklyEntries.sorted { 
            ($0.timestamp ?? Date()) < ($1.timestamp ?? Date()) 
        }
        
        let firstHalf = Array(sortedEntries.prefix(sortedEntries.count / 2))
        let secondHalf = Array(sortedEntries.suffix(sortedEntries.count / 2))
        
        let firstAvg = await calculateAverageIntensity(firstHalf)
        let secondAvg = await calculateAverageIntensity(secondHalf)
        
        let difference = secondAvg - firstAvg
        
        if abs(difference) < 0.5 {
            return "Стабильное настроение"
        } else if difference > 0 {
            return "Настроение улучшается"
        } else {
            return "Настроение снижается"
        }
    }
    
    // MARK: - Методы для UI
    
    func getChartData(for days: Int, from analytics: MoodAnalytics) -> [(Date, Double)] {
        let calendar = Calendar.current
        let now = Date()
        
        return (0..<days).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { return nil }
            let startOfDay = calendar.startOfDay(for: date)
            let intensity = analytics.dailyIntensity[startOfDay] ?? 0
            return (startOfDay, intensity)
        }.reversed()
    }
    
    func getEmotionChartData(from analytics: MoodAnalytics) -> [(String, Int, Color)] {
        return analytics.emotionDistribution.map { emotion, count in
            let dogEmotion = DogEmotion(rawValue: emotion) ?? .happy
            return (dogEmotion.displayName, count, dogEmotion.color)
        }.sorted { $0.1 > $1.1 }
    }
} 