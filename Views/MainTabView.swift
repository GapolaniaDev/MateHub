import SwiftUI
import Combine

struct MainTabView: View {
    @StateObject private var userSession = UserSessionManager()
    @State private var selectedTab = 0
    
    var body: some View {
        if userSession.isLoading {
            LoadingView()
        } else if userSession.isLoggedIn, let _ = userSession.currentUser {
            TabView(selection: $selectedTab) {
                // Map tab
                EnhancedMapView()
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Map")
                    }
                    .tag(0)
                
                // Profile tab
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.crop.circle.fill")
                        Text("Profile")
                    }
                    .tag(1)
                
                // Time tab
                TimeTrackingView()
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("Time")
                    }
                    .tag(2)
                
                // More tab
                MoreView(userSession: userSession)
                    .tabItem {
                        Image(systemName: "ellipsis.circle.fill")
                        Text("More")
                    }
                    .tag(3)
            }
            .tint(.blue)
            .customTabBar()
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToTrophies"))) { _ in
                selectedTab = 1 // Navigate to Profile tab where trophies are
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToMap"))) { _ in
                selectedTab = 0 // Navigate to Map tab after registration
            }
        } else {
            WelcomeView(userSession: userSession)
        }
    }
}

struct WelcomeView: View {
    @ObservedObject var userSession: UserSessionManager
    @State private var showingRegistration = false
    @State private var showingLogin = false
    @State private var showingAIRegistration = false
    @State private var showingVoiceRegistration = false
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer(minLength: 60)
                    
