import Foundation

// MARK: - Event Model
struct Event: Identifiable, Codable {
    let id: String
    let title: String
    let city: String
    let state: String
    let category: String
    let date: String
    let price: Double
    let coords: Coordinates
    let venue: String
    let sponsored: Bool
}

struct Coordinates: Codable {
    let lat: Double
    let lng: Double
}

// MARK: - Attendee Model
struct Attendee: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var age: Int
    var gender: String
    var countryOfBirth: String
    var languageAtHome: String
    
    init(id: String = UUID().uuidString, name: String = "", age: Int = 0, gender: String = "", countryOfBirth: String = "Australia", languageAtHome: String = "English") {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.countryOfBirth = countryOfBirth
        self.languageAtHome = languageAtHome
    }
}

// MARK: - Filter Options
enum AustralianState: String, CaseIterable {
    case all = "All"
    case nsw = "NSW"
    case vic = "VIC"
    case qld = "QLD"
    case sa = "SA"
    case wa = "WA"
    case tas = "TAS"
    case nt = "NT"
    case act = "ACT"
}

enum EventCategory: String, CaseIterable {
    case all = "All"
    case sports = "Sports"
    case culture = "Culture"
    case music = "Music"
    case arts = "Arts"
    case education = "Education"
    case food = "Food"
}

// MARK: - Static Data
struct DataConstants {
    static let languages = ["English", "Spanish", "Mandarin", "Arabic", "Hindi", "Vietnamese", "Italian", "Greek", "Punjabi", "Other"]
    
    static let countries = ["Australia", "China", "India", "Colombia", "UK", "Vietnam", "Italy", "Greece", "Philippines", "Other"]
    
    static let genders = ["Female", "Male", "Non-binary", "Prefer not to say"]
    
    static let mockEvents = [
        Event(
            id: "evt1",
            title: "AFL Match – Crows vs Power",
            city: "Adelaide, SA",
            state: "SA",
            category: "Sports",
            date: "2025-09-15",
            price: 60,
            coords: Coordinates(lat: -34.915, lng: 138.596),
            venue: "Adelaide Oval",
            sponsored: true
        ),
        Event(
            id: "evt2",
            title: "Sydney Festival Night Market",
            city: "Sydney, NSW",
            state: "NSW",
            category: "Culture",
            date: "2025-10-10",
            price: 25,
            coords: Coordinates(lat: -33.8688, lng: 151.2093),
            venue: "CBD",
            sponsored: true
        ),
        Event(
            id: "evt3",
            title: "Melbourne International Film Festival",
            city: "Melbourne, VIC",
            state: "VIC",
            category: "Arts",
            date: "2025-11-02",
            price: 45,
            coords: Coordinates(lat: -37.8136, lng: 144.9631),
            venue: "Arts Precinct",
            sponsored: false
        ),
        Event(
            id: "evt4",
            title: "Darwin Multicultural Fair",
            city: "Darwin, NT",
            state: "NT",
            category: "Culture",
            date: "2025-09-30",
            price: 10,
            coords: Coordinates(lat: -12.4634, lng: 130.8456),
            venue: "Waterfront Park",
            sponsored: true
        ),
        Event(
            id: "evt5",
            title: "Brisbane Riverstage Concert",
            city: "Brisbane, QLD",
            state: "QLD",
            category: "Music",
            date: "2025-09-20",
            price: 55,
            coords: Coordinates(lat: -27.4698, lng: 153.0251),
            venue: "Riverstage",
            sponsored: false
        ),
        Event(
            id: "evt6",
            title: "Perth Food & Footy Day",
            city: "Perth, WA",
            state: "WA",
            category: "Sports",
            date: "2025-10-05",
            price: 35,
            coords: Coordinates(lat: -31.9505, lng: 115.8605),
            venue: "Langley Park",
            sponsored: true
        ),
        Event(
            id: "evt7",
            title: "Canberra Science Week Expo",
            city: "Canberra, ACT",
            state: "ACT",
            category: "Education",
            date: "2025-08-31",
            price: 15,
            coords: Coordinates(lat: -35.2809, lng: 149.13),
            venue: "Exhibition Park",
            sponsored: false
        ),
        Event(
            id: "evt8",
            title: "Hobart Taste of Tasmania",
            city: "Hobart, TAS",
            state: "TAS",
            category: "Food",
            date: "2025-12-28",
            price: 30,
            coords: Coordinates(lat: -42.8821, lng: 147.3272),
            venue: "Salamanca Place",
            sponsored: true
        )
    ]
}