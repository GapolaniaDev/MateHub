import SwiftUI

struct SurveyCompletionView: View {
    let cohesionScore: Double
    let averageScore: Double
    let onViewTrophies: () -> Void
    let onContinue: () -> Void
    let eventTitle: String?
    
    @State private var showConfetti = false
    @State private var showBridge = false
    @State private var animateScore = false
    @State private var showingGallery = false
    
    // Badge to unlock - choosing "Feedback Bridge Builder" as the most appealing
    private let unlockedTrophy = TrophyModel(
        id: "sv_01", 
        title: "Feedback Bridge Builder", 
        description: "Bridge communities through valuable feedback.", 
        category: "Survey Bridge", 
        iconName: "point.3.connected.trianglepath.dotted", 
        emoji: "🌉", 
        conditionJson: "{\"surveysCompleted\":1}", 
        isUnlocked: true
    )
    
    var cohesionLevel: String {
        switch cohesionScore {
        case 4.5...5.0: return "Incredible"
        case 3.5..<4.5: return "Amazing"
        case 2.5..<3.5: return "Great"
        case 1.5..<2.5: return "Good"
        default: return "Solid"
        }
    }
    
    var impactMessage: String {
        switch cohesionScore {
        case 4.5...5.0: return "You're building bridges across cultures! Your openness is creating a more connected community. 🌟"
        case 3.5..<4.5: return "You're making real connections! Your positive attitude is helping unite people from different backgrounds. 💫"
        case 2.5..<3.5: return "You're contributing to community harmony! Every interaction helps create a more inclusive society. ✨"
        default: return "Every voice matters! Your participation helps us understand how to build better connections. 🤝"
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 40)
                    
                    // Celebration header
                    VStack(spacing: 16) {
                        Text("🎉")
                            .font(.system(size: 80))
                            .scaleEffect(animateScore ? 1.2 : 1.0)
                            .animation(.bouncy(duration: 0.6), value: animateScore)
                        
                        Text("Awesome Work!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("You just helped build a stronger community")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Cohesion score display
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("Your Social Cohesion Score")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack(alignment: .bottom, spacing: 4) {
                                Text("\(String(format: "%.1f", cohesionScore))")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                    .scaleEffect(animateScore ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.8).delay(0.3), value: animateScore)
                                
                                Text("/5.0")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                    .opacity(animateScore ? 1.0 : 0.0)
                                    .animation(.easeInOut(duration: 0.5).delay(0.6), value: animateScore)
                            }
                            
                            Text("\(cohesionLevel) Connection!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .opacity(animateScore ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.5).delay(0.8), value: animateScore)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.2), radius: 10)
                    }
                    
                    // Impact message
                    VStack(spacing: 12) {
                        Text("Your Impact")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(impactMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Bridge built section
                    if showBridge {
                        VStack(spacing: 20) {
                            HStack {
                                Text("🌉")
                                    .font(.title)
                                Text("Bridge Built!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                            
                            BridgeBuiltCard(trophy: unlockedTrophy)
                            
                            Text("1 of \(getTotalBridgeCount()) bridges built")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button {
                            // Send notification to navigate to trophies
                            NotificationCenter.default.post(name: NSNotification.Name("NavigateToTrophies"), object: nil)
                            onViewTrophies()
                        } label: {
                            HStack {
                                Image(systemName: "point.3.connected.trianglepath.dotted")
                                Text("View Badge")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                        .scaleEffect(showBridge ? 1.0 : 0.8)
                        .opacity(showBridge ? 1.0 : 0.0)
                        .animation(.bouncy(duration: 0.6).delay(1.2), value: showBridge)
                        
                        if let eventTitle = eventTitle {
                            Button {
                                showingGallery = true
                            } label: {
                                HStack {
                                    Image(systemName: "photo.stack")
                                    Text("View Gallery")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.8))
                                .cornerRadius(12)
                            }
                            .scaleEffect(showBridge ? 1.0 : 0.8)
                            .opacity(showBridge ? 1.0 : 0.0)
                            .animation(.bouncy(duration: 0.6).delay(1.4), value: showBridge)
                        }
                        
                        Button {
                            onContinue()
                        } label: {
                            Text("Continue")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .opacity(showBridge ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.3).delay(1.6), value: showBridge)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .onAppear {
            startAnimationSequence()
        }
        .sheet(isPresented: $showingGallery) {
            if let eventTitle = eventTitle {
                GalleryView(eventTitle: eventTitle)
            }
        }
    }
    
    private func startAnimationSequence() {
        // Start confetti immediately
        showConfetti = true
        
        // Start score animation
        withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
            animateScore = true
        }
        
        // Show bridge after a delay
        withAnimation(.bouncy(duration: 0.8).delay(1.0)) {
            showBridge = true
        }
        
        // Stop confetti after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            showConfetti = false
        }
    }
    
    private func getTotalBridgeCount() -> Int {
        // This should return the actual total count from ProfileViewModel
        // For now, returning a reasonable number based on our bridging badge system
        return 44 // 41 existing + 3 new survey bridges
    }
}

struct BridgeBuiltCard: View {
    let trophy: TrophyModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Bridge icon with glow effect
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.teal, .teal.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                    .shadow(color: .teal.opacity(0.5), radius: 20)
                
                Text(trophy.emoji ?? "🌉")
                    .font(.system(size: 40))
            }
            
            VStack(spacing: 6) {
                Text(trophy.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(trophy.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(trophy.category?.uppercased() ?? "SURVEY BRIDGE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.teal)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.teal.opacity(0.2))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8)
    }
}

// Confetti animation view
struct ConfettiView: View {
    @State private var animate = false
    
    private let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { i in
                ConfettiPiece(color: colors.randomElement() ?? .blue)
                    .offset(
                        x: animate ? .random(in: -200...200) : 0,
                        y: animate ? .random(in: -100...800) : -100
                    )
                    .rotation3DEffect(
                        .degrees(animate ? .random(in: 0...360) : 0),
                        axis: (x: 1, y: 1, z: 0)
                    )
                    .animation(
                        .easeOut(duration: .random(in: 2.0...4.0))
                        .delay(.random(in: 0...2.0)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
            .cornerRadius(2)
    }
}