import SwiftUI
import MapKit
import Combine

struct EnhancedMapView: View {
    @StateObject private var viewModel = EnhancedMapViewModel()
    @State private var showingEventDetail = false
    @State private var selectedEvent: EventModel?
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            // Full-screen map
            Map(coordinateRegion: $viewModel.region, 
                annotationItems: viewModel.filteredEvents) { event in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: event.lat ?? 0, 
                    longitude: event.lng ?? 0
                )) {
                    EnhancedEventPin(event: event) {
                        selectedEvent = event
                        showingEventDetail = true
                    }
                }
            }
            .ignoresSafeArea()
            
            // Search bar overlay
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search events or city...", text: $searchText)
                            .onChange(of: searchText) { oldValue, newValue in
                                Task { @MainActor in
                                    viewModel.searchQuery = newValue
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                viewModel.searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Filter button
                    Button {
                        viewModel.showingFilters.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
                
                // Quick stats at bottom
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewModel.filteredEvents.count) events")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.centerOnUserLocation()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showingEventDetail) {
            if let event = selectedEvent {
                EventDetailSheet(event: event)
                    .presentationDragIndicator(.visible)
            } else {
                Text("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            }
        }
        .sheet(isPresented: $viewModel.showingFilters) {
            FilterSheet(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadEvents()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissAllModals"))) { _ in
            showingEventDetail = false
            viewModel.showingFilters = false
        }
    }
}

struct EnhancedEventPin: View {
    let event: EventModel
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Price badge
            Text("$\(Int(event.price))")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(event.sponsored ? Color.green : Color.blue)
                .cornerRadius(8)
            
            // Category icon
            Image(systemName: iconForCategory(event.category))
                .font(.title2)
                .foregroundColor(.white)
                .padding(8)
                .background(categoryColor(event.category))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            // Pin tail
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(categoryColor(event.category))
                .offset(y: -2)
        }
        .shadow(radius: 4)
        .onTapGesture {
            onTap()
        }
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
    
    private func categoryColor(_ category: String) -> Color {
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
}

struct EventDetailSheet: View {
    let event: EventModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var groupsViewModel = EventGroupsViewModel()
    
    var body: some View {
        NavigationContainer {
            VStack {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("\(event.city), \(event.state)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Event info card
                        EventInfoCard(event: event)
                        
                        // Suggested groups section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Join a Diverse Group & Save!")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            Text("Connect with people from different cultures and get group discounts")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            if groupsViewModel.isLoading {
                                ProgressView("Loading groups...")
                                    .padding()
                                    .onAppear {
                                        print("DEBUG: Showing loading view")
                                    }
                            } else if groupsViewModel.suggestedGroups.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "person.3")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("No groups available")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Be the first to create a group for this event!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(groupsViewModel.suggestedGroups) { group in
                                        GroupCard(
                                            group: group,
                                            event: event,
                                            onJoinGroup: { groupId in
                                                Task {
                                                    await groupsViewModel.joinGroup(groupId: groupId, userId: "user_gustavo")
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .task(id: event.id) {
            print("DEBUG: EventDetailSheet task triggered for event: \(event.id)")
            await groupsViewModel.loadGroups(for: event.id)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        guard let date = formatter.date(from: dateString) else { return dateString }
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EnhancedAttendeeRow: View {
    @State private var attendee: AttendeeModel
    let onUpdate: (AttendeeModel) -> Void
    let onDelete: () -> Void
    
    init(attendee: AttendeeModel, onUpdate: @escaping (AttendeeModel) -> Void, onDelete: @escaping () -> Void) {
        self._attendee = State(initialValue: attendee)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Basic info
            HStack(spacing: 12) {
                TextField("Name", text: Binding(
                    get: { attendee.name ?? "" },
                    set: { attendee.name = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 100)
                
                TextField("Age", value: Binding(
                    get: { attendee.age },
                    set: { attendee.age = $0 }
                ), formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 60)
                .keyboardType(.numberPad)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // Demographics
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                CustomPicker(
                    title: "Gender",
                    selection: Binding(
                        get: { attendee.gender ?? "" },
                        set: { attendee.gender = $0.isEmpty ? nil : $0 }
                    ),
                    options: EnhancedDataConstants.genders
                )
                
                CustomPicker(
                    title: "State",
                    selection: Binding(
                        get: { attendee.state ?? "" },
                        set: { attendee.state = $0.isEmpty ? nil : $0 }
                    ),
                    options: EnhancedDataConstants.australianStates
                )
                
                CustomPicker(
                    title: "Country",
                    selection: Binding(
                        get: { attendee.countryOfBirth ?? "" },
                        set: { attendee.countryOfBirth = $0.isEmpty ? nil : $0 }
                    ),
                    options: EnhancedDataConstants.countries
                )
                
                CustomPicker(
                    title: "Language",
                    selection: Binding(
                        get: { attendee.languageAtHome ?? "" },
                        set: { attendee.languageAtHome = $0.isEmpty ? nil : $0 }
                    ),
                    options: EnhancedDataConstants.languages
                )
            }
            
            // Special demographics
            HStack {
                Toggle("First Nations", isOn: $attendee.isFirstNations)
                    .font(.caption)
                
                Spacer()
                
                Toggle("Disability", isOn: $attendee.hasDisability)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .onChange(of: attendee) { oldValue, newValue in
            Task { @MainActor in
                onUpdate(newValue)
            }
        }
    }
}

struct CustomPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        Menu {
            Button("Not specified") {
                selection = ""
            }
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selection = option
                }
            }
        } label: {
            HStack {
                Text(selection.isEmpty ? title : selection)
                    .foregroundColor(selection.isEmpty ? .secondary : .primary)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.systemBackground))
            .cornerRadius(6)
        }
    }
}

struct DiversityMeterCard: View {
    let attendees: [AttendeeModel]
    
    var diversityScore: Int {
        EnhancedDiversityCalculator.calculateDiversityIndex(attendees: attendees)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Multicultural Diversity Index")
                    .font(.headline)
                Spacer()
                Text("\(diversityScore)/100")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(meterColor)
            }
            
            // Progress bar
            ProgressView(value: Double(diversityScore), total: 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: meterColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("Includes diversity by: country, language, gender, age, state, First Nations and disability")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
    
    private var meterColor: Color {
        switch diversityScore {
        case 85...100: return .green
        case 70...84: return Color(red: 0.8, green: 0.9, blue: 0.2)
        case 50...69: return .orange
        case 30...49: return .red
        default: return .gray
        }
    }
}

struct PurchaseSummaryCard: View {
    let event: EventModel
    let attendees: [AttendeeModel]
    let onPurchase: () -> Void
    
    private var diversityScore: Int {
        EnhancedDiversityCalculator.calculateDiversityIndex(attendees: attendees)
    }
    
    private var discountRate: Double {
        EnhancedDiversityCalculator.discountRate(for: diversityScore)
    }
    
    private var baseTotal: Double {
        event.price * Double(attendees.count)
    }
    
    private var discountAmount: Double {
        baseTotal * discountRate
    }
    
    private var finalTotal: Double {
        baseTotal - discountAmount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Purchase Summary")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Base (\(attendees.count)×)")
                    Spacer()
                    Text(formatCurrency(baseTotal))
                }
                
                HStack {
                    Text("Discount (\(Int(discountRate * 100))%)")
                    Spacer()
                    Text("-\(formatCurrency(discountAmount))")
                        .foregroundColor(.green)
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text(formatCurrency(finalTotal))
                        .fontWeight(.bold)
                        .font(.title3)
                }
            }
            
            Button(action: onPurchase) {
                Text("Confirm Purchase")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(attendees.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(attendees.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

@MainActor
class AttendeeManager: ObservableObject {
    @Published var attendees: [AttendeeModel] = []
    
    init() {
        // Start with one attendee (the user)
        attendees = [AttendeeModel(name: "You")]
    }
    
    func addAttendee() {
        Task { @MainActor in
            attendees.append(AttendeeModel())
        }
    }
    
    func removeAttendee(at index: Int) {
        guard index > 0 && index < attendees.count else { return } // Don't remove first attendee
        Task { @MainActor in
            attendees.remove(at: index)
        }
    }
    
    func updateAttendee(at index: Int, with attendee: AttendeeModel) {
        guard index < attendees.count else { return }
        Task { @MainActor in
            attendees[index] = attendee
        }
    }
}

struct PurchaseFormSheet: View {
    let event: EventModel
    @StateObject private var attendeeManager = AttendeeManager()
    @Environment(\.dismiss) private var dismiss
    @State private var showingConfirmation = false
    
    
    var discountRate: Double {
        let otherPeople = attendeeManager.attendees.count - 1 // Exclude the user
        switch otherPeople {
        case 1: return 0.15 // 15%
        case 2: return 0.20 // 20%
        case 3...: return 0.25 // 25%
        default: return 0.0 // 0%
        }
    }
    
    var baseTotal: Double {
        event.price * Double(attendeeManager.attendees.count)
    }
    
    var discountAmount: Double {
        baseTotal * discountRate
    }
    
    var finalTotal: Double {
        baseTotal - discountAmount
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Purchase Tickets")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Event info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("\(event.city), \(event.state)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("$\(Int(event.price)) per person")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Group section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Your Group")
                                .font(.headline)
                            Spacer()
                            Text("\(attendeeManager.attendees.count) people")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        ForEach(Array(attendeeManager.attendees.enumerated()), id: \.element.id) { index, attendee in
                            AttendeeFormRow(
                                attendee: attendee,
                                onUpdate: { updated in
                                    attendeeManager.updateAttendee(at: index, with: updated)
                                },
                                onDelete: index > 0 ? {
                                    attendeeManager.removeAttendee(at: index)
                                } : nil
                            )
                        }
                        
                        Button(action: attendeeManager.addAttendee) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Person")
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Diversity meter
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Group Size")
                                .font(.headline)
                            Spacer()
                            Text("\(attendeeManager.attendees.count) people")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        ProgressView(value: Double(attendeeManager.attendees.count - 1), total: 3.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: discountColor))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                        
                        Text("Invite friends to get up to 25% discount!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Price summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Price Summary")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Base (\(attendeeManager.attendees.count)×)")
                                Spacer()
                                Text(formatCurrency(baseTotal))
                            }
                            
                            if discountRate > 0 {
                                HStack {
                                    Text("Group Discount (\(Int(discountRate * 100))%)")
                                    Spacer()
                                    Text("-\(formatCurrency(discountAmount))")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .fontWeight(.bold)
                                Spacer()
                                Text(formatCurrency(finalTotal))
                                    .fontWeight(.bold)
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Purchase button
                    Button {
                        showingConfirmation = true
                    } label: {
                        Text("Confirm Purchase")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(attendeeManager.attendees.isEmpty ? Color.gray : Color.green)
                            .cornerRadius(12)
                    }
                    .disabled(attendeeManager.attendees.isEmpty)
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .alert("Purchase Confirmed", isPresented: $showingConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your tickets have been purchased for \(formatCurrency(finalTotal))")
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private var discountColor: Color {
        let otherPeople = attendeeManager.attendees.count - 1
        switch otherPeople {
        case 1: return .orange
        case 2: return .blue
        case 3...: return .green
        default: return .gray
        }
    }
}

struct AttendeeFormRow: View {
    @State private var attendee: AttendeeModel
    let onUpdate: (AttendeeModel) -> Void
    let onDelete: (() -> Void)?
    
    init(attendee: AttendeeModel, onUpdate: @escaping (AttendeeModel) -> Void, onDelete: (() -> Void)? = nil) {
        self._attendee = State(initialValue: attendee)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                TextField("Name", text: Binding(
                    get: { attendee.name ?? "" },
                    set: { attendee.name = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Age", value: Binding(
                    get: { attendee.age },
                    set: { attendee.age = $0 }
                ), formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 60)
                .keyboardType(.numberPad)
                
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                Menu {
                    Button("Not specified") { attendee.gender = nil }
                    ForEach(EnhancedDataConstants.genders, id: \.self) { gender in
                        Button(gender) { attendee.gender = gender }
                    }
                } label: {
                    HStack {
                        Text(attendee.gender ?? "Gender")
                            .foregroundColor(attendee.gender == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(6)
                }
                
                Menu {
                    Button("Not specified") { attendee.state = nil }
                    ForEach(EnhancedDataConstants.australianStates, id: \.self) { state in
                        Button(state) { attendee.state = state }
                    }
                } label: {
                    HStack {
                        Text(attendee.state ?? "State")
                            .foregroundColor(attendee.state == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(6)
                }
                
                Menu {
                    Button("Not specified") { attendee.countryOfBirth = nil }
                    ForEach(EnhancedDataConstants.countries, id: \.self) { country in
                        Button(country) { attendee.countryOfBirth = country }
                    }
                } label: {
                    HStack {
                        Text(attendee.countryOfBirth ?? "Country")
                            .foregroundColor(attendee.countryOfBirth == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(6)
                }
                
                Menu {
                    Button("Not specified") { attendee.languageAtHome = nil }
                    ForEach(EnhancedDataConstants.languages, id: \.self) { language in
                        Button(language) { attendee.languageAtHome = language }
                    }
                } label: {
                    HStack {
                        Text(attendee.languageAtHome ?? "Language")
                            .foregroundColor(attendee.languageAtHome == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(6)
                }
            }
            
            HStack {
                Toggle("First Nations", isOn: $attendee.isFirstNations)
                    .font(.caption)
                
                Spacer()
                
                Toggle("Has Disability", isOn: $attendee.hasDisability)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .onChange(of: attendee) { oldValue, newValue in
            onUpdate(newValue)
        }
    }
}

// MARK: - Event Groups System

@MainActor
class EventGroupsViewModel: ObservableObject {
    @Published var suggestedGroups: [EventGroupModel] = []
    @Published var isLoading = false
    @Published var selectedGroupId: String?
    @Published var showingGroupChat = false
    
    private var currentEventId: String?
    
    func loadGroups(for eventId: String) async {
        print("DEBUG: loadGroups START for eventId: \(eventId)")
        print("DEBUG: Current state - isLoading: \(isLoading), groups count: \(suggestedGroups.count), currentEventId: \(currentEventId ?? "nil")")
        
        // Skip loading if we already have groups for this event
        if currentEventId == eventId && !suggestedGroups.isEmpty {
            print("DEBUG: Skipping load, already have groups for this event")
            return
        }
        
        print("DEBUG: Setting isLoading to true and clearing groups")
        await MainActor.run {
            isLoading = true
            suggestedGroups = [] // Clear existing groups immediately
        }
        
        // Load groups immediately
        let groups = MockDatabaseManager.shared.getEventGroups(eventId: eventId)
        print("DEBUG: Loaded \(groups.count) groups from database for event \(eventId)")
        
        // Update UI on main actor
        await MainActor.run {
            currentEventId = eventId
            suggestedGroups = groups
            isLoading = false
            print("DEBUG: Final UI update - isLoading: \(isLoading), groups count: \(suggestedGroups.count)")
        }
        
        print("DEBUG: loadGroups COMPLETE for eventId: \(eventId)")
    }
    
    func joinGroup(groupId: String, userId: String) async {
        let success = MockDatabaseManager.shared.joinGroup(groupId: groupId, userId: userId)
        
        if success {
            selectedGroupId = groupId
            showingGroupChat = true
            
            // Generate tickets for the group
            _ = MockDatabaseManager.shared.createTicketsForGroup(groupId: groupId)
        }
    }
}

struct EventInfoCard: View {
    let event: EventModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(event.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Text("$\(Int(event.price))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            if let venue = event.venue {
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.secondary)
                    Text(venue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(formatDate(event.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        guard let date = formatter.date(from: dateString) else { return dateString }
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct GroupCard: View {
    let group: EventGroupModel
    let event: EventModel
    let onJoinGroup: (String) -> Void
    @State private var showingGroupChat = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("\(group.members.count)/\(group.maxMembers) members")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(group.discountPercentage)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("discount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Member avatars and diversity info
            HStack {
                // Show first few member flags/countries
                HStack(spacing: -8) {
                    ForEach(Array(group.members.prefix(4)), id: \.id) { member in
                        Circle()
                            .fill(colorForCountry(member.countryOfBirth ?? "Unknown"))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(countryFlag(member.countryOfBirth ?? "Unknown"))
                                    .font(.caption)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    
                    if group.availableSpots > 0 {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("+\(group.availableSpots)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Diversity: \(group.diversityScore)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Final Price: $\(Int(event.price * (1 - group.discountRate)))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            // Member details
            VStack(alignment: .leading, spacing: 4) {
                Text("Members:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach(group.members, id: \.id) { member in
                        VStack(spacing: 2) {
                            Text(member.name.components(separatedBy: " ").first ?? "")
                                .font(.caption2)
                                .fontWeight(.medium)
                            
                            Text("\(member.age ?? 0)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    }
                    
                    Spacer()
                }
            }
            
            // Join button
            Button {
                onJoinGroup(group.id)
                showingGroupChat = true
            } label: {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text(group.availableSpots > 0 ? "Mingle" : "Group Full")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(group.availableSpots > 0 ? Color.blue : Color.gray)
                .cornerRadius(10)
            }
            .disabled(group.availableSpots == 0)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .fullScreenCover(isPresented: $showingGroupChat) {
            GroupChatView(group: group, event: event)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissAllModals"))) { _ in
            showingGroupChat = false
        }
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