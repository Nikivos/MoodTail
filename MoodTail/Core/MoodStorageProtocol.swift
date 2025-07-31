//
//  MoodStorageProtocol.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import Foundation
import Combine

protocol MoodStorageProtocol {
    func saveMoodEntry(_ entry: MoodEntryData) async throws
    func fetchMoodEntries(for days: Int) async throws -> [MoodEntry]
    func deleteMoodEntry(_ entry: MoodEntry) async throws
    func fetchMoodEntriesByDate(_ date: Date) async throws -> [MoodEntry]
}

// Временный класс для передачи данных
class MoodEntryData {
    var id: UUID?
    var emotion: String?
    var intensity: Int16 = 0
    var note: String?
    var timestamp: Date?
}

enum MoodStorageError: Error, LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case invalidData
    case invalidEntry(String)
    case entryNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Не удалось сохранить запись настроения"
        case .fetchFailed:
            return "Не удалось загрузить записи настроения"
        case .deleteFailed:
            return "Не удалось удалить запись настроения"
        case .invalidData:
            return "Некорректные данные"
        case .invalidEntry(let message):
            return "Некорректная запись: \(message)"
        case .entryNotFound(let message):
            return "Запись не найдена: \(message)"
        }
    }
} 