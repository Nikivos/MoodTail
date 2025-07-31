import SwiftUI

struct InsightsView: View {
    let analytics: MoodAnalytics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Инсайты")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                // Тренд недели
                InsightCard(
                    title: "Тренд недели",
                    value: analytics.weeklyTrend,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                // Самая частая эмоция
                InsightCard(
                    title: "Частая эмоция",
                    value: mostCommonEmotionText,
                    icon: "heart.fill",
                    color: .pink
                )
                
                // Средняя интенсивность
                InsightCard(
                    title: "Средняя интенсивность",
                    value: String(format: "%.1f/10", analytics.averageIntensity),
                    icon: "gauge",
                    color: .orange
                )
                
                // Записи за неделю
                InsightCard(
                    title: "За неделю",
                    value: "\(analytics.entriesThisWeek) записей",
                    icon: "calendar",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var mostCommonEmotionText: String {
        guard let emotion = analytics.mostCommonEmotion else { return "Нет данных" }
        let dogEmotion = DogEmotion(rawValue: emotion) ?? .happy
        return dogEmotion.displayName
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    let sampleAnalytics = MoodAnalytics(
        dailyIntensity: [:],
        emotionDistribution: ["happy": 15, "calm": 12, "excited": 8],
        weeklyTrend: "Настроение улучшается",
        mostCommonEmotion: "happy",
        averageIntensity: 7.5,
        totalEntries: 35,
        entriesThisWeek: 8,
        entriesThisMonth: 25
    )
    
    return InsightsView(analytics: sampleAnalytics)
        .padding()
} 