//
//  MoodLoggerViewModel.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import Foundation
import Combine

@MainActor
class MoodLoggerViewModel: BaseViewModel {
    @Published var selectedEmotion: DogEmotion?
    @Published var intensity: Int = 5
    @Published var note: String = ""
    @Published var isSaving = false
    
    private let moodStorage: MoodStorageProtocol
    
    init(moodStorage: MoodStorageProtocol) {
        self.moodStorage = moodStorage
        super.init()
    }
    
    func selectEmotion(_ emotion: DogEmotion) {
        selectedEmotion = emotion
    }
    
    func updateIntensity(_ newIntensity: Int) {
        intensity = max(1, min(10, newIntensity))
    }
    
    func saveMoodEntry() async {
        guard let emotion = selectedEmotion else {
            handleError(MoodStorageError.invalidData)
            return
        }
        
        isSaving = true
        isLoading = true
        
        do {
            // Создаем временный объект для передачи данных
            let tempEntry = MoodEntryData()
            tempEntry.id = UUID()
            tempEntry.emotion = emotion.rawValue
            tempEntry.intensity = Int16(intensity)
            tempEntry.note = note.isEmpty ? nil : note
            tempEntry.timestamp = Date()
            
            // Сохраняем через background context
            try await moodStorage.saveMoodEntry(tempEntry)
            
            // Сброс формы
            selectedEmotion = nil
            intensity = 5
            note = ""
            
        } catch {
            handleError(error)
        }
        
        isSaving = false
        isLoading = false
    }
    
    var canSave: Bool {
        selectedEmotion != nil && !isSaving
    }
    
    var intensityDescription: String {
        switch intensity {
        case 1...2: return "Очень низкое"
        case 3...4: return "Низкое"
        case 5: return "Среднее"
        case 6...7: return "Высокое"
        case 8...10: return "Очень высокое"
        default: return "Среднее"
        }
    }
}

 