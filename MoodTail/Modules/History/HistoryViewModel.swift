import Foundation
import Combine
import CoreData

@MainActor
class HistoryViewModel: BaseViewModel {
    @Published var moodEntries: [MoodEntry] = []
    @Published var groupedEntries: [Date: [MoodEntry]] = [:]
    @Published var statistics: MoodStatistics = .empty
    @Published var analytics: MoodAnalytics = .empty // Новое свойство для аналитики
    
    private let moodStorage: MoodStorageProtocol
    let analyticsEngine = MoodAnalyticsEngine() // Сделал публичным для доступа из View
    
    init(moodStorage: MoodStorageProtocol) {
        self.moodStorage = moodStorage
        super.init()
    }
    
    func loadMoodEntries() async {
        isLoading = true
        
        do {
            // Загружаем записи за последние 30 дней
            moodEntries = try await moodStorage.fetchMoodEntries(for: 30)
            
            // Обрабатываем данные в background
            await processDataInBackground()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) async {
        do {
            // Проверяем только базовые условия
            guard let entryID = entry.id else {
                handleError(MoodStorageError.invalidEntry("Entry has no ID"))
                return
            }
            
            try await moodStorage.deleteMoodEntry(entry)
            
            // Локальное обновление без перезагрузки
            moodEntries.removeAll { $0.safeID == entry.safeID }
            await processDataInBackground()
        } catch {
            handleError(error)
        }
    }
    
    private func processDataInBackground() async {
        let entries = moodEntries // Копируем данные для background обработки
        
        await Task.detached(priority: .userInitiated) {
            // Группировка в background
            let calendar = Calendar.current
            let grouped = Dictionary(grouping: entries) { entry in
                guard let timestamp = entry.timestamp else { return Date() }
                return calendar.startOfDay(for: timestamp)
            }
            
            // Вычисление статистики в background
            let stats = MoodStatistics.calculate(from: entries)
            
            // Возвращаемся на главный поток
            await MainActor.run {
                self.groupedEntries = grouped
                self.statistics = stats
            }
        }.value
        
        // Аналитика в отдельном Task для лучшей производительности
        await calculateAnalytics()
    }
    
    private func calculateAnalytics() async {
        analytics = await analyticsEngine.analyzeMoodData(moodEntries)
    }
    
    // Удаляем старые вычисляемые свойства - теперь используем кэшированную статистику
    var totalEntries: Int {
        statistics.totalEntries
    }
    
    var averageIntensity: Double {
        statistics.averageIntensity
    }
    
    var mostCommonEmotion: String? {
        statistics.mostCommonEmotion
    }
    
    var entriesThisWeek: Int {
        statistics.entriesThisWeek
    }
    
    var entriesThisMonth: Int {
        statistics.entriesThisMonth
    }
} 