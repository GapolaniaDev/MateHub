import Foundation

// MARK: - Database Models

struct UserModel: Identifiable, Codable {
    let id: String
    let name: String
    let email: String?
    let phone: String?
    let age: Int?
    let gender: String?
    let countryOfBirth: String?
    let languageAtHome: String?
    let state: String?
    let isFirstNations: Bool
    let hasDisability: Bool
    
    init(id: String = UUID().uuidString, name: String, email: String? = nil, phone: String? = nil, age: Int? = nil, gender: String? = nil, countryOfBirth: String? = nil, languageAtHome: String? = nil, state: String? = nil, isFirstNations: Bool = false, hasDisability: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.age = age
        self.gender = gender
        self.countryOfBirth = countryOfBirth
        self.languageAtHome = languageAtHome
        self.state = state
        self.isFirstNations = isFirstNations
        self.hasDisability = hasDisability
    }
}

struct InterestModel: Identifiable, Codable {
    let id: String
    let name: String
    let slug: String
    let category: String?
}

struct EventModel: Identifiable, Codable {
    let id: String
    let title: String
    let date: String
    let priceCents: Int
    let category: String
    let state: String
    let city: String
    let venue: String?
    let lat: Double?
    let lng: Double?
    let sponsored: Bool
    
    var price: Double {
        return Double(priceCents) / 100.0
    }
    
    var coordinates: Coordinates? {
        guard let lat = lat, let lng = lng else { return nil }
        return Coordinates(lat: lat, lng: lng)
    }
}

struct AttendeeModel: Identifiable, Codable, Equatable {
    let id: String
    var name: String?
    var age: Int?
    var gender: String?
    var countryOfBirth: String?
    var languageAtHome: String?
    var state: String?
    var isFirstNations: Bool
    var hasDisability: Bool
    
    init(id: String = UUID().uuidString, name: String? = nil, age: Int? = nil, gender: String? = nil, countryOfBirth: String? = nil, languageAtHome: String? = nil, state: String? = nil, isFirstNations: Bool = false, hasDisability: Bool = false) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.countryOfBirth = countryOfBirth
        self.languageAtHome = languageAtHome
        self.state = state
        self.isFirstNations = isFirstNations
        self.hasDisability = hasDisability
    }
}

struct OrderModel: Identifiable, Codable {
    let id: String
    let userId: String
    let eventId: String
    let baseTotalCents: Int
    let discountRate: Double
    let finalTotalCents: Int
    let durationHours: Double?
    let completedAt: String?
    
    var baseTotal: Double {
        return Double(baseTotalCents) / 100.0
    }
    
    var finalTotal: Double {
        return Double(finalTotalCents) / 100.0
    }
    
    var discountAmount: Double {
        return baseTotal * discountRate
    }
}

struct SurveyModel: Identifiable, Codable {
    let id: String
    let orderId: String
    let q1: Int? // Comfort level with group members (1-5)
    let q2: Int? // Feeling welcome and accepted (1-5)
    let q3: Int? // Cultural learning from group (1-5)
    let q4: Int? // Likelihood to stay in contact (1-5) 
    let q5: Int? // Strengthened sense of community (1-5)
    let q2Text: String? // Legacy field - no longer used
    let q3Bool: Bool?   // Legacy field - no longer used
    let q5Text: String? // Legacy field - no longer used
    let audioUrl: String?
    let transcript: String?
    let createdAt: String
    
    init(id: String = UUID().uuidString, orderId: String, q1: Int? = nil, q2: Int? = nil, q3: Int? = nil, q4: Int? = nil, q5: Int? = nil, q2Text: String? = nil, q3Bool: Bool? = nil, q5Text: String? = nil, audioUrl: String? = nil, transcript: String? = nil) {
        self.id = id
        self.orderId = orderId
        self.q1 = q1
        self.q2 = q2
        self.q3 = q3
        self.q4 = q4
        self.q5 = q5
        self.q2Text = q2Text // Legacy
        self.q3Bool = q3Bool // Legacy  
        self.q5Text = q5Text // Legacy
        self.audioUrl = audioUrl
        self.transcript = transcript
        self.createdAt = ISO8601DateFormatter().string(from: Date())
    }
}

struct TrophyModel: Identifiable, Codable {
    let id: String
    let title: String
    let description: String?
    let category: String?
    let iconName: String?
    let emoji: String?
    let conditionJson: String?
    var isUnlocked: Bool = false
    
    var condition: TrophyCondition? {
        guard let conditionJson = conditionJson,
              let data = conditionJson.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(TrophyCondition.self, from: data)
    }
}

