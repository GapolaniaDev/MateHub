import SwiftUI

struct PostEventSurveyView: View {
    let orderId: String
    @StateObject private var viewModel = SurveyViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestion = 0
    
    let questions = SurveyQuestions.allQuestions
    
    var body: some View {
        NavigationContainer {
            if viewModel.showingCompletion {
                SurveyCompletionView(
                    cohesionScore: viewModel.socialCohesionScore,
                    averageScore: viewModel.socialCohesionScore,
                    onViewTrophies: {
                        // Primero cerrar todas las ventanas modales (chat, eventos, etc.)
                        NotificationCenter.default.post(name: NSNotification.Name("DismissAllModals"), object: nil)
                        // Luego navegar a trofeos
                        NotificationCenter.default.post(name: NSNotification.Name("NavigateToTrophies"), object: nil)
                        // Finalmente cerrar esta ventana
                        dismiss()
                    },
                    onContinue: {
                        // Solo cerrar cuando el usuario presione Continue
                        dismiss()
                    },
                    eventTitle: getEventTitle()
                )
            } else {
                VStack(spacing: 0) {
                    // Progress bar
                    ProgressView(value: Double(currentQuestion), total: Double(questions.count - 1))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding()
                    
                    // Question content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Question number
                            HStack {
                                Text("Question \(currentQuestion + 1) of \(questions.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            
                            // Question view
                            questionView(for: currentQuestion)
                        }
                        .padding()
                    }
                
                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentQuestion > 0 {
                            Button("Previous") {
                                currentQuestion -= 1
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Spacer()
                        
                        if currentQuestion < questions.count - 1 {
                            Button("Next") {
                                currentQuestion += 1
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!canProceed)
                        } else {
                            Button("Finish") {
                                Task {
                                    await viewModel.submitSurvey(orderId: orderId)
                                    // No cerrar automáticamente, dejar que el usuario presione Continue
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!canFinish)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Post-Event Survey")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    @ViewBuilder
    private func questionView(for index: Int) -> some View {
        let question = questions[index]
        
        LikertQuestionView(
            question: question,
            selection: binding(for: index)
        )
    }
    
    private func binding(for index: Int) -> Binding<Int?> {
        switch index {
        case 0: return $viewModel.q1
        case 1: return $viewModel.q2
        case 2: return $viewModel.q3
        case 3: return $viewModel.q4
        case 4: return $viewModel.q5
        default: return .constant(nil)
        }
    }
    
    private var canProceed: Bool {
        return binding(for: currentQuestion).wrappedValue != nil
    }
    
    private var canFinish: Bool {
        return viewModel.canSubmit
    }
    
    private func getEventTitle() -> String {
        // In a real app, this would fetch the event title from the orderId
        // For now, returning a generic title based on the orderId
        switch orderId {
        case "group_1": return "Adelaide Multicultural Food Festival"
        case "group_2": return "University Innovation Expo"
        case "group_3": return "Barossa Vintage Festival"
        case "group_4": return "Chinese New Year Celebrations"
        case "group_5": return "AFL Finals - Adelaide Oval"
        default: return "Community Event"
        }
    }
}

struct LikertQuestionView: View {
    let question: SurveyQuestion
    @Binding var selection: Int?
    
    let options = [
        (1, "Very Poor", "😞"),
        (2, "Poor", "😐"),
        (3, "Average", "😊"),
        (4, "Good", "😄"),
        (5, "Excellent", "🤩")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question.text)
                .font(.title2)
                .fontWeight(.semibold)
            
            if let subtitle = question.subtitle {
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                ForEach(options, id: \.0) { value, label, emoji in
                    Button {
                        selection = value
                    } label: {
                        HStack(spacing: 12) {
                            Text(emoji)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(label)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Text("\(value)/5")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selection == value {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Circle()
                                    .stroke(Color.gray, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .foregroundColor(.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selection == value ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                .stroke(selection == value ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct SurveyQuestion {
    let id: String
    let text: String
    let subtitle: String?
    let type: QuestionType
    
    enum QuestionType {
        case likert
        case text
        case boolean
        case textWithAudio
    }
}

struct SurveyQuestions {
    static let allQuestions = [
        SurveyQuestion(
            id: "q1",
            text: "How comfortable did you feel interacting with the people in your group?",
            subtitle: "Rate your comfort level connecting with your group members.",
            type: .likert
        ),
        SurveyQuestion(
            id: "q2",
            text: "How welcome and accepted did you feel by your group members?",
            subtitle: "Evaluate how included you felt within the group dynamic.",
            type: .likert
        ),
        SurveyQuestion(
            id: "q3",
            text: "How much did you learn about other cultures from your group members?",
            subtitle: "Rate the cultural exchange and learning experience with the group.",
            type: .likert
        ),
        SurveyQuestion(
            id: "q4",
            text: "How likely are you to stay in contact with someone from this group?",
            subtitle: "Measure the personal connections formed with group members.",
            type: .likert
        ),
        SurveyQuestion(
            id: "q5",
            text: "How much did this group experience strengthen your sense of community?",
            subtitle: "Rate how the group interaction enhanced your feeling of belonging.",
            type: .likert
        )
    ]
}

@MainActor
class SurveyViewModel: ObservableObject {
    @Published var q1: Int? = nil
    @Published var q2: Int? = nil
    @Published var q3: Int? = nil
    @Published var q4: Int? = nil
    @Published var q5: Int? = nil
    
    @Published var isRecording: Bool = false
    @Published var isProcessing: Bool = false
    @Published var showingCompletion: Bool = false
    
    func submitSurvey(orderId: String) async {
        let survey = SurveyModel(
            orderId: orderId,
            q1: q1,
            q2: q2,
            q3: q3,
            q4: q4,
            q5: q5
        )
        
        MockDatabaseManager.shared.saveSurvey(survey)
        _ = MockDatabaseManager.shared.unlockSurveyTrophy(userId: "user_gustavo")
        
        // Simular delay de red
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mostrar la pantalla de congratulación
        showingCompletion = true
    }
    
    var canSubmit: Bool {
        return q1 != nil && q2 != nil && q3 != nil && q4 != nil && q5 != nil
    }
    
    var socialCohesionScore: Double {
        guard let q1 = q1, let q2 = q2, let q3 = q3, let q4 = q4, let q5 = q5 else { return 0.0 }
        return Double(q1 + q2 + q3 + q4 + q5) / 5.0
    }
}