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
        List {
            ForEach(viewModel.groupedEntries.keys.sorted(by: >), id: \.self) { date in
                Section(header: dateHeader(for: date)) {
                    ForEach(viewModel.groupedEntries[date] ?? [], id: \.id) { entry in
                        MoodEntryRow(entry: entry) {
                            await viewModel.deleteMoodEntry(entry)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
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
            // Эмодзи эмоции
            Text(emotionEmoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color(emotionColor))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(emotionDisplayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(formatTime(entry.timestamp ?? Date()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Интенсивность: \(entry.intensity)/10")
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
                
                if let note = entry.note, !note.isEmpty {
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
        guard let emotionString = entry.emotion else { return "❓" }
        let emotion = DogEmotion(rawValue: emotionString) ?? .happy
        return emotion.emoji
    }
    
    private var emotionDisplayName: String {
        guard let emotionString = entry.emotion else { return "Неизвестно" }
        let emotion = DogEmotion(rawValue: emotionString) ?? .happy
        return emotion.displayName
    }
    
    private var emotionColor: Color {
        guard let emotionString = entry.emotion else { return .gray }
        let emotion = DogEmotion(rawValue: emotionString) ?? .happy
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