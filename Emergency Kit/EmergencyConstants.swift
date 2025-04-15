import Foundation
import CoreLocation

enum EmergencyConstants {
    static let defaultServices: [DefaultService] = [
        DefaultService(
            name: "Emergency Services (Police/Fire/Medical)",
            type: "emergency",
            phone: "911",
            address: "National Emergency Number"
        ),
        DefaultService(
            name: "Poison Control Center",
            type: "emergency",
            phone: "1-800-222-1222",
            address: "National Poison Control"
        ),
        DefaultService(
            name: "Local Police Department",
            type: "police",
            phone: "911",
            address: "Local Law Enforcement"
        ),
        DefaultService(
            name: "Local Fire Department",
            type: "fire",
            phone: "911",
            address: "Local Fire Services"
        ),
        DefaultService(
            name: "Local Hospital",
            type: "hospital",
            phone: "911",
            address: "Nearest Emergency Room"
        ),
        DefaultService(
            name: "Local Pharmacy",
            type: "pharmacy",
            phone: "000-000-0000",
            address: "Nearest 24-Hour Pharmacy"
        )
    ]
    
    static func defaultEmergencyPlaces(userLocation: CLLocationCoordinate2D?) -> [EmergencyPlace] {
        let defaultLocation = userLocation ?? CLLocationCoordinate2D(latitude: 37.3361, longitude: -122.0090)
        
        return defaultServices.map { service in
            EmergencyPlace(
                name: service.name,
                coordinate: defaultLocation,
                address: service.address,
                phone: service.phone,
                type: service.emergencyType
            )
        }
    }
} 