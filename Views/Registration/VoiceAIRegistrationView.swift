import SwiftUI
import Speech
import AVFoundation

struct VoiceAIRegistrationView: View {
    @StateObject private var viewModel = VoiceAIRegistrationViewModel()
    @Binding var isPresented: Bool
    @Binding var currentUser: UserModel?
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationContainer {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) { // Reduced from 40 to 20
                    // Header (more compact)
                    VStack(spacing: 8) { // Reduced from 16 to 8
                        Text("Voice Registration")
                            .font(.title2) // Reduced from .largeTitle to .title2
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Have a natural conversation with our AI assistant")
                            .font(.caption) // Reduced from .subheadline to .caption
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10) // Reduced from 20 to 10
                    
                    // Voice Visualizer
                    VoiceVisualizerView(
                        isListening: viewModel.isListening,
                        isSpeaking: viewModel.isSpeaking,
                        audioLevel: viewModel.audioLevel
                    )
                    
                    // Current conversation state
                    VStack(spacing: 8) { // Further reduced spacing from 12 to 8
                        if !viewModel.currentAIMessage.isEmpty {
                            VStack(spacing: 4) { // Reduced spacing from 8 to 4
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .font(.caption) // Made icon smaller
                                        .foregroundColor(.purple)
                                    Text("AI Assistant")
                                        .font(.caption2) // Made text smaller
                                        .foregroundColor(.purple)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                
                                ScrollView {
                                    Text(viewModel.currentAIMessage)
                                        .font(.body)
                                        .lineLimit(nil) // Allow unlimited lines
                                        .multilineTextAlignment(.leading)
                                        .padding(8) // Further reduced padding
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.purple.opacity(0.1))
                                        .cornerRadius(12)
                                }
                                .frame(maxHeight: 60) // Further reduced from 80 to 60
                            }
                        }
                        
                        if !viewModel.currentUserMessage.isEmpty {
                            VStack(spacing: 8) {
                                HStack {
                                    Spacer()
                                    Text("You")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .fontWeight(.medium)
                                    Image(systemName: "person.crop.circle")
                                        .foregroundColor(.blue)
                                }
                                
                                ScrollView {
                                    Text(viewModel.currentUserMessage)
                                        .font(.body)
                                        .lineLimit(nil) // Allow unlimited lines
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(2) // Add line spacing for better readability
                                        .padding(16) // Increase padding
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(12)
                                }
                                .frame(maxHeight: 300) // Further increased from 200 to 300 for user text
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Control buttons
                    VStack(spacing: 20) {
                        // Start Talking button
                        if !viewModel.isListening {
                            Button {
                                viewModel.startListening()
                            } label: {
                                HStack {
                                    Image(systemName: "mic.fill")
                                        .font(.title2)
                                    Text("Start Talking")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                            }
                            .disabled(viewModel.isSpeaking)
                        }
                        
                        // Stop Listening button (completes registration)
                        if viewModel.isListening {
                            Button {
                                viewModel.completeRegistration()
                            } label: {
                                HStack {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.title2)
                                    Text("Stop Listening")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.red, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .scaleEffect(1.05)
                                .animation(.bouncy(duration: 0.3), value: viewModel.isListening)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    
                    // Status text
                    Text(viewModel.statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.setupVoiceRegistration()
        }
        .onDisappear {
            viewModel.cleanup()
        }
        .fullScreenCover(isPresented: $showingSuccess) {
            WelcomeCompleteView {
                currentUser = viewModel.user
                showingSuccess = false
                isPresented = false
            }
        }
        .onChange(of: viewModel.registrationComplete) { _, isComplete in
            if isComplete {
                showingSuccess = true
            }
        }
    }
}

struct VoiceVisualizerView: View {
    let isListening: Bool
    let isSpeaking: Bool
    let audioLevel: Float
    
    @State private var animationPhase = 0.0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.2), .pink.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100) // Further reduced from 150 to 100
            
            // Animated rings
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.6), .pink.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 80 + CGFloat(index * 10), height: 80 + CGFloat(index * 10)) // Further reduced
                    .scaleEffect(isListening || isSpeaking ? 1.0 + sin(animationPhase + Double(index)) * 0.1 : 0.8)
                    .opacity(isListening || isSpeaking ? 0.7 - Double(index) * 0.2 : 0.3)
            }
            
            // Center icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40) // Further reduced from 60 to 40
                    .scaleEffect(1.0 + CGFloat(audioLevel) * 0.3)
                
                Image(systemName: getIconName())
                    .font(.system(size: 18)) // Further reduced from 25 to 18
                    .foregroundColor(.white)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isListening)
        .animation(.easeInOut(duration: 0.3), value: isSpeaking)
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            if isListening || isSpeaking {
                animationPhase += 0.2
            }
        }
    }
    
    private func getIconName() -> String {
        if isSpeaking {
            return "speaker.wave.2.fill"
        } else if isListening {
            return "mic.fill"
        } else {
            return "brain.head.profile"
        }
    }
}