struct TrophyCondition: Codable {
    let minHours: Double?
    let minEvents: Int?
    let minGroup: Int?
    let minAgeBrackets: Int?
    let minLanguages: Int?
    let minCountries: Int?
    let communitiesIncludes: [String]?
    let categoryIncludes: [String]?
    let stateIncludes: [String]?
    let requiresFirstNations: Bool?
    let requiresDisability: Bool?
    let minDiversityScore: Int?
    let maxDiversityScore: Int?
}

struct UserTrophyModel: Codable {
    let userId: String
    let trophyId: String
    let unlockedAt: String
}

// MARK: - Group System Models

struct EventGroupModel: Identifiable, Codable {
    let id: String
    let eventId: String
    let name: String
    let members: [UserModel]
    let maxMembers: Int
    let diversityScore: Int
    let discountRate: Double
    let isComplete: Bool
    let createdAt: String
    
    var availableSpots: Int {
        return maxMembers - members.count
    }
    
    var discountPercentage: String {
        return "\(Int(discountRate * 100))%"
    }
    
    init(id: String = UUID().uuidString, eventId: String, name: String, members: [UserModel], maxMembers: Int) {
        self.id = id
        self.eventId = eventId
        self.name = name
        self.members = members
        self.maxMembers = maxMembers
        self.diversityScore = EnhancedDiversityCalculator.calculateGroupDiversity(members: members)
        self.discountRate = EnhancedDiversityCalculator.groupDiscountRate(for: members.count)
        self.isComplete = members.count >= maxMembers
        self.createdAt = ISO8601DateFormatter().string(from: Date())
    }
}

struct GroupChatMessage: Identifiable, Codable {
    let id: String
    let groupId: String
    let userId: String
    let userName: String
    let message: String
    let messageType: MessageType
    let timestamp: String
    let imageUrl: String?
    let location: LocationData?
    
    enum MessageType: String, Codable {
        case text = "text"
        case image = "image"
        case location = "location"
        case ticket = "ticket"
        case system = "system"
    }
    
    init(id: String = UUID().uuidString, groupId: String, userId: String, userName: String, message: String, messageType: MessageType = .text, imageUrl: String? = nil, location: LocationData? = nil) {
        self.id = id
        self.groupId = groupId
        self.userId = userId
        self.userName = userName
        self.message = message
        self.messageType = messageType
        self.timestamp = ISO8601DateFormatter().string(from: Date())
        self.imageUrl = imageUrl
        self.location = location
    }
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let address: String?
}

struct EventTicket: Identifiable, Codable {
    let id: String
    let groupId: String
    let userId: String
    let userName: String
    let eventId: String
    let eventTitle: String
    let eventDate: String
    let seatNumber: String
    let section: String
    let price: Double
    let discountApplied: Double
    let finalPrice: Double
    
    init(id: String = UUID().uuidString, groupId: String, userId: String, userName: String, eventId: String, eventTitle: String, eventDate: String, seatNumber: String, section: String = "General", price: Double, discountRate: Double) {
        self.id = id
        self.groupId = groupId
        self.userId = userId
        self.userName = userName
        self.eventId = eventId
        self.eventTitle = eventTitle
        self.eventDate = eventDate
        self.seatNumber = seatNumber
        self.section = section
        self.price = price
        self.discountApplied = price * discountRate
        self.finalPrice = price - (price * discountRate)
    }
}

struct PostEventSurvey: Identifiable, Codable {
    let id: String
    let userId: String
    let groupId: String
    let eventId: String
    let responses: [Int] // 1-5 scale responses
    let averageScore: Double
    let completedAt: String
    
    init(id: String = UUID().uuidString, userId: String, groupId: String, eventId: String, responses: [Int]) {
        self.id = id
        self.userId = userId
        self.groupId = groupId
        self.eventId = eventId
        self.responses = responses
        self.averageScore = responses.isEmpty ? 0 : Double(responses.reduce(0, +)) / Double(responses.count)
        self.completedAt = ISO8601DateFormatter().string(from: Date())
    }
}

// MARK: - Enhanced Diversity Calculator with new dimensions
class EnhancedDiversityCalculator {
    
