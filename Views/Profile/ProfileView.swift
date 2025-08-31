import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedBridgeCategory = "All"
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    
    var body: some View {
        NavigationContainer {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    ProfileHeaderCard(viewModel: viewModel)
                    
                    // Bridge stats
                    BridgeStatsCard(viewModel: viewModel)
                    
                    // Bridge filter
                    BridgeFilterBar(selectedCategory: $selectedBridgeCategory)
                    
                    // Bridge grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.filteredTrophies(category: selectedBridgeCategory)) { trophy in
                            BridgeCard(trophy: trophy)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
            .refreshable {
                await viewModel.refreshProfile()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadProfile()
            }
        }
    }
}

struct ProfileHeaderCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar and basic info
            HStack(spacing: 16) {
                // Profile image placeholder
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(viewModel.user?.name.prefix(1).uppercased() ?? "U")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user?.name ?? "Usuario")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let email = viewModel.user?.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        if let age = viewModel.user?.age {
                            Label("\(age) years", systemImage: "calendar")
                        }
                        
                        if let state = viewModel.user?.state {
                            Label(state, systemImage: "location")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Quick stats
            HStack {
                StatItem(
                    title: "Events",
                    value: "\(viewModel.stats.eventsAttended)",
                    icon: "ticket.fill"
                )
                
                Divider()
                    .frame(height: 30)
                
                StatItem(
                    title: "Hours",
                    value: String(format: "%.1f", viewModel.stats.totalHours),
                    icon: "clock.fill"
                )
                
                Divider()
                    .frame(height: 30)
                
                StatItem(
                    title: "Avg MDI",
                    value: "\(viewModel.stats.averageDiversityScore)",
                    icon: "person.3.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct BridgeStatsCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bridging Badges")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("\(viewModel.unlockedTrophiesCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.teal)
                    Text("bridges built")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(viewModel.totalTrophiesCount)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            ProgressView(
                value: Double(viewModel.unlockedTrophiesCount), 
                total: viewModel.totalTrophiesCount > 0 ? Double(viewModel.totalTrophiesCount) : 1.0
            )
            .progressViewStyle(LinearProgressViewStyle(tint: .teal))
            .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("\(viewModel.totalTrophiesCount > 0 ? Int((Double(viewModel.unlockedTrophiesCount) / Double(viewModel.totalTrophiesCount)) * 100) : 0)% completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
        .padding(.horizontal)
    }
}

struct BridgeFilterBar: View {
    @Binding var selectedCategory: String
    
    let categories = ["All", "Time Bridge", "Community Bridge", "Cultural Bridge", "Social Bridge", "Sports Bridge", "Survey Bridge"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        let categoryColor = category == "All" ? Color.gray : primaryCategoryColor(for: category)
                        
                        Text(categoryDisplayName(category))
                            .font(.subheadline)
                            .fontWeight(selectedCategory == category ? .semibold : .regular)
                            .foregroundColor(selectedCategory == category ? .white : categoryColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category ? categoryColor : categoryColor.opacity(0.1)
                            )
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func categoryDisplayName(_ category: String) -> String {
        switch category {
        case "All": return "All"
        case "Time Bridge": return "Time"
        case "Community Bridge": return "Community"
        case "Cultural Bridge": return "Cultural"
        case "Social Bridge": return "Social"
        case "Sports Bridge": return "Sports"
        case "Survey Bridge": return "Survey"
        default: return category
        }
    }
    
    private func primaryCategoryColor(for category: String?) -> Color {
        switch category {
        case "Time Bridge": return .blue
        case "Community Bridge": return .green
        case "Cultural Bridge": return .purple
        case "Social Bridge": return .orange
        case "Sports Bridge": return .red
        case "Survey Bridge": return .teal
        default: return .gray
        }
    }
}

struct BridgeCard: View {
    let trophy: TrophyModel
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(trophy.isUnlocked ? 
                              categoryGradient(for: trophy.category) :
                              LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 50, height: 50)
                    
                    if trophy.isUnlocked {
                        Text(trophy.emoji ?? "🌉")
                            .font(.title2)
                    } else {
                        Image(systemName: trophy.iconName ?? "lock.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
                
                Text(trophy.title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(trophy.isUnlocked ? .primary : .secondary)
                    .lineLimit(2)
            }
            .padding(8)
            .background(Color(.systemGray6).opacity(trophy.isUnlocked ? 1.0 : 0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        trophy.isUnlocked ? Color.teal.opacity(0.5) : Color.clear, 
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            BridgeDetailSheet(trophy: trophy)
        }
    }
    
    private func categoryGradient(for category: String?) -> LinearGradient {
        let colors = categoryColors(for: category)
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
    
    private func categoryColors(for category: String?) -> [Color] {
        switch category {
        case "Time Bridge": return [.blue, .blue.opacity(0.7)]
        case "Community Bridge": return [.green, .green.opacity(0.7)]
        case "Cultural Bridge": return [.purple, .purple.opacity(0.7)]
        case "Social Bridge": return [.orange, .orange.opacity(0.7)]
        case "Sports Bridge": return [.red, .red.opacity(0.7)]
        case "Survey Bridge": return [.teal, .teal.opacity(0.7)]
        default: return [.gray, .gray.opacity(0.7)]
        }
    }
    
    private func primaryCategoryColor(for category: String?) -> Color {
        switch category {
        case "Time Bridge": return .blue
        case "Community Bridge": return .green
        case "Cultural Bridge": return .purple
        case "Social Bridge": return .orange
        case "Sports Bridge": return .red
        case "Survey Bridge": return .teal
        default: return .gray
        }
    }
}

struct BridgeDetailSheet: View {
    let trophy: TrophyModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationContainer {
            VStack(spacing: 24) {
                // Bridge icon
                ZStack {
                    Circle()
                        .fill(trophy.isUnlocked ? 
                              categoryGradient(for: trophy.category) :
                              LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 120, height: 120)
                    
                    if trophy.isUnlocked {
                        Text(trophy.emoji ?? "🌉")
                            .font(.system(size: 60))
                    } else {
                        Image(systemName: trophy.iconName ?? "lock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(spacing: 12) {
                    Text(trophy.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    if let category = trophy.category {
                        let categoryColor = primaryCategoryColor(for: category)
                        Text(category)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(categoryColor.opacity(0.2))
                            .foregroundColor(categoryColor)
                            .cornerRadius(12)
                    }
                    
                    if let description = trophy.description {
                        Text(description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }
                
                if trophy.isUnlocked {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Bridge built!")
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        Text("Built on August 15, 2025")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.orange)
                            Text("Bridge not built yet")
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                        
                        Text("Keep connecting with your community to build this bridge")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Bridge Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func categoryGradient(for category: String?) -> LinearGradient {
        let colors = categoryColors(for: category)
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
    
    private func categoryColors(for category: String?) -> [Color] {
        switch category {
        case "Time Bridge": return [.blue, .blue.opacity(0.7)]
        case "Community Bridge": return [.green, .green.opacity(0.7)]
        case "Cultural Bridge": return [.purple, .purple.opacity(0.7)]
        case "Social Bridge": return [.orange, .orange.opacity(0.7)]
        case "Sports Bridge": return [.red, .red.opacity(0.7)]
        case "Survey Bridge": return [.teal, .teal.opacity(0.7)]
        default: return [.gray, .gray.opacity(0.7)]
        }
    }
    
    private func primaryCategoryColor(for category: String?) -> Color {
        switch category {
        case "Time Bridge": return .blue
        case "Community Bridge": return .green
        case "Cultural Bridge": return .purple
        case "Social Bridge": return .orange
        case "Sports Bridge": return .red
        case "Survey Bridge": return .teal
        default: return .gray
        }
    }
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var trophies: [TrophyModel] = []
    @Published var stats = UserStats()
    @Published var isLoading = false
    
    var unlockedTrophiesCount: Int {
        trophies.filter(\.isUnlocked).count
    }
    
    var totalTrophiesCount: Int {
        trophies.count
    }
    
    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load user data from database
        user = MockDatabaseManager.shared.getUser(id: "user_gustavo")
        
        // Load trophies (mock data for now)
        loadMockTrophies()
        
        // Calculate stats
        calculateStats()
    }
    
    func refreshProfile() async {
        await loadProfile()
    }
    
    func filteredTrophies(category: String) -> [TrophyModel] {
        if category == "All" {
            return trophies
        } else {
            return trophies.filter { $0.category == category }
        }
    }
    
    private func loadMockTrophies() {
        trophies = createCompleteTrophySystem()
    }
    
    private func createCompleteTrophySystem() -> [TrophyModel] {
        var allTrophies: [TrophyModel] = []
        
        // TIME BRIDGE CATEGORY (6 trophies) - Teal theme
        allTrophies += [
            TrophyModel(id: "hr_01", title: "First Connection Bridge", description: "Build your first hour of community connections.", category: "Time Bridge", iconName: "clock", emoji: "⏰", conditionJson: "{\"minHours\":1}", isUnlocked: true),
            TrophyModel(id: "hr_02", title: "Time Bridge Keeper", description: "Bridge communities for 10+ hours.", category: "Time Bridge", iconName: "stopwatch", emoji: "⏱️", conditionJson: "{\"minHours\":10}", isUnlocked: true),
            TrophyModel(id: "hr_03", title: "Connection Bridge Master", description: "Build 50 hours of diverse bridges.", category: "Time Bridge", iconName: "clock.arrow.circlepath", emoji: "🔄", conditionJson: "{\"minHours\":50}", isUnlocked: true),
            TrophyModel(id: "hr_04", title: "Time Bridge Guardian", description: "Bridge communities for 100+ hours.", category: "Time Bridge", iconName: "clock.circle.fill", emoji: "⭕", conditionJson: "{\"minHours\":100}", isUnlocked: true),
            TrophyModel(id: "hr_05", title: "Master Bridge Builder", description: "Build 500 hours of cultural bridges.", category: "Time Bridge", iconName: "hourglass", emoji: "⌛", conditionJson: "{\"minHours\":500}", isUnlocked: false),
            TrophyModel(id: "hr_06", title: "Infinite Bridge Creator", description: "Master 1000+ hours of unity bridges.", category: "Time Bridge", iconName: "infinity.circle.fill", emoji: "♾️", conditionJson: "{\"minHours\":1000}", isUnlocked: false)
        ]
        
        // COMMUNITY BRIDGE CATEGORY (7 trophies) - Teal theme  
        allTrophies += [
            TrophyModel(id: "ev_01", title: "First Community Bridge", description: "Build your first community connection at an event.", category: "Community Bridge", iconName: "person.2", emoji: "👥", conditionJson: "{\"minEvents\":1}", isUnlocked: true),
            TrophyModel(id: "ev_02", title: "Gathering Bridge Builder", description: "Bridge communities across 5 multicultural events.", category: "Community Bridge", iconName: "person.3", emoji: "👨‍👩‍👧", conditionJson: "{\"minEvents\":5}", isUnlocked: true),
            TrophyModel(id: "ev_03", title: "Social Connection Bridge", description: "Build bridges at 15 community celebrations.", category: "Community Bridge", iconName: "person.2.circle", emoji: "🤝", conditionJson: "{\"minEvents\":15}", isUnlocked: true),
            TrophyModel(id: "ev_04", title: "Community Bridge Regular", description: "Bridge diverse communities at 30+ activities.", category: "Community Bridge", iconName: "person.crop.circle.badge.plus", emoji: "👨‍💼", conditionJson: "{\"minEvents\":30}", isUnlocked: true),
            TrophyModel(id: "ev_05", title: "Master Community Bridge", description: "Connect communities at 75+ celebrations.", category: "Community Bridge", iconName: "building.2", emoji: "🏢", conditionJson: "{\"minEvents\":75}", isUnlocked: false),
            TrophyModel(id: "ev_06", title: "Unity Bridge Ambassador", description: "Build bridges at 150+ cultural celebrations.", category: "Community Bridge", iconName: "heart.circle.fill", emoji: "❤️", conditionJson: "{\"minEvents\":150}", isUnlocked: false),
            TrophyModel(id: "ev_07", title: "Legendary Bridge Builder", description: "Master 300+ community connection bridges.", category: "Community Bridge", iconName: "crown.fill", emoji: "👑", conditionJson: "{\"minEvents\":300}", isUnlocked: false)
        ]
        
        // CULTURAL BRIDGE CATEGORY (7 trophies) - Teal theme
        allTrophies += [
            TrophyModel(id: "dv_01", title: "Cultural Bridge Novice", description: "Build your first cultural bridges with 30+ MDI score.", category: "Cultural Bridge", iconName: "globe", emoji: "🌍", conditionJson: "{\"minDiversityScore\":30}", isUnlocked: true),
            TrophyModel(id: "dv_02", title: "Diversity Bridge Builder", description: "Bridge diverse cultures with 50+ MDI score.", category: "Cultural Bridge", iconName: "globe.americas", emoji: "🌏", conditionJson: "{\"minDiversityScore\":50}", isUnlocked: true),
            TrophyModel(id: "dv_03", title: "Global Bridge Connector", description: "Connect global communities with 70+ MDI score.", category: "Cultural Bridge", iconName: "globe.europe.africa", emoji: "🌍", conditionJson: "{\"minDiversityScore\":70}", isUnlocked: true),
            TrophyModel(id: "dv_04", title: "Harmony Bridge Creator", description: "Create harmony bridges with 85+ MDI score.", category: "Cultural Bridge", iconName: "hands.sparkles", emoji: "✨", conditionJson: "{\"minDiversityScore\":85}", isUnlocked: false),
            TrophyModel(id: "dv_05", title: "Language Bridge Master", description: "Bridge communities speaking 4+ languages.", category: "Cultural Bridge", iconName: "bubble.left.and.bubble.right", emoji: "💬", conditionJson: "{\"minLanguages\":4}", isUnlocked: false),
            TrophyModel(id: "dv_06", title: "Rainbow Bridge Builder", description: "Build the most inclusive cultural bridges.", category: "Cultural Bridge", iconName: "rainbow", emoji: "🌈", conditionJson: "{\"minDiversityScore\":85, \"minLanguages\":3}", isUnlocked: false),
            TrophyModel(id: "dv_07", title: "Legendary Cultural Bridge", description: "Master legendary cultural bridge leadership.", category: "Cultural Bridge", iconName: "star.fill", emoji: "⭐", conditionJson: "{\"minDiversityScore\":95, \"minEvents\":25}", isUnlocked: false)
        ]
        
        // SPORTS BRIDGE CATEGORY (6 trophies) - Teal theme
        allTrophies += [
            TrophyModel(id: "ct_01", title: "Sports Bridge Builder", description: "Bridge communities through 10+ sports events.", category: "Sports Bridge", iconName: "sportscourt", emoji: "⚽", conditionJson: "{\"categoryIncludes\":[\"Sports\"], \"minEvents\":10}", isUnlocked: true),
            TrophyModel(id: "ct_02", title: "Cultural Activity Bridge", description: "Connect cultures through 10+ cultural events.", category: "Cultural Bridge", iconName: "theatermasks", emoji: "🎭", conditionJson: "{\"categoryIncludes\":[\"Culture\"], \"minEvents\":10}", isUnlocked: true),
            TrophyModel(id: "ct_03", title: "Arts Connection Bridge", description: "Bridge communities through 10+ arts events.", category: "Cultural Bridge", iconName: "paintbrush", emoji: "🎨", conditionJson: "{\"categoryIncludes\":[\"Arts\"], \"minEvents\":10}", isUnlocked: true),
            TrophyModel(id: "ct_04", title: "Music Unity Bridge", description: "Connect through 10+ music events.", category: "Cultural Bridge", iconName: "music.note", emoji: "🎵", conditionJson: "{\"categoryIncludes\":[\"Music\"], \"minEvents\":10}", isUnlocked: false),
            TrophyModel(id: "ct_05", title: "Food Culture Bridge", description: "Bridge cultures through 10+ food events.", category: "Cultural Bridge", iconName: "fork.knife", emoji: "🍽️", conditionJson: "{\"categoryIncludes\":[\"Food\"], \"minEvents\":10}", isUnlocked: false),
            TrophyModel(id: "ct_06", title: "Multi-Bridge Master", description: "Build bridges across all event categories.", category: "Community Bridge", iconName: "star.circle", emoji: "⭐", conditionJson: "{\"minCategories\":6}", isUnlocked: false)
        ]
        
        // SOCIAL BRIDGE CATEGORY (5 trophies) - Teal theme  
        allTrophies += [
            TrophyModel(id: "rg_01", title: "Sydney Bridge Explorer", description: "Build community bridges across Sydney.", category: "Social Bridge", iconName: "building.columns", emoji: "🏛️", conditionJson: "{\"stateIncludes\":[\"NSW\"], \"minEvents\":5}", isUnlocked: true),
            TrophyModel(id: "rg_02", title: "Melbourne Bridge Maven", description: "Bridge Melbourne's diverse communities.", category: "Social Bridge", iconName: "cup.and.saucer", emoji: "☕", conditionJson: "{\"stateIncludes\":[\"VIC\"], \"minEvents\":5}", isUnlocked: true),
            TrophyModel(id: "rg_03", title: "Adelaide Bridge Ambassador", description: "Foster community bridges in South Australia.", category: "Social Bridge", iconName: "leaf", emoji: "🌿", conditionJson: "{\"stateIncludes\":[\"SA\"], \"minEvents\":5}", isUnlocked: true),
            TrophyModel(id: "rg_04", title: "State Bridge Hopper", description: "Build bridges in 3+ different states.", category: "Social Bridge", iconName: "airplane", emoji: "✈️", conditionJson: "{\"minStates\":3}", isUnlocked: false),
            TrophyModel(id: "rg_05", title: "Continental Bridge Unity", description: "Achieve national-level bridge impact.", category: "Social Bridge", iconName: "map", emoji: "🗺️", conditionJson: "{\"minStates\":5, \"minEvents\":50}", isUnlocked: false)
        ]
        
        // COMMUNITY BRIDGE SPECIAL (5 trophies) - Teal theme
        allTrophies += [
            TrophyModel(id: "sp_01", title: "Founding Bridge Pioneer", description: "Be among the first MateHub bridge builders.", category: "Community Bridge", iconName: "flag", emoji: "🚩", conditionJson: "{\"foundingMember\":true}", isUnlocked: true),
            TrophyModel(id: "sp_02", title: "Perfect Bridge Score", description: "Achieve flawless diversity bridge metrics.", category: "Cultural Bridge", iconName: "target", emoji: "🎯", conditionJson: "{\"minDiversityScore\":100}", isUnlocked: false),
            TrophyModel(id: "sp_03", title: "Social Impact Bridge Hero", description: "Transform communities through bridge connections.", category: "Social Bridge", iconName: "heart.fill", emoji: "❤️", conditionJson: "{\"socialImpact\":true}", isUnlocked: true),
            TrophyModel(id: "sp_04", title: "Budget Bridge Master", description: "Maximize discounts through diversity bridges.", category: "Community Bridge", iconName: "dollarsign.circle", emoji: "💰", conditionJson: "{\"totalSavings\":500}", isUnlocked: true),
            TrophyModel(id: "sp_05", title: "Legendary Bridge Builder", description: "Become a legendary community bridge master.", category: "Community Bridge", iconName: "crown.fill", emoji: "👑", conditionJson: "{\"minHours\":500, \"minEvents\":100, \"minDiversityScore\":85}", isUnlocked: false)
        ]
        
        // COMMUNITY BRIDGE LEADERSHIP (5 trophies) - Teal theme
        allTrophies += [
            TrophyModel(id: "cm_01", title: "Bridge Group Leader", description: "Successfully lead diverse community bridges.", category: "Community Bridge", iconName: "person.badge.plus", emoji: "👨‍💼", conditionJson: "{\"groupsLed\":5}", isUnlocked: true),
            TrophyModel(id: "cm_02", title: "Community Bridge Catalyst", description: "Spark bridge connections between strangers.", category: "Community Bridge", iconName: "spark", emoji: "✨", conditionJson: "{\"connectionsCreated\":25}", isUnlocked: true),
            TrophyModel(id: "cm_03", title: "Social Bridge Architect", description: "Design inclusive bridge experiences.", category: "Social Bridge", iconName: "hammer", emoji: "🔨", conditionJson: "{\"eventsOrganized\":3}", isUnlocked: true),
            TrophyModel(id: "cm_04", title: "Bridge Friend Maker", description: "Make lasting bridge connections at events.", category: "Social Bridge", iconName: "person.2.wave.2", emoji: "👋", conditionJson: "{\"friendsMade\":20}", isUnlocked: false),
            TrophyModel(id: "cm_05", title: "Bridge Connection Master", description: "Master the art of bringing communities together.", category: "Community Bridge", iconName: "network", emoji: "🕸️", conditionJson: "{\"connectionsCreated\":100, \"minDiversityScore\":70}", isUnlocked: false)
        ]
        
        // SURVEY BRIDGE TROPHIES (3 trophies) - Teal theme
        allTrophies += [
            TrophyModel(id: "sv_01", title: "Feedback Bridge Builder", description: "Bridge communities through valuable feedback.", category: "Survey Bridge", iconName: "text.bubble", emoji: "💬", conditionJson: "{\"surveysCompleted\":1}", isUnlocked: false),
            TrophyModel(id: "sv_02", title: "Community Bridge Builder", description: "Achieve high cohesion scores through bridge connections.", category: "Survey Bridge", iconName: "chart.bar.fill", emoji: "📊", conditionJson: "{\"avgCohesionScore\":4.0}", isUnlocked: false),
            TrophyModel(id: "sv_03", title: "Social Bridge Researcher", description: "Contribute valuable bridge data to community research.", category: "Survey Bridge", iconName: "magnifyingglass", emoji: "🔍", conditionJson: "{\"surveysCompleted\":5, \"avgCohesionScore\":3.5}", isUnlocked: false)
        ]
        
        return allTrophies
    }
    
    private func calculateStats() {
        // This would calculate from database
        stats = UserStats(
            eventsAttended: 3,
            totalHours: 12.5,
            averageDiversityScore: 67,
            averageGroupSize: 4.2
        )
    }
}

struct UserStats {
    var eventsAttended: Int = 0
    var totalHours: Double = 0.0
    var averageDiversityScore: Int = 0
    var averageGroupSize: Double = 0.0
}
