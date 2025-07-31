import SwiftUI
import Charts

struct IntensityChartView: View {
    let data: [(Date, Double)]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if data.isEmpty || data.allSatisfy({ $0.1 == 0 }) {
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
        Chart(data, id: \.0) { item in
            LineMark(
                x: .value("День", item.0, unit: .day),
                y: .value("Интенсивность", item.1)
            )
            .foregroundStyle(.blue)
            .lineStyle(StrokeStyle(lineWidth: 3))
            
            AreaMark(
                x: .value("День", item.0, unit: .day),
                y: .value("Интенсивность", item.1)
            )
            .foregroundStyle(.blue.opacity(0.1))
            
            PointMark(
                x: .value("День", item.0, unit: .day),
                y: .value("Интенсивность", item.1)
            )
            .foregroundStyle(.blue)
        }
        .chartYScale(domain: 0...10)
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .frame(height: 200)
        .animation(.easeInOut(duration: 0.8), value: data.map { $0.1.isNaN ? 0.0 : max(0.0, $0.1) })
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Недостаточно данных")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleData = [
        (Date().addingTimeInterval(-6 * 86400), 7.0),
        (Date().addingTimeInterval(-5 * 86400), 8.5),
        (Date().addingTimeInterval(-4 * 86400), 6.0),
        (Date().addingTimeInterval(-3 * 86400), 9.0),
        (Date().addingTimeInterval(-2 * 86400), 7.5),
        (Date().addingTimeInterval(-1 * 86400), 8.0),
        (Date(), 6.5)
    ]
    
    return IntensityChartView(data: sampleData, title: "Динамика настроения")
        .padding()
} 