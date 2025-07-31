import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page indicator
                pageIndicator
                
                // Content
                TabView(selection: $viewModel.currentPage) {
                    welcomePage
                        .tag(0)
                    
                    purposePage
                        .tag(1)
                    
                    featuresPage
                        .tag(2)
                    
                    howItWorksPage
                        .tag(3)
                    
                    permissionsPage
                        .tag(4)
                    
                    finalPage
                        .tag(5)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
                
                // Navigation buttons
                navigationButtons
            }
        }
    }
    
    // MARK: - Computed Colors
    private var backgroundColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .lightBackground
        case .dark:
            return .darkBackground
        case .system:
            return themeManager.isDarkMode ? .darkBackground : .lightBackground
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
    
    // MARK: - Page Indicator
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(index == viewModel.currentPage ? accentColor : secondaryTextColor.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
    }
    
    // MARK: - Welcome Page
    private var welcomePage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Logo and title
            VStack(spacing: 24) {
                Image(systemName: "pawprint.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(accentColor)
                
                VStack(spacing: 12) {
                    Text("Добро пожаловать")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(primaryTextColor)
                    
                    Text("в MoodTail")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(accentColor)
                }
            }
            
            // Description
            VStack(spacing: 16) {
                Text("Ваш помощник в понимании")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(primaryTextColor)
                
                Text("настроения вашей собаки")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(primaryTextColor)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Purpose Page
    private var purposePage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Text("Зачем это нужно?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)
                    .multilineTextAlignment(.center)
            }
            
            // Purpose cards
            VStack(spacing: 20) {
                PurposeCard(
                    icon: "brain.head.profile",
                    title: "Понимание поведения",
                    description: "Отслеживайте изменения настроения и выявляйте паттерны в поведении вашей собаки"
                )
                
                PurposeCard(
                    icon: "heart.fill",
                    title: "Улучшение отношений",
                    description: "Лучше понимайте потребности питомца и укрепляйте вашу связь"
                )
                
                PurposeCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Предотвращение проблем",
                    description: "Замечайте ранние признаки стресса или дискомфорта"
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Features Page
    private var featuresPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Text("Возможности приложения")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)
                    .multilineTextAlignment(.center)
            }
            
            // Features
            VStack(spacing: 20) {
                FeatureCard(
                    icon: "plus.circle.fill",
                    title: "Быстрая запись",
                    description: "Записывайте настроение собаки одним касанием - просто выберите эмоцию",
                    color: .pink
                )
                
                FeatureCard(
                    icon: "chart.bar.fill",
                    title: "Детальная аналитика",
                    description: "Просматривайте графики, тренды и статистику настроения",
                    color: .blue
                )
                
                FeatureCard(
                    icon: "bell.fill",
                    title: "Умные напоминания",
                    description: "Получайте персонализированные уведомления в оптимальное время",
                    color: .orange
                )
                
                FeatureCard(
                    icon: "note.text",
                    title: "Заметки и контекст",
                    description: "Добавляйте заметки о событиях, которые повлияли на настроение",
                    color: .green
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - How It Works Page
    private var howItWorksPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Text("Как это работает?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)
                    .multilineTextAlignment(.center)
            }
            
            // Steps
            VStack(spacing: 24) {
                StepCard(
                    number: "1",
                    title: "Наблюдайте",
                    description: "Обратите внимание на поведение собаки - хвост, уши, позу, звуки"
                )
                
                StepCard(
                    number: "2",
                    title: "Записывайте",
                    description: "Выберите подходящую эмоцию и интенсивность настроения"
                )
                
                StepCard(
                    number: "3",
                    title: "Анализируйте",
                    description: "Изучайте тренды и выявляйте факторы, влияющие на настроение"
                )
                
                StepCard(
                    number: "4",
                    title: "Действуйте",
                    description: "Используйте полученные знания для улучшения жизни питомца"
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Permissions Page
    private var permissionsPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Text("Разрешения")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)
                    .multilineTextAlignment(.center)
            }
            
            // Permissions
            VStack(spacing: 24) {
                PermissionCard(
                    icon: "bell.fill",
                    title: "Уведомления",
                    description: "Получайте напоминания о записи настроения в удобное время",
                    isGranted: viewModel.notificationsGranted,
                    onToggle: {
                        Task {
                            await viewModel.requestNotificationPermission()
                        }
                    }
                )
                
                VStack(spacing: 12) {
                    Text("Почему это важно?")
                        .font(.headline)
                        .foregroundColor(primaryTextColor)
                    
                    Text("Регулярные записи помогут лучше понять вашу собаку и выявить важные паттерны в её поведении")
                        .font(.body)
                        .foregroundColor(secondaryTextColor)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(cardBackgroundColor.opacity(0.5))
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Final Page
    private var finalPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Text("Готовы начать?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)
                    .multilineTextAlignment(.center)
            }
            
            // Summary
            VStack(spacing: 20) {
                SummaryCard(
                    icon: "checkmark.circle.fill",
                    title: "Простота использования",
                    description: "Интуитивный интерфейс для быстрой записи настроения"
                )
                
                SummaryCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Полезная аналитика",
                    description: "Графики и статистика для понимания трендов"
                )
                
                SummaryCard(
                    icon: "heart.fill",
                    title: "Лучшие отношения",
                    description: "Укрепляйте связь с питомцем через понимание"
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack {
            if viewModel.currentPage > 0 {
                Button("Назад") {
                    withAnimation {
                        viewModel.currentPage -= 1
                    }
                }
                .foregroundColor(secondaryTextColor)
                .font(.headline)
            }
            
            Spacer()
            
            Button(viewModel.currentPage == 5 ? "Начать" : "Далее") {
                print("🎯 Button pressed: currentPage=\(viewModel.currentPage)")
                if viewModel.currentPage < 5 {
                    withAnimation {
                        viewModel.currentPage += 1
                    }
                } else {
                    print("🎯 Completing onboarding...")
                    viewModel.completeOnboarding()
                }
            }
            .foregroundColor(.white)
            .font(.headline)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(accentColor)
            .cornerRadius(12)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
    }
}

// MARK: - Purpose Card
struct PurposeCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Step Card
struct StepCard: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 40, height: 40)
                .background(Color.green.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Permission Card
struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isGranted ? Color.green : Color.orange)
                .frame(width: 40, height: 40)
                .background((isGranted ? Color.green : Color.orange).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(isGranted ? "Разрешено" : "Разрешить") {
                onToggle()
            }
            .foregroundColor(isGranted ? Color.green : Color.orange)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background((isGranted ? Color.green : Color.orange).opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(ThemeManager())
} 