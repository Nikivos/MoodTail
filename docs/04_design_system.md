# Этап 4. UI Design System для MoodTail (iOS)

## Цветовая палитра

### Основные цвета
- **Primary Blue**: #007AFF
- **Secondary Blue**: #5AC8FA
- **Success Green**: #34C759
- **Warning Orange**: #FF9500
- **Error Red**: #FF3B30

### Эмоциональные цвета
- **Радость**: #FFD700 (Золотой)
- **Нейтрально**: #8E8E93 (Серый)
- **Грусть**: #007AFF (Синий)
- **Злость**: #FF3B30 (Красный)
- **Усталость**: #AF52DE (Фиолетовый)
- **Задумчивость**: #5856D6 (Индиго)

### Фоновые цвета
- **Background**: #FFFFFF
- **Secondary Background**: #F2F2F7
- **Tertiary Background**: #E5E5EA

## Типографика

### Заголовки
- **H1**: SF Pro Display, 34pt, Bold
- **H2**: SF Pro Display, 28pt, Semibold
- **H3**: SF Pro Display, 22pt, Semibold

### Текст
- **Body Large**: SF Pro Text, 17pt, Regular
- **Body Medium**: SF Pro Text, 15pt, Regular
- **Body Small**: SF Pro Text, 13pt, Regular
- **Caption**: SF Pro Text, 12pt, Regular

## Компоненты

### Кнопки
```swift
// Primary Button
Button("Сохранить") {
    // action
}
.buttonStyle(PrimaryButtonStyle())

// Secondary Button
Button("Отмена") {
    // action
}
.buttonStyle(SecondaryButtonStyle())
```

### Карточки
```swift
CardView {
    VStack {
        Text("Заголовок")
        Text("Описание")
    }
}
```

### Эмоции
```swift
EmotionButton(emotion: .happy) {
    // action
}
```

## Иконки

### Системные иконки
- **Добавить**: plus.circle.fill
- **История**: chart.bar.fill
- **Настройки**: gear
- **График**: chart.line.uptrend.xyaxis
- **Экспорт**: square.and.arrow.up

### Эмоциональные иконки
- **Радость**: 😊
- **Нейтрально**: 😐
- **Грусть**: 😢
- **Злость**: 😡
- **Усталость**: 😴
- **Задумчивость**: 🤔

## Отступы и размеры

### Стандартные отступы
- **XS**: 4pt
- **S**: 8pt
- **M**: 16pt
- **L**: 24pt
- **XL**: 32pt
- **XXL**: 48pt

### Размеры компонентов
- **Кнопка высота**: 44pt
- **Карточка радиус**: 12pt
- **Эмоция размер**: 60x60pt

## Анимации

### Переходы
- **Duration**: 0.3s
- **Easing**: easeInOut
- **Spring**: damping: 0.8, response: 0.6

### Микроанимации
- **Tap Scale**: 0.95
- **Hover Opacity**: 0.8
- **Loading Rotation**: 360° over 1s 