@MainActor
class VoiceAIRegistrationViewModel: ObservableObject {
    @Published var isListening = false
    @Published var isSpeaking = false
    @Published var audioLevel: Float = 0.0
    @Published var currentAIMessage = ""
    @Published var currentUserMessage = ""
    @Published var statusText = "Tap 'Start Talking' to begin our conversation"
    @Published var registrationComplete = false
    
    // Registration data
    @Published var selectedLanguage: String = ""
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    @Published var userCountry: String = ""
    @Published var userCity: String = ""
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private var speechSynthesizer: AVSpeechSynthesizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var conversationState: VoiceRegistrationState = .greeting
    
    // Robust simulator detection
    private var isSimulatorMode: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    init() {
        // Set initial status based on environment
        if isSimulatorMode {
            statusText = "Demo mode: Voice features simulated for development"
        }
    }
    
    var user: UserModel {
        UserModel(
            name: userName,
            email: userEmail,
            phone: userPhone.isEmpty ? nil : userPhone,
            age: nil,
            gender: nil,
            countryOfBirth: userCountry.isEmpty ? nil : userCountry,
            languageAtHome: selectedLanguage.isEmpty ? nil : selectedLanguage,
            state: userCity.isEmpty ? nil : userCity,
            isFirstNations: false,
            hasDisability: false
        )
    }
    
