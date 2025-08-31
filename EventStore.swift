import Foundation
import Combine

class EventStore: ObservableObject {
    @Published var events: [Event] = DataConstants.mockEvents
    @Published var attendees: [Attendee] = []
    @Published var selectedEventId: String = ""
    @Published var searchText: String = ""
    @Published var selectedState: AustralianState = .all
    @Published var selectedCategory: EventCategory = .all
    @Published var selectedDate: Date? = nil
    
    // Computed Properties
    var filteredEvents: [Event] {
        events.filter { event in
            let matchesSearch = searchText.isEmpty || 
                event.title.lowercased().contains(searchText.lowercased()) ||
                event.city.lowercased().contains(searchText.lowercased()) ||
                event.venue.lowercased().contains(searchText.lowercased())
            
            let matchesState = selectedState == .all || event.state == selectedState.rawValue
            let matchesCategory = selectedCategory == .all || event.category == selectedCategory.rawValue
            
            let matchesDate: Bool
            if let selectedDate = selectedDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                matchesDate = event.date == formatter.string(from: selectedDate)
            } else {
                matchesDate = true
            }
            
            return matchesSearch && matchesState && matchesCategory && matchesDate
        }
    }
    
    var selectedEvent: Event? {
        events.first { $0.id == selectedEventId } ?? filteredEvents.first
    }
    
    var diversityScore: Int {
        DiversityCalculator.calculateDiversityIndex(attendees: attendees)
    }
    
    var discountRate: Double {
        DiversityCalculator.discountRate(for: diversityScore)
    }
    
    // MARK: - Initialization
    init() {
        selectedEventId = events.first?.id ?? ""
        // Add default attendees
        attendees = [
            Attendee(name: "Gustavo", age: 29, gender: "Male", countryOfBirth: "Colombia", languageAtHome: "Spanish"),
            Attendee(name: "Angie", age: 28, gender: "Female", countryOfBirth: "Australia", languageAtHome: "English")
        ]
    }
    
    // MARK: - Event Management
    func selectEvent(_ eventId: String) {
        selectedEventId = eventId
    }
    
    // MARK: - Attendee Management
    func addAttendee() {
        attendees.append(Attendee())
    }
    
    func removeAttendee(at index: Int) {
        guard index < attendees.count else { return }
        attendees.remove(at: index)
    }
    
    func updateAttendee(at index: Int, with attendee: Attendee) {
        guard index < attendees.count else { return }
        attendees[index] = attendee
    }
    
    // MARK: - Pricing Calculations
    func basePrice() -> Double {
        guard let event = selectedEvent else { return 0 }
        return event.price * Double(attendees.count)
    }
    
    func discountAmount() -> Double {
        return basePrice() * discountRate
    }
    
    func totalPrice() -> Double {
        return basePrice() - discountAmount()
    }
    
    // MARK: - Formatting
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}