    static func calculateGroupDiversity(members: [UserModel]) -> Int {
        let count = members.count
        guard count >= 2 else { return 0 }
        
        let dimensions = ["countryOfBirth", "languageAtHome", "gender", "age", "state", "firstNations", "disability"]
        var scores: [Double] = []
        
        for dimension in dimensions {
            var values: [String] = []
            
            switch dimension {
            case "age":
                values = members.compactMap { member in
                    guard let age = member.age else { return nil }
                    return ageToBracket(age)
                }
            case "countryOfBirth":
                values = members.compactMap { $0.countryOfBirth }.filter { !$0.isEmpty }
            case "languageAtHome":
                values = members.compactMap { $0.languageAtHome }.filter { !$0.isEmpty }
            case "gender":
                values = members.compactMap { $0.gender }.filter { !$0.isEmpty }
            case "state":
                values = members.compactMap { $0.state }.filter { !$0.isEmpty }
            case "firstNations":
                values = members.map { $0.isFirstNations ? "Yes" : "No" }
            case "disability":
                values = members.map { $0.hasDisability ? "Yes" : "No" }
            default:
                continue
            }
            
            if !values.isEmpty {
                let uniqueCount = Set(values).count
                let score = count > 1 ? max(0, min(1, Double(uniqueCount - 1) / Double(count - 1))) : 0
                scores.append(score)
            }
        }
        
        let averageScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)
        return Int(round(averageScore * 100))
    }
    
    static func groupDiscountRate(for memberCount: Int) -> Double {
        switch memberCount {
        case 1: return 0.15 // 15%
        case 2: return 0.20 // 20%
        case 3...: return 0.25 // 25%
        default: return 0.0 // 0%
        }
    }
    
    static func calculateDiversityIndex(attendees: [AttendeeModel]) -> Int {
        let count = attendees.count
        guard count >= 2 else { return 0 }
        
        let dimensions = ["countryOfBirth", "languageAtHome", "gender", "age", "state", "firstNations", "disability"]
        var scores: [Double] = []
        
        for dimension in dimensions {
            var values: [String] = []
            
            switch dimension {
            case "age":
                values = attendees.compactMap { attendee in
                    guard let age = attendee.age else { return nil }
                    return ageToBracket(age)
                }
            case "countryOfBirth":
                values = attendees.compactMap { $0.countryOfBirth }.filter { !$0.isEmpty }
            case "languageAtHome":
                values = attendees.compactMap { $0.languageAtHome }.filter { !$0.isEmpty }
            case "gender":
                values = attendees.compactMap { $0.gender }.filter { !$0.isEmpty }
            case "state":
                values = attendees.compactMap { $0.state }.filter { !$0.isEmpty }
            case "firstNations":
                values = attendees.map { $0.isFirstNations ? "Yes" : "No" }
            case "disability":
                values = attendees.map { $0.hasDisability ? "Yes" : "No" }
            default:
                continue
            }
            
            if !values.isEmpty {
                let uniqueCount = Set(values).count
                let score = count > 1 ? max(0, min(1, Double(uniqueCount - 1) / Double(count - 1))) : 0
                scores.append(score)
            }
        }
        
        let averageScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)
        return Int(round(averageScore * 100))
    }
    
    static func ageToBracket(_ age: Int) -> String {
        switch age {
        case 0..<18: return "<18"
        case 18...24: return "18–24"
        case 25...34: return "25–34"
        case 35...49: return "35–49"
        case 50...64: return "50–64"
        default: return "65+"
        }
    }
    
    static func discountRate(for score: Int) -> Double {
        switch score {
        case 85...100: return 0.25 // 25%
        case 70...84: return 0.15  // 15%
        case 50...69: return 0.10  // 10%
        case 30...49: return 0.05  // 5%
        default: return 0.0        // 0%
        }
    }
    
    static func discountDescription(for score: Int) -> String {
        let percentage = Int(discountRate(for: score) * 100)
        return "\(percentage)%"
    }
}

// MARK: - Updated Constants
struct EnhancedDataConstants {
    static let languages = [
        "English", "Spanish", "Mandarin", "Arabic", "Hindi", "Vietnamese", 
        "Italian", "Greek", "Punjabi", "French", "German", "Korean", 
        "Japanese", "Portuguese", "Russian", "Other"
    ]
    
    static let countries = [
        "Australia", "China", "India", "Colombia", "UK", "Vietnam", 
        "Italy", "Greece", "Philippines", "New Zealand", "Germany",
        "South Korea", "Japan", "USA", "Canada", "Brazil", "Other"
    ]
    
    static let genders = ["Female", "Male", "Non-binary", "Prefer not to say"]
    
    static let australianStates = [
        "NSW", "VIC", "QLD", "SA", "WA", "TAS", "NT", "ACT"
    ]
    
    static let eventCategories = [
        "Sports", "Culture", "Music", "Arts", "Education", "Food", "Technology", "Health"
    ]
    
    static let interestCategories = [
        "Leisure", "Arts", "Education", "Technology", "Health", "Community"
    ]
}