    func setupVoiceRegistration() {
        if isSimulatorMode {
            print("🟡 Voice Registration: Running in simulator - using demo mode")
            statusText = "Demo Mode: Voice features simulated for development"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startSimulatorDemo()
            }
        } else {
            print("🟢 Voice Registration: Running on real device - initializing voice features")
            // Initialize speech objects only on real device
            do {
                speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
                audioEngine = AVAudioEngine()
                speechSynthesizer = AVSpeechSynthesizer()
                
                requestPermissions()
                setupAudioSession()
                startWelcomeMessage()
            } catch {
                print("❌ Failed to initialize voice components: \(error)")
                statusText = "Voice initialization failed. Please try again."
            }
        }
    }
    
    private func startSimulatorDemo() {
        // Simulate the voice conversation flow in simulator
        print("🟡 Starting simulator demo mode")
        statusText = "Demo mode ready"
        
        // Start with welcome message
        speakMessage("Welcome to MateHub! Please tell me about yourself.")
        
        conversationState = .greeting
    }
    
    private func shouldUseVoiceFeatures() -> Bool {
        return !isSimulatorMode && speechRecognizer != nil && audioEngine != nil
    }
    
    func startListening() {
        print("🎤 StartListening called - Simulator mode: \(isSimulatorMode)")
        
        if isSimulatorMode {
            print("🟡 Using simulator demo mode instead of real microphone")
            statusText = "Demo mode: Use 'Skip' button to advance conversation"
            simulateUserResponse()
            return
        }
        
        guard shouldUseVoiceFeatures() else {
            print("❌ Voice features not available - shouldUseVoiceFeatures returned false")
            statusText = "Voice features not available in this environment"
            return
        }
        
        guard let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            print("❌ Speech recognizer not available")
            statusText = "Speech recognition not available"
            return
        }
        
        guard let audioEngine = audioEngine else {
            print("❌ Audio engine not initialized")
            statusText = "Audio engine not initialized"
            return
        }
        
        print("🟢 Proceeding with real voice recognition")
        
        stopListening() // Stop any existing session
        
        do {
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                statusText = "Unable to create recognition request"
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                DispatchQueue.main.async {
                    if let result = result {
                        self.currentUserMessage = result.bestTranscription.formattedString
                        
                        if result.isFinal {
                            self.processUserSpeech(self.currentUserMessage)
                            self.stopListening()
                        }
                    }
                    
                    if let error = error {
                        // Only log errors if not in simulator mode
                        if !self.isSimulatorMode {
                            print("Speech recognition error: \(error)")
                        }
                        self.stopListening()
                    }
                }
            }
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
                
                // Calculate audio level for visualization
                let channelData = buffer.floatChannelData?[0]
                let frames = buffer.frameLength
                var sum: Float = 0
                
                if let channelData = channelData {
                    for i in 0..<Int(frames) {
                        sum += abs(channelData[i])
                    }
                }
                
                let average = sum / Float(frames)
                DispatchQueue.main.async {
                    self.audioLevel = min(average * 10, 1.0) // Normalize and amplify
                }
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isListening = true
            statusText = "I'm listening... Speak now"
            
        } catch {
            if !isSimulatorMode {
                print("Failed to start listening: \(error)")
            }
            statusText = "Failed to start voice recognition"
        }
    }
    
    private func simulateUserResponse() {
        // Simple simulation for demo
        print("🟡 Simulating user talking...")
        currentUserMessage = "Hi there! My name is Gustavo. I'm originally from Colombia, specifically from Bogotá, but I moved to Adelaide a few years ago to study and work. I have a strong Latin American background - I grew up with Colombian traditions, love our music like salsa and vallenato, and I'm passionate about Colombian coffee and food. In my time free I enjoy playing football, learning about technology and coding, and I'm really interested in connecting with people from different cultures here in Australia."
        statusText = "Demo: Simulating your voice input..."
        
        // Simulate some talking time
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.statusText = "Demo: Press 'Stop Listening' to complete your registration"
        }
    }
    
    func cleanup() {
        print("🧹 Cleanup called - Simulator mode: \(isSimulatorMode)")
        stopListening()
        
        if shouldUseVoiceFeatures() {
            print("🟢 Cleaning up voice components")
            do {
                speechSynthesizer?.stopSpeaking(at: .immediate)
                audioEngine?.stop()
            } catch {
                print("⚠️ Error during cleanup: \(error)")
            }
        } else {
            print("🟡 Skipping voice cleanup - simulator mode or no voice features")
        }
    }
    
    private func requestPermissions() {
        print("🔒 Requesting permissions - Simulator mode: \(isSimulatorMode)")
        
        guard !isSimulatorMode else {
            print("🟡 Skipping permission requests in simulator")
            return
        }
        
        print("🟢 Requesting speech recognition permission")
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("✅ Speech recognition permission granted")
                    self.statusText = "Voice permissions granted. Ready to start!"
                case .denied, .restricted:
                    print("❌ Speech recognition permission denied")
                    self.statusText = "Voice permissions denied. Please enable in Settings."
                case .notDetermined:
                    print("⏳ Speech recognition permission pending")
                    self.statusText = "Voice permissions pending..."
                @unknown default:
                    print("❓ Unknown speech recognition permission status")
                    self.statusText = "Unknown permission status"
                }
            }
        }
        
        print("🟢 Requesting microphone permission")
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Microphone permission granted")
                } else {
                    print("❌ Microphone permission denied")
                    self.statusText = "Microphone permission required for voice registration"
                }
            }
        }
    }
    
    private func setupAudioSession() {
        print("🔊 Setting up audio session - Simulator mode: \(isSimulatorMode)")
        
        guard !isSimulatorMode else {
            print("🟡 Skipping audio session setup in simulator")
            return
        }
        
        print("🟢 Configuring audio session for real device")
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
    
    private func startWelcomeMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.speakMessage("Welcome to MateHub! Please tell me about yourself.")
        }
    }
    
    
    func stopListening() {
        print("🛑 StopListening called - Simulator mode: \(isSimulatorMode)")
        
        if shouldUseVoiceFeatures(), let audioEngine = audioEngine {
            print("🟢 Stopping real audio engine")
            do {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
                recognitionRequest?.endAudio()
                recognitionTask?.cancel()
                recognitionTask = nil
                recognitionRequest = nil
            } catch {
                print("⚠️ Error stopping audio components: \(error)")
            }
        } else {
            print("🟡 Skipping audio engine stop - simulator mode or no voice features")
        }
        
        isListening = false
        audioLevel = 0
        
        if !currentUserMessage.isEmpty {
            statusText = "Processing your response..."
        }
    }
    
    private func processUserSpeech(_ speech: String) {
        let response = generateVoiceResponse(speech)
        speakMessage(response)
    }
    
    private func speakMessage(_ message: String) {
        print("🗣️ SpeakMessage called - Simulator mode: \(isSimulatorMode)")
        print("💬 Message: \(message)")
        
        currentAIMessage = message
        isSpeaking = true
        statusText = "AI is speaking..."
        
        if isSimulatorMode {
            print("🟡 Using simulator text-only mode")
            // In simulator, just show the text without using speech synthesizer
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isSpeaking = false
                self.statusText = "Demo mode: Use 'Start Talking' to advance conversation"
            }
        } else if let speechSynthesizer = speechSynthesizer {
            print("🟢 Using real text-to-speech")
            do {
                let utterance = AVSpeechUtterance(string: message)
                utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
                utterance.pitchMultiplier = 1.0
                utterance.volume = 0.8
                
                // Use a more natural voice if available
                if let voice = AVSpeechSynthesisVoice(language: "en-US") {
                    utterance.voice = voice
                }
                
                speechSynthesizer.speak(utterance)
                print("✅ Speech synthesis started")
                
                // Monitor when speaking finishes
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(message.count) * 0.05 + 2.0) {
                    self.isSpeaking = false
                    self.statusText = "Tap 'Start Talking' when you're ready to respond"
                }
            } catch {
                print("❌ Error in speech synthesis: \(error)")
                self.isSpeaking = false
                self.statusText = "Speech error occurred"
            }
        } else {
            print("⚠️ Speech synthesizer not available")
            self.isSpeaking = false
            self.statusText = "Speech not available"
        }
    }
    
    private func generateVoiceResponse(_ userMessage: String) -> String {
        switch conversationState {
        case .greeting:
            return handleLanguageSelection(userMessage)
        case .languageSelected:
            return handlePersonalIntro(userMessage)
        case .collectingName:
            return handleNameCollection(userMessage)
        case .collectingEmail:
            return handleEmailCollection(userMessage)
        case .collectingPhone:
            return handlePhoneCollection(userMessage)
        case .collectingCountry:
            return handleCountryCollection(userMessage)
        case .collectingCity:
            return handleCityCollection(userMessage)
        case .completing:
            return completeRegistration()
        }
    }
    
    // Similar response logic as the text version, but optimized for speech
    private func handleLanguageSelection(_ message: String) -> String {
        selectedLanguage = extractLanguageFromSpeech(message)
        conversationState = .languageSelected
        return "Great! I'll continue in \(selectedLanguage). Tell me a bit about yourself - where are you from and what brings you to MateHub?"
    }
    
    private func extractLanguageFromSpeech(_ message: String) -> String {
        let lowercased = message.lowercased()
        if lowercased.contains("spanish") || lowercased.contains("español") {
            return "Spanish"
        } else if lowercased.contains("french") || lowercased.contains("français") {
            return "French"
        } else if lowercased.contains("german") || lowercased.contains("deutsch") {
            return "German"
        } else if lowercased.contains("chinese") || lowercased.contains("中文") {
            return "Chinese"
        }
        return "English"
    }
    
    private func handlePersonalIntro(_ message: String) -> String {
        conversationState = .collectingName
        return "That's wonderful! To get started with your registration, what's your full name?"
    }
    
    private func handleNameCollection(_ message: String) -> String {
        userName = extractNameFromSpeech(message)
        conversationState = .collectingEmail
        return "Nice to meet you, \(userName)! What's your email address?"
    }
    
    private func extractNameFromSpeech(_ message: String) -> String {
        // Simple extraction - in a real app, you'd use more sophisticated NLP
        let words = message.components(separatedBy: " ")
        if words.count >= 2 {
            return words.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func handleEmailCollection(_ message: String) -> String {
        userEmail = extractEmailFromSpeech(message)
        conversationState = .collectingPhone
        return "Perfect! And your phone number? You can say 'skip' if you prefer not to share it."
    }
    
    private func extractEmailFromSpeech(_ message: String) -> String {
        // Convert spoken email format to written format
        let processed = message.lowercased()
            .replacingOccurrences(of: " at ", with: "@")
            .replacingOccurrences(of: " dot ", with: ".")
            .replacingOccurrences(of: " ", with: "")
        return processed
    }
    
    private func handlePhoneCollection(_ message: String) -> String {
        if !message.lowercased().contains("skip") {
            userPhone = extractPhoneFromSpeech(message)
        }
        conversationState = .collectingCountry
        return "Great! Which country are you originally from?"
    }
    
    private func extractPhoneFromSpeech(_ message: String) -> String {
        // Extract digits and common phone number words
        return message.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    private func handleCountryCollection(_ message: String) -> String {
        userCountry = message.trimmingCharacters(in: .whitespacesAndNewlines)
        conversationState = .collectingCity
        return "Excellent! \(userCountry) is a wonderful place. What city do you currently live in?"
    }
    
    private func handleCityCollection(_ message: String) -> String {
        userCity = message.trimmingCharacters(in: .whitespacesAndNewlines)
        conversationState = .completing
        return completeRegistration()
    }
    
    private func completeRegistration() -> String {
        let success = MockDatabaseManager.shared.createUser(user)
        
        if success {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.registrationComplete = true
            }
            
            return "Fantastic, \(userName)! Your voice registration is complete. Welcome to MateHub, where cultures meet and bridges are built. You'll be taken to explore amazing events near you in \(userCity) in just a moment!"
        } else {
            return "I'm sorry, there was a problem saving your registration. Could you try again?"
        }
    }
    
    func repeatLastMessage() {
        if !currentAIMessage.isEmpty {
            speakMessage(currentAIMessage)
        }
    }
    
    func skipCurrentQuestion() {
        switch conversationState {
        case .collectingPhone:
            conversationState = .collectingCountry
            speakMessage("No problem! Which country are you originally from?")
        case .collectingCountry:
            conversationState = .collectingCity
            speakMessage("That's okay. What city do you currently live in?")
        default:
            speakMessage("I can't skip this question, but I can repeat it if you'd like.")
        }
    }
    
    func completeRegistration() {
        print("🎯 CompleteRegistration called")
        stopListening()
        
        // Set data based on the simulated conversation
        selectedLanguage = "English"
        userName = "Gustavo"
        userEmail = "gustavo@example.com"
        userPhone = "04-1234-5678"
        userCountry = "Colombia"
        userCity = "Adelaide"
        
        statusText = "Completing your registration, Gustavo..."
        
        // Show a brief completion message
        speakMessage("Registration complete. Welcome to MateHub!")
        
        // Create user with demo data
        let success = MockDatabaseManager.shared.createUser(user)
        
        if success {
            print("✅ Registration successful for Gustavo")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.registrationComplete = true
            }
        } else {
            print("❌ Registration failed")
            print("❌ Registration failed")
            statusText = "Registration failed. Please try again."
        }
    }
}

enum VoiceRegistrationState {
    case greeting
    case languageSelected
    case collectingName
    case collectingEmail
    case collectingPhone
    case collectingCountry
    case collectingCity
    case completing
}
