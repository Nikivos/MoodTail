import SwiftUI
import Charts

struct EmotionPieChartView: View {
    let data: [(String, Int, Color)]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if data.isEmpty {
                emptyStateView
            } else {
                chartView
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var chartView: some View {
        VStack(spacing: 16) {
            // Pie Chart
            Chart(data, id: \.0) { item in
                SectorMark(
                    angle: .value("Количество", item.1),
                    innerRadius: .ratio(0.4),
                    angularInset: 2
                )
                .foregroundStyle(item.2)
            }
            .frame(height: 150)
            .animation(.easeInOut(duration: 0.8), value: data.map { max(0, $0.1) })
            
            // Legend
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(data, id: \.0) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.2)
                            .frame(width: 12, height: 12)
                        
                        Text(item.0)
                            .font(.caption)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(item.1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Нет данных")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleData = [
        ("Счастлив", 15, Color.moodColors.happy),
        ("Спокоен", 12, Color.moodColors.calm),
        ("Возбужден", 8, Color.moodColors.excited),
        ("Игрив", 6, Color.moodColors.playful),
        ("Грустен", 3, Color.moodColors.sad)
    ]
    
    return EmotionPieChartView(data: sampleData, title: "Распределение эмоций")
        .padding()
} 