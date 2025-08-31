import SwiftUI
import MapKit

struct GroupChatView: View {
    let group: EventGroupModel
    let event: EventModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = GroupChatViewModel()
    @State private var messageText = ""
    @State private var showingTickets = false
    @State private var showingSurvey = false
    @State private var showingLocationPicker = false
    @State private var showingImagePicker = false
    @State private var showingGallery = false
    
    var body: some View {
        NavigationContainer {
            VStack {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Button("Close") {
                            dismiss()
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text(group.name)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text("\(event.title)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Survey") {
                            showingSurvey = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // Group info bar
                    HStack {
                        HStack(spacing: -4) {
                            ForEach(Array(group.members.prefix(5)), id: \.id) { member in
                                Circle()
                                    .fill(colorForCountry(member.countryOfBirth ?? ""))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text(countryFlag(member.countryOfBirth ?? ""))
                                            .font(.caption2)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                            }
                        }
                        
                        Text("\(group.members.count) members • \(group.discountPercentage) discount")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button {
                            showingTickets = true
                        } label: {
                            HStack {
                                Image(systemName: "ticket")
                                Text("Tickets")
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message, currentUserId: "user_gustavo")
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                
                // Message input
                VStack(spacing: 8) {
                    // Action buttons
                    HStack {
                        Button {
                            showingLocationPicker = true
                        } label: {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                        }
                        
                        Button {
                            showingImagePicker = true
                        } label: {
                            Image(systemName: "camera")
                                .foregroundColor(.blue)
                        }
                        
                        Button {
                            showingTickets = true
                        } label: {
                            Image(systemName: "ticket")
                                .foregroundColor(.blue)
                        }
                        
                        Button {
                            showingGallery = true
                        } label: {
                            Image(systemName: "photo.stack")
                                .foregroundColor(.purple)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Text input
                    HStack {
                        TextField("Type a message...", text: $messageText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(1...4)
                        
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(messageText.isEmpty ? Color.gray : Color.blue)
                                .clipShape(Circle())
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingTickets) {
            TicketsView(group: group, event: event)
        }
        .sheet(isPresented: $showingSurvey) {
            PostEventSurveyView(orderId: group.id)
        }
        .sheet(isPresented: $showingGallery) {
            GalleryView(eventTitle: event.title)
        }
        .task {
            await viewModel.loadMessages(for: group.id)
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let message = GroupChatMessage(
            groupId: group.id,
            userId: "user_gustavo",
            userName: "Gustavo Polania",
            message: messageText,
            messageType: .text
        )
        
        viewModel.sendMessage(message)
        messageText = ""
    }
    
    private func colorForCountry(_ country: String) -> Color {
        switch country {
        case "China": return .red
        case "India": return .orange
        case "Colombia": return .yellow
        case "Lebanon": return .green
        case "Italy": return .green
        case "France": return .blue
        case "Japan": return .red
        case "Australia": return .blue
        case "Poland": return .red
        case "Brazil": return .green
        case "Nigeria": return .green
        case "South Korea": return .blue
        default: return .gray
        }
    }
    
    private func countryFlag(_ country: String) -> String {
        switch country {
        case "China": return "🇨🇳"
        case "India": return "🇮🇳"
        case "Colombia": return "🇨🇴"
        case "Lebanon": return "🇱🇧"
        case "Italy": return "🇮🇹"
        case "France": return "🇫🇷"
        case "Japan": return "🇯🇵"
        case "Australia": return "🇦🇺"
        case "Poland": return "🇵🇱"
        case "Brazil": return "🇧🇷"
        case "Nigeria": return "🇳🇬"
        case "South Korea": return "🇰🇷"
        default: return "🌍"
        }
    }
}

@MainActor
class GroupChatViewModel: ObservableObject {
    @Published var messages: [GroupChatMessage] = []
    @Published var isLoading = false
    
    func loadMessages(for groupId: String) async {
        isLoading = true
        messages = MockDatabaseManager.shared.getChatMessages(groupId: groupId)
        isLoading = false
    }
    
    func sendMessage(_ message: GroupChatMessage) {
        MockDatabaseManager.shared.sendMessage(message: message)
        messages.append(message)
    }
}

struct MessageBubble: View {
    let message: GroupChatMessage
    let currentUserId: String
    
    var isCurrentUser: Bool {
        message.userId == currentUserId
    }
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser && message.messageType != .system {
                    Text(message.userName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Group {
                    switch message.messageType {
                    case .text:
                        Text(message.message)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                isCurrentUser ? Color.blue : Color(.systemGray5)
                            )
                            .foregroundColor(
                                isCurrentUser ? .white : .primary
                            )
                            .cornerRadius(12)
                    
                    case .system:
                        Text(message.message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    
                    case .ticket:
                        HStack {
                            Image(systemName: "ticket")
                            Text("Ticket shared")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(12)
                    
                    case .location:
                        HStack {
                            Image(systemName: "location")
                            Text("Location shared")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(12)
                    
                    case .image:
                        HStack {
                            Image(systemName: "photo")
                            Text("Photo shared")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
    
    private func formatTime(_ timestamp: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = formatter.date(from: timestamp) else { return "" }
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: date)
    }
}

struct TicketsView: View {
    let group: EventGroupModel
    let event: EventModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TicketsViewModel()
    @State private var showingPaymentSuccess = false
    
    var body: some View {
        NavigationContainer {
            VStack {
                // Header
                HStack {
                    Text("Group Tickets")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button("Close") {
                        dismiss()
                    }
                }
                .padding()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.tickets) { ticket in
                            TicketCard(ticket: ticket)
                        }
                    }
                    .padding()
                }
                
                // Payment summary and button
                if !viewModel.tickets.isEmpty {
                    VStack(spacing: 16) {
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total for \(viewModel.tickets.count) tickets")
                                    .font(.headline)
                                
                                Text("With \(Int(group.discountPercentage))% diversity discount")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("$\(Int(viewModel.totalAmount))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Text("was $\(Int(viewModel.originalAmount))")
                                    .font(.caption)
                                    .strikethrough()
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button {
                            processPayment()
                        } label: {
                            HStack {
                                Image(systemName: "creditcard")
                                Text("Pay Now")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isProcessingPayment)
                        
                        if viewModel.isProcessingPayment {
                            ProgressView("Processing payment...")
                                .padding()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.loadTickets(for: group.id)
        }
        .alert("Payment Successful!", isPresented: $showingPaymentSuccess) {
            Button("Great!") {
                dismiss()
            }
        } message: {
            Text("Your tickets have been confirmed. Check your email for details!")
        }
    }
    
    private func processPayment() {
        Task {
            await viewModel.processPayment()
            showingPaymentSuccess = true
        }
    }
}

struct TicketCard: View {
    let ticket: EventTicket
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(ticket.eventTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(ticket.userName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("$\(Int(ticket.finalPrice))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("was $\(Int(ticket.price))")
                        .font(.caption)
                        .strikethrough()
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Seat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ticket.seatNumber)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Section")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ticket.section)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDate(ticket.eventDate))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        guard let date = formatter.date(from: dateString) else { return dateString }
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

@MainActor
class TicketsViewModel: ObservableObject {
    @Published var tickets: [EventTicket] = []
    @Published var isProcessingPayment = false
    
    var totalAmount: Double {
        tickets.reduce(0) { $0 + $1.finalPrice }
    }
    
    var originalAmount: Double {
        tickets.reduce(0) { $0 + $1.price }
    }
    
    func loadTickets(for groupId: String) async {
        tickets = MockDatabaseManager.shared.getGroupTickets(groupId: groupId)
    }
    
    func processPayment() async {
        isProcessingPayment = true
        
        // Simulate payment processing delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // In a real app, this would process the payment with a payment gateway
        // For now, we'll just simulate success
        
        isProcessingPayment = false
    }
}