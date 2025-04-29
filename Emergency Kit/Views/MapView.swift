import SwiftUI
import MapKit

// MARK: - Map View
extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center.latitude == rhs.center.latitude &&
               lhs.center.longitude == rhs.center.longitude &&
               lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
               lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

enum LocationErrorType {
    case denied
    case disabled
    
    var title: String {
        switch self {
        case .denied:
            return "Location Access Required"
        case .disabled:
            return "Location Services Disabled"
        }
    }
    
    var message: String {
        switch self {
        case .denied:
            return "Emergency Kit needs location access to show nearby emergency services. Please enable location access in Settings."
        case .disabled:
            return "Please enable Location Services in your device settings to find nearby emergency services."
        }
    }
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3361, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedPlace: EmergencyPlace?
    @State private var showingPlaceDetails = false
    @State private var searchText = ""
    @State private var places: [EmergencyPlace] = []
    @State private var selectedFilter: EmergencyPlace.PlaceType?
    @State private var isTrackingLocation = false
    @State private var showLocationError = false
    @State private var locationErrorType: LocationErrorType = LocationErrorType.denied
    @State private var lastSearchRegion: MKCoordinateRegion?
    @State private var isSearching = false
    
    // Constants for region change threshold
    private let searchThreshold = 0.7 // 70% of the visible region needs to be new to trigger a search
    
