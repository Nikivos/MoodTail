//
//  CoreDataMoodStorage.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import Foundation
import CoreData

class CoreDataMoodStorage: MoodStorageProtocol {
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func saveMoodEntry(_ entry: MoodEntryData) async throws {
        try await container.performBackgroundTask { context in
            // Создаем новый объект в background context
            let newEntry = MoodEntry(context: context)
            newEntry.id = entry.id ?? UUID() // Гарантируем, что ID всегда есть
            newEntry.emotion = entry.emotion
            newEntry.intensity = entry.intensity
            newEntry.note = entry.note
            newEntry.timestamp = entry.timestamp
            
            try context.save()
        }
    }
    
    func fetchMoodEntries(for days: Int) async throws -> [MoodEntry] {
        return try await container.performBackgroundTask { context in
            let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
            
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            
            request.predicate = NSPredicate(format: "timestamp >= %@", startDate as NSDate)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.timestamp, ascending: false)]
            request.fetchBatchSize = 20 // Оптимизация памяти
            
            return try context.fetch(request)
        }
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) async throws {
        try await container.performBackgroundTask { context in
            // Проверяем, что entry имеет валидный ID
            guard let entryID = entry.id else {
                throw MoodStorageError.invalidEntry("Entry has no ID")
            }
            
            // Получаем объект в background context по ID
            let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entryID as NSUUID)
            request.fetchLimit = 1
            
            let entries = try context.fetch(request)
            if let entryToDelete = entries.first {
                context.delete(entryToDelete)
                try context.save()
                print("Successfully deleted entry with ID: \(entryID)")
            } else {
                // Если запись не найдена, возможно она уже удалена
                print("Entry with ID \(entryID) not found, might be already deleted")
                // Не выбрасываем ошибку, так как цель (удаление) достигнута
            }
        }
    }
    
    func fetchMoodEntriesByDate(_ date: Date) async throws -> [MoodEntry] {
        return try await container.performBackgroundTask { context in
            let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
            
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
            
            request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", 
                                           startOfDay as NSDate, endOfDay as NSDate)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.timestamp, ascending: false)]
            request.fetchBatchSize = 20
            
            return try context.fetch(request)
        }
    }
} 