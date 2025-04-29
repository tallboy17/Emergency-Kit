import SwiftUI
import MapKit

// MARK: - Emergency Place Model
struct EmergencyPlace: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let phone: String
    let type: PlaceType
    
    enum PlaceType {
        case hospital
        case police
        case fireStation
        case pharmacy
        case restaurant
        case grocery
        case convenience
        case gasStation
        case other
        
        var icon: String {
            switch self {
            case .hospital: return "cross.circle.fill"
            case .police: return "shield.fill"
            case .fireStation: return "building.2.fill"
            case .pharmacy: return "pills.fill"
            case .restaurant: return "fork.knife"
            case .grocery: return "cart.fill"
            case .convenience: return "basket.fill"
            case .gasStation: return "fuelpump.fill"
            case .other: return "mappin.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .hospital: return .red
            case .police: return .blue
            case .fireStation: return .orange
            case .pharmacy: return .green
            case .restaurant: return .purple
            case .grocery: return .green
            case .convenience: return .blue
            case .gasStation: return .yellow
            case .other: return .gray
            }
        }
        
        var title: String {
            switch self {
            case .hospital: return "Hospitals"
            case .police: return "Police"
            case .fireStation: return "Fire"
            case .pharmacy: return "Pharmacy"
            case .restaurant: return "Food"
            case .grocery: return "Grocery"
            case .convenience: return "Stores"
            case .gasStation: return "Gas"
            case .other: return "Other"
            }
        }
        
        static func determineType(from item: MKMapItem) -> PlaceType {
            let category = item.pointOfInterestCategory
            let name = item.name?.lowercased() ?? ""
            
            switch category {
            case .hospital:
                return .hospital
            case .police:
                return .police
            case .foodMarket:
                if name.contains("grocery") || name.contains("supermarket") {
                    return .grocery
                } else if name.contains("convenience") || name.contains("store") || name.contains("7-eleven") || name.contains("market") || name.contains("mart"){
                    return .convenience
                }
                return .restaurant
            case .gasStation:
                return .gasStation
            default:
                // Check name-based categories
                if name.contains("hospital") || name.contains("emergency") || name.contains("medical center") || name.contains("health center") || name.contains("urgent care") || name.contains("pediatric"){
                    return .hospital
                } else if name.contains("police") {
                    return .police
                } else if name.contains("fire") || name.contains("station") {
                    return .fireStation
                } else if name.contains("pharmacy") || name.contains("drugstore") {
                    return .pharmacy
                } else if name.contains("restaurant") || name.contains("cafe") || name.contains("food") {
                    return .restaurant
                } else if name.contains("grocery") || name.contains("supermarket") {
                    return .grocery
                } else if name.contains("convenience") || name.contains("store") || name.contains("mini market") || name.contains("7-eleven"){
                    return .convenience
                } else if name.contains("gas") || name.contains("fuel") {
                    return .gasStation
                }
                return .other
            }
        }
    }
}

// MARK: - Default Services
struct DefaultService: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let phone: String
    let address: String
    
    var emergencyType: EmergencyPlace.PlaceType {
        switch type.lowercased() {
        case "hospital": return .hospital
        case "police": return .police
        case "fire": return .fireStation
        case "pharmacy": return .pharmacy
        case "restaurant": return .restaurant
        case "grocery": return .grocery
        case "convenience": return .convenience
        case "gas": return .gasStation
        case "emergency": return .hospital
        default: return .other
        }
    }
} 