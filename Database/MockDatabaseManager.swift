import Foundation

// Mock database manager that doesn't require SQLite dependency
class MockDatabaseManager {
    static let shared = MockDatabaseManager()
    
    private init() {
        seedMockData()
    }
    
    // Mock storage
    private var users: [UserModel] = []
    private var events: [EventModel] = []
    private var interests: [InterestModel] = []
    private var orders: [OrderModel] = []
    private var trophies: [TrophyModel] = []
    private var eventGroups: [EventGroupModel] = []
    private var chatMessages: [GroupChatMessage] = []
    private var tickets: [EventTicket] = []
    private var surveys: [PostEventSurvey] = []
    
    private func seedMockData() {
        // Seed interests
        interests = [
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
        
        // Seed events - All in South Australia
        events = [
            // Adelaide events
            EventModel(
                id: "evt_adl_afl_crows",
                title: "AFL Match – Crows vs Power",
                date: "2025-09-15T18:00:00+09:30",
                priceCents: 6000,
                category: "Sports",
                state: "SA",
                city: "Adelaide",
                venue: "Adelaide Oval",
                lat: -34.915,
                lng: 138.596,
                sponsored: true
            ),
            EventModel(
                id: "evt_adl_fringe",
                title: "Adelaide Fringe Festival",
                date: "2025-09-25T20:00:00+09:30",
                priceCents: 3500,
                category: "Arts",
                state: "SA",
                city: "Adelaide",
                venue: "Adelaide Festival Centre",
                lat: -34.9205,
                lng: 138.5986,
                sponsored: true
            ),
            EventModel(
                id: "evt_adl_multicultural",
                title: "Adelaide Multicultural Festival",
                date: "2025-10-12T16:00:00+09:30",
                priceCents: 2000,
                category: "Culture",
                state: "SA",
                city: "Adelaide",
                venue: "Victoria Square",
                lat: -34.9249,
                lng: 138.5999,
                sponsored: true
            ),
            EventModel(
                id: "evt_adl_food_wine",
                title: "Adelaide Food & Wine Festival",
                date: "2025-11-08T18:30:00+09:30",
                priceCents: 4500,
                category: "Food",
                state: "SA",
                city: "Adelaide",
                venue: "Central Market",
                lat: -34.9301,
                lng: 138.5831,
                sponsored: false
            ),
            EventModel(
                id: "evt_adl_jazz",
                title: "Adelaide Jazz Festival",
                date: "2025-09-28T19:00:00+09:30",
                priceCents: 4000,
                category: "Music",
                state: "SA",
                city: "Adelaide",
                venue: "Elder Park",
                lat: -34.9158,
                lng: 138.6063,
                sponsored: false
            ),
            EventModel(
                id: "evt_adl_uni_expo",
                title: "University of Adelaide Science Expo",
                date: "2025-10-15T10:00:00+09:30",
                priceCents: 1500,
                category: "Education",
                state: "SA",
                city: "Adelaide",
                venue: "University of Adelaide",
                lat: -34.9197,
                lng: 138.6056,
                sponsored: true
            ),
            // Glenelg events
            EventModel(
                id: "evt_glenelg_beach",
                title: "Glenelg Beach Sports Festival",
                date: "2025-10-20T14:00:00+09:30",
                priceCents: 2500,
                category: "Sports",
                state: "SA",
                city: "Glenelg",
                venue: "Glenelg Beach",
                lat: -34.9794,
                lng: 138.5124,
                sponsored: true
            ),
            EventModel(
                id: "evt_glenelg_market",
                title: "Glenelg Sunday Market",
                date: "2025-09-29T09:00:00+09:30",
                priceCents: 1000,
                category: "Culture",
                state: "SA",
                city: "Glenelg",
                venue: "Glenelg Foreshore",
                lat: -34.9801,
                lng: 138.5150,
                sponsored: false
            ),
            // Port Adelaide events
            EventModel(
                id: "evt_port_heritage",
                title: "Port Adelaide Heritage Festival",
                date: "2025-11-01T15:00:00+09:30",
                priceCents: 2800,
                category: "Culture",
                state: "SA",
                city: "Port Adelaide",
                venue: "Historic Wharf Area",
                lat: -34.8470,
                lng: 138.5070,
                sponsored: true
            ),
            EventModel(
                id: "evt_port_power",
                title: "Port Power Home Game",
                date: "2025-10-03T14:30:00+09:30",
                priceCents: 5500,
                category: "Sports",
                state: "SA",
                city: "Port Adelaide",
                venue: "Adelaide Oval",
                lat: -34.915,
                lng: 138.596,
                sponsored: false
            ),
            // Adelaide Hills events
            EventModel(
                id: "evt_hills_wine",
                title: "Adelaide Hills Wine Festival",
                date: "2025-10-25T11:00:00+09:30",
                priceCents: 5000,
                category: "Food",
                state: "SA",
                city: "Stirling",
                venue: "Mount Lofty Ranges",
                lat: -35.0231,
                lng: 138.7281,
                sponsored: false
            ),
            EventModel(
                id: "evt_hills_arts",
                title: "Hills Arts & Crafts Fair",
                date: "2025-11-15T10:00:00+09:30",
                priceCents: 3000,
                category: "Arts",
                state: "SA",
                city: "Hahndorf",
                venue: "Main Street",
                lat: -35.0296,
                lng: 138.8117,
                sponsored: true
            ),
            // Barossa Valley events
            EventModel(
                id: "evt_barossa_vintage",
                title: "Barossa Vintage Festival",
                date: "2025-09-22T12:00:00+09:30",
                priceCents: 6500,
                category: "Food",
                state: "SA",
                city: "Tanunda",
                venue: "Barossa Valley",
                lat: -34.5236,
                lng: 138.9594,
                sponsored: true
            ),
            EventModel(
                id: "evt_barossa_music",
                title: "Barossa Music Festival",
                date: "2025-11-20T17:00:00+09:30",
                priceCents: 4200,
                category: "Music",
                state: "SA",
                city: "Nuriootpa",
                venue: "Town Square",
                lat: -34.4669,
                lng: 138.9896,
                sponsored: false
            ),
            // McLaren Vale events
            EventModel(
                id: "evt_mclaren_wine",
                title: "McLaren Vale Wine & Food Festival",
                date: "2025-10-18T13:00:00+09:30",
                priceCents: 5500,
                category: "Food",
                state: "SA",
                city: "McLaren Vale",
                venue: "McLaren Vale Winery",
                lat: -35.2176,
                lng: 138.5456,
                sponsored: false
            ),
            // Victor Harbor events
            EventModel(
                id: "evt_victor_whale",
                title: "Victor Harbor Whale Festival",
                date: "2025-09-18T10:00:00+09:30",
                priceCents: 3200,
                category: "Culture",
                state: "SA",
                city: "Victor Harbor",
                venue: "Encounter Bay",
                lat: -35.5527,
                lng: 138.6211,
                sponsored: true
            ),
            // Mount Gambier events
            EventModel(
                id: "evt_mtgambier_cave",
                title: "Mount Gambier Cave Festival",
                date: "2025-11-12T14:00:00+09:30",
                priceCents: 2800,
                category: "Education",
                state: "SA",
                city: "Mount Gambier",
                venue: "Blue Lake",
                lat: -37.8284,
                lng: 140.7831,
                sponsored: true
            ),
            // Additional Adelaide events
            EventModel(
                id: "evt_adl_cabaret",
                title: "Adelaide Cabaret Festival",
                date: "2025-10-08T21:00:00+09:30",
                priceCents: 7500,
                category: "Music",
                state: "SA",
                city: "Adelaide",
                venue: "Adelaide Festival Centre",
                lat: -34.9205,
                lng: 138.5986,
                sponsored: false
            ),
            EventModel(
                id: "evt_adl_writers",
                title: "Adelaide Writers' Week",
                date: "2025-11-25T15:00:00+09:30",
                priceCents: 2000,
                category: "Education",
                state: "SA",
                city: "Adelaide",
                venue: "State Library",
                lat: -34.9200,
                lng: 138.6010,
                sponsored: true
            ),
            EventModel(
                id: "evt_adl_night_market",
                title: "Adelaide Central Market Night",
                date: "2025-09-12T17:00:00+09:30",
                priceCents: 1500,
                category: "Food",
                state: "SA",
                city: "Adelaide",
                venue: "Central Market",
                lat: -34.9301,
                lng: 138.5831,
                sponsored: true
            )
        ]
        
        // Seed diverse users
        users = [
            UserModel(
                id: "user_gustavo",
                name: "Gustavo Polania",
                email: "gustavo@example.com",
                age: 29,
                gender: "Male",
                countryOfBirth: "Colombia",
                languageAtHome: "Spanish",
                state: "SA",
                isFirstNations: false,
                hasDisability: false
            ),
            // Additional diverse users for groups
            UserModel(
                id: "user_mei",
                name: "Mei Chen",
                email: "mei@example.com",
                age: 24,
                gender: "Female",
                countryOfBirth: "China",
                languageAtHome: "Mandarin",
                state: "SA",
                isFirstNations: false,
                hasDisability: false
            ),
            UserModel(
                id: "user_priya",
                name: "Priya Patel",
                email: "priya@example.com",
                age: 32,
                gender: "Female",
                countryOfBirth: "India",
                languageAtHome: "Hindi",
                state: "SA",
                isFirstNations: false,
                hasDisability: false
            ),
            UserModel(
                id: "user_james",
                name: "James Wilson",
                email: "james@example.com",
                age: 45,
                gender: "Male",
                countryOfBirth: "Australia",
                languageAtHome: "English",
                state: "SA",
                isFirstNations: true,
                hasDisability: false
            ),
            UserModel(
                id: "user_fatima",
                name: "Fatima Al-Zahra",
                email: "fatima@example.com",
                age: 28,
                gender: "Female",
                countryOfBirth: "Lebanon",
                languageAtHome: "Arabic",
                state: "SA",
                isFirstNations: false,
                hasDisability: false
            ),
            UserModel(
                id: "user_marco",
                name: "Marco Rossi",
                email: "marco@example.com",
                age: 35,
                gender: "Male",
                countryOfBirth: "Italy",
                languageAtHome: "Italian",
                state: "SA",
                isFirstNations: false,
                hasDisability: true
            ),
            UserModel(
                id: "user_sophie",
                name: "Sophie Dubois",
                email: "sophie@example.com",
                age: 22,
                gender: "Female",
                countryOfBirth: "France",
                languageAtHome: "French",
                state: "SA",
                isFirstNations: false,
                hasDisability: false
            ),
            UserModel(
                id: "user_hiroshi",
                name: "Hiroshi Tanaka",
                email: "hiroshi@example.com",
                age: 38,
                gender: "Male",
                countryOfBirth: "Japan",
                languageAtHome: "Japanese",
                state: "SA",
                isFirstNations: false,
                hasDisability: false
            ),
            UserModel(
                id: "user_anna",
                name: "Anna Kowalski",
                email: "anna@example.com",
                age: 26,
                gender: "Female",
                countryOfBirth: "Poland",
                languageAtHome: "Polish",
                state: "SA",
                isFirstNations: false,
                hasDisability: false
            ),
            UserModel(
                id: "user_carlos",
                name: "Carlos Silva",
                email: "carlos@example.com",
                age: 31,
                gender: "Male",
                countryOfBirth: "Brazil",
                languageAtHome: "Portuguese",
                state: "SA",
                isFirstNations: false,
                hasDisability: false
            ),
            UserModel(
                id: "user_aisha",
                name: "Aisha Johnson",
                email: "aisha@example.com",
                age: 27,
                gender: "Female",
                countryOfBirth: "Nigeria",
                languageAtHome: "English",
                state: "SA",
                isFirstNations: false,
                hasDisability: false
            ),
            UserModel(
                id: "user_david",
                name: "David Kim",
                email: "david@example.com",
                age: 30,
                gender: "Male",
                countryOfBirth: "South Korea",
                languageAtHome: "Korean",
                state: "SA",
                isFirstNations: false,
                hasDisability: false
            )
        ]
        
        // Generate mock trophies
        generateMockTrophies()
        
        // Generate mock groups
        generateMockGroups()
    }
    
    private func generateMockTrophies() {
        trophies = [
            TrophyModel(id: "tr_hours_1", title: "First Connection Bridge", description: "Connect at your first community event.", category: "Time Bridge", iconName: "point.3.connected.trianglepath.dotted", emoji: "🌉", conditionJson: "{\"minHours\":1}", isUnlocked: true),
            TrophyModel(id: "tr_hours_5", title: "Community Explorer Bridge", description: "Build 5 hours of community connections.", category: "Time Bridge", iconName: "point.3.connected.trianglepath.dotted", emoji: "🌉", conditionJson: "{\"minHours\":5}", isUnlocked: true),
            TrophyModel(id: "tr_hours_25", title: "Community Builder Bridge", description: "Bridge communities for 25+ hours.", category: "Time Bridge", iconName: "point.3.connected.trianglepath.dotted", emoji: "🌉", conditionJson: "{\"minHours\":25}", isUnlocked: false),
            TrophyModel(id: "tr_events_1", title: "First Event Bridge", description: "Start building bridges at your first event.", category: "Community Bridge", iconName: "point.3.connected.trianglepath.dotted", emoji: "🌉", conditionJson: "{\"minEvents\":1}", isUnlocked: true),
            TrophyModel(id: "tr_div_basic", title: "Diversity Bridge Builder", description: "Bridge diverse communities with 30+ IDM score.", category: "Cultural Bridge", iconName: "point.3.connected.trianglepath.dotted", emoji: "🌉", conditionJson: "{\"minDiversityScore\":30}", isUnlocked: true)
        ]
        
        // Add 95 more mock bridging badges
        for i in 6...100 {
            trophies.append(TrophyModel(
                id: "tr_mock_\(i)",
                title: "Bridge Builder \(i)",
                description: "Bridging communities through connection \(i)",
                category: ["Time Bridge", "Community Bridge", "Cultural Bridge", "Social Bridge", "Sports Bridge", "Survey Bridge"].randomElement(),
                iconName: "point.3.connected.trianglepath.dotted",
                emoji: "🌉",
                conditionJson: "{}",
                isUnlocked: i <= 10 // First 10 unlocked
            ))
        }
    }
    
    private func generateMockGroups() {
        // Create diverse groups for ALL events
        for (eventIndex, event) in events.enumerated() {
            createGroupsForEvent(event: event, eventIndex: eventIndex)
        }
        
        // Generate sample chat messages for all groups
        for group in eventGroups {
            generateSampleChatMessages(for: group)
        }
    }
    
    private func createGroupsForEvent(event: EventModel, eventIndex: Int) {
        let groupNameSuffixes = [
            ["Cultural Mix Squad", "International Friends", "World Unity Group", "Young Explorers", "Global Connections"],
            ["Diversity Champions", "United Nations", "Rainbow Coalition", "Cross-Cultural Club", "Heritage Heroes"],
            ["Multicultural Marvels", "Border Crossers", "Culture Fusion", "Unity Squad", "Global Family"],
            ["World Warriors", "International Icons", "Culture Connect", "Diverse Dreams", "Unity United"],
            ["Global Guardians", "Cultural Crew", "International Impact", "Diverse Dynasty", "Unity Vision"]
        ]
        
        let groupNames = groupNameSuffixes[eventIndex % groupNameSuffixes.count]
        
        // Group 1: High diversity (China, India, Lebanon, Australia)
        let group1Members = [
            users.first(where: { $0.id == "user_mei" })!,
            users.first(where: { $0.id == "user_priya" })!,
            users.first(where: { $0.id == "user_fatima" })!,
            users.first(where: { $0.id == "user_james" })!
        ]
        eventGroups.append(EventGroupModel(
            eventId: event.id,
            name: groupNames[0],
            members: group1Members,
            maxMembers: 6
        ))
        
        // Group 2: Medium diversity (Italy, France, Japan)
        let group2Members = [
            users.first(where: { $0.id == "user_marco" })!,
            users.first(where: { $0.id == "user_sophie" })!,
            users.first(where: { $0.id == "user_hiroshi" })!
        ]
        eventGroups.append(EventGroupModel(
            eventId: event.id,
            name: groupNames[1],
            members: group2Members,
            maxMembers: 5
        ))
        
        // Group 3: High diversity (Poland, Brazil, Nigeria, Korea)
        let group3Members = [
            users.first(where: { $0.id == "user_anna" })!,
            users.first(where: { $0.id == "user_carlos" })!,
            users.first(where: { $0.id == "user_aisha" })!,
            users.first(where: { $0.id == "user_david" })!
        ]
        eventGroups.append(EventGroupModel(
            eventId: event.id,
            name: groupNames[2],
            members: group3Members,
            maxMembers: 6
        ))
        
        // Group 4: Smaller diverse group
        let group4Members = [
            users.first(where: { $0.id == "user_sophie" })!,
            users.first(where: { $0.id == "user_david" })!,
            users.first(where: { $0.id == "user_mei" })!
        ]
        eventGroups.append(EventGroupModel(
            eventId: event.id,
            name: groupNames[3],
            members: group4Members,
            maxMembers: 4
        ))
        
        // Group 5: Large diverse group
        let group5Members = [
            users.first(where: { $0.id == "user_marco" })!,
            users.first(where: { $0.id == "user_aisha" })!,
            users.first(where: { $0.id == "user_anna" })!,
            users.first(where: { $0.id == "user_james" })!,
            users.first(where: { $0.id == "user_carlos" })!
        ]
        eventGroups.append(EventGroupModel(
            eventId: event.id,
            name: groupNames[4],
            members: group5Members,
            maxMembers: 8
        ))
    }
    
    private func generateSampleChatMessages(for group: EventGroupModel) {
        // Use actual group members for realistic conversation
        let members = Array(group.members.prefix(4)) // Use first 4 members for conversation
        guard members.count >= 2 else { return } // Need at least 2 members for conversation
        
        var groupMessages: [GroupChatMessage] = []
        
        // Get event info for context
        let event = events.first(where: { $0.id == group.eventId })
        let eventType = event?.category ?? "event"
        let eventName = event?.title ?? "the event"
        
        // Create conversation with actual group members
        if members.count >= 1 {
            let member1 = members[0]
            groupMessages.append(GroupChatMessage(
                groupId: group.id,
                userId: member1.id,
                userName: member1.name,
                message: "Hi everyone! 👋 So excited to meet you all at \(eventName)! 🎉",
                messageType: .text
            ))
        }
        
        if members.count >= 2 {
            let member2 = members[1]
            let culturalContext = getCulturalMessage(for: member2.countryOfBirth)
            groupMessages.append(GroupChatMessage(
                groupId: group.id,
                userId: member2.id,
                userName: member2.name,
                message: "Hello! \(culturalContext) Looking forward to this experience! 😊",
                messageType: .text
            ))
        }
        
        if members.count >= 3 {
            let member3 = members[2]
            groupMessages.append(GroupChatMessage(
                groupId: group.id,
                userId: member3.id,
                userName: member3.name,
                message: "This is going to be amazing! I love meeting people from different backgrounds. Should we meet at the entrance?",
                messageType: .text
            ))
        }
        
        if members.count >= 4 {
            let member4 = members[3]
            let foodOffer = getFoodOffer(for: member4.countryOfBirth)
            groupMessages.append(GroupChatMessage(
                groupId: group.id,
                userId: member4.id,
                userName: member4.name,
                message: "Great idea! \(foodOffer) What time should we meet?",
                messageType: .text
            ))
        }
        
        // System message
        groupMessages.append(GroupChatMessage(
            groupId: group.id,
            userId: "system",
            userName: "System",
            message: "🎫 Tickets have been distributed to all members with \(Int(group.discountPercentage))% group discount applied",
            messageType: .system
        ))
        
        // More conversation with actual members
        if members.count >= 2 {
            let member1 = members[0]
            let member2 = members[1]
            
            groupMessages.append(GroupChatMessage(
                groupId: group.id,
                userId: member1.id,
                userName: member1.name,
                message: "How about 30 minutes before the event starts? That gives us time to find each other and chat",
                messageType: .text
            ))
            
            groupMessages.append(GroupChatMessage(
                groupId: group.id,
                userId: member2.id,
                userName: member2.name,
                message: "Perfect! I'm really looking forward to learning about everyone's cultures 🌍",
                messageType: .text
            ))
        }
        
        if members.count >= 3 {
            let member3 = members[2]
            groupMessages.append(GroupChatMessage(
                groupId: group.id,
                userId: member3.id,
                userName: member3.name,
                message: "This app is such a great idea! Building bridges across communities 🤝",
                messageType: .text
            ))
        }
        
        // Final coordination
        if members.count >= 1 {
            let lastMember = members[members.count - 1]
            groupMessages.append(GroupChatMessage(
                groupId: group.id,
                userId: lastMember.id,
                userName: lastMember.name,
                message: "I'm on my way! See you all soon! 🚗💨",
                messageType: .text
            ))
        }
        
        // Add messages to the main chatMessages array
        chatMessages.append(contentsOf: groupMessages)
        
        // Generate sample tickets for group members
        generateSampleTickets(for: group)
    }
    
    private func getCulturalMessage(for country: String?) -> String {
        switch country {
        case "China": return "I'm from China and this will be my first Australian sports event!"
        case "India": return "This is so different from cricket back in India, can't wait to learn!"
        case "Lebanon": return "In Lebanon we mostly watch football, this will be a new experience!"
        case "Italy": return "I love how sports bring people together, just like in Italy!"
        case "France": return "The atmosphere here reminds me of French stadiums!"
        case "Japan": return "This is so exciting! Sports culture is so interesting here!"
        case "Brazil": return "The energy here is almost like Brazilian football matches!"
        case "Nigeria": return "I love how diverse this group is, just like my community back home!"
        case "Poland": return "Polish people love sports too, looking forward to this!"
        case "South Korea": return "Korean sports culture is different but this looks fun!"
        default: return "I've never been to an event like this before!"
        }
    }
    
    private func getFoodOffer(for country: String?) -> String {
        switch country {
        case "China": return "I can bring some traditional Chinese dumplings to share! 🥟"
        case "India": return "I'll bring some samosas for everyone to try! 🥙"
        case "Lebanon": return "I'll bring some delicious Arabic sweets! 🍯"
        case "Italy": return "I'll bring some Italian pastries! 🥐"
        case "France": return "I can bring some French macarons! 🧁"
        case "Japan": return "I'll bring some Japanese snacks! 🍡"
        case "Brazil": return "I'll bring some Brazilian treats! 🍮"
        case "Nigeria": return "I'll bring some Nigerian snacks to share! 🥜"
        case "Poland": return "I'll bring some Polish pierogi! 🥟"
        case "South Korea": return "I'll bring some Korean snacks! 🍘"
        default: return "I'll bring some snacks for everyone!"
        }
    }
    
    private func generateSampleTickets(for group: EventGroupModel) {
        let event = events.first(where: { $0.id == group.eventId })!
        let sections = ["Section A", "Section A", "Section A", "Section A", "Section A"] // Keep them together
        let baseSeats = [15, 16, 17, 18, 19] // Adjacent seats
        
        // Only create up to 5 tickets maximum
        let membersToProcess = Array(group.members.prefix(5))
        
        for (index, member) in membersToProcess.enumerated() {
            tickets.append(EventTicket(
                groupId: group.id,
                userId: member.id,
                userName: member.name,
                eventId: event.id,
                eventTitle: event.title,
                eventDate: event.date,
                seatNumber: "Row 12, Seat \(baseSeats[index])",
                section: sections[index],
                price: event.price,
                discountRate: group.discountRate
            ))
        }
    }
    
    // MARK: - Public API
    
    func createUser(_ user: UserModel) -> Bool {
        users.append(user)
        return true
    }
    
    func getUser(id: String) -> UserModel? {
        return users.first { $0.id == id }
    }
    
    func getAllEvents() -> [EventModel] {
        return events
    }
    
    func getAllInterests() -> [InterestModel] {
        return interests
    }
    
    func getAllTrophies() -> [TrophyModel] {
        return trophies
    }
    
    func createOrder(_ order: OrderModel, attendees: [AttendeeModel]) -> Bool {
        orders.append(order)
        return true
    }
    
    func getUserOrders(userId: String) -> [OrderModel] {
        return orders.filter { $0.userId == userId }
    }
    
    func saveSurvey(_ survey: SurveyModel) -> Bool {
        // Mock save
        return true
    }
    
    // MARK: - Groups API
    
    func getEventGroups(eventId: String) -> [EventGroupModel] {
        return eventGroups.filter { $0.eventId == eventId }
    }
    
    func joinGroup(groupId: String, userId: String) -> Bool {
        guard let groupIndex = eventGroups.firstIndex(where: { $0.id == groupId }),
              let user = users.first(where: { $0.id == userId }),
              eventGroups[groupIndex].availableSpots > 0 else {
            return false
        }
        
        var updatedGroup = eventGroups[groupIndex]
        var updatedMembers = updatedGroup.members
        updatedMembers.append(user)
        
        eventGroups[groupIndex] = EventGroupModel(
            id: updatedGroup.id,
            eventId: updatedGroup.eventId,
            name: updatedGroup.name,
            members: updatedMembers,
            maxMembers: updatedGroup.maxMembers
        )
        
        return true
    }
    
    func getChatMessages(groupId: String) -> [GroupChatMessage] {
        return chatMessages.filter { $0.groupId == groupId }.sorted { $0.timestamp < $1.timestamp }
    }
    
    func sendMessage(message: GroupChatMessage) -> Bool {
        chatMessages.append(message)
        return true
    }
    
    func getGroupTickets(groupId: String) -> [EventTicket] {
        return tickets.filter { $0.groupId == groupId }
    }
    
    func createTicketsForGroup(groupId: String) -> Bool {
        guard let group = eventGroups.first(where: { $0.id == groupId }),
              let event = events.first(where: { $0.id == group.eventId }) else {
            return false
        }
        
        // Generate adjacent seats for group members
        let baseSeats = Array(20...(20 + group.members.count - 1))
        
        for (index, member) in group.members.enumerated() {
            let ticket = EventTicket(
                groupId: group.id,
                userId: member.id,
                userName: member.name,
                eventId: event.id,
                eventTitle: event.title,
                eventDate: event.date,
                seatNumber: "Row 12, Seat \(baseSeats[index])",
                section: "Section A",
                price: event.price,
                discountRate: group.discountRate
            )
            tickets.append(ticket)
        }
        
        return true
    }
    
    func savePostEventSurvey(_ survey: PostEventSurvey) -> Bool {
        surveys.append(survey)
        return true
    }
    
    func getUserSurveys(userId: String) -> [PostEventSurvey] {
        return surveys.filter { $0.userId == userId }
    }
    
    // MARK: - Trophy Management
    
    func unlockSurveyTrophy(userId: String) -> TrophyModel? {
        // Check if Survey Bridge badge should be unlocked
        let surveyCount = surveys.filter { $0.userId == userId }.count
        
        if surveyCount >= 1 {
            // Create an unlocked Survey Bridge badge
            return TrophyModel(
                id: "sv_01",
                title: "Feedback Bridge Builder",
                description: "Bridge communities through valuable feedback.",
                category: "Survey Bridge",
                iconName: "point.3.connected.trianglepath.dotted",
                emoji: "🌉",
                conditionJson: "{\"surveysCompleted\":1}",
                isUnlocked: true
            )
        }
        
        return nil
    }
    
    func getTrophyById(id: String) -> TrophyModel? {
        // This would normally query the trophies, but for simplicity
        // we'll return the Survey Bridge badge
        if id == "sv_01" {
            return TrophyModel(
                id: "sv_01",
                title: "Feedback Bridge Builder",
                description: "Bridge communities through valuable feedback.",
                category: "Survey Bridge",
                iconName: "point.3.connected.trianglepath.dotted",
                emoji: "🌉",
                conditionJson: "{\"surveysCompleted\":1}",
                isUnlocked: true
            )
        }
        return nil
    }
}