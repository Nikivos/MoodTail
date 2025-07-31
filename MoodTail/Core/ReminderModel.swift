import Foundation
import UserNotifications

// MARK: - Reminder Model
struct Reminder: Identifiable, Codable {
    let id: UUID
    var time: Date
    var daysOfWeek: Set<DayOfWeek>
    var isEnabled: Bool
    var message: String
    var sound: ReminderSound
    
    init(
        id: UUID = UUID(),
        time: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date(),
        daysOfWeek: Set<DayOfWeek> = Set(DayOfWeek.allCases),
        isEnabled: Bool = true,
        message: String = "Как твое настроение?",
        sound: ReminderSound = .default
    ) {
        self.id = id
        self.time = time
        self.daysOfWeek = daysOfWeek
        self.isEnabled = isEnabled
        self.message = message
        self.sound = sound
    }
    
    // MARK: - Computed Properties
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    var daysString: String {
        if daysOfWeek.count == 7 {
            return "Каждый день"
        } else if daysOfWeek.count == 5 && daysOfWeek.contains(.monday) && daysOfWeek.contains(.friday) {
            return "Будние дни"
        } else if daysOfWeek.count == 2 && daysOfWeek.contains(.saturday) && daysOfWeek.contains(.sunday) {
            return "Выходные"
        } else {
            let sortedDays = daysOfWeek.sorted { $0.rawValue < $1.rawValue }
            return sortedDays.map { $0.shortName }.joined(separator: ", ")
        }
    }
    
    var notificationIdentifier: String {
        return "mood-reminder-\(id.uuidString)"
    }
}

// MARK: - Day of Week
enum DayOfWeek: Int, CaseIterable, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var name: String {
        switch self {
        case .sunday: return "Воскресенье"
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        }
    }
    
    var shortName: String {
        switch self {
        case .sunday: return "Вс"
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        }
    }
    
    var weekday: Int {
        return rawValue
    }
}

// MARK: - Reminder Sound
enum ReminderSound: String, CaseIterable, Codable {
    case `default` = "default"
    case gentle = "gentle"
    case chime = "chime"
    case bell = "bell"
    case none = "none"
    
    var displayName: String {
        switch self {
        case .default: return "По умолчанию"
        case .gentle: return "Мягкий"
        case .chime: return "Звонок"
        case .bell: return "Колокольчик"
        case .none: return "Без звука"
        }
    }
    
    var soundName: UNNotificationSound? {
        switch self {
        case .default:
            return .default
        case .gentle:
            return UNNotificationSound(named: UNNotificationSoundName("gentle.wav"))
        case .chime:
            return UNNotificationSound(named: UNNotificationSoundName("chime.wav"))
        case .bell:
            return UNNotificationSound(named: UNNotificationSoundName("bell.wav"))
        case .none:
            return nil
        }
    }
}

// MARK: - Reminder Templates
extension Reminder {
    static let templates: [Reminder] = [
        Reminder(
            time: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
            daysOfWeek: Set([.monday, .tuesday, .wednesday, .thursday, .friday]),
            message: "Доброе утро! Как твое настроение?",
            sound: .gentle
        ),
        Reminder(
            time: Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date(),
            daysOfWeek: Set(DayOfWeek.allCases),
            message: "Время подвести итоги дня. Как ты себя чувствуешь?",
            sound: .chime
        ),
        Reminder(
            time: Calendar.current.date(from: DateComponents(hour: 15, minute: 30)) ?? Date(),
            daysOfWeek: Set([.monday, .wednesday, .friday]),
            message: "Перерыв! Как твое настроение?",
            sound: .bell
        )
    ]
} 