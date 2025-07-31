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
    
    func saveMoodEntry(_ entry: MoodEntry) async throws {
        do {
            try container.viewContext.save()
        } catch {
            throw MoodStorageError.saveFailed
        }
    }
    
    func fetchMoodEntries(for days: Int) async throws -> [MoodEntry] {
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        request.predicate = NSPredicate(format: "timestamp >= %@", startDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.timestamp, ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            throw MoodStorageError.fetchFailed
        }
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) async throws {
        container.viewContext.delete(entry)
        
        do {
            try container.viewContext.save()
        } catch {
            throw MoodStorageError.deleteFailed
        }
    }
    
    func fetchMoodEntriesByDate(_ date: Date) async throws -> [MoodEntry] {
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", 
                                       startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.timestamp, ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            throw MoodStorageError.fetchFailed
        }
    }
} 