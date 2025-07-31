import SwiftUI
import CoreData

struct HistoryView: View {
    @StateObject private var viewModel: HistoryViewModel
    
    init(moodStorage: MoodStorageProtocol = CoreDataMoodStorage(container: PersistenceController.shared.container)) {
        _viewModel = StateObject(wrappedValue: HistoryViewModel(moodStorage: moodStorage))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Загрузка...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.moodEntries.isEmpty {
                    emptyStateView
                } else {
                    moodEntriesList
                }
            }
            .themeable()
            .navigationTitle("История")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadMoodEntries()
            }
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
        .task {
            await viewModel.loadMoodEntries()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Нет записей")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Добавьте первую запись настроения вашей собаки")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var moodEntriesList: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Секция аналитики
                if !viewModel.analytics.dailyIntensity.isEmpty {
                    analyticsSection
                }
                
                // Секция записей или пустое состояние
                if viewModel.groupedEntries.isEmpty {
                    EmptyStateView(
                        title: "Нет записей",
                        subtitle: "Добавьте первую запись о настроении вашей собаки",
                        icon: "pawprint.circle"
                    )
                } else {
                    entriesSection
                }
            }
            .padding()
        }
    }
    
    private var analyticsSection: some View {
        VStack(spacing: 16) {
            // Линейный график
            IntensityChartView(
                data: viewModel.analyticsEngine.getChartData(for: 7, from: viewModel.analytics),
                title: "Динамика настроения (7 дней)"
            )
            
            // Круговая диаграмма
            EmotionPieChartView(
                data: viewModel.analyticsEngine.getEmotionChartData(from: viewModel.analytics),
                title: "Распределение эмоций"
            )
            
            // Инсайты
            InsightsView(analytics: viewModel.analytics)
        }
    }
    
    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Записи")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(viewModel.groupedEntries.keys.sorted(by: >), id: \.self) { date in
                VStack(alignment: .leading, spacing: 8) {
                    dateHeader(for: date)
                    
                    ForEach(viewModel.groupedEntries[date] ?? [], id: \.safeID) { entry in
                        MoodEntryRow(entry: entry) {
                            await viewModel.deleteMoodEntry(entry)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
            }
        }
    }
    
    private func dateHeader(for date: Date) -> some View {
        HStack {
            Text(formatDate(date))
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let entries = viewModel.groupedEntries[date] {
                Text("\(entries.count) записей")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct MoodEntryRow: View {
    let entry: MoodEntry
    let onDelete: () async -> Void
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Эмодзи или изображение эмоции
            if let emotionImage = emotionImage {
                emotionImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .background(Color(emotionColor))
                    .clipShape(Circle())
            } else {
                Text(emotionEmoji)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color(emotionColor))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(emotionDisplayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(formatTime(entry.safeTimestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Интенсивность: \(entry.safeIntensity)/10")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                if let note = entry.safeNote {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
        .alert("Удалить запись?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                Task {
                    await onDelete()
                }
            }
        } message: {
            Text("Эта запись будет удалена безвозвратно")
        }
    }
    
    private var emotionEmoji: String {
        let emotion = DogEmotion(rawValue: entry.safeEmotion) ?? .happy
        return emotion.emoji
    }
    
    private var emotionImage: Image? {
        let emotion = DogEmotion(rawValue: entry.safeEmotion) ?? .happy
        return emotion.image
    }
    
    private var emotionDisplayName: String {
        let emotion = DogEmotion(rawValue: entry.safeEmotion) ?? .happy
        return emotion.displayName
    }
    
    private var emotionColor: Color {
        let emotion = DogEmotion(rawValue: entry.safeEmotion) ?? .happy
        return emotion.color
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 