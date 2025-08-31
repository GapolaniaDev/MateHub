import Foundation

class DiversityCalculator {
    
    // MARK: - Diversity Index Calculation
    static func calculateDiversityIndex(attendees: [Attendee]) -> Int {
        let count = attendees.count
        guard count >= 2 else { return 0 }
        
        let dimensions = ["countryOfBirth", "languageAtHome", "gender", "age"]
        var scores: [Double] = []
        
        for dimension in dimensions {
            var values: [String] = []
            
            switch dimension {
            case "age":
                values = attendees.map { ageToBracket($0.age) }
            case "countryOfBirth":
                values = attendees.map { $0.countryOfBirth }
            case "languageAtHome":
                values = attendees.map { $0.languageAtHome }
            case "gender":
                values = attendees.map { $0.gender }
            default:
                continue
            }
            
            let nonEmptyValues = values.filter { !$0.isEmpty }
            let uniqueCount = Set(nonEmptyValues).count
            let score = count > 1 ? max(0, min(1, Double(uniqueCount - 1) / Double(count - 1))) : 0
            scores.append(score)
        }
        
        let averageScore = scores.reduce(0, +) / Double(scores.count)
        return Int(round(averageScore * 100))
    }
    
    // MARK: - Age Bracket Conversion
    static func ageToBracket(_ age: Int) -> String {
        switch age {
        case 0..<18:
            return "<18"
        case 18...24:
            return "18–24"
        case 25...34:
            return "25–34"
        case 35...49:
            return "35–49"
        case 50...64:
            return "50–64"
        default:
            return "65+"
        }
    }
    
    // MARK: - Discount Calculation
    static func discountRate(for score: Int) -> Double {
        switch score {
        case 85...100:
            return 0.25 // 25%
        case 70...84:
            return 0.15 // 15%
        case 50...69:
            return 0.10 // 10%
        case 30...49:
            return 0.05 // 5%
        default:
            return 0.0  // 0%
        }
    }
    
    // MARK: - Discount Description
    static func discountDescription(for score: Int) -> String {
        let percentage = Int(discountRate(for: score) * 100)
        return "\(percentage)%"
    }
    
    // MARK: - Meter Color
    static func meterColor(for score: Int) -> String {
        switch score {
        case 85...100:
            return "green"
        case 70...84:
            return "lime"
        case 50...69:
            return "orange"
        case 30...49:
            return "red"
        default:
            return "gray"
        }
    }
}