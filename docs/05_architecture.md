# Этап 5. ARCHITECTURE.md — MoodTail

## Архитектура проекта

### MVVM (Model-View-ViewModel)
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    View     │◄──►│  ViewModel  │◄──►│   Model     │
│             │    │             │    │             │
│  SwiftUI    │    │  @State     │    │  Core Data  │
│  Views      │    │  @Binding   │    │  Entities   │
└─────────────┘    └─────────────┘    └─────────────┘
```

## Структура папок

```
MoodTail/
├── App/
│   ├── MoodTailApp.swift
│   └── AppDelegate.swift
├── Models/
│   ├── CoreData/
│   │   ├── MoodEntry.swift
│   │   └── MoodTail.xcdatamodeld
│   └── Enums/
│       ├── Emotion.swift
│       └── MoodIntensity.swift
├── Views/
│   ├── Main/
│   │   ├── DashboardView.swift
│   │   ├── HistoryView.swift
│   │   └── SettingsView.swift
│   ├── Components/
│   │   ├── EmotionButton.swift
│   │   ├── MoodCard.swift
│   │   └── ChartView.swift
│   └── Onboarding/
│       └── OnboardingView.swift
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── HistoryViewModel.swift
│   └── SettingsViewModel.swift
├── Services/
│   ├── CoreDataService.swift
│   ├── NotificationService.swift
│   └── AnalyticsService.swift
├── Utils/
│   ├── Extensions/
│   │   ├── Color+Extensions.swift
│   │   └── Date+Extensions.swift
│   ├── Constants/
│   │   └── AppConstants.swift
│   └── Helpers/
│       └── DateHelper.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

## Модели данных

### Core Data Entities

#### MoodEntry
```swift
@objc(MoodEntry)
public class MoodEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var emotion: String
    @NSManaged public var intensity: Int16
    @NSManaged public var note: String?
    @NSManaged public var timestamp: Date
    @NSManaged public var activities: Set<Activity>?
}
```

#### Activity
```swift
@objc(Activity)
public class Activity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var icon: String
    @NSManaged public var moodEntries: Set<MoodEntry>?
}
```

### Enums

#### Emotion
```swift
enum Emotion: String, CaseIterable {
    case happy = "happy"
    case neutral = "neutral"
    case sad = "sad"
    case angry = "angry"
    case tired = "tired"
    case thoughtful = "thoughtful"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .neutral: return "😐"
        case .sad: return "😢"
        case .angry: return "😡"
        case .tired: return "😴"
        case .thoughtful: return "🤔"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .neutral: return .gray
        case .sad: return .blue
        case .angry: return .red
        case .tired: return .purple
        case .thoughtful: return .indigo
        }
    }
}
```

## ViewModels

### DashboardViewModel
```swift
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var currentMood: Emotion?
    @Published var weeklyStats: [MoodEntry] = []
    @Published var isLoading = false
    
    private let coreDataService: CoreDataService
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }
    
    func addMoodEntry(_ emotion: Emotion, note: String?) {
        // Логика добавления записи
    }
    
    func loadWeeklyStats() {
        // Загрузка статистики за неделю
    }
}
```

## Services

### CoreDataService
```swift
class CoreDataService {
    static let shared = CoreDataService()
    
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "MoodTail")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }
    
    func saveMoodEntry(_ entry: MoodEntry) {
        // Сохранение записи
    }
    
    func fetchMoodEntries(for period: DatePeriod) -> [MoodEntry] {
        // Получение записей за период
    }
}
```

## Dependency Injection

### AppContainer
```swift
class AppContainer {
    static let shared = AppContainer()
    
    lazy var coreDataService = CoreDataService.shared
    lazy var notificationService = NotificationService()
    lazy var analyticsService = AnalyticsService()
    
    private init() {}
}
```

## Навигация

### TabView Structure
```swift
TabView {
    DashboardView()
        .tabItem {
            Image(systemName: "house.fill")
            Text("Главная")
        }
    
    HistoryView()
        .tabItem {
            Image(systemName: "chart.bar.fill")
            Text("История")
        }
    
    SettingsView()
        .tabItem {
            Image(systemName: "gear")
            Text("Настройки")
        }
}
```

## Принципы архитектуры

### 1. Single Responsibility
- Каждый класс имеет одну ответственность
- ViewModels управляют состоянием
- Services обрабатывают бизнес-логику

### 2. Dependency Injection
- Использование протоколов для тестирования
- Централизованное управление зависимостями

### 3. Reactive Programming
- @Published для реактивного обновления UI
- Combine для асинхронных операций

### 4. Error Handling
- Централизованная обработка ошибок
- User-friendly сообщения об ошибках

### 5. Testing
- Unit тесты для ViewModels
- UI тесты для критических сценариев
- Mock данные для тестирования 