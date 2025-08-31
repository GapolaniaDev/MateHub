import SwiftUI
import Foundation

struct AIRegistrationView: View {
    @StateObject private var viewModel = AIRegistrationViewModel()
    @Binding var isPresented: Bool
    @Binding var currentUser: UserModel?
    @State private var messageText = ""
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationContainer {
            VStack {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome to MateHub! 👋")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Let's get to know you with our AI assistant")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Skip") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                AIMessageBubble(message: message)
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("AI is typing...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                                    
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input area
                if !viewModel.registrationComplete {
                    VStack(spacing: 12) {
                        // Suggested responses (if any)
                        if !viewModel.suggestedResponses.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.suggestedResponses, id: \.self) { response in
                                        Button(response) {
                                            sendMessage(response)
                                        }
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(16)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Text input
                        HStack {
                            TextField("Type your message...", text: $messageText, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(1...4)
                            
                            Button {
                                sendMessage(messageText)
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(messageText.isEmpty ? Color.gray : Color.blue)
                                    .clipShape(Circle())
                            }
                            .disabled(messageText.isEmpty || viewModel.isLoading)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.startConversation()
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
    
    private func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        viewModel.sendMessage(text)
        messageText = ""
        viewModel.suggestedResponses = []
    }
}

struct AIMessageBubble: View {
    let message: AIMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                if !message.isFromUser {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("MateHub AI")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                }
                
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        message.isFromUser ? 
                        Color.blue : Color(.systemGray5)
                    )
                    .foregroundColor(
                        message.isFromUser ? .white : .primary
                    )
                    .cornerRadius(12)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isFromUser {
                Spacer()
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AIMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    
    static func == (lhs: AIMessage, rhs: AIMessage) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
class AIRegistrationViewModel: ObservableObject {
    @Published var messages: [AIMessage] = []
    @Published var isLoading = false
    @Published var registrationComplete = false
    @Published var suggestedResponses: [String] = []
    
    // Registration data
    @Published var selectedLanguage: String = ""
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    @Published var userCountry: String = ""
    @Published var userCity: String = ""
    
    private let apiKey = "YOUR_OPENAI_API_KEY_HERE" // Replace with secure storage
    private var conversationState: RegistrationState = .greeting
    
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
    
    func startConversation() {
        let welcomeMessage = """
        ¡Hola! 👋 Soy el asistente de MateHub. Es un placer conocerte.
        
        Estoy aquí para ayudarte a registrarte de una manera más personal. Antes de comenzar, me gustaría saber: ¿qué idioma prefieres para nuestra conversación?
        """
        
        addMessage(welcomeMessage, from: false)
        suggestedResponses = ["Español", "English", "Français", "Deutsch", "中文"]
    }
    
    func sendMessage(_ content: String) {
        addMessage(content, from: true)
        processUserMessage(content)
    }
    
    private func addMessage(_ content: String, from user: Bool) {
        let message = AIMessage(content: content, isFromUser: user, timestamp: Date())
        messages.append(message)
    }
    
    private func processUserMessage(_ content: String) {
        isLoading = true
        
        Task {
            do {
                // Simulate API delay
                try await Task.sleep(nanoseconds: 1_500_000_000)
                
                let response = await generateAIResponse(content)
                addMessage(response, from: false)
                
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    addMessage("Lo siento, hubo un error. ¿Podrías intentar nuevamente?", from: false)
                    isLoading = false
                }
            }
        }
    }
    
    private func generateAIResponse(_ userMessage: String) async -> String {
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
    
    private func handleLanguageSelection(_ message: String) -> String {
        selectedLanguage = message.lowercased()
        conversationState = .languageSelected
        
        let responses = [
            "español": "¡Perfecto! Continuaremos en español. Me encanta poder conectar contigo en tu idioma. Cuéntame un poco sobre ti, ¿de dónde eres y qué te trae a MateHub?",
            "english": "Great! We'll continue in English. I'm excited to help you join our diverse community. Tell me a bit about yourself - where are you from and what brings you to MateHub?",
            "français": "Parfait ! Nous continuerons en français. Je suis ravi de vous aider à rejoindre notre communauté diversifiée. Parlez-moi un peu de vous - d'où venez-vous et qu'est-ce qui vous amène à MateHub ?",
            "deutsch": "Ausgezeichnet! Wir werden auf Deutsch fortfahren. Ich freue mich darauf, Ihnen zu helfen, unserer vielfältigen Gemeinschaft beizutreten. Erzählen Sie mir etwas über sich - woher kommen Sie und was bringt Sie zu MateHub?",
            "中文": "太好了！我们用中文继续。我很高兴能帮助您加入我们多元化的社区。请告诉我一些关于您的情况 - 您来自哪里，是什么让您来到MateHub？"
        ]
        
        return responses[selectedLanguage] ?? responses["english"]!
    }
    
    private func handlePersonalIntro(_ message: String) -> String {
        conversationState = .collectingName
        
        let responses = [
            "español": "¡Qué interesante! Me encanta conocer a personas de diferentes lugares. Para comenzar tu registro, necesito algunos datos básicos. ¿Cuál es tu nombre completo?",
            "english": "That's fascinating! I love meeting people from different places. To start your registration, I need some basic information. What's your full name?",
            "français": "C'est fascinant ! J'adore rencontrer des personnes de différents endroits. Pour commencer votre inscription, j'ai besoin de quelques informations de base. Quel est votre nom complet ?",
            "deutsch": "Das ist faszinierend! Ich liebe es, Menschen aus verschiedenen Orten zu treffen. Um Ihre Registrierung zu beginnen, benötige ich einige grundlegende Informationen. Wie ist Ihr vollständiger Name?",
            "中文": "太有趣了！我喜欢认识来自不同地方的人。要开始您的注册，我需要一些基本信息。您的全名是什么？"
        ]
        
        return responses[selectedLanguage] ?? responses["english"]!
    }
    
    private func handleNameCollection(_ message: String) -> String {
        userName = message
        conversationState = .collectingEmail
        
        let responses = [
            "español": "Encantado de conocerte, \(userName)! Ahora necesito tu dirección de correo electrónico para crear tu cuenta.",
            "english": "Nice to meet you, \(userName)! Now I need your email address to create your account.",
            "français": "Ravi de vous rencontrer, \(userName) ! Maintenant j'ai besoin de votre adresse e-mail pour créer votre compte.",
            "deutsch": "Schön Sie kennenzulernen, \(userName)! Jetzt brauche ich Ihre E-Mail-Adresse, um Ihr Konto zu erstellen.",
            "中文": "很高兴认识您，\(userName)！现在我需要您的电子邮件地址来创建您的账户。"
        ]
        
        return responses[selectedLanguage] ?? responses["english"]!
    }
    
    private func handleEmailCollection(_ message: String) -> String {
        userEmail = message
        conversationState = .collectingPhone
        
        let responses = [
            "español": "Perfecto, \(userEmail) guardado. ¿Podrías compartir tu número de teléfono? (Opcional, pero nos ayuda a conectarte mejor con eventos locales)",
            "english": "Perfect, \(userEmail) saved. Could you share your phone number? (Optional, but it helps us connect you better with local events)",
            "français": "Parfait, \(userEmail) enregistré. Pourriez-vous partager votre numéro de téléphone ? (Optionnel, mais cela nous aide à mieux vous connecter avec les événements locaux)",
            "deutsch": "Perfekt, \(userEmail) gespeichert. Könnten Sie Ihre Telefonnummer teilen? (Optional, aber es hilft uns, Sie besser mit lokalen Veranstaltungen zu verbinden)",
            "中文": "完美，\(userEmail) 已保存。您能分享您的电话号码吗？（可选，但这有助于我们更好地为您连接本地活动）"
        ]
        
        suggestedResponses = ["Skip / Omitir"]
        
        return responses[selectedLanguage] ?? responses["english"]!
    }
    
    private func handlePhoneCollection(_ message: String) -> String {
        if !message.lowercased().contains("skip") && !message.lowercased().contains("omitir") {
            userPhone = message
        }
        conversationState = .collectingCountry
        suggestedResponses = []
        
        let responses = [
            "español": "Genial! Ahora, ¿de qué país eres originalmente? Esto nos ayuda a crear conexiones más significativas con personas de tu cultura.",
            "english": "Great! Now, which country are you originally from? This helps us create more meaningful connections with people from your culture.",
            "français": "Génial ! Maintenant, de quel pays êtes-vous originaire ? Cela nous aide à créer des connexions plus significatives avec des personnes de votre culture.",
            "deutsch": "Großartig! Aus welchem Land kommen Sie ursprünglich? Das hilft uns, sinnvollere Verbindungen zu Menschen aus Ihrer Kultur zu schaffen.",
            "中文": "太好了！现在，您最初来自哪个国家？这有助于我们与来自您文化的人建立更有意义的联系。"
        ]
        
        return responses[selectedLanguage] ?? responses["english"]!
    }
    
    private func handleCountryCollection(_ message: String) -> String {
        userCountry = message
        conversationState = .collectingCity
        
        let responses = [
            "español": "¡Excelente! \(userCountry) es un país maravilloso. Por último, ¿en qué ciudad vives actualmente? Esto nos permite mostrarte eventos cercanos a ti.",
            "english": "Excellent! \(userCountry) is a wonderful country. Finally, what city do you currently live in? This allows us to show you events near you.",
            "français": "Excellent ! \(userCountry) est un pays merveilleux. Enfin, dans quelle ville habitez-vous actuellement ? Cela nous permet de vous montrer des événements près de chez vous.",
            "deutsch": "Ausgezeichnet! \(userCountry) ist ein wunderbares Land. Schließlich, in welcher Stadt leben Sie derzeit? Das ermöglicht es uns, Ihnen Veranstaltungen in Ihrer Nähe zu zeigen.",
            "中文": "太好了！\(userCountry) 是一个美妙的国家。最后，您目前住在哪个城市？这让我们可以向您展示附近的活动。"
        ]
        
        return responses[selectedLanguage] ?? responses["english"]!
    }
    
    private func handleCityCollection(_ message: String) -> String {
        userCity = message
        conversationState = .completing
        
        return completeRegistration()
    }
    
    private func completeRegistration() -> String {
        // Save user data to database
        let success = MockDatabaseManager.shared.createUser(user)
        
        if success {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.registrationComplete = true
            }
            
            let responses = [
                "español": "¡Fantástico, \(userName)! Tu registro está completo. Bienvenido a MateHub, donde las culturas se encuentran y los puentes se construyen. 🌉\n\nEn unos momentos te llevaré a explorar eventos increíbles cerca de ti en \(userCity). ¡Prepárate para hacer conexiones increíbles!",
                "english": "Fantastic, \(userName)! Your registration is complete. Welcome to MateHub, where cultures meet and bridges are built. 🌉\n\nIn a moment I'll take you to explore amazing events near you in \(userCity). Get ready to make incredible connections!",
                "français": "Fantastique, \(userName) ! Votre inscription est terminée. Bienvenue à MateHub, où les cultures se rencontrent et les ponts se construisent. 🌉\n\nDans un moment, je vous emmènerai explorer des événements incroyables près de chez vous à \(userCity). Préparez-vous à faire des connexions incroyables !",
                "deutsch": "Fantastisch, \(userName)! Ihre Registrierung ist abgeschlossen. Willkommen bei MateHub, wo sich Kulturen treffen und Brücken gebaut werden. 🌉\n\nIn einem Moment bringe ich Sie dazu, erstaunliche Veranstaltungen in Ihrer Nähe in \(userCity) zu erkunden. Machen Sie sich bereit für unglaubliche Verbindungen!",
                "中文": "太棒了，\(userName)！您的注册已完成。欢迎来到MateHub，这里是文化相遇、桥梁建立的地方。🌉\n\n稍后我会带您探索\(userCity)附近的精彩活动。准备好建立令人难以置信的联系吧！"
            ]
            
            return responses[selectedLanguage] ?? responses["english"]!
        } else {
            let errorResponses = [
                "español": "Hubo un problema al guardar tu registro. ¿Podrías intentar nuevamente?",
                "english": "There was a problem saving your registration. Could you try again?",
                "français": "Il y a eu un problème pour enregistrer votre inscription. Pourriez-vous réessayer ?",
                "deutsch": "Es gab ein Problem beim Speichern Ihrer Registrierung. Könnten Sie es erneut versuchen?",
                "中文": "保存您的注册时出现问题。您能再试一次吗？"
            ]
            
            return errorResponses[selectedLanguage] ?? errorResponses["english"]!
        }
    }
}

enum RegistrationState {
    case greeting
    case languageSelected
    case collectingName
    case collectingEmail
    case collectingPhone
    case collectingCountry
    case collectingCity
    case completing
}