    var filteredPlaces: [EmergencyPlace] {
        guard let filter = selectedFilter else { return places }
        return places.filter { $0.type == filter }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: filteredPlaces) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        VStack {
                            Image(systemName: place.type.icon)
                                .font(.system(size: 24))
                                .foregroundColor(place.type.color)
                                .background(
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 40, height: 40)
                                        .shadow(radius: 2)
                                )
                                .onTapGesture {
                                    selectedPlace = place
                                    showingPlaceDetails = true
                                }
                        }
                    }
                }
                .onChange(of: region) { newRegion in
                    handleRegionChange(newRegion)
                }
                
                VStack {
                    if !locationManager.locationServicesEnabled || locationManager.authorizationStatus == .denied {
                        LocationPermissionBanner(errorType: locationManager.locationServicesEnabled ? .denied : .disabled) {
                            openSettings()
                        }
                        .transition(.move(edge: .top))
                    }
                    
                    Spacer()
                    
                    // Place Details Card or Filter Menu
                    if showingPlaceDetails, let place = selectedPlace {
                        PlaceDetailCard(place: place, isShowing: $showingPlaceDetails)
                            .transition(.move(edge: .bottom))
                            .animation(.spring(), value: showingPlaceDetails)
                    } else {
                        // Bottom Filter Menu
                        VStack(spacing: 0) {
                            Divider()
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    // Emergency Services
                                    FilterButton(
                                        type: .hospital,
                                        isSelected: selectedFilter == .hospital,
                                        action: { toggleFilter(.hospital) }
                                    )
                                    FilterButton(
                                        type: .pharmacy,
                                        isSelected: selectedFilter == .pharmacy,
                                        action: { toggleFilter(.pharmacy) }
                                    )
                                    FilterButton(
                                        type: .police,
                                        isSelected: selectedFilter == .police,
                                        action: { toggleFilter(.police) }
                                    )
                                    FilterButton(
                                        type: .fireStation,
                                        isSelected: selectedFilter == .fireStation,
                                        action: { toggleFilter(.fireStation) }
                                    )
                                    
                                    // Essential Services
                                    FilterButton(
                                        type: .restaurant,
                                        isSelected: selectedFilter == .restaurant,
                                        action: { toggleFilter(.restaurant) }
                                    )
                                    FilterButton(
                                        type: .grocery,
                                        isSelected: selectedFilter == .grocery,
                                        action: { toggleFilter(.grocery) }
                                    )
                                    FilterButton(
                                        type: .convenience,
                                        isSelected: selectedFilter == .convenience,
                                        action: { toggleFilter(.convenience) }
                                    )
                                    FilterButton(
                                        type: .gasStation,
                                        isSelected: selectedFilter == .gasStation,
                                        action: { toggleFilter(.gasStation) }
                                    )
                                    
                                    if selectedFilter != nil {
                                        Button(action: { selectedFilter = nil }) {
                                            Text("All")
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                            .background(Color(.systemBackground))
                        }
                    }
                }
                
                // Location Button (Bottom Right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            handleLocationButtonTap()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 56, height: 56)
                                    .shadow(radius: 4)
                                
                                Image(systemName: locationButtonIcon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(locationButtonColor)
                            }
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, showingPlaceDetails ? 300 : 110) // Adjust based on card visibility
                    }
                }
            }
            .navigationTitle("Emergency Locations")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestAuthorization()
                } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                          locationManager.authorizationStatus == .authorizedAlways {
                    locationManager.startUpdatingLocation()
                }
            }
        }
    }
    
    private var locationButtonIcon: String {
        if !locationManager.locationServicesEnabled || locationManager.authorizationStatus == .denied {
            return "location.slash"
        }
        return isTrackingLocation ? "location.fill" : "location"
    }
    
    private var locationButtonColor: Color {
        if !locationManager.locationServicesEnabled || locationManager.authorizationStatus == .denied {
            return .red
        }
        return isTrackingLocation ? .blue : .gray
    }
    
    private func handleLocationButtonTap() {
        if !locationManager.locationServicesEnabled {
            locationErrorType = LocationErrorType.disabled
            showLocationError = true
            return
        }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAuthorization()
        case .restricted, .denied:
            locationErrorType = LocationErrorType.denied
            showLocationError = true
        case .authorizedWhenInUse, .authorizedAlways:
            toggleLocationTracking()
        @unknown default:
            break
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func toggleLocationTracking() {
        isTrackingLocation.toggle()
        if isTrackingLocation {
            locationManager.startUpdatingLocation()
            if let location = locationManager.location {
                withAnimation {
                    region.center = location.coordinate
                    region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                }
            }
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
    
    private func toggleFilter(_ type: EmergencyPlace.PlaceType) {
        if selectedFilter == type {
            selectedFilter = nil
        } else {
            selectedFilter = type
            searchNearbyPlaces()
        }
    }
    
    private func searchNearbyPlaces() {
        searchInCurrentRegion()
    }
    
    private func handleRegionChange(_ newRegion: MKCoordinateRegion) {
        guard !isSearching else { return }
        
        // Check if we have searched this region before
        if let lastRegion = lastSearchRegion {
            let overlap = calculateRegionOverlap(lastRegion, newRegion)
            
            // Only search if the overlap is less than our threshold
            if overlap < searchThreshold {
                searchInCurrentRegion()
            }
        } else {
            // First time searching
            searchInCurrentRegion()
        }
    }
    
    private func calculateRegionOverlap(_ region1: MKCoordinateRegion, _ region2: MKCoordinateRegion) -> Double {
        // Calculate the intersection of the two regions
        let minLat = max(
            region1.center.latitude - region1.span.latitudeDelta/2,
            region2.center.latitude - region2.span.latitudeDelta/2
        )
        let maxLat = min(
            region1.center.latitude + region1.span.latitudeDelta/2,
            region2.center.latitude + region2.span.latitudeDelta/2
        )
        let minLon = max(
            region1.center.longitude - region1.span.longitudeDelta/2,
            region2.center.longitude - region2.span.longitudeDelta/2
        )
        let maxLon = min(
            region1.center.longitude + region1.span.longitudeDelta/2,
            region2.center.longitude + region2.span.longitudeDelta/2
        )
        
        // If there's no overlap, return 0
        if minLat > maxLat || minLon > maxLon {
            return 0
        }
        
        // Calculate areas
        let intersectionArea = (maxLat - minLat) * (maxLon - minLon)
        let region1Area = region1.span.latitudeDelta * region1.span.longitudeDelta
        let region2Area = region2.span.latitudeDelta * region2.span.longitudeDelta
        
        // Return the ratio of intersection to the smaller region
        return intersectionArea / min(region1Area, region2Area)
    }
    
    private func searchInCurrentRegion() {
        guard !isSearching else { return }
        isSearching = true
        
        let request = MKLocalSearch.Request()
        
        // Set the search query based on the selected filter or default to "hospital"
        if let filter = selectedFilter {
            switch filter {
            case .hospital:
                request.naturalLanguageQuery = "hospital medical center urgent care"
            case .police:
                request.naturalLanguageQuery = "police station law enforcement"
            case .fireStation:
                request.naturalLanguageQuery = "fire station"
            case .pharmacy:
                request.naturalLanguageQuery = "pharmacy drugstore"
            case .restaurant:
                request.naturalLanguageQuery = "restaurant food"
            case .grocery:
                request.naturalLanguageQuery = "grocery supermarket"
            case .convenience:
                request.naturalLanguageQuery = "convenience store"
            case .gasStation:
                request.naturalLanguageQuery = "gas station fuel"
            case .other:
                request.naturalLanguageQuery = searchText.isEmpty ? "hospital" : searchText
            }
        } else {
            request.naturalLanguageQuery = searchText.isEmpty ? "hospital" : searchText
        }
        
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            
            if let error = error {
                print("Search error: \(error)")
                return
            }
            
            guard let response = response else {
                return
            }
            
            // Update places and last search region
            self.places = response.mapItems.map { item in
                EmergencyPlace(
                    name: item.name ?? "",
                    coordinate: item.placemark.coordinate,
                    address: item.placemark.title ?? "",
                    phone: item.phoneNumber ?? "N/A",
                    type: .determineType(from: item)
                )
            }
            
            self.lastSearchRegion = self.region
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var locationError: Error?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationServicesEnabled: Bool = CLLocationManager.locationServicesEnabled()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.allowsBackgroundLocationUpdates = false
        
        // Instead of checking authorization here, we'll wait for the delegate callback
        authorizationStatus = manager.authorizationStatus
        locationServicesEnabled = CLLocationManager.locationServicesEnabled()
    }
    
    func requestAuthorization() {
        // Only request if not determined yet
        if authorizationStatus == .notDetermined {
            DispatchQueue.main.async {
                self.manager.requestWhenInUseAuthorization()
            }
        }
    }
    
    func startUpdatingLocation() {
        guard locationServicesEnabled else { return }
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else { return }
        
        DispatchQueue.main.async {
            self.manager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        DispatchQueue.main.async {
            self.manager.stopUpdatingLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            self.locationServicesEnabled = CLLocationManager.locationServicesEnabled()
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdatingLocation()
            case .restricted, .denied:
                self.stopUpdatingLocation()
            case .notDetermined:
                // Wait for user response
                break
            @unknown default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.location = locations.last
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = error
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.stopUpdatingLocation()
                default:
                    break
                }
            }
        }
    }
}

// MARK: - Place Detail Card
struct PlaceDetailCard: View {
    let place: EmergencyPlace
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with close button
            HStack {
                Image(systemName: place.type.icon)
                    .foregroundColor(place.type.color)
                    .font(.system(size: 24))
                
                Text(place.name)
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                }
            }
            
            // Address
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.gray)
                Text(place.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Phone
            if place.phone != "N/A" {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.gray)
                    Text(place.phone)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Get directions
                    let placemark = MKPlacemark(coordinate: place.coordinate)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = place.name
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                }) {
                    HStack {
                        Image(systemName: "car.fill")
                        Text("Directions")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                if place.phone != "N/A" {
                    Button(action: {
                        // Call location
                        guard let url = URL(string: "tel://\(place.phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))") else { return }
                        UIApplication.shared.open(url)
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Call")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let type: EmergencyPlace.PlaceType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                Text(type.title)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? type.color.opacity(0.2) : Color.blue.opacity(0.1))
            .foregroundColor(isSelected ? type.color : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Location Permission Banner
struct LocationPermissionBanner: View {
    let errorType: LocationErrorType
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "location.slash.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(errorType.title)
                        .font(.headline)
                    
                    Text(errorType.message)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: action) {
                    Text("Enable")
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
} 