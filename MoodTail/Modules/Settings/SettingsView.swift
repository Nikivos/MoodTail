import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingAboutApp = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sections) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.items) { item in
                            SettingsRowView(item: item) {
                                handleItemTap(item)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAboutApp) {
                AboutAppView()
            }
        }
    }
    
    private func handleItemTap(_ item: SettingItem) {
        switch item.type {
        case .petProfile:
            // TODO: Переход на EditPetView
            break
        case .notifications:
            viewModel.toggleNotifications()
        case .theme:
            viewModel.toggleTheme()
        case .aboutApp:
            showingAboutApp = true
        }
    }
}

struct SettingsRowView: View {
    let item: SettingItem
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundColor(item.iconColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body)
                
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            switch item.accessory {
            case .chevron:
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            case .toggle(let isOn):
                Toggle("", isOn: .constant(isOn))
                    .labelsHidden()
            case .none:
                EmptyView()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct AboutAppView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.pink)
                
                VStack(spacing: 8) {
                    Text("MoodTail")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Версия 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    Text("Приложение для отслеживания настроения вашей собаки")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Разработано с ❤️ для заботливых владельцев")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("О приложении")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        // Закрытие модального окна
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
} 