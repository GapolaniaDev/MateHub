import SwiftUI
// import Charts // Commented out for iOS compatibility

struct TimeTrackingView: View {
    @StateObject private var viewModel = TimeTrackingViewModel()
    @State private var selectedTimeframe: TimeFrame = .month
    
    var body: some View {
        NavigationContainer {
            ScrollView {
                VStack(spacing: 20) {
                    // Statistics cards
                    StatisticsCardsView(viewModel: viewModel)
                    
                    // Chart section
                    ChartSectionView(
                        viewModel: viewModel, 
                        selectedTimeframe: $selectedTimeframe
                    )
                    
                    // Recent events
                    RecentEventsView(viewModel: viewModel)
                }
                .padding(.horizontal)
            }
            .navigationTitle("My Time")
            .refreshable {
                await viewModel.loadData()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
    }
}

struct StatisticsCardsView: View {
    @ObservedObject var viewModel: TimeTrackingViewModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Total Hours",
                value: String(format: "%.1f", viewModel.totalHours),
                subtitle: "in events",
                icon: "clock.fill",
                color: .blue
            )
            
            StatCard(
                title: "Events",
                value: "\(viewModel.totalEvents)",
                subtitle: "attended",
                icon: "ticket.fill",
                color: .green
            )
            
            StatCard(
                title: "Avg Group",
                value: String(format: "%.1f", viewModel.averageGroupSize),
                subtitle: "people",
                icon: "person.3.fill",
                color: .orange
            )
            
            StatCard(
                title: "Avg MDI",
                value: "\(viewModel.averageDiversityScore)",
                subtitle: "diversity",
                icon: "globe",
                color: .purple
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ChartSectionView: View {
    @ObservedObject var viewModel: TimeTrackingViewModel
    @Binding var selectedTimeframe: TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activity")
                    .font(.headline)
                
                Spacer()
                
                Picker("Timeframe", selection: $selectedTimeframe) {
                    Text("Month").tag(TimeFrame.month)
                    Text("3 Months").tag(TimeFrame.quarter)
                    Text("Year").tag(TimeFrame.year)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            // Using legacy chart view for compatibility
            LegacyChartView(data: viewModel.chartData(for: selectedTimeframe))
                .frame(height: 200)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

struct LegacyChartView: View {
    let data: [ChartDataPoint]
    
    var body: some View {
        LineChartView(data: data)
            .padding()
    }
}

struct LineChartView: View {
    let data: [ChartDataPoint]
    
    private var maxValue: Double {
        data.map(\.hours).max() ?? 1
    }
    
    private var minValue: Double {
        data.map(\.hours).min() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Chart area
            GeometryReader { geometry in
                ZStack {
                    // Grid lines
                    Path { path in
                        let stepY = geometry.size.height / 4
                        for i in 0..<5 {
                            let y = CGFloat(i) * stepY
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                    
                    // Data line
                    Path { path in
                        guard !data.isEmpty else { return }
                        
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        
                        for (index, dataPoint) in data.enumerated() {
                            let x = CGFloat(index) * stepX
                            let normalizedValue = (dataPoint.hours - minValue) / (maxValue - minValue)
                            let y = geometry.size.height * (1 - normalizedValue)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    
                    // Data points
                    ForEach(Array(data.enumerated()), id: \.offset) { index, dataPoint in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        let x = CGFloat(index) * stepX
                        let normalizedValue = (dataPoint.hours - minValue) / (maxValue - minValue)
                        let y = geometry.size.height * (1 - normalizedValue)
                        
                        Circle()
                            .fill(.white)
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                    
                    // Value labels on points
                    ForEach(Array(data.enumerated()), id: \.offset) { index, dataPoint in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        let x = CGFloat(index) * stepX
                        let normalizedValue = (dataPoint.hours - minValue) / (maxValue - minValue)
                        let y = geometry.size.height * (1 - normalizedValue) - 20
                        
                        Text("\(String(format: "%.1f", dataPoint.hours))h")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .position(x: x, y: max(10, y))
                    }
                }
            }
            .frame(height: 120)
            
            // X-axis labels
            HStack {
                ForEach(data, id: \.period) { dataPoint in
                    Text(dataPoint.period)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct RecentEventsView: View {
    @ObservedObject var viewModel: TimeTrackingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Events")
                    .font(.headline)
                
                Spacer()
                
                Button("View all") {
                    // Navigate to full list
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.recentEvents) { event in
                    EventRowView(eventHistory: event)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct EventRowView: View {
    let eventHistory: EventHistory
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: iconForCategory(eventHistory.category))
                .font(.title2)
                .foregroundColor(colorForCategory(eventHistory.category))
                .frame(width: 40, height: 40)
                .background(colorForCategory(eventHistory.category).opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(eventHistory.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(eventHistory.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label("\(String(format: "%.1f", eventHistory.duration))h", 
                          systemImage: "clock")
                    
                    Label("MDI \(eventHistory.diversityScore)", 
                          systemImage: "person.3")
                    
                    if eventHistory.discountApplied > 0 {
                        Label("\(Int(eventHistory.discountApplied * 100))% desc.", 
                              systemImage: "percent")
                            .foregroundColor(.green)
                    }
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(eventHistory.finalPrice))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if eventHistory.discountApplied > 0 {
                    Text(formatCurrency(eventHistory.originalPrice))
                        .font(.caption2)
                        .strikethrough()
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Sports": return "sportscourt.fill"
        case "Culture": return "theatermasks.fill"
        case "Music": return "music.note"
        case "Arts": return "paintpalette.fill"
        case "Education": return "graduationcap.fill"
        case "Food": return "fork.knife"
        default: return "star.fill"
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Sports": return .orange
        case "Culture": return .purple
        case "Music": return .pink
        case "Arts": return .red
        case "Education": return .blue
        case "Food": return .yellow
        default: return .gray
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// Data models
struct EventHistory: Identifiable {
    let id: String
    let title: String
    let date: String
    let category: String
    let duration: Double
    let diversityScore: Int
    let discountApplied: Double
    let originalPrice: Double
    let finalPrice: Double
    let groupSize: Int
}

struct ChartDataPoint {
    let period: String
    let hours: Double
}

enum TimeFrame: CaseIterable {
    case month, quarter, year
    
    var displayName: String {
        switch self {
        case .month: return "This Month"
        case .quarter: return "3 Months"
        case .year: return "This Year"
        }
    }
}

@MainActor
class TimeTrackingViewModel: ObservableObject {
    @Published var totalHours: Double = 0
    @Published var totalEvents: Int = 0
    @Published var averageGroupSize: Double = 0
    @Published var averageDiversityScore: Int = 0
    @Published var recentEvents: [EventHistory] = []
    @Published var isLoading: Bool = false
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate loading from database
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock data
        totalHours = 47.5
        totalEvents = 12
        averageGroupSize = 4.3
        averageDiversityScore = 68
        
        recentEvents = [
            EventHistory(
                id: "1",
                title: "AFL Match – Crows vs Power",
                date: "15 Sep 2025",
                category: "Sports",
                duration: 3.5,
                diversityScore: 75,
                discountApplied: 0.15,
                originalPrice: 240.0,
                finalPrice: 204.0,
                groupSize: 4
            ),
            EventHistory(
                id: "2",
                title: "Sydney Festival Night Market",
                date: "10 Oct 2025",
                category: "Culture",
                duration: 4.0,
                diversityScore: 82,
                discountApplied: 0.15,
                originalPrice: 100.0,
                finalPrice: 85.0,
                groupSize: 4
            ),
            EventHistory(
                id: "3",
                title: "Melbourne Film Festival",
                date: "2 Nov 2025",
                category: "Arts",
                duration: 2.5,
                diversityScore: 60,
                discountApplied: 0.10,
                originalPrice: 180.0,
                finalPrice: 162.0,
                groupSize: 4
            )
        ]
    }
    
    func chartData(for timeframe: TimeFrame) -> [ChartDataPoint] {
        switch timeframe {
        case .month:
            return [
                ChartDataPoint(period: "Nov 1-7", hours: 8.5),
                ChartDataPoint(period: "Nov 8-14", hours: 12.0),
                ChartDataPoint(period: "Nov 15-21", hours: 6.5),
                ChartDataPoint(period: "Nov 22-30", hours: 15.5)
            ]
        case .quarter:
            return [
                ChartDataPoint(period: "August", hours: 18.5),
                ChartDataPoint(period: "September", hours: 22.0),
                ChartDataPoint(period: "October", hours: 16.5)
            ]
        case .year:
            return [
                ChartDataPoint(period: "Jan", hours: 12.0),
                ChartDataPoint(period: "Feb", hours: 8.5),
                ChartDataPoint(period: "Mar", hours: 15.0),
                ChartDataPoint(period: "Apr", hours: 20.0),
                ChartDataPoint(period: "May", hours: 18.5),
                ChartDataPoint(period: "Jun", hours: 25.0),
                ChartDataPoint(period: "Jul", hours: 22.5),
                ChartDataPoint(period: "Aug", hours: 28.0),
                ChartDataPoint(period: "Sep", hours: 24.5),
                ChartDataPoint(period: "Oct", hours: 19.0),
                ChartDataPoint(period: "Nov", hours: 16.5),
                ChartDataPoint(period: "Dec", hours: 14.0)
            ]
        }
    }
}