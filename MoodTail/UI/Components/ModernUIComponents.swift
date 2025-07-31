import SwiftUI

// MARK: - Modern Emotion Card
struct ModernEmotionCard: View {
    let emotion: DogEmotion
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            VStack(spacing: 12) {
                // Эмоция иконка (без круга)
                if let image = emotion.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .foregroundColor(isSelected ? .white : emotion.color)
                } else {
                    Text(emotion.emoji)
                        .font(.system(size: 28))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                // Название эмоции
                Text(emotion.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? emotion.color : Color.moodColors.cardBackground)
                    .shadow(
                        color: isSelected ? emotion.color.opacity(0.4) : Color.moodColors.cardShadow,
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 6 : 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? emotion.color : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Modern Intensity Slider
struct ModernIntensitySlider: View {
    @Binding var intensity: Int
    let emotion: DogEmotion
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок
            HStack {
                Text("Интенсивность")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(intensity)/10")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(emotion.color)
            }
            
            // Слайдер
            VStack(spacing: 8) {
                HStack {
                    Text("1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: Binding(
                        get: { Double(max(1, min(10, intensity))) },
                        set: { intensity = Int(max(1, min(10, $0))) }
                    ), in: 1...10, step: 1)
                    .accentColor(emotion.color)
                    .scaleEffect(1.1)
                    
                    Text("10")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Визуальные индикаторы
                HStack(spacing: 4) {
                    ForEach(1...10, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(level <= intensity ? emotion.color : Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
            }
            
            // Описание
            Text(intensityDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.moodColors.cardBackground)
                .shadow(color: Color.moodColors.cardShadow, radius: 8, x: 0, y: 4)
        )
    }
    
    private var intensityDescription: String {
        switch intensity {
        case 1...2: return "Очень слабо проявляется"
        case 3...4: return "Слабо проявляется"
        case 5...6: return "Умеренно проявляется"
        case 7...8: return "Сильно проявляется"
        case 9...10: return "Очень сильно проявляется"
        default: return ""
        }
    }
}

// MARK: - Modern Save Button
struct ModernSaveButton: View {
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                }
                
                Text(isLoading ? "Сохранение..." : "Сохранить настроение")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnabled ? Color.moodColors.success : Color.gray.opacity(0.3))
                    .shadow(
                        color: isEnabled ? Color.moodColors.success.opacity(0.4) : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
            .foregroundColor(.white)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .disabled(!isEnabled || isLoading)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Modern Note Field
struct ModernNoteField: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.secondary)
                
                Text("Заметка")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .autocorrectionDisabled(false)
                .textInputAutocapitalization(.sentences)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("Готово") {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.moodColors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
                .lineLimit(3...6)
        }
    }
}

// MARK: - Success Feedback
struct SuccessFeedback: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
                .font(.system(size: 20))
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.moodColors.success)
                .shadow(color: Color.moodColors.success.opacity(0.4), radius: 8, x: 0, y: 4)
        )
        .opacity(isShowing ? 1 : 0)
        .scaleEffect(isShowing ? 1 : 0.8)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
    }
} 