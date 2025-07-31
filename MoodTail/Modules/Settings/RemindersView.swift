import SwiftUI

struct RemindersView: View {
    @ObservedObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddReminder = false
    @State private var selectedReminder: Reminder?
    
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
    
    private var shadowColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightShadow
        case .dark:
            return .darkShadow
        case .system:
            return themeManager.isDarkMode ? .darkShadow : .lightShadow
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Content
                    if notificationManager.reminders.isEmpty {
                        emptyStateView
                    } else {
                        remindersList
                    }
                }
            }
            .navigationTitle("Напоминания")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        showingAddReminder = true
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(accentColor)
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                ReminderEditView(
                    reminder: nil,
                    onSave: { reminder in
                        notificationManager.addReminder(reminder)
                        Task {
                            await notificationManager.scheduleAllReminders()
                        }
                    }
                )
            }
            .sheet(item: $selectedReminder) { reminder in
                ReminderEditView(
                    reminder: reminder,
                    onSave: { updatedReminder in
                        notificationManager.updateReminder(updatedReminder)
                        Task {
                            await notificationManager.scheduleAllReminders()
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Напоминания о настроении")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(primaryTextColor)
                    
                    Text("Настройте время для записи настроения")
                        .font(.body)
                        .foregroundColor(secondaryTextColor)
                }
                
                Spacer()
                
                // Toggle all reminders button
                Button(action: {
                    Task {
                        await notificationManager.toggleAllReminders()
                    }
                }) {
                    Image(systemName: notificationManager.isAnyReminderEnabled ? "bell.fill" : "bell.slash")
                        .font(.title2)
                        .foregroundColor(notificationManager.isAnyReminderEnabled ? accentColor : secondaryTextColor)
                        .frame(width: 44, height: 44)
                        .background(cardBackgroundColor)
                        .clipShape(Circle())
                        .shadow(color: shadowColor, radius: 2, x: 0, y: 1)
                }
            }
            
            // Smart notifications toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Умные уведомления")
                        .font(.headline)
                        .foregroundColor(primaryTextColor)
                    
                    Text("Персонализированные сообщения на основе данных")
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { notificationManager.smartNotificationsEnabled },
                    set: { _ in
                        notificationManager.toggleSmartNotifications()
                        Task {
                            await notificationManager.scheduleAllReminders()
                        }
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: accentColor))
            }
            .padding()
            .background(cardBackgroundColor.opacity(0.5))
            .cornerRadius(12)
            
            // Quick templates
            if notificationManager.reminders.isEmpty {
                quickTemplatesSection
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Quick Templates Section
    private var quickTemplatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Быстрые шаблоны")
                .font(.headline)
                .foregroundColor(primaryTextColor)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Reminder.templates, id: \.id) { template in
                        Button(action: {
                            notificationManager.addReminder(template)
                            Task {
                                await notificationManager.scheduleAllReminders()
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.timeString)
                                    .font(.headline)
                                    .foregroundColor(primaryTextColor)
                                
                                Text(template.daysString)
                                    .font(.caption)
                                    .foregroundColor(secondaryTextColor)
                                
                                Text(template.message)
                                    .font(.caption2)
                                    .foregroundColor(secondaryTextColor.opacity(0.7))
                                    .lineLimit(2)
                            }
                            .frame(width: 120, alignment: .leading)
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(12)
                            .shadow(color: shadowColor, radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Reminders List
    private var remindersList: some View {
        List {
            ForEach(notificationManager.reminders) { reminder in
                ReminderRowView(reminder: reminder, onToggle: {
                    notificationManager.toggleReminder(reminder)
                    Task {
                        await notificationManager.scheduleAllReminders()
                    }
                })
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        notificationManager.deleteReminder(reminder)
                        Task {
                            await notificationManager.scheduleAllReminders()
                        }
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        selectedReminder = reminder
                    } label: {
                        Label("Изменить", systemImage: "pencil")
                    }
                    .tint(accentColor)
                }
            }
        }
        .listStyle(PlainListStyle())
        .background(backgroundColor)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(secondaryTextColor)
            
            VStack(spacing: 8) {
                Text("Нет напоминаний")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(primaryTextColor)
                
                Text("Добавьте напоминания, чтобы не забывать записывать настроение")
                    .font(.body)
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddReminder = true
            }) {
                Text("Добавить напоминание")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(accentColor)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Reminder Row View
struct ReminderRowView: View {
    let reminder: Reminder
    let onToggle: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    // MARK: - Computed Colors
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
    
    private var tertiaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightTertiaryText
        case .dark:
            return .darkTertiaryText
        case .system:
            return themeManager.isDarkMode ? .darkTertiaryText : .lightTertiaryText
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
    
    private var shadowColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightShadow
        case .dark:
            return .darkShadow
        case .system:
            return themeManager.isDarkMode ? .darkShadow : .lightShadow
        }
    }
    
    private var errorColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightError
        case .dark:
            return .darkError
        case .system:
            return themeManager.isDarkMode ? .darkError : .lightError
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Time and info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(reminder.timeString)
                            .font(.headline)
                            .foregroundColor(primaryTextColor)
                        
                        if reminder.isEnabled {
                            Image(systemName: "bell.fill")
                                .font(.caption)
                                .foregroundColor(accentColor)
                        }
                    }
                    
                    Text(reminder.daysString)
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                    
                    Text(reminder.message)
                        .font(.caption2)
                        .foregroundColor(tertiaryTextColor)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Toggle button
                Button(action: onToggle) {
                    Image(systemName: reminder.isEnabled ? "bell.fill" : "bell.slash")
                        .font(.title3)
                        .foregroundColor(reminder.isEnabled ? accentColor : secondaryTextColor)
                        .frame(width: 44, height: 44)
                        .background(cardBackgroundColor)
                        .clipShape(Circle())
                        .shadow(color: shadowColor, radius: 2, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(cardBackgroundColor)
            .cornerRadius(12)
            .shadow(color: shadowColor, radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    RemindersView(notificationManager: NotificationManager())
} 