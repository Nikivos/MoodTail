//
//  MoodLoggerView.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import SwiftUI

struct MoodLoggerView: View {
    @StateObject private var viewModel: MoodLoggerViewModel
    
    init(moodStorage: MoodStorageProtocol = CoreDataMoodStorage(container: PersistenceController.shared.container)) {
        _viewModel = StateObject(wrappedValue: MoodLoggerViewModel(moodStorage: moodStorage))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    emotionSelectionSection
                    intensitySection
                    noteSection
                    saveButton
                }
                .padding()
            }
            .navigationTitle("Настроение собаки")
            .navigationBarTitleDisplayMode(.large)
            .alert("Ошибка", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.clearError() }
            )) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🐕")
                .font(.system(size: 60))
            
            Text("Как чувствует себя твоя собака?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Выбери эмоцию и интенсивность")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var emotionSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Эмоция")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(DogEmotion.allCases, id: \.self) { emotion in
                    EmotionCard(
                        emotion: emotion,
                        isSelected: viewModel.selectedEmotion == emotion
                    ) {
                        viewModel.selectEmotion(emotion)
                    }
                }
            }
        }
    }
    
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Интенсивность: \(viewModel.intensityDescription)")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: Binding(
                        get: { Double(viewModel.intensity) },
                        set: { viewModel.updateIntensity(Int($0)) }
                    ), in: 1...10, step: 1)
                    .accentColor(.blue)
                    
                    Text("10")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Уровень: \(viewModel.intensity)/10")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Новый поясняющий текст
                Text("Интенсивность — насколько сильно собака проявляет эмоцию (1 — слабо, 10 — очень сильно)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Заметка (необязательно)")
                .font(.headline)
            
            TextField("Что произошло сегодня?", text: $viewModel.note, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
    }
    
    private var saveButton: some View {
        Button {
            Task {
                await viewModel.saveMoodEntry()
            }
        } label: {
            HStack {
                if viewModel.isSaving {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }
                
                Text(viewModel.isSaving ? "Сохранение..." : "Сохранить")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(viewModel.canSave ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canSave)
        .padding(.top)
    }
}

struct EmotionCard: View {
    let emotion: DogEmotion
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emotion.emoji)
                    .font(.system(size: 32))
                
                Text(emotion.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MoodLoggerView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 