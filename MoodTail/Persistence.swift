//
//  Persistence.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Создаем тестовые записи настроения
        let emotions = ["happy", "calm", "excited", "sad", "playful"]
        for i in 0..<5 {
            let newEntry = MoodEntry(context: viewContext)
            newEntry.id = UUID()
            newEntry.emotion = emotions[i]
            newEntry.intensity = Int16.random(in: 1...10)
            newEntry.note = "Тестовая запись \(i + 1)"
            newEntry.timestamp = Date().addingTimeInterval(-Double(i * 86400)) // Каждый день назад
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MoodTail")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
