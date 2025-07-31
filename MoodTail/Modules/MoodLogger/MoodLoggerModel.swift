//
//  MoodLoggerModel.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import Foundation
import SwiftUI

struct MoodLoggerModel {
    let emotion: DogEmotion
    let intensity: Int
    let note: String?
    let timestamp: Date
    
    init(emotion: DogEmotion, intensity: Int = 5, note: String? = nil, timestamp: Date = Date()) {
        self.emotion = emotion
        self.intensity = max(1, min(10, intensity)) // Ограничиваем от 1 до 10
        self.note = note
        self.timestamp = timestamp
    }
}

enum DogEmotion: String, CaseIterable, Codable {
    case happy = "happy"
    case excited = "excited"
    case calm = "calm"
    case anxious = "anxious"
    case sad = "sad"
    case playful = "playful"
    case tired = "tired"
    case aggressive = "aggressive"
    
    var emoji: String {
        switch self {
        case .happy: return "🐕"
        case .excited: return "🤩"
        case .calm: return "😌"
        case .anxious: return "😰"
        case .sad: return "😢"
        case .playful: return "🤪"
        case .tired: return "😴"
        case .aggressive: return "😠"
        }
    }
    
    var image: Image? {
        switch self {
        case .happy: return Image("happy-dog")
        default: return nil
        }
    }
    
    var displayName: String {
        switch self {
        case .happy: return "Счастлив"
        case .excited: return "Возбужден"
        case .calm: return "Спокоен"
        case .anxious: return "Тревожен"
        case .sad: return "Грустен"
        case .playful: return "Игрив"
        case .tired: return "Устал"
        case .aggressive: return "Агрессивен"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return Color.moodColors.happy
        case .excited: return Color.moodColors.excited
        case .calm: return Color.moodColors.calm
        case .anxious: return Color.moodColors.anxious
        case .sad: return Color.moodColors.sad
        case .playful: return Color.moodColors.playful
        case .tired: return Color.moodColors.tired
        case .aggressive: return Color.moodColors.aggressive
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .happy: return Color.moodColors.happyGradient
        case .excited: return Color.moodColors.excitedGradient
        case .calm: return Color.moodColors.calmGradient
        case .anxious: return Color.moodColors.anxiousGradient
        case .sad: return Color.moodColors.sadGradient
        case .playful: return Color.moodColors.playfulGradient
        case .tired: return Color.moodColors.tiredGradient
        case .aggressive: return Color.moodColors.aggressiveGradient
        }
    }
} 