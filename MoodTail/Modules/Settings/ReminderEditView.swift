import SwiftUI

struct ReminderEditView: View {
    let reminder: Reminder?
    let onSave: (Reminder) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var time: Date
    @State private var selectedDays: Set<DayOfWeek>
    @State private var message: String
    @State private var sound: ReminderSound
    @State private var isEnabled: Bool
    
    // MARK: - Computed Colors
    private var backgroundColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightSecondaryBackground
        case .dark:
            return .darkSecondaryBackground
        case .system:
            return themeManager.isDarkMode ? .darkSecondaryBackground : .lightSecondaryBackground
        }
    }
    
    private var primaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightPrimaryText
        case .dark:
            return .darkPrimaryText
        case .system:
            return themeManager.isDarkMode ? .darkPrimaryText : .lightPrimaryText
        }
    }
    
    private var secondaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightSecondaryText
        case .dark:
            return .darkSecondaryText
        case .system:
            return themeManager.isDarkMode ? .darkSecondaryText : .lightSecondaryText
        }
    }
    
    private var accentColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightAccent
        case .dark:
            return .darkAccent
        case .system:
            return themeManager.isDarkMode ? .darkAccent : .lightAccent
        }
    }
    
    private var cardBackgroundColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightCardBackground
        case .dark:
            return .darkCardBackground
        case .system:
            return themeManager.isDarkMode ? .darkCardBackground : .lightCardBackground
        }
    }
    
    private var borderColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightBorder
        case .dark:
            return .darkBorder
        case .system:
            return themeManager.isDarkMode ? .darkBorder : .lightBorder
        }
    }
    
    init(reminder: Reminder?, onSave: @escaping (Reminder) -> Void) {
        self.reminder = reminder
        self.onSave = onSave
        
        let defaultTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
        
        _time = State(initialValue: reminder?.time ?? defaultTime)
        _selectedDays = State(initialValue: reminder?.daysOfWeek ?? Set(DayOfWeek.allCases))
        _message = State(initialValue: reminder?.message ?? "Как твое настроение?")
        _sound = State(initialValue: reminder?.sound ?? .default)
        _isEnabled = State(initialValue: reminder?.isEnabled ?? true)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time picker
                    timeSection
                    
                    // Days selection
                    daysSection
                    
                    // Message
                    messageSection
                    
                    // Sound
                    soundSection
                    
                    // Enable/disable
                    enableSection
                }
                .padding()
            }
            .background(backgroundColor)
            .navigationTitle(reminder == nil ? "Новое напоминание" : "Редактировать")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveReminder()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Time Section
    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Время")
                .font(.headline)
                .foregroundColor(primaryTextColor)
            
            DatePicker("Время", selection: $time, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                .background(cardBackgroundColor)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Days Section
    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Дни недели")
                .font(.headline)
                .foregroundColor(primaryTextColor)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    DayToggleButton(
                        day: day,
                        isSelected: selectedDays.contains(day),
                        onToggle: {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        }
                    )
                }
            }
            
            // Quick selections
            HStack(spacing: 12) {
                QuickSelectionButton(
                    title: "Будние",
                    isSelected: selectedDays == Set([.monday, .tuesday, .wednesday, .thursday, .friday]),
                    action: {
                        selectedDays = Set([.monday, .tuesday, .wednesday, .thursday, .friday])
                    }
                )
                
                QuickSelectionButton(
                    title: "Выходные",
                    isSelected: selectedDays == Set([.saturday, .sunday]),
                    action: {
                        selectedDays = Set([.saturday, .sunday])
                    }
                )
                
                QuickSelectionButton(
                    title: "Каждый день",
                    isSelected: selectedDays == Set(DayOfWeek.allCases),
                    action: {
                        selectedDays = Set(DayOfWeek.allCases)
                    }
                )
            }
        }
    }
    
    // MARK: - Message Section
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сообщение")
                .font(.headline)
                .foregroundColor(primaryTextColor)
            
            TextField("Введите сообщение", text: $message, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
            
            // Quick messages
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickMessages, id: \.self) { quickMessage in
                        Button(action: {
                            message = quickMessage
                        }) {
                            Text(quickMessage)
                                .font(.caption)
                                .foregroundColor(secondaryTextColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(cardBackgroundColor)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Sound Section
    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Звук")
                .font(.headline)
                .foregroundColor(primaryTextColor)
            
            Picker("Звук", selection: $sound) {
                ForEach(ReminderSound.allCases, id: \.self) { sound in
                    Text(sound.displayName).tag(sound)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(cardBackgroundColor)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Enable Section
    private var enableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статус")
                .font(.headline)
                .foregroundColor(primaryTextColor)
            
            Toggle("Включить напоминание", isOn: $isEnabled)
                .padding()
                .background(cardBackgroundColor)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Quick Messages
    private var quickMessages: [String] {
        [
            "Как твое настроение?",
            "Время записать настроение",
            "Как дела?",
            "Как ты себя чувствуешь?",
            "Доброе утро! Как настроение?",
            "Время подвести итоги дня",
            "Перерыв! Как настроение?"
        ]
    }
    
    // MARK: - Save
    private func saveReminder() {
        let newReminder = Reminder(
            id: reminder?.id ?? UUID(),
            time: time,
            daysOfWeek: selectedDays,
            isEnabled: isEnabled,
            message: message,
            sound: sound
        )
        
        onSave(newReminder)
        dismiss()
    }
}

// MARK: - Day Toggle Button
struct DayToggleButton: View {
    let day: DayOfWeek
    let isSelected: Bool
    let onToggle: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else {
            switch themeManager.currentTheme {
            case .light:
                return .lightPrimaryText
            case .dark:
                return .darkPrimaryText
            case .system:
                return themeManager.isDarkMode ? .darkPrimaryText : .lightPrimaryText
            }
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            switch themeManager.currentTheme {
            case .light:
                return .lightAccent
            case .dark:
                return .darkAccent
            case .system:
                return themeManager.isDarkMode ? .darkAccent : .lightAccent
            }
        } else {
            switch themeManager.currentTheme {
            case .light:
                return .lightBackground
            case .dark:
                return .darkBackground
            case .system:
                return themeManager.isDarkMode ? .darkBackground : .lightBackground
            }
        }
    }
    
    var body: some View {
        Button(action: onToggle) {
            Text(day.shortName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .frame(width: 32, height: 32)
                .background(backgroundColor)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick Selection Button
struct QuickSelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else {
            switch themeManager.currentTheme {
            case .light:
                return .lightSecondaryText
            case .dark:
                return .darkSecondaryText
            case .system:
                return themeManager.isDarkMode ? .darkSecondaryText : .lightSecondaryText
            }
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            switch themeManager.currentTheme {
            case .light:
                return .lightAccent
            case .dark:
                return .darkAccent
            case .system:
                return themeManager.isDarkMode ? .darkAccent : .lightAccent
            }
        } else {
            switch themeManager.currentTheme {
            case .light:
                return .lightBackground
            case .dark:
                return .darkBackground
            case .system:
                return themeManager.isDarkMode ? .darkBackground : .lightBackground
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(backgroundColor)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ReminderEditView(
        reminder: Reminder.templates.first,
        onSave: { _ in }
    )
} 