                    // App icon and title
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 120, height: 120)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                            
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        .animation(.bouncy(duration: 1.0), value: animateContent)
                        
                        VStack(spacing: 12) {
                            Text("Welcome to MateHub")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Connect & Discover Together")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.3), value: animateContent)
                    }
                    
                    // Features highlight
                    VStack(spacing: 20) {
                        FeatureRow(
                            icon: "map.fill",
                            title: "Discover Events",
                            description: "Find cultural and sports events near you",
                            color: .blue
                        )
                        
                        FeatureRow(
                            icon: "person.3.fill",
                            title: "Join Diverse Groups",
                            description: "Connect with people from different backgrounds",
                            color: .green
                        )
                        
                        FeatureRow(
                            icon: "percent",
                            title: "Get Discounts",
                            description: "Earn rewards for multicultural connections",
                            color: .orange
                        )
                    }
                    .opacity(animateContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.6), value: animateContent)
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button {
                            showingVoiceRegistration = true
                        } label: {
                            HStack {
                                Image(systemName: "mic.fill")
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Voice Registration")
                                        .font(.headline)
                                    Text("Talk naturally with AI")
                                        .font(.caption)
                                        .opacity(0.8)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                            .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        Button {
                            showingAIRegistration = true
                        } label: {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                Text("Text AI Registration")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                        }
                        
                        Button {
                            showingRegistration = true
                        } label: {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Traditional Registration")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                        }
                        
                        Button {
                            showingLogin = true
                        } label: {
                            HStack {
                                Image(systemName: "person.circle")
                                Text("Sign In")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                        }
                        
                        // Demo option
                        Divider()
                            .padding(.vertical)
                        
                        Button {
                            userSession.loginDemoUser()
                        } label: {
                            HStack {
                                Image(systemName: "eye")
                                Text("Continue as Demo")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .opacity(animateContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.9), value: animateContent)
                    
                    Spacer(minLength: 60)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingRegistration) {
            RegistrationView(
                isPresented: $showingRegistration,
                currentUser: Binding(
                    get: { userSession.currentUser },
                    set: { 
                        userSession.currentUser = $0
                        if $0 != nil {
                            userSession.isLoggedIn = true
                            // Navigate to Map tab after registration
                            NotificationCenter.default.post(name: NSNotification.Name("NavigateToMap"), object: nil)
                        }
                    }
                )
            )
        }
        .sheet(isPresented: $showingLogin) {
            LoginView(
                isPresented: $showingLogin,
                currentUser: Binding(
                    get: { userSession.currentUser },
                    set: { 
                        userSession.currentUser = $0
                        if $0 != nil {
                            userSession.isLoggedIn = true
                        }
                    }
                )
            )
        }
        .fullScreenCover(isPresented: $showingAIRegistration) {
            AIRegistrationView(
                isPresented: $showingAIRegistration,
                currentUser: Binding(
                    get: { userSession.currentUser },
                    set: { 
                        userSession.currentUser = $0
                        if $0 != nil {
                            userSession.isLoggedIn = true
                            // Navigate to Map tab after AI registration
                            NotificationCenter.default.post(name: NSNotification.Name("NavigateToMap"), object: nil)
                        }
                    }
                )
            )
        }
        .fullScreenCover(isPresented: $showingVoiceRegistration) {
            VoiceAIRegistrationView(
                isPresented: $showingVoiceRegistration,
                currentUser: Binding(
                    get: { userSession.currentUser },
                    set: { 
                        userSession.currentUser = $0
                        if $0 != nil {
                            userSession.isLoggedIn = true
                            // Navigate to Map tab after voice registration
                            NotificationCenter.default.post(name: NSNotification.Name("NavigateToMap"), object: nil)
                        }
                    }
                )
            )
        }
        .onAppear {
            withAnimation(.bouncy(duration: 1.0).delay(0.1)) {
                animateContent = true
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct LoginView: View {
    @Binding var isPresented: Bool
    @Binding var currentUser: UserModel?
    @State private var email = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationContainer {
            VStack(spacing: 24) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    Button {
                        Task {
                            await loginUser()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            }
                            Text("Sign In")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(email.isEmpty || isLoading)
                }
                
                Spacer()
                
                Button {
                    // Demo login
                    currentUser = UserModel(name: "Gustavo Polania", email: "gustavo@example.com")
                    isPresented = false
                } label: {
                    Text("Continue as Demo")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func loginUser() async {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate login
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        if let user = MockDatabaseManager.shared.getUser(id: "user_gustavo") {
            currentUser = user
            isPresented = false
        }
    }
}

struct MoreView: View {
    @ObservedObject var userSession: UserSessionManager
    
    var body: some View {
        NavigationContainer {
            List {
                Section {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                    
                    NavigationLink {
                        InterestsView()
                    } label: {
                        Label("My Interests", systemImage: "heart")
                    }
                    
                    NavigationLink {
                        NotificationsView()
                    } label: {
                        HStack {
                            Label("Notifications", systemImage: "bell")
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 20, height: 20)
                                Text("3")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                Section("Support") {
                    NavigationLink {
                        HelpView()
                    } label: {
                        Label("Help", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink {
                        FeedbackView()
                    } label: {
                        Label("Send Feedback", systemImage: "envelope")
                    }
                    
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
                
                Section {
                    Button {
                        userSession.logout()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("More")
        }
    }
}

// Placeholder views for More section
struct SettingsView: View {
    @State private var enableNotifications = true
    @State private var enableLocationServices = true
    @State private var enableEmailUpdates = false
    @State private var darkModeEnabled = false
    @State private var selectedLanguage = "English"
    @State private var maxDistanceKm = 25.0
    
    var body: some View {
        NavigationContainer {
            List {
                Section("Preferences") {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.blue)
                        Toggle("Push Notifications", isOn: $enableNotifications)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.green)
                        Toggle("Location Services", isOn: $enableLocationServices)
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.orange)
                        Toggle("Email Updates", isOn: $enableEmailUpdates)
                    }
                    
                    HStack {
                        Image(systemName: "moon")
                            .foregroundColor(.purple)
                        Toggle("Dark Mode", isOn: $darkModeEnabled)
                    }
                }
                
                Section("Discovery") {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                        Picker("Language", selection: $selectedLanguage) {
                            Text("English").tag("English")
                            Text("Español").tag("Español")
                            Text("Français").tag("Français")
                            Text("Deutsch").tag("Deutsch")
                            Text("中文").tag("中文")
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "map")
                                .foregroundColor(.red)
                            Text("Search Radius")
                            Spacer()
                            Text("\(Int(maxDistanceKm)) km")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $maxDistanceKm, in: 5...100, step: 5)
                    }
                }
                
                Section("Privacy & Safety") {
                    NavigationLink {
                        Text("Privacy Policy content would go here")
                            .navigationTitle("Privacy Policy")
                    } label: {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.green)
                            Text("Privacy Policy")
                        }
                    }
                    
                    NavigationLink {
                        Text("Terms of Service content would go here")
                            .navigationTitle("Terms of Service")
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("Terms of Service")
                        }
                    }
                    
                    NavigationLink {
                        Text("Safety Guidelines content would go here")
                            .navigationTitle("Safety Guidelines")
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.shield")
                                .foregroundColor(.orange)
                            Text("Safety Guidelines")
                        }
                    }
                }
                
                Section("Data") {
                    Button {
                        // Clear cache action
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Clear Cache")
                        }
                    }
                    
                    Button {
                        // Export data action
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Export My Data")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct InterestsView: View {
    @StateObject private var viewModel = InterestsViewModel()
    
    var body: some View {
        NavigationContainer {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Your Interests")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Choose what you're passionate about to help us recommend the best events for you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Categories
                    ForEach(viewModel.categorizedInterests.keys.sorted(), id: \.self) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category)
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(viewModel.categorizedInterests[category] ?? [], id: \.id) { interest in
                                    InterestCard(
                                        interest: interest,
                                        isSelected: viewModel.selectedInterests.contains(interest.id)
                                    ) {
                                        viewModel.toggleInterest(interest.id)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Selected count
                    if !viewModel.selectedInterests.isEmpty {
                        VStack(spacing: 12) {
                            Text("Selected: \(viewModel.selectedInterests.count) interests")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button {
                                viewModel.saveInterests()
                            } label: {
                                Text("Save Interests")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("My Interests")
            .onAppear {
                viewModel.loadInterests()
            }
        }
    }
}

struct InterestCard: View {
    let interest: InterestModel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(iconForInterest(interest.name))
                    .font(.title)
                
                Text(interest.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForInterest(_ name: String) -> String {
        switch name.lowercased() {
        case let x where x.contains("sport"): return "⚽"
        case let x where x.contains("culture"): return "🎭"
        case let x where x.contains("music"): return "🎵"
        case let x where x.contains("art"): return "🎨"
        case let x where x.contains("food"): return "🍽️"
        case let x where x.contains("book"): return "📚"
        case let x where x.contains("science"): return "🔬"
        case let x where x.contains("tech"): return "💻"
        case let x where x.contains("dance"): return "💃"
        case let x where x.contains("film"): return "🎬"
        case let x where x.contains("photo"): return "📸"
        case let x where x.contains("travel"): return "✈️"
        case let x where x.contains("nature"): return "🌿"
        case let x where x.contains("fitness"): return "💪"
        default: return "🌟"
        }
    }
}

@MainActor
class InterestsViewModel: ObservableObject {
    @Published var availableInterests: [InterestModel] = []
    @Published var selectedInterests: Set<String> = []
    @Published var isLoading = false
    
    var categorizedInterests: [String: [InterestModel]] {
        Dictionary(grouping: availableInterests) { $0.category ?? "Other" }
    }
    
    func loadInterests() {
        isLoading = true
        
        // Load available interests
        availableInterests = MockDatabaseManager.shared.getAllInterests()
        
        // Load user's selected interests (mock for now)
        selectedInterests = Set(["int_sports", "int_culture"])
        
        isLoading = false
    }
    
    func toggleInterest(_ interestId: String) {
        if selectedInterests.contains(interestId) {
            selectedInterests.remove(interestId)
        } else {
            selectedInterests.insert(interestId)
        }
    }
    
    func saveInterests() {
        // Save to database (mock for now)
        print("Saving interests: \(selectedInterests)")
        // In a real app, this would save to UserDefaults or backend
    }
}

struct NotificationsView: View {
    @State private var notifications = [
        NotificationItem(
            id: "1",
            title: "New Cultural Event",
            message: "Adelaide Chinese Festival is happening this weekend! Join diverse groups and get up to 25% discount.",
            timestamp: Date().addingTimeInterval(-300), // 5 minutes ago
            isRead: false,
            type: .event,
            icon: "party.popper"
        ),
        NotificationItem(
            id: "2", 
            title: "Group Invitation",
            message: "You've been invited to join 'International Friends' group for the Multicultural Food Festival.",
            timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
            isRead: false,
            type: .group,
            icon: "person.3"
        ),
        NotificationItem(
            id: "3",
            title: "Bridge Built! 🌉",
            message: "Congratulations! You've unlocked the 'Cultural Bridge Builder' badge for connecting diverse communities.",
            timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
            isRead: true,
            type: .achievement,
            icon: "trophy"
        ),
        NotificationItem(
            id: "4",
            title: "Event Reminder",
            message: "Don't forget: University Innovation Expo starts in 2 hours at Adelaide University.",
            timestamp: Date().addingTimeInterval(-10800), // 3 hours ago
            isRead: false,
            type: .reminder,
            icon: "clock"
        ),
        NotificationItem(
            id: "5",
            title: "Special Discount",
            message: "Your diverse group qualifies for 20% off tickets! Complete your purchase by tomorrow.",
            timestamp: Date().addingTimeInterval(-86400), // 1 day ago
            isRead: true,
            type: .discount,
            icon: "percent"
        ),
        NotificationItem(
            id: "6",
            title: "New Connection",
            message: "Maria from Colombia would like to connect with you after the Food & Wine Festival.",
            timestamp: Date().addingTimeInterval(-172800), // 2 days ago
            isRead: true,
            type: .social,
            icon: "person.crop.circle.badge.plus"
        )
    ]
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    var body: some View {
        NavigationContainer {
            List {
                if unreadCount > 0 {
                    Section {
                        HStack {
                            Text("\(unreadCount) unread notifications")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Mark all as read") {
                                markAllAsRead()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                ForEach(notifications) { notification in
                    NotificationRow(notification: notification) {
                        markAsRead(notification.id)
                    }
                }
            }
            .navigationTitle("Notifications")
        }
    }
    
    private func markAsRead(_ id: String) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
        }
    }
    
    private func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
}

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    var isRead: Bool
    let type: NotificationType
    let icon: String
}

enum NotificationType {
    case event, group, achievement, reminder, discount, social
    
    var color: Color {
        switch self {
        case .event: return .blue
        case .group: return .green
        case .achievement: return .orange
        case .reminder: return .red
        case .discount: return .purple
        case .social: return .pink
        }
    }
}

struct NotificationRow: View {
    let notification: NotificationItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(notification.type.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: notification.icon)
                        .foregroundColor(notification.type.color)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.headline)
                            .fontWeight(notification.isRead ? .medium : .semibold)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Text(formatTimestamp(notification.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

struct HelpView: View {
    var body: some View {
        Text("Help")
            .navigationTitle("Help")
    }
}

struct FeedbackView: View {
    var body: some View {
        Text("Send Feedback")
            .navigationTitle("Feedback")
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "ticket")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("MateHub")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("An app to connect diverse communities through cultural and sports events.")
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("About")
    }
}

@MainActor
class UserSessionManager: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = true
    
    init() {
        // Check for existing session
        checkExistingSession()
    }
    
    private func checkExistingSession() {
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // In a real app, check UserDefaults or Keychain for existing session
            // For now, we'll start with no user logged in to show welcome/registration flow
            self.currentUser = nil
            self.isLoggedIn = false
            self.isLoading = false
        }
    }
    
    func loginDemoUser() {
        // Demo user login function for testing
        self.currentUser = UserModel(
            id: "user_gustavo",
            name: "Gustavo Polania",
            email: "gustavo@example.com",
            age: 29,
            gender: "Male",
            countryOfBirth: "Colombia",
            languageAtHome: "Spanish",
            state: "SA",
            isFirstNations: false,
            hasDisability: false
        )
        self.isLoggedIn = true
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        isLoading = false
        // Clear stored session
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "ticket")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            
            Text("MateHub")
                .font(.title)
                .fontWeight(.bold)
            
            ProgressView()
                .scaleEffect(1.2)
                .tint(.blue)
        }
        .onAppear {
            isAnimating = true
        }
    }
}