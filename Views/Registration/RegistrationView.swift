import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @State private var currentStep = 0
    @State private var showingWelcome = false
    @Binding var isPresented: Bool
    @Binding var currentUser: UserModel?
    
    var body: some View {
        NavigationContainer {
            VStack {
                // Progress indicator
                ProgressView(value: Double(currentStep), total: 5.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding()
                
                // Step indicator
                HStack(spacing: 8) {
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom)
                
                // Step content
                TabView(selection: $currentStep) {
                    NameStep(viewModel: viewModel)
                        .tag(0)
                    
                    EmailStep(viewModel: viewModel)
                        .tag(1)
                    
                    PhoneStep(viewModel: viewModel)
                        .tag(2)
                    
                    BackgroundInfoStep(viewModel: viewModel)
                        .tag(3)
                    
                    InterestsSelectionStep(viewModel: viewModel)
                        .tag(4)
                    
                    SummaryStep(viewModel: viewModel)
                        .tag(5)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentStep < 5 {
                        Button("Next") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.canProceedFromStep(currentStep))
                    } else {
                        Button("Complete Registration") {
                            Task {
                                if await viewModel.completeRegistration() {
                                    showingWelcome = true
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.canCompleteRegistration || viewModel.isLoading)
                    }
                }
                .padding()
            }
            .navigationTitle(stepTitle(currentStep))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingWelcome) {
            WelcomeCompleteView {
                currentUser = viewModel.user
                showingWelcome = false
                isPresented = false
            }
        }
    }
    
    private func stepTitle(_ step: Int) -> String {
        switch step {
        case 0: return "Your Name"
        case 1: return "Email Address"
        case 2: return "Phone Number"
        case 3: return "Background"
        case 4: return "Interests"
        case 5: return "Summary"
        default: return "Registration"
        }
    }
}

// Step 1: Name
struct NameStep: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("What's your name?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This is how other people will see you in the app")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                TextField("Enter your full name", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
                    .textContentType(.name)
                    .autocapitalization(.words)
                
                if !viewModel.name.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Looks good!")
                            .foregroundColor(.green)
                    }
                    .font(.subheadline)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// Step 2: Email
struct EmailStep: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("What's your email?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("We'll use this to send you event updates and notifications")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                TextField("Enter your email address", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                if !viewModel.email.isEmpty {
                    HStack {
                        if viewModel.email.contains("@") && viewModel.email.contains(".") {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Valid email address")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                            Text("Please enter a valid email")
                                .foregroundColor(.orange)
                        }
                    }
                    .font(.subheadline)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// Step 3: Phone
struct PhoneStep: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Phone number")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Optional - helps event organizers contact you if needed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                TextField("Enter your phone number", text: $viewModel.phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                
                if !viewModel.phone.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Thank you!")
                            .foregroundColor(.green)
                    }
                    .font(.subheadline)
                }
                
                Button("Skip this step") {
                    // Will be handled by the parent view
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

// Step 4: Background Information
struct BackgroundInfoStep: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "globe.americas")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Tell us about yourself")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This information helps us calculate diversity scores and find you better discounts. It's completely optional.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                
                Group {
                    // Age
                    HStack {
                        Text("Age")
                            .font(.headline)
                        Spacer()
                        TextField("Age", value: $viewModel.age, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                            .keyboardType(.numberPad)
                    }
                    
                    // Gender selection
                    VStack(alignment: .leading) {
                        Text("Gender")
                            .font(.headline)
                        
                        Picker("Gender", selection: $viewModel.gender) {
                            Text("Select").tag("")
                            ForEach(EnhancedDataConstants.genders, id: \.self) { gender in
                                Text(gender).tag(gender)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Background
                    VStack(alignment: .leading) {
                        Text("Background")
                            .font(.headline)
                        
                        Picker("Background", selection: $viewModel.countryOfBirth) {
                            Text("Select").tag("")
                            ForEach(EnhancedDataConstants.countries, id: \.self) { country in
                                Text(country).tag(country)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Language at home
                    VStack(alignment: .leading) {
                        Text("Language at home")
                            .font(.headline)
                        
                        Picker("Language at home", selection: $viewModel.languageAtHome) {
                            Text("Select").tag("")
                            ForEach(EnhancedDataConstants.languages, id: \.self) { language in
                                Text(language).tag(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // State
                    VStack(alignment: .leading) {
                        Text("State/Territory")
                            .font(.headline)
                        
                        Picker("State", selection: $viewModel.state) {
                            Text("Select").tag("")
                            ForEach(EnhancedDataConstants.australianStates, id: \.self) { state in
                                Text(state).tag(state)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Special demographics
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Additional information (optional)")
                            .font(.headline)
                        
                        Toggle("First Nations", isOn: $viewModel.isFirstNations)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        Toggle("Person with disability", isOn: $viewModel.hasDisability)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                }
            }
            .padding()
        }
    }
}

struct InterestsSelectionStep: View {
    @ObservedObject var viewModel: RegistrationViewModel
    @State private var availableInterests: [InterestModel] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Select your interests")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("Choose the categories that interest you most to personalize your experience.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(availableInterests) { interest in
                        InterestCard(
                            interest: interest,
                            isSelected: viewModel.selectedInterests.contains(interest.id)
                        ) {
                            viewModel.toggleInterest(interest.id)
                        }
                    }
                }
                
                if !viewModel.selectedInterests.isEmpty {
                    Text("Selected \(viewModel.selectedInterests.count) interests")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.top)
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .onAppear {
            loadInterests()
        }
    }
    
    private func loadInterests() {
        // Load interests from database
        availableInterests = [
            // Arts
            InterestModel(id: "int_culture", name: "Culture", slug: "culture", category: "Arts"),
            InterestModel(id: "int_music", name: "Music", slug: "music", category: "Arts"),
            InterestModel(id: "int_art", name: "Visual Arts", slug: "visual-arts", category: "Arts"),
            InterestModel(id: "int_dance", name: "Dance", slug: "dance", category: "Arts"),
            InterestModel(id: "int_theatre", name: "Theatre", slug: "theatre", category: "Arts"),
            InterestModel(id: "int_film", name: "Film & Cinema", slug: "film", category: "Arts"),
            InterestModel(id: "int_photography", name: "Photography", slug: "photography", category: "Arts"),
            
            // Leisure
            InterestModel(id: "int_sports", name: "Sports", slug: "sports", category: "Leisure"),
            InterestModel(id: "int_food", name: "Food & Festivals", slug: "food", category: "Leisure"),
            InterestModel(id: "int_travel", name: "Travel", slug: "travel", category: "Leisure"),
            InterestModel(id: "int_fitness", name: "Fitness", slug: "fitness", category: "Leisure"),
            InterestModel(id: "int_nature", name: "Nature & Outdoors", slug: "nature", category: "Leisure"),
            InterestModel(id: "int_gaming", name: "Gaming", slug: "gaming", category: "Leisure"),
            
            // Education
            InterestModel(id: "int_books", name: "Books & Reading", slug: "books", category: "Education"),
            InterestModel(id: "int_science", name: "Science", slug: "science", category: "Education"),
            InterestModel(id: "int_tech", name: "Technology", slug: "tech", category: "Education"),
            InterestModel(id: "int_history", name: "History", slug: "history", category: "Education"),
            InterestModel(id: "int_languages", name: "Languages", slug: "languages", category: "Education"),
            InterestModel(id: "int_workshops", name: "Workshops", slug: "workshops", category: "Education"),
            
            // Community
            InterestModel(id: "int_volunteer", name: "Volunteering", slug: "volunteer", category: "Community"),
            InterestModel(id: "int_networking", name: "Networking", slug: "networking", category: "Community"),
            InterestModel(id: "int_social", name: "Social Events", slug: "social", category: "Community"),
            InterestModel(id: "int_family", name: "Family Activities", slug: "family", category: "Community"),
            
            // Health
            InterestModel(id: "int_wellness", name: "Wellness", slug: "wellness", category: "Health"),
            InterestModel(id: "int_mental", name: "Mental Health", slug: "mental-health", category: "Health"),
            InterestModel(id: "int_meditation", name: "Meditation", slug: "meditation", category: "Health")
        ]
    }
}

// Step 6: Summary
struct SummaryStep: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Review your information")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Make sure everything looks correct before completing your registration")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    SummaryRow(title: "Name", value: viewModel.name)
                    SummaryRow(title: "Email", value: viewModel.email)
                    
                    if !viewModel.phone.isEmpty {
                        SummaryRow(title: "Phone", value: viewModel.phone)
                    }
                    
                    if let age = viewModel.age {
                        SummaryRow(title: "Age", value: "\(age)")
                    }
                    
                    if !viewModel.gender.isEmpty {
                        SummaryRow(title: "Gender", value: viewModel.gender)
                    }
                    
                    if !viewModel.countryOfBirth.isEmpty {
                        SummaryRow(title: "Background", value: viewModel.countryOfBirth)
                    }
                    
                    if !viewModel.languageAtHome.isEmpty {
                        SummaryRow(title: "Language at home", value: viewModel.languageAtHome)
                    }
                    
                    if !viewModel.state.isEmpty {
                        SummaryRow(title: "State/Territory", value: viewModel.state)
                    }
                    
                    if !viewModel.selectedInterests.isEmpty {
                        SummaryRow(title: "Interests", value: "\(viewModel.selectedInterests.count) selected")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                if viewModel.isLoading {
                    ProgressView("Creating your account...")
                        .padding()
                }
            }
            .padding()
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// Welcome Complete View
struct WelcomeCompleteView: View {
    let onComplete: () -> Void
    @State private var showingAnimation = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                // Animated welcome icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .scaleEffect(showingAnimation ? 1.0 : 0.8)
                        .opacity(showingAnimation ? 1.0 : 0.8)
                    
                    Text("🎉")
                        .font(.system(size: 60))
                        .scaleEffect(showingAnimation ? 1.2 : 1.0)
                }
                .animation(.bouncy(duration: 1.0), value: showingAnimation)
                
                VStack(spacing: 12) {
                    Text("Welcome to MateHub!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("You're all set to start connecting with your community and building bridges across cultures.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "map.fill")
                            .foregroundColor(.blue)
                        Text("Discover events near you")
                            .font(.headline)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.green)
                        Text("Join diverse groups")
                            .font(.headline)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "percent")
                            .foregroundColor(.orange)
                        Text("Get discounts for diversity")
                            .font(.headline)
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Button {
                    onComplete()
                } label: {
                    Text("Start Exploring")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.bouncy(duration: 1.0).delay(0.3)) {
                showingAnimation = true
            }
        }
    }
}


@MainActor
class RegistrationViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var age: Int? = nil
    @Published var gender: String = ""
    @Published var countryOfBirth: String = ""
    @Published var languageAtHome: String = ""
    @Published var state: String = ""
    @Published var isFirstNations: Bool = false
    @Published var hasDisability: Bool = false
    @Published var selectedInterests: Set<String> = []
    @Published var isLoading: Bool = false
    
    func canProceedFromStep(_ step: Int) -> Bool {
        switch step {
        case 0: // Name step
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1: // Email step
            return isValidEmail(email)
        case 2: // Phone step (optional, always can proceed)
            return true
        case 3: // Background step (optional, always can proceed)
            return true
        case 4: // Interests step
            return !selectedInterests.isEmpty
        case 5: // Summary step
            return canCompleteRegistration
        default:
            return false
        }
    }
    
    var canCompleteRegistration: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               isValidEmail(email) &&
               !selectedInterests.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailTrimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return emailTrimmed.contains("@") && emailTrimmed.contains(".")
    }
    
    var user: UserModel {
        UserModel(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.isEmpty ? nil : phone.trimmingCharacters(in: .whitespacesAndNewlines),
            age: age,
            gender: gender.isEmpty ? nil : gender,
            countryOfBirth: countryOfBirth.isEmpty ? nil : countryOfBirth,
            languageAtHome: languageAtHome.isEmpty ? nil : languageAtHome,
            state: state.isEmpty ? nil : state,
            isFirstNations: isFirstNations,
            hasDisability: hasDisability
        )
    }
    
    func toggleInterest(_ interestId: String) {
        if selectedInterests.contains(interestId) {
            selectedInterests.remove(interestId)
        } else {
            selectedInterests.insert(interestId)
        }
    }
    
    func completeRegistration() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Create user in database
        let success = MockDatabaseManager.shared.createUser(user)
        
        if success {
            // Save user interests
            // This would be implemented to save the user-interest relationships
            print("User registered successfully with \(selectedInterests.count) interests")
            print("User phone: \(phone.isEmpty ? "Not provided" : phone)")
        }
        
        return success
    }
}