import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthorized: Bool = false
    @Published var reminders: [Reminder] = []
    @Published var isAnyReminderEnabled: Bool = false
    @Published var smartNotificationsEnabled: Bool = true
    
    // MARK: - Constants
    private let userDefaults = UserDefaults.standard
    private let remindersKey = "savedReminders"
    private let smartNotificationsKey = "smartNotificationsEnabled"
    
    // MARK: - Smart Notification Properties
    private var moodStorage: MoodStorageProtocol?
    private var lastNotificationTime: Date?
    private var notificationEffectiveness: [String: Int] = [:] // ID -> effectiveness score
    
    // MARK: - Initialization
    init() {
        loadReminders()
        loadSmartNotificationsSettings()
        checkNotificationStatus()
    }
    
    // MARK: - Smart Notifications Setup
    func setMoodStorage(_ storage: MoodStorageProtocol) {
        self.moodStorage = storage
    }
    
    private func loadSmartNotificationsSettings() {
        smartNotificationsEnabled = userDefaults.bool(forKey: smartNotificationsKey)
    }
    
    func toggleSmartNotifications() {
        smartNotificationsEnabled.toggle()
        userDefaults.set(smartNotificationsEnabled, forKey: smartNotificationsKey)
        print("🧠 Smart notifications: \(smartNotificationsEnabled ? "enabled" : "disabled")")
    }
    
    // MARK: - Reminders Management
    private func loadReminders() {
        if let data = userDefaults.data(forKey: remindersKey),
           let savedReminders = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = savedReminders
            print("📋 Loaded \(reminders.count) saved reminders")
        } else {
            // Загружаем шаблоны по умолчанию
            reminders = Reminder.templates
            print("📋 Loaded \(reminders.count) default reminder templates")
        }
        updateReminderStatus()
    }
    
    private func saveReminders() {
        if let data = try? JSONEncoder().encode(reminders) {
            userDefaults.set(data, forKey: remindersKey)
            print("💾 Saved \(reminders.count) reminders to UserDefaults")
        }
    }
    
    // MARK: - Status Checking
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
                self.updateReminderStatus()
                print("🔔 Notification status checked: \(settings.authorizationStatus == .authorized ? "Authorized" : "Not authorized")")
            }
        }
    }
    
    private func updateReminderStatus() {
        let enabledCount = reminders.filter { $0.isEnabled }.count
        isAnyReminderEnabled = enabledCount > 0
        print("📊 Reminder status updated: \(enabledCount) enabled out of \(reminders.count) total")
    }
    
    // MARK: - Scheduling
    func scheduleReminder(_ reminder: Reminder) async {
        guard isAuthorized && reminder.isEnabled else {
            print("⚠️ Cannot schedule reminder: notifications not authorized (\(isAuthorized)) or reminder disabled (\(reminder.isEnabled))")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "MoodTail"
        
        // Используем умное сообщение
        let smartMessage = await generateSmartMessage(for: reminder)
        content.body = smartMessage
        content.sound = reminder.sound.soundName
        content.badge = 1
        
        // Добавляем данные для отслеживания
        content.userInfo = [
            "reminderId": reminder.id.uuidString,
            "isSmartNotification": smartNotificationsEnabled
        ]
        
        // Оптимизируем время уведомления
        let optimizedTime = await optimizeNotificationTime(for: reminder)
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: optimizedTime)
        
        print("⏰ Scheduling smart reminder for \(optimizedTime) on \(reminder.daysString)")
        print("  - Smart message: \(smartMessage)")
        print("  - Time components: \(timeComponents)")
        
        // Создаем триггер для повторения в выбранные дни
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: timeComponents,
            repeats: true
        )
        
        // Создаем запрос
        let request = UNNotificationRequest(
            identifier: reminder.notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Smart reminder scheduled successfully: \(reminder.notificationIdentifier)")
        } catch {
            print("❌ Error scheduling smart reminder: \(error)")
        }
    }
    
    func scheduleAllReminders() async {
        guard isAuthorized else {
            print("⚠️ Cannot schedule reminders: notifications not authorized")
            return
        }
        
        print("🔄 Scheduling all enabled reminders...")
        
        // Сначала отменяем все существующие уведомления
        await cancelAllReminders()
        
        // Ждем немного, чтобы убедиться, что отмена завершилась
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунды
        
        // Планируем все активные напоминания
        let enabledReminders = reminders.filter { $0.isEnabled }
        print("📋 Found \(enabledReminders.count) enabled reminders to schedule")
        
        for reminder in enabledReminders {
            await scheduleReminder(reminder)
        }
        
        updateReminderStatus()
        
        // Проверяем результат
        await printPendingNotifications()
    }
    
    func cancelAllReminders() async {
        let center = UNUserNotificationCenter.current()
        
        // Получаем все pending notifications
        let requests = await center.pendingNotificationRequests()
        let ourIdentifiers = requests.filter { request in
            request.identifier.hasPrefix("mood-reminder-")
        }.map { $0.identifier }
        
        // Отменяем все наши уведомления
        if !ourIdentifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: ourIdentifiers)
            print("🗑️ Cancelled \(ourIdentifiers.count) existing notifications")
        }
        
        await MainActor.run {
            self.isAnyReminderEnabled = false
        }
        
        print("✅ All reminders cancelled")
    }
    
    // MARK: - Reminder Management
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
        updateReminderStatus()
        print("➕ Added new reminder: \(reminder.timeString) - \(reminder.message)")
    }
    
    func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            saveReminders()
            updateReminderStatus()
            print("✏️ Updated reminder: \(reminder.timeString) - \(reminder.message)")
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
        updateReminderStatus()
        print("🗑️ Deleted reminder: \(reminder.timeString) - \(reminder.message)")
    }
    
    func toggleReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isEnabled.toggle()
            saveReminders()
            updateReminderStatus()
            print("🔄 Toggled reminder: \(reminder.timeString) - \(reminders[index].isEnabled ? "Enabled" : "Disabled")")
        }
    }
    
    // MARK: - Toggle All Reminders
    func toggleAllReminders() async {
        if isAnyReminderEnabled {
            print("🔄 Disabling all reminders...")
            await cancelAllReminders()
        } else {
            print("🔄 Enabling all reminders...")
            await scheduleAllReminders()
        }
    }
    
    // MARK: - Debug Methods
    func printPendingNotifications() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        print("📋 Pending notifications: \(requests.count)")
        for request in requests {
            print("  - ID: \(request.identifier)")
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                print("    Date: \(trigger.dateComponents)")
                print("    Repeats: \(trigger.repeats)")
                print("    Next trigger date: \(trigger.nextTriggerDate()?.description ?? "Unknown")")
            }
        }
    }
    
    // MARK: - Authorization with Reminders
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            if granted {
                print("✅ Notification authorization granted")
                await scheduleAllReminders()
            } else {
                print("❌ Notification authorization denied")
            }
            
            return granted
        } catch {
            print("❌ Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    // MARK: - Smart Notifications
    
    /// Генерирует персонализированное сообщение на основе данных
    private func generateSmartMessage(for reminder: Reminder) async -> String {
        guard smartNotificationsEnabled, let storage = moodStorage else {
            return reminder.message
        }
        
        do {
            let entries = try await storage.fetchMoodEntries(for: 30) // Получаем записи за 30 дней
            
            // Анализируем последние записи
            let recentEntries = entries.filter { 
                Calendar.current.isDate($0.safeTimestamp, inSameDayAs: Date()) ||
                Calendar.current.isDate($0.safeTimestamp, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
            }
            
            // Если сегодня уже записали - мотивируем на завтра
            if recentEntries.contains(where: { Calendar.current.isDate($0.safeTimestamp, inSameDayAs: Date()) }) {
                return generateMotivationalMessage()
            }
            
            // Если вчера не записали - мягкое напоминание
            if !recentEntries.contains(where: { Calendar.current.isDate($0.safeTimestamp, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()) }) {
                return "Не забыли про настроение вашей собаки? 🐕"
            }
            
            // Анализируем тренд настроения
            let weeklyEntries = entries.filter { 
                $0.safeTimestamp >= Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            }
            
            if let trend = analyzeMoodTrend(weeklyEntries) {
                return generateTrendBasedMessage(trend)
            }
            
            // Стандартное сообщение с эмодзи
            return generateDefaultMessage()
            
        } catch {
            print("❌ Error generating smart message: \(error)")
            return reminder.message
        }
    }
    
    /// Анализирует тренд настроения
    private func analyzeMoodTrend(_ entries: [MoodEntry]) -> MoodTrend? {
        guard entries.count >= 3 else { return nil }
        
        let sortedEntries = entries.sorted { $0.safeTimestamp < $1.safeTimestamp }
        let recentEntries = Array(sortedEntries.suffix(3))
        
        let totalIntensity = recentEntries.reduce(0.0) { $0 + Double($1.safeIntensity) }
        let averageIntensity = recentEntries.count > 0 ? totalIntensity / Double(recentEntries.count) : 0.0
        let safeAverageIntensity = averageIntensity.isNaN ? 0.0 : averageIntensity
        
        // Определяем тренд
        if safeAverageIntensity >= 7.0 {
            return .improving
        } else if safeAverageIntensity <= 4.0 {
            return .declining
        } else {
            return .stable
        }
    }
    
    /// Генерирует сообщение на основе тренда
    private func generateTrendBasedMessage(_ trend: MoodTrend) -> String {
        switch trend {
        case .improving:
            return "Отлично! Настроение улучшается! Продолжайте наблюдать 🎉"
        case .declining:
            return "Заметили изменения в настроении? Время для записи 📝"
        case .stable:
            return "Стабильное настроение - отлично! Запишите сегодняшнее состояние 📊"
        }
    }
    
    /// Генерирует мотивационное сообщение
    private func generateMotivationalMessage() -> String {
        let messages = [
            "Отличная работа! Завтра снова следите за настроением 🐕",
            "Вы на правильном пути! Продолжайте наблюдать за собакой ✨",
            "Замечательно! Регулярные записи помогают лучше понимать питомца 🎯"
        ]
        return messages.randomElement() ?? "Отличная работа! 🐕"
    }
    
    /// Генерирует стандартное сообщение
    private func generateDefaultMessage() -> String {
        let messages = [
            "Как настроение вашей собаки сегодня? 🐕",
            "Время записать настроение питомца 📝",
            "Не забудьте про настроение вашей собаки 🐾",
            "Как чувствует себя ваш четвероногий друг? 🐕"
        ]
        return messages.randomElement() ?? "Как настроение вашей собаки? 🐕"
    }
    
    /// Оптимизирует время уведомления на основе паттернов
    private func optimizeNotificationTime(for reminder: Reminder) async -> Date {
        guard smartNotificationsEnabled, let storage = moodStorage else {
            return reminder.time
        }
        
        do {
            let entries = try await storage.fetchMoodEntries(for: 7) // Получаем записи за 7 дней
            
            // Анализируем время последних записей
            let recentEntries = entries.filter { 
                $0.safeTimestamp >= Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            }
            
            if !recentEntries.isEmpty {
                // Находим наиболее популярное время записи
                let hourCounts = Dictionary(grouping: recentEntries) { entry in
                    Calendar.current.component(.hour, from: entry.safeTimestamp)
                }.mapValues { $0.count }
                
                if let mostPopularHour = hourCounts.max(by: { $0.value < $1.value })?.key {
                    // Оптимизируем время на 30 минут раньше
                    let optimizedHour = max(mostPopularHour - 1, 8) // Не раньше 8 утра
                    var components = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
                    components.hour = optimizedHour
                    components.minute = 0
                    
                    if let optimizedTime = Calendar.current.date(from: components) {
                        print("⏰ Optimized notification time: \(optimizedTime)")
                        return optimizedTime
                    }
                }
            }
            
        } catch {
            print("❌ Error optimizing notification time: \(error)")
        }
        
        return reminder.time
    }
    
    /// Отслеживает эффективность уведомления
    func trackNotificationEffectiveness(reminderId: String, wasEffective: Bool) {
        let currentScore = notificationEffectiveness[reminderId] ?? 0
        let newScore = wasEffective ? currentScore + 1 : max(currentScore - 1, 0)
        notificationEffectiveness[reminderId] = newScore
        
        print("📊 Notification effectiveness for \(reminderId): \(newScore)")
    }
}

// MARK: - Mood Trend Enum
enum MoodTrend {
    case improving
    case declining
    case stable
} 