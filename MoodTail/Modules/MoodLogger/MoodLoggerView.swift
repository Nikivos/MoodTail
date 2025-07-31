//
//  MoodLoggerView.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import SwiftUI

struct MoodLoggerView: View {
    @StateObject private var viewModel: MoodLoggerViewModel
    @State private var showSuccessFeedback = false
    
    init(moodStorage: MoodStorageProtocol = CoreDataMoodStorage(container: PersistenceController.shared.container)) {
        _viewModel = StateObject(wrappedValue: MoodLoggerViewModel(moodStorage: moodStorage))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Современный заголовок
                    modernHeaderSection
                    
                    // Выбор эмоций
                    modernEmotionSelectionSection
                    
                    // Интенсивность (показывается только если выбрана эмоция)
                    if viewModel.selectedEmotion != nil {
                        modernIntensitySection
                    }
                    
                    // Заметка
                    modernNoteSection
                    
                    // Кнопка сохранения
                    modernSaveButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.moodColors.background.ignoresSafeArea())
            .navigationTitle("Настроение")
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
            .overlay(
                // Успешное сохранение
                VStack {
                    if showSuccessFeedback {
                        SuccessFeedback(
                            message: "Настроение сохранено! 🎉",
                            isShowing: $showSuccessFeedback
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 100)
                    }
                    Spacer()
                }
            )
        }
    }
    
    // MARK: - Modern Header Section
    private var modernHeaderSection: some View {
        VStack(spacing: 16) {
            // Анимированная иконка собаки
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.moodColors.happy.opacity(0.2), Color.moodColors.calm.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text("🐕")
                    .font(.system(size: 40))
            }
            .scaleEffect(showSuccessFeedback ? 1.1 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessFeedback)
            
            VStack(spacing: 8) {
                Text("Как чувствует себя твоя собака?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Выбери эмоцию и интенсивность для лучшего понимания")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Modern Emotion Selection Section
    private var modernEmotionSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 18))
                
                Text("Эмоция")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(DogEmotion.allCases, id: \.self) { emotion in
                    ModernEmotionCard(
                        emotion: emotion,
                        isSelected: viewModel.selectedEmotion == emotion
                    ) {
                        viewModel.selectEmotion(emotion)
                    }
                }
            }
        }
    }
    
    // MARK: - Modern Intensity Section
    private var modernIntensitySection: some View {
        ModernIntensitySlider(
            intensity: Binding(
                get: { viewModel.intensity },
                set: { viewModel.updateIntensity($0) }
            ),
            emotion: viewModel.selectedEmotion ?? .happy
        )
    }
    
    // MARK: - Modern Note Section
    private var modernNoteSection: some View {
        ModernNoteField(
            text: $viewModel.note,
            placeholder: "Что произошло сегодня? Какие события повлияли на настроение?"
        )
    }
    
    // MARK: - Modern Save Button
    private var modernSaveButton: some View {
        ModernSaveButton(
            isEnabled: viewModel.canSave,
            isLoading: viewModel.isSaving
        ) {
            Task {
                await viewModel.saveMoodEntry()
                
                // Показываем успешное сохранение
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showSuccessFeedback = true
                }
                
                // Скрываем через 3 секунды
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showSuccessFeedback = false
                    }
                }
            }
        }
    }
}

#Preview {
    MoodLoggerView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 