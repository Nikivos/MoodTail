import Foundation
import SwiftUI
import Combine

@MainActor
class PetProfileViewModel: ObservableObject {
    @Published var petProfile: PetProfile?
    @Published var statistics: PetStatistics = PetStatistics()
    @Published var isLoading = false
    @Published var showingImagePicker = false
    @Published var showingEditProfile = false
    
    private let userDefaults = UserDefaults.standard
    private let petProfileKey = "petProfile"
    private let statisticsKey = "petStatistics"
    
    init() {
        loadPetProfile()
        loadStatistics()
    }
    
    // MARK: - Pet Profile Management
    
    func loadPetProfile() {
        if let data = userDefaults.data(forKey: petProfileKey),
           let profile = try? JSONDecoder().decode(PetProfile.self, from: data) {
            self.petProfile = profile
        } else {
            // Создаем дефолтный профиль
            self.petProfile = PetProfile(name: "Мой питомец")
        }
    }
    
    func savePetProfile() {
        guard let profile = petProfile else { return }
        
        if let data = try? JSONEncoder().encode(profile) {
            userDefaults.set(data, forKey: petProfileKey)
        }
    }
    
    func updatePetProfile(_ profile: PetProfile) {
        self.petProfile = profile
        savePetProfile()
    }
    
    // MARK: - Statistics Management
    
    func loadStatistics() {
        if let data = userDefaults.data(forKey: statisticsKey),
           let stats = try? JSONDecoder().decode(PetStatistics.self, from: data) {
            self.statistics = stats
        }
    }
    
    func saveStatistics() {
        if let data = try? JSONEncoder().encode(statistics) {
            userDefaults.set(data, forKey: statisticsKey)
        }
    }
    
    func updateStatistics(from moodEntries: [MoodEntry]) {
        guard !moodEntries.isEmpty else { return }
        
        statistics.totalEntries = moodEntries.count
        
        // Безопасное вычисление среднего настроения
        let totalIntensity = moodEntries.reduce(0) { $0 + $1.intensity }
        let averageMood = totalIntensity > 0 ? Double(totalIntensity) / Double(moodEntries.count) : 0.0
        statistics.averageMood = averageMood.isNaN ? 0.0 : averageMood
        
        // Находим любимую эмоцию
        let emotionCounts = Dictionary(grouping: moodEntries, by: { $0.emotion })
            .mapValues { $0.count }
        
        if let favorite = emotionCounts.max(by: { $0.value < $1.value }) {
            statistics.favoriteEmotion = DogEmotion(rawValue: favorite.key ?? "")
        }
        
        // Находим самый активный день
        let dayCounts = Dictionary(grouping: moodEntries, by: { 
            Calendar.current.component(.weekday, from: $0.timestamp ?? Date())
        }).mapValues { $0.count }
        
        if let mostActive = dayCounts.max(by: { $0.value < $1.value }) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            let dayIndex = mostActive.key - 1
            if dayIndex >= 0 && dayIndex < formatter.weekdaySymbols.count {
                statistics.mostActiveDay = formatter.weekdaySymbols[dayIndex]
            }
        }
        
        // Обновляем дату последней записи
        if let lastEntry = moodEntries.max(by: { ($0.timestamp ?? Date()) < ($1.timestamp ?? Date()) }) {
            statistics.lastEntryDate = lastEntry.timestamp
        }
        
        saveStatistics()
    }
    
    // MARK: - Image Management
    
    func setPetPhoto(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        petProfile?.photoData = data
        petProfile?.updatedAt = Date()
        savePetProfile()
    }
    
    func getPetPhoto() -> UIImage? {
        guard let data = petProfile?.photoData else { return nil }
        return UIImage(data: data)
    }
    
    // MARK: - Computed Properties
    
    var hasPetProfile: Bool {
        return petProfile != nil && petProfile?.name != "Мой питомец"
    }
    
    var displayName: String {
        return petProfile?.name ?? "Мой питомец"
    }
    
    var displayBreed: String {
        return petProfile?.breed.isEmpty == false ? petProfile?.breed ?? "" : "Порода не указана"
    }
    
    var displayAge: String {
        guard let age = petProfile?.age, age > 0 else { return "Возраст не указан" }
        return "\(age) \(age == 1 ? "год" : age < 5 ? "года" : "лет")"
    }
    
    var displayWeight: String {
        guard let weight = petProfile?.weight, weight > 0 else { return "Вес не указан" }
        return String(format: "%.1f кг", weight)
    }
} 