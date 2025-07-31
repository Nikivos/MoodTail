import Foundation
import SwiftUI

// MARK: - Pet Profile Model
struct PetProfile: Codable, Identifiable {
    var id = UUID()
    var name: String
    var breed: String
    var age: Int
    var weight: Double
    var gender: PetGender
    var birthDate: Date
    var photoData: Data?
    var specialNotes: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        breed: String = "",
        age: Int = 0,
        weight: Double = 0.0,
        gender: PetGender = .unknown,
        birthDate: Date = Date(),
        photoData: Data? = nil,
        specialNotes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.breed = breed
        self.age = age
        self.weight = weight
        self.gender = gender
        self.birthDate = birthDate
        self.photoData = photoData
        self.specialNotes = specialNotes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Pet Gender
enum PetGender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .male: return "Мальчик"
        case .female: return "Девочка"
        case .unknown: return "Не указан"
        }
    }
    
    var emoji: String {
        switch self {
        case .male: return "🐕‍♂️"
        case .female: return "🐕‍♀️"
        case .unknown: return "🐕"
        }
    }
}

// MARK: - Pet Statistics
struct PetStatistics: Codable {
    var totalEntries: Int
    var averageMood: Double
    var favoriteEmotionString: String?
    var mostActiveDay: String?
    var streakDays: Int
    var lastEntryDate: Date?
    
    init() {
        self.totalEntries = 0
        self.averageMood = 0.0
        self.favoriteEmotionString = nil
        self.mostActiveDay = nil
        self.streakDays = 0
        self.lastEntryDate = nil
    }
    
    var favoriteEmotion: DogEmotion? {
        get {
            guard let emotionString = favoriteEmotionString else { return nil }
            return DogEmotion(rawValue: emotionString)
        }
        set {
            favoriteEmotionString = newValue?.rawValue
        }
    }
} 