import Foundation
import Combine
import CoreData

@MainActor
class HistoryViewModel: BaseViewModel {
    @Published var moodEntries: [MoodEntry] = []
    @Published var groupedEntries: [Date: [MoodEntry]] = [:]
    
    private let moodStorage: MoodStorageProtocol
    
    init(moodStorage: MoodStorageProtocol) {
        self.moodStorage = moodStorage
        super.init()
    }
    
    func loadMoodEntries() async {
        isLoading = true
        
        do {
            // Загружаем записи за последние 30 дней
            moodEntries = try await moodStorage.fetchMoodEntries(for: 30)
            groupEntriesByDate()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) async {
        do {
            try await moodStorage.deleteMoodEntry(entry)
            await loadMoodEntries() // Перезагружаем список
        } catch {
            handleError(error)
        }
    }
    
    private func groupEntriesByDate() {
        let calendar = Calendar.current
        
        groupedEntries = Dictionary(grouping: moodEntries) { entry in
            guard let timestamp = entry.timestamp else { return Date() }
            return calendar.startOfDay(for: timestamp)
        }
    }
    
    // Статистика
    var totalEntries: Int {
        moodEntries.count
    }
    
    var averageIntensity: Double {
        guard !moodEntries.isEmpty else { return 0 }
        let total = moodEntries.reduce(0) { $0 + Int($1.intensity) }
        return Double(total) / Double(moodEntries.count)
    }
    
    var mostCommonEmotion: String? {
        let emotionCounts: [String: Int] = moodEntries.reduce(into: [:]) { counts, entry in
            if let emotion = entry.emotion {
                counts[emotion, default: 0] += 1
            }
        }
        
        return emotionCounts.max(by: { $0.value < $1.value })?.key
    }
    
    var entriesThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return moodEntries.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return timestamp >= weekAgo
        }.count
    }
} 