import SwiftUI
import MapKit
import PDFKit
import CoreData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(tabSelection: $selectedTab)
                .tabItem {
                    Label("SOS", systemImage: "exclamationmark.circle.fill")
                }
                .tag(0)
            
            ContactsView()
                .tabItem {
                    Label("Contacts", systemImage: "phone.fill")
                }
                .tag(1)
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "mappin.circle.fill")
                }
                .tag(2)
            
            EvacuationView()
                .tabItem {
                    Label("Evac", systemImage: "house.fill")
                }
                .tag(3)
            
            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis")
                }
                .tag(4)
        }
        .accentColor(.red)
    }
}

// MARK: - Home View
struct HomeView: View {
    @Binding var tabSelection: Int
    @State private var showingMedicalInfo = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    Text("Emergency Info")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.red)
                        .padding(.top, 20)
                    
                    // SOS Button
                    Button(action: {
                        // Handle SOS action
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 160, height: 160)
                                .shadow(radius: 5)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 144, height: 144)
                            
                            Text("SOS")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Quick Access Tiles
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        QuickTile(icon: "phone.fill", label: "Emergency Contacts", color: .blue) {
                            tabSelection = 1
                        }
                        
                        QuickTile(icon: "mappin.circle.fill", label: "Emergency Locations", color: .green) {
                            tabSelection = 2
                        }
                        
                        QuickTile(icon: "house.fill", label: "Evacuation Points", color: .orange) {
                            tabSelection = 3
                        }
                        
                        QuickTile(icon: "heart.fill", label: "Medical Info", color: .purple) {
                            showingMedicalInfo = true
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingMedicalInfo) {
                MedicalView()
            }
        }
    }
}

// MARK: - Contact Model
struct Contact: Identifiable, Codable {
    var id = UUID()
    var name: String
    var number: String
    var relationship: String?
    var isEmergencyService: Bool
}

// MARK: - Contacts View
struct ContactsView: View {
    @State private var contacts: [Contact] = []
    @State private var showingAddContact = false
    @State private var editingContact: Contact?
    
    var emergencyContacts: [Contact] {
        contacts.filter { $0.isEmergencyService }
    }
    
    var personalContacts: [Contact] {
        contacts.filter { !$0.isEmergencyService }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Emergency Services Section Label
                    HStack {
                        Text("🚨 Emergency Services")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Emergency Services
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(emergencyContacts) { contact in
                            ContactItem(contact: contact) {
                                editingContact = contact
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                    
                    // Personal Contacts Section Label
                    HStack {
                        Text("👥 Personal Contacts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Personal Contacts
                    VStack(alignment: .leading, spacing: 4) {
                        if personalContacts.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 12) {
                                    Image(systemName: "person.2.slash")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No Personal Contacts")
                            .font(.headline)
                                        .foregroundColor(.gray)
                                    Text("Tap + to add contacts")
                                        .font(.subheadline)
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                                Spacer()
                            }
                            .padding(.vertical, 32)
                        } else {
                            ForEach(personalContacts) { contact in
                                ContactItem(contact: contact) {
                                    editingContact = contact
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                }
                .padding()
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddContact = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                ContactEditView(contacts: $contacts, contact: nil)
            }
            .sheet(item: $editingContact) { contact in
                ContactEditView(contacts: $contacts, contact: contact)
            }
        }
        .onAppear(perform: loadContacts)
    }
    
    private func loadContacts() {
        if let data = UserDefaults.standard.data(forKey: "savedContacts") {
            if let decoded = try? JSONDecoder().decode([Contact].self, from: data) {
                contacts = decoded
                return
            }
        }
        
        // Load default emergency contacts if no saved contacts
        contacts = [
            Contact(name: "Emergency (Police, Fire, Medical)", number: "911", isEmergencyService: true),
            Contact(name: "Poison Control", number: "1-800-222-1222", isEmergencyService: true)
        ]
        saveContacts()
    }
    
    private func saveContacts() {
        if let encoded = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(encoded, forKey: "savedContacts")
        }
    }
}

// MARK: - Contact Edit View
struct ContactEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var contacts: [Contact]
    let contact: Contact?
    
    @State private var name: String = ""
    @State private var number: String = ""
    @State private var relationship: String = ""
    @State private var isEmergencyService: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $number)
                        .keyboardType(.phonePad)
                    TextField("Relationship (Optional)", text: $relationship)
                }
                
                Section {
                    Toggle("Emergency Service", isOn: $isEmergencyService)
                }
            }
            .navigationTitle(contact == nil ? "Add Contact" : "Edit Contact")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveContact()
                }
            )
        }
        .onAppear {
            if let contact = contact {
                name = contact.name
                number = contact.number
                relationship = contact.relationship ?? ""
                isEmergencyService = contact.isEmergencyService
            }
        }
    }
    
    private func saveContact() {
        let newContact = Contact(
            id: contact?.id ?? UUID(),
            name: name,
            number: number,
            relationship: relationship.isEmpty ? nil : relationship,
            isEmergencyService: isEmergencyService
        )
        
        if let existingIndex = contacts.firstIndex(where: { $0.id == contact?.id }) {
            contacts[existingIndex] = newContact
        } else {
            contacts.append(newContact)
        }
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(encoded, forKey: "savedContacts")
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Modified ContactItem
struct ContactItem: View {
    let contact: Contact
    var onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                
                // Contact Details
                VStack(alignment: .leading, spacing: 8) {
                    // Name
                    Text(contact.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    // Number with phone icon
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(contact.number)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    // Relationship badge if exists
                    if let relationship = contact.relationship {
                        HStack(spacing: 6) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 12))
                    .foregroundColor(.blue)
                            Text(relationship)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.vertical, 4)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    // Edit Button
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                    
                    // Call Button
                    Button(action: {
                        guard let url = URL(string: "tel://\(contact.number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))") else { return }
                        UIApplication.shared.open(url)
                    }) {
                ZStack {
                            Circle()
                                .fill(contact.isEmergencyService ? Color.red : Color.blue)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "phone.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }
}

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
            
            //print("📍 Place Category: \(String(describing: category))")
            //print("📍 Place Name: \(name)")
            
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

// MARK: - Evacuation Point Model
struct EvacuationPoint: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: EvacuationType
    var notes: String?
    var coordinate: EvacuationCoordinate
    
    struct EvacuationCoordinate: Codable {
        var latitude: Double
        var longitude: Double
        
        var clCoordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    enum EvacuationType: String, Codable, CaseIterable {
        case shelter = "Public Shelter"
        case meetingPoint = "Meeting Point"
        case personal = "Personal"
        
        var icon: String {
            switch self {
            case .shelter: return "building.2.fill"
            case .meetingPoint: return "figure.wave"
            case .personal: return "house.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .shelter: return .blue
            case .meetingPoint: return .green
            case .personal: return .orange
            }
        }
    }
}

// MARK: - Evacuation View
struct EvacuationView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3361, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var evacuationPoints: [EvacuationPoint] = []
    @State private var showingAddPoint = false
    @State private var selectedPoint: EvacuationPoint?
    @State private var showingPointDetails = false
    @State private var isEditingPoint = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: evacuationPoints) { point in
                    MapAnnotation(coordinate: point.coordinate.clCoordinate) {
                        Button(action: {
                            selectedPoint = point
                            showingPointDetails = true
                        }) {
                    VStack {
                                Image(systemName: point.type.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(point.type.color)
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 40, height: 40)
                                            .shadow(radius: 2)
                                    )
                                
                                Text(point.name)
                            .font(.caption)
                            .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(8)
                                    .shadow(radius: 1)
                            }
                        }
                    }
                }
                
                // Location Button
                    VStack {
                    Spacer()
                        HStack {
                            Spacer()
                        Button(action: {
                            if let location = locationManager.location {
                                withAnimation {
                                    region.center = location.coordinate
                                    region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                }
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.blue)
                                .frame(width: 50, height: 50)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 100)
                    }
                }
                
                // Add Button
                VStack {
                    Spacer()
                    Button(action: {
                        showingAddPoint = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Evacuation Point")
                        }
                        .padding()
                        .background(Color.blue)
                                    .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                    .padding(.bottom, 30)
                }
            }
            .sheet(isPresented: $showingAddPoint) {
                EvacuationPointEditView(
                    evacuationPoints: $evacuationPoints,
                    coordinate: region.center
                )
            }
            .sheet(item: $selectedPoint, onDismiss: { selectedPoint = nil }) { point in
                EvacuationPointDetailView(
                    point: point,
                    evacuationPoints: $evacuationPoints,
                    isPresented: $showingPointDetails
                )
            }
            .navigationTitle("Evacuation")
            .onAppear(perform: loadEvacuationPoints)
        }
    }
    
    private func loadEvacuationPoints() {
        if let data = UserDefaults.standard.data(forKey: "evacuationPoints") {
            if let decoded = try? JSONDecoder().decode([EvacuationPoint].self, from: data) {
                evacuationPoints = decoded
                
                // Center map on first point if available
                if let firstPoint = evacuationPoints.first {
                    region.center = firstPoint.coordinate.clCoordinate
                }
            }
        }
    }
}

// MARK: - Evacuation Point Edit View
struct EvacuationPointEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var evacuationPoints: [EvacuationPoint]
    let coordinate: CLLocationCoordinate2D
    var editingPoint: EvacuationPoint?
    
    @State private var name = ""
    @State private var type = EvacuationPoint.EvacuationType.meetingPoint
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(EvacuationPoint.EvacuationType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    TextField("Notes (Optional)", text: $notes)
                }
                
                Section(header: Text("Location")) {
                            HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        Text("Latitude: \(coordinate.latitude, specifier: "%.4f")")
                    }
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        Text("Longitude: \(coordinate.longitude, specifier: "%.4f")")
                    }
                }
            }
            .navigationTitle(editingPoint == nil ? "Add Point" : "Edit Point")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    savePoint()
                }
            )
            .onAppear {
                if let point = editingPoint {
                    name = point.name
                    type = point.type
                    notes = point.notes ?? ""
                }
            }
        }
    }
    
    private func savePoint() {
        let point = EvacuationPoint(
            id: editingPoint?.id ?? UUID(),
            name: name,
            type: type,
            notes: notes.isEmpty ? nil : notes,
            coordinate: EvacuationPoint.EvacuationCoordinate(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        )
        
        if let index = evacuationPoints.firstIndex(where: { $0.id == editingPoint?.id }) {
            evacuationPoints[index] = point
        } else {
            evacuationPoints.append(point)
        }
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(evacuationPoints) {
            UserDefaults.standard.set(encoded, forKey: "evacuationPoints")
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Evacuation Point Detail View
struct EvacuationPointDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let point: EvacuationPoint
    @Binding var evacuationPoints: [EvacuationPoint]
    @Binding var isPresented: Bool
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingDirectionsActionSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: point.type.icon)
                            .foregroundColor(point.type.color)
                            .font(.system(size: 24))
                                VStack(alignment: .leading) {
                            Text(point.name)
                                        .font(.headline)
                            Text(point.type.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                    }
                    .padding(.vertical, 8)
                }
                
                if let notes = point.notes {
                    Section(header: Text("Notes")) {
                        Text(notes)
                    }
                }
                
                Section(header: Text("Actions")) {
                                Button(action: {
                        showingDirectionsActionSheet = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                .foregroundColor(.blue)
                            Text("Get Directions")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                                }
                                
                                Button(action: {
                        openInMaps()
                    }) {
                        HStack {
                            Image(systemName: "map.fill")
                                        .foregroundColor(.blue)
                            Text("View in Maps")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Location")) {
                    HStack {
                        Text("Latitude")
                        Spacer()
                        Text("\(point.coordinate.latitude, specifier: "%.4f")")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Longitude")
                        Spacer()
                        Text("\(point.coordinate.longitude, specifier: "%.4f")")
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete Point")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Point Details")
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Edit") {
                    showingEditSheet = true
                }
            )
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Evacuation Point"),
                    message: Text("Are you sure you want to delete this evacuation point? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        deletePoint()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingEditSheet) {
                EvacuationPointEditView(
                    evacuationPoints: $evacuationPoints,
                    coordinate: point.coordinate.clCoordinate,
                    editingPoint: point
                )
            }
            .actionSheet(isPresented: $showingDirectionsActionSheet) {
                ActionSheet(
                    title: Text("Get Directions"),
                    message: Text("Choose your preferred mode of transportation"),
                    buttons: [
                        .default(Text("🚗 Driving")) {
                            getDirections(mode: .driving)
                        },
                        .default(Text("🚶‍♂️ Walking")) {
                            getDirections(mode: .walking)
                        },
                        .default(Text("🚲 Cycling")) {
                            getDirections(mode: .cycling)
                        },
                        .default(Text("🚌 Transit")) {
                            getDirections(mode: .transit)
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
    
    private func getDirections(mode: TransportMode) {
        let placemark = MKPlacemark(coordinate: point.coordinate.clCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = point.name
        
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: mode.mapKitValue
        ]
        
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: point.coordinate.clCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = point.name
        mapItem.openInMaps(launchOptions: nil)
    }
    
    private func deletePoint() {
        evacuationPoints.removeAll { $0.id == point.id }
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(evacuationPoints) {
            UserDefaults.standard.set(encoded, forKey: "evacuationPoints")
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Transport Mode
enum TransportMode {
    case driving
    case walking
    case cycling
    case transit
    
    var mapKitValue: String {
        switch self {
        case .driving:
            return MKLaunchOptionsDirectionsModeDriving
        case .walking:
            return MKLaunchOptionsDirectionsModeWalking
        case .cycling:
            return MKLaunchOptionsDirectionsModeDefault // No direct cycling option in MapKit
        case .transit:
            return MKLaunchOptionsDirectionsModeTransit
        }
    }
}

// MARK: - Medical Info Model
struct MedicalInfo: Codable {
    var personalInfo: PersonalInfo
    var conditions: [MedicalCondition]
    var medications: [Medication]
    var allergies: [Allergy]
    var mentalHealth: [MentalHealthCondition]
    
    struct PersonalInfo: Codable {
        var name: String
        var dateOfBirth: String
        var bloodType: String
        var weight: String
        var height: String
        var emergencyContact: String
    }
    
    struct MedicalCondition: Codable, Identifiable {
        var id = UUID()
        var name: String
        var severity: String
        var notes: String
    }
    
    struct Medication: Codable, Identifiable {
        var id = UUID()
        var name: String
        var dosage: String
        var frequency: String
        var notes: String
    }
    
    struct Allergy: Codable, Identifiable {
        var id = UUID()
        var allergen: String
        var severity: String
        var reaction: String
        var treatment: String
    }
    
    struct MentalHealthCondition: Codable, Identifiable {
        var id = UUID()
        var condition: String
        var diagnosis: String
        var provider: String
        var treatment: String
        var notes: String
    }
    
    static var empty: MedicalInfo {
        MedicalInfo(
            personalInfo: PersonalInfo(
                name: "",
                dateOfBirth: "",
                bloodType: "",
                weight: "",
                height: "",
                emergencyContact: ""
            ),
            conditions: [],
            medications: [],
            allergies: [],
            mentalHealth: []
        )
    }
}

// MARK: - Medical View
struct MedicalView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var medicalInfo: MedicalInfo = .empty
    @State private var isEditingPersonalInfo = false
    @State private var showingAddCondition = false
    @State private var showingAddMedication = false
    @State private var showingAddAllergy = false
    @State private var showingAddMentalHealth = false
    @State private var editingCondition: MedicalInfo.MedicalCondition?
    @State private var editingMedication: MedicalInfo.Medication?
    @State private var editingAllergy: MedicalInfo.Allergy?
    @State private var editingMentalHealth: MedicalInfo.MentalHealthCondition?
    
    var body: some View {
        NavigationView {
            List {
                // Personal Information Section
                Section(header: Text("Personal Information")) {
                    PersonalInfoRow(title: "Name", value: medicalInfo.personalInfo.name)
                    PersonalInfoRow(title: "Date of Birth", value: medicalInfo.personalInfo.dateOfBirth)
                    PersonalInfoRow(title: "Blood Type", value: medicalInfo.personalInfo.bloodType)
                    PersonalInfoRow(title: "Weight", value: medicalInfo.personalInfo.weight)
                    PersonalInfoRow(title: "Height", value: medicalInfo.personalInfo.height)
                    PersonalInfoRow(title: "Emergency Contact", value: medicalInfo.personalInfo.emergencyContact)
                }
                .headerProminence(.increased)
                
                // Allergies Section
                Section(header: ListSectionHeader(title: "Allergies", action: { showingAddAllergy = true })) {
                    if medicalInfo.allergies.isEmpty {
                        Text("No allergies added")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(medicalInfo.allergies) { allergy in
                            AllergyRow(allergy: allergy)
                                .onTapGesture {
                                    editingAllergy = allergy
                                }
                        }
                    }
                }
                .headerProminence(.increased)
                
                // Medical Conditions Section
                Section(header: ListSectionHeader(title: "Medical Conditions", action: { showingAddCondition = true })) {
                    if medicalInfo.conditions.isEmpty {
                        Text("No medical conditions added")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(medicalInfo.conditions) { condition in
                            ConditionRow(condition: condition)
                                .onTapGesture {
                                    editingCondition = condition
                                }
                        }
                    }
                }
                .headerProminence(.increased)
                
                // Mental Health Section
                Section(header: ListSectionHeader(title: "Mental Health", action: { showingAddMentalHealth = true })) {
                    if medicalInfo.mentalHealth.isEmpty {
                        Text("No mental health conditions added")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(medicalInfo.mentalHealth) { condition in
                            MentalHealthRow(condition: condition)
                                .onTapGesture {
                                    editingMentalHealth = condition
                                }
                        }
                    }
                }
                .headerProminence(.increased)
                
                // Medications Section
                Section(header: ListSectionHeader(title: "Medications", action: { showingAddMedication = true })) {
                    if medicalInfo.medications.isEmpty {
                        Text("No medications added")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(medicalInfo.medications) { medication in
                            MedicationRow(medication: medication)
                                .onTapGesture {
                                    editingMedication = medication
                                }
                        }
                    }
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Medical Info")
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Edit Info") {
                    isEditingPersonalInfo = true
                }
            )
            .sheet(isPresented: $isEditingPersonalInfo) {
                PersonalInfoEditView(personalInfo: $medicalInfo.personalInfo)
            }
            .sheet(isPresented: $showingAddCondition) {
                ConditionEditView(conditions: $medicalInfo.conditions)
            }
            .sheet(item: $editingCondition) { condition in
                ConditionEditView(conditions: $medicalInfo.conditions, editingCondition: condition)
            }
            .sheet(isPresented: $showingAddMedication) {
                MedicationEditView(medications: $medicalInfo.medications)
            }
            .sheet(item: $editingMedication) { medication in
                MedicationEditView(medications: $medicalInfo.medications, editingMedication: medication)
            }
            .sheet(isPresented: $showingAddAllergy) {
                AllergyEditView(allergies: $medicalInfo.allergies)
            }
            .sheet(item: $editingAllergy) { allergy in
                AllergyEditView(allergies: $medicalInfo.allergies, editingAllergy: allergy)
            }
            .sheet(isPresented: $showingAddMentalHealth) {
                MentalHealthEditView(conditions: $medicalInfo.mentalHealth)
            }
            .sheet(item: $editingMentalHealth) { condition in
                MentalHealthEditView(conditions: $medicalInfo.mentalHealth, editingCondition: condition)
            }
            .onAppear(perform: loadMedicalInfo)
        }
    }
    
    private func loadMedicalInfo() {
        if let data = UserDefaults.standard.data(forKey: "medicalInfo") {
            if let decoded = try? JSONDecoder().decode(MedicalInfo.self, from: data) {
                medicalInfo = decoded
                return
            }
        }
        medicalInfo = .empty
    }
}

// MARK: - Personal Info Edit View
struct PersonalInfoEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var personalInfo: MedicalInfo.PersonalInfo
    
    @State private var name: String = ""
    @State private var dateOfBirth: String = ""
    @State private var bloodType: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var emergencyContact: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Date of Birth", text: $dateOfBirth)
                    TextField("Blood Type", text: $bloodType)
                    TextField("Weight", text: $weight)
                    TextField("Height", text: $height)
                    TextField("Emergency Contact", text: $emergencyContact)
                }
            }
            .navigationTitle("Edit Personal Info")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    savePersonalInfo()
                }
            )
            .onAppear {
                name = personalInfo.name
                dateOfBirth = personalInfo.dateOfBirth
                bloodType = personalInfo.bloodType
                weight = personalInfo.weight
                height = personalInfo.height
                emergencyContact = personalInfo.emergencyContact
            }
        }
    }
    
    private func savePersonalInfo() {
        personalInfo = MedicalInfo.PersonalInfo(
            name: name,
            dateOfBirth: dateOfBirth,
            bloodType: bloodType,
            weight: weight,
            height: height,
            emergencyContact: emergencyContact
        )
        saveMedicalInfo()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveMedicalInfo() {
        if let encoded = try? JSONEncoder().encode(personalInfo) {
            UserDefaults.standard.set(encoded, forKey: "medicalInfo")
        }
    }
}

// MARK: - Condition Edit View
struct ConditionEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var conditions: [MedicalInfo.MedicalCondition]
    var editingCondition: MedicalInfo.MedicalCondition?
    
    @State private var name: String = ""
    @State private var severity: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Condition Details")) {
                    TextField("Condition Name", text: $name)
                    TextField("Severity", text: $severity)
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle(editingCondition == nil ? "Add Condition" : "Edit Condition")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveCondition()
                }
            )
            .onAppear {
                if let condition = editingCondition {
                    name = condition.name
                    severity = condition.severity
                    notes = condition.notes
                }
            }
        }
    }
    
    private func saveCondition() {
        let condition = MedicalInfo.MedicalCondition(
            id: editingCondition?.id ?? UUID(),
            name: name,
            severity: severity,
            notes: notes
        )
        
        if let index = conditions.firstIndex(where: { $0.id == editingCondition?.id }) {
            conditions[index] = condition
        } else {
            conditions.append(condition)
        }
        
        saveMedicalInfo()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveMedicalInfo() {
        if let encoded = try? JSONEncoder().encode(conditions) {
            UserDefaults.standard.set(encoded, forKey: "medicalConditions")
        }
    }
}

// MARK: - Medication Edit View
struct MedicationEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var medications: [MedicalInfo.Medication]
    var editingMedication: MedicalInfo.Medication?
    
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var frequency: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage", text: $dosage)
                    TextField("Frequency", text: $frequency)
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle(editingMedication == nil ? "Add Medication" : "Edit Medication")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveMedication()
                }
            )
            .onAppear {
                if let medication = editingMedication {
                    name = medication.name
                    dosage = medication.dosage
                    frequency = medication.frequency
                    notes = medication.notes
                }
            }
        }
    }
    
    private func saveMedication() {
        let medication = MedicalInfo.Medication(
            id: editingMedication?.id ?? UUID(),
            name: name,
            dosage: dosage,
            frequency: frequency,
            notes: notes
        )
        
        if let index = medications.firstIndex(where: { $0.id == editingMedication?.id }) {
            medications[index] = medication
        } else {
            medications.append(medication)
        }
        
        saveMedicalInfo()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveMedicalInfo() {
        if let encoded = try? JSONEncoder().encode(medications) {
            UserDefaults.standard.set(encoded, forKey: "medicalMedications")
        }
    }
}

// MARK: - Supporting Views
struct PersonalInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value.isEmpty ? "Not Set" : value)
                .foregroundColor(value.isEmpty ? .gray : .primary)
        }
    }
}

struct ConditionRow: View {
    let condition: MedicalInfo.MedicalCondition
    
    var body: some View {
                    VStack(alignment: .leading, spacing: 4) {
            Text(condition.name)
                            .font(.headline)
            if !condition.severity.isEmpty {
                Text("Severity: \(condition.severity)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if !condition.notes.isEmpty {
                Text(condition.notes)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MedicationRow: View {
    let medication: MedicalInfo.Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(medication.name)
                .font(.headline)
            if !medication.dosage.isEmpty {
                Text("Dosage: \(medication.dosage)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if !medication.frequency.isEmpty {
                Text("Frequency: \(medication.frequency)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if !medication.notes.isEmpty {
                Text(medication.notes)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ListSectionHeader: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button(action: action) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - More View
struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: MedicalView()) {
                    Label("Medical Info", systemImage: "heart.fill")
                }
                
                NavigationLink(destination: DocumentsView()) {
                    Label("Documents", systemImage: "doc.text.fill")
                }
                
                NavigationLink(destination: GuidelineView()) {
                    Label("Guidelines", systemImage: "book.fill")
                }
                
                NavigationLink(destination: ProfileView()) {
                    Label("Profile", systemImage: "person.fill")
                }
                
                Section {
                    Button(action: {
                        // App settings
                    }) {
                        Label("Settings", systemImage: "gear")
                    }
                    
                    Button(action: {
                        // Help section
                    }) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("More")
        }
    }
}

// MARK: - Components
struct QuickTile: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundColor(.black)
                }
                
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
    }
}

struct InfoItem: View {
    let label: String
    let value: String
    var highlight: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(highlight ? .red : .primary)
        }
        .padding(.vertical, 8)
        .overlay(
            Divider()
                .background(Color(UIColor.systemGray5))
                .offset(y: 19),
            alignment: .bottom
        )
    }
}

struct DocumentItem: View {
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .foregroundColor(Color(UIColor.systemGray2))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Button("View") {
                // View document
            }
            .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
        .overlay(
            Divider()
                .background(Color(UIColor.systemGray5))
                .offset(y: 19),
            alignment: .bottom
        )
    }
}

struct EvacuationItem: View {
    let title: String
    let distance: String
    let type: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 36, height: 36)
                
                Image(systemName: "house.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                
                Text("\(distance) • \(type)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                // Show on map
            }) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.vertical, 8)
        .overlay(
            Divider()
                .background(Color(UIColor.systemGray5))
                .offset(y: 19),
            alignment: .bottom
        )
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

// MARK: - Document Models
class DocumentManager: ObservableObject {
    static let shared = DocumentManager()
    
    @Published var documents: [PDFDocument] = []
    @Published var tags: [Tag] = []
    
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    private let documentsKey = "savedDocuments"
    private let tagsKey = "savedTags"
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentsDirectory = documentsPath.appendingPathComponent("PDFs", isDirectory: true)
        
        // Create PDFs directory if it doesn't exist
        if !fileManager.fileExists(atPath: documentsDirectory.path) {
            try? fileManager.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
        }
        
        loadDocuments()
        loadTags()
    }
    
    func loadDocuments() {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            
            // Load saved documents from UserDefaults
            if let savedData = UserDefaults.standard.data(forKey: documentsKey),
               let savedDocuments = try? JSONDecoder().decode([PDFDocument].self, from: savedData) {
                documents = savedDocuments
            } else {
                // If no saved documents, create new ones from files
                documents = fileURLs.compactMap { fileURL in
                    PDFDocument(
                        name: fileURL.deletingPathExtension().lastPathComponent,
                        url: fileURL,
                        tags: []
                    )
                }
                saveDocuments()
            }
        } catch {
            print("Error loading documents: \(error)")
        }
    }
    
    func loadTags() {
        if let savedData = UserDefaults.standard.data(forKey: tagsKey),
           let savedTags = try? JSONDecoder().decode([Tag].self, from: savedData) {
            tags = savedTags
        }
    }
    
    func saveDocument(_ document: PDFDocument) {
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index] = document
        } else {
            documents.append(document)
        }
        saveDocuments()
    }
    
    func updateDocumentTags(_ document: PDFDocument, tags: [Tag]) {
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            var updatedDocument = documents[index]
            updatedDocument.tags = tags
            documents[index] = updatedDocument
            saveDocuments()
        }
    }
    
    func addTag(_ tag: Tag) {
        if !tags.contains(where: { $0.id == tag.id }) {
            tags.append(tag)
            saveTags()
        }
    }
    
    func removeTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
        // Remove tag from all documents
        for i in documents.indices {
            documents[i].tags.removeAll { $0.id == tag.id }
        }
        saveTags()
        saveDocuments()
    }
    
    func deleteDocument(_ document: PDFDocument) -> Bool {
        do {
            try fileManager.removeItem(at: document.url)
            documents.removeAll { $0.id == document.id }
            saveDocuments()
            return true
        } catch {
            print("Error deleting document: \(error)")
            return false
        }
    }
    
    private func saveDocuments() {
        if let encoded = try? JSONEncoder().encode(documents) {
            UserDefaults.standard.set(encoded, forKey: documentsKey)
        }
    }
    
    private func saveTags() {
        if let encoded = try? JSONEncoder().encode(tags) {
            UserDefaults.standard.set(encoded, forKey: tagsKey)
        }
    }
}

struct PDFDocument: Identifiable, Codable {
    let id: UUID
    var name: String
    let url: URL
    var tags: [Tag]
    let dateAdded: Date
    
    // Custom coding keys
    enum CodingKeys: String, CodingKey {
        case id, name, urlString, tags, dateAdded
    }
    
    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(url.absoluteString, forKey: .urlString)
        try container.encode(tags, forKey: .tags)
        try container.encode(dateAdded, forKey: .dateAdded)
    }
    
    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let urlString = try container.decode(String.self, forKey: .urlString)
        guard let url = URL(string: urlString) else {
            throw DecodingError.dataCorruptedError(forKey: .urlString, in: container, debugDescription: "Invalid URL string")
        }
        self.url = url
        tags = try container.decode([Tag].self, forKey: .tags)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
    }
    
    // Regular initializer
    init(id: UUID = UUID(), name: String, url: URL, tags: [Tag] = [], dateAdded: Date = Date()) {
        self.id = id
        self.name = name
        self.url = url
        self.tags = tags
        self.dateAdded = dateAdded
    }
}

struct Tag: Identifiable, Codable {
    let id: UUID
    var name: String
    var color: Color
    
    // Custom coding keys
    enum CodingKeys: String, CodingKey {
        case id, name, colorRed, colorGreen, colorBlue, colorAlpha
    }
    
    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        
        // Convert Color to components
        let components = color.components
        try container.encode(components.red, forKey: .colorRed)
        try container.encode(components.green, forKey: .colorGreen)
        try container.encode(components.blue, forKey: .colorBlue)
        try container.encode(components.alpha, forKey: .colorAlpha)
    }
    
    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        // Reconstruct Color from components
        let red = try container.decode(Double.self, forKey: .colorRed)
        let green = try container.decode(Double.self, forKey: .colorGreen)
        let blue = try container.decode(Double.self, forKey: .colorBlue)
        let alpha = try container.decode(Double.self, forKey: .colorAlpha)
        
        color = Color(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    // Regular initializer
    init(id: UUID = UUID(), name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

// Extension to get Color components
extension Color {
    var components: (red: Double, green: Double, blue: Double, alpha: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let uiColor = UIColor(self)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}

// MARK: - PDF Viewer
struct PDFViewer: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.backgroundColor = .systemBackground
        
        if let document = PDFKit.PDFDocument(url: url) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - Documents View
struct DocumentsView: View {
    @StateObject private var documentManager = DocumentManager.shared
    @State private var showingDocumentPicker = false
    @State private var selectedDocument: PDFDocument?
    @State private var showingDeleteAlert = false
    @State private var documentToDelete: PDFDocument?
    @State private var selectedTag: Tag?
    
    var filteredDocuments: [PDFDocument] {
        if let tag = selectedTag {
            return documentManager.documents.filter { document in
                document.tags.contains(where: { $0.id == tag.id })
            }
        }
        return documentManager.documents
    }
    
    var allTags: [Tag] {
        var uniqueTags: [Tag] = []
        for document in documentManager.documents {
            for tag in document.tags {
                if !uniqueTags.contains(where: { $0.id == tag.id }) {
                    uniqueTags.append(tag)
                }
            }
        }
        return uniqueTags.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Documents List
                List {
                    ForEach(filteredDocuments) { document in
                        DocumentRow(document: document) {
                            selectedDocument = document
                        } onDelete: {
                            documentToDelete = document
                            showingDeleteAlert = true
                        }
                    }
                }
                
                // Tag Filter Bar (Bottom)
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Divider()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Button(action: {
                                    selectedTag = nil
                                }) {
                                    HStack {
                                        Image(systemName: "tag.fill")
                                        Text("All Documents")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedTag == nil ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedTag == nil ? .blue : .gray)
                                    .cornerRadius(20)
                                }
                                
                                ForEach(allTags) { tag in
                                    Button(action: {
                                        selectedTag = tag
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(tag.color)
                                                .frame(width: 8, height: 8)
                                            Text(tag.name)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedTag?.id == tag.id ? tag.color.opacity(0.2) : Color.gray.opacity(0.1))
                                        .foregroundColor(selectedTag?.id == tag.id ? tag.color : .gray)
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            .padding()
                        }
                        .background(Color(UIColor.systemBackground))
                    }
                    .background(Color(UIColor.systemBackground))
                }
            }
            .navigationTitle("Documents")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingDocumentPicker = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker { document in
                    if let document = document {
                        documentManager.saveDocument(document)
                    }
                }
            }
            .sheet(item: $selectedDocument) { document in
                NavigationView {
                    PDFViewerView(document: document)
                }
            }
            .alert("Delete Document", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let document = documentToDelete {
                        _ = documentManager.deleteDocument(document)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this document? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Document Row
struct DocumentRow: View {
    let document: PDFDocument
    var onTap: () -> Void
    var onDelete: () -> Void
    @State private var showingTagEditor = false
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack {
                Image(systemName: "doc.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.name)
                        .font(.headline)
                    
                    Text(document.dateAdded.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if !document.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(document.tags) { tag in
                                    Text(tag.name)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(tag.color.opacity(0.2))
                                        .foregroundColor(tag.color)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingTagEditor = true
                }) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .sheet(isPresented: $showingTagEditor) {
            NavigationView {
                TagEditorView(document: document)
            }
        }
    }
}

// MARK: - Tag Editor View
struct TagEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    let document: PDFDocument
    @StateObject private var documentManager = DocumentManager.shared
    @State private var newTagName = ""
    @State private var selectedColor: Color = .blue
    @State private var showingColorPicker = false
    
    let availableColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        Form {
            Section(header: Text("Current Tags")) {
                if document.tags.isEmpty {
                    Text("No tags added")
                        .foregroundColor(.gray)
                } else {
                    ForEach(document.tags) { tag in
                        HStack {
                            Circle()
                                .fill(tag.color)
                                .frame(width: 12, height: 12)
                            Text(tag.name)
                            Spacer()
                            Button(action: {
                                removeTag(tag)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Add New Tag")) {
                TextField("Tag Name", text: $newTagName)
                
                HStack {
                    Text("Color")
                    Spacer()
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            showingColorPicker = true
                        }
                }
                
                if showingColorPicker {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(availableColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .onTapGesture {
                                        selectedColor = color
                                        showingColorPicker = false
                                    }
                            }
                        }
                    }
                }
                
                Button(action: addTag) {
                    Label("Add Tag", systemImage: "plus.circle.fill")
                }
                .disabled(newTagName.isEmpty)
            }
        }
        .navigationTitle("Edit Tags")
        .navigationBarItems(
            trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
    
    private func addTag() {
        let newTag = Tag(name: newTagName, color: selectedColor)
        documentManager.addTag(newTag)
        
        var updatedTags = document.tags
        updatedTags.append(newTag)
        documentManager.updateDocumentTags(document, tags: updatedTags)
        
        newTagName = ""
    }
    
    private func removeTag(_ tag: Tag) {
        var updatedTags = document.tags
        updatedTags.removeAll { $0.id == tag.id }
        documentManager.updateDocumentTags(document, tags: updatedTags)
    }
}

// MARK: - PDF Viewer View
struct PDFViewerView: View {
    let document: PDFDocument
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            PDFViewer(url: document.url)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationTitle(document.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

// MARK: - Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    var onDocumentPicked: (PDFDocument?) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let sourceURL = urls.first else { return }
            
            // Start accessing the security-scoped resource
            guard sourceURL.startAccessingSecurityScopedResource() else {
                return
            }
            
            // Create a permanent copy in the app's document directory
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let pdfsDirectory = documentsDirectory.appendingPathComponent("PDFs", isDirectory: true)
            let fileName = sourceURL.lastPathComponent
            let destinationURL = pdfsDirectory.appendingPathComponent(fileName)
            
            do {
                // Remove any existing file
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                // Copy the file
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                
                // Create PDFDocument with the file name
                let document = PDFDocument(
                    name: sourceURL.deletingPathExtension().lastPathComponent,
                    url: destinationURL,
                    tags: []
                )
                
                parent.onDocumentPicked(document)
            } catch {
                print("Error copying file: \(error.localizedDescription)")
                parent.onDocumentPicked(nil)
            }
            
            // Stop accessing the security-scoped resource
            sourceURL.stopAccessingSecurityScopedResource()
        }
    }
}

// MARK: - Supporting Views
struct DocumentCategoryHeader: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.headline)
            .foregroundColor(.primary)
    }
}

// MARK: - Allergy Edit View
struct AllergyEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var allergies: [MedicalInfo.Allergy]
    var editingAllergy: MedicalInfo.Allergy?
    
    @State private var allergen: String = ""
    @State private var severity: String = ""
    @State private var reaction: String = ""
    @State private var treatment: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allergy Details")) {
                    TextField("Allergen", text: $allergen)
                    TextField("Severity (e.g., Mild, Moderate, Severe)", text: $severity)
                    TextField("Reaction", text: $reaction)
                    TextField("Treatment/Action Required", text: $treatment)
                }
            }
            .navigationTitle(editingAllergy == nil ? "Add Allergy" : "Edit Allergy")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveAllergy()
                }
            )
            .onAppear {
                if let allergy = editingAllergy {
                    allergen = allergy.allergen
                    severity = allergy.severity
                    reaction = allergy.reaction
                    treatment = allergy.treatment
                }
            }
        }
    }
    
    private func saveAllergy() {
        let allergy = MedicalInfo.Allergy(
            id: editingAllergy?.id ?? UUID(),
            allergen: allergen,
            severity: severity,
            reaction: reaction,
            treatment: treatment
        )
        
        if let index = allergies.firstIndex(where: { $0.id == editingAllergy?.id }) {
            allergies[index] = allergy
        } else {
            allergies.append(allergy)
        }
        
        saveMedicalInfo()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveMedicalInfo() {
        if let encoded = try? JSONEncoder().encode(allergies) {
            UserDefaults.standard.set(encoded, forKey: "medicalAllergies")
        }
    }
}

// MARK: - Mental Health Edit View
struct MentalHealthEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var conditions: [MedicalInfo.MentalHealthCondition]
    var editingCondition: MedicalInfo.MentalHealthCondition?
    
    @State private var condition: String = ""
    @State private var diagnosis: String = ""
    @State private var provider: String = ""
    @State private var treatment: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mental Health Condition")) {
                    TextField("Condition", text: $condition)
                    TextField("Diagnosis Date", text: $diagnosis)
                    TextField("Healthcare Provider", text: $provider)
                    TextField("Treatment Plan", text: $treatment)
                    TextField("Additional Notes", text: $notes)
                }
            }
            .navigationTitle(editingCondition == nil ? "Add Condition" : "Edit Condition")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveCondition()
                }
            )
            .onAppear {
                if let existingCondition = editingCondition {
                    condition = existingCondition.condition
                    diagnosis = existingCondition.diagnosis
                    provider = existingCondition.provider
                    treatment = existingCondition.treatment
                    notes = existingCondition.notes
                }
            }
        }
    }
    
    private func saveCondition() {
        let mentalHealthCondition = MedicalInfo.MentalHealthCondition(
            id: editingCondition?.id ?? UUID(),
            condition: condition,
            diagnosis: diagnosis,
            provider: provider,
            treatment: treatment,
            notes: notes
        )
        
        if let index = conditions.firstIndex(where: { $0.id == editingCondition?.id }) {
            conditions[index] = mentalHealthCondition
        } else {
            conditions.append(mentalHealthCondition)
        }
        
        saveMedicalInfo()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveMedicalInfo() {
        if let encoded = try? JSONEncoder().encode(conditions) {
            UserDefaults.standard.set(encoded, forKey: "medicalMentalHealth")
        }
    }
}

// MARK: - Allergy Row
struct AllergyRow: View {
    let allergy: MedicalInfo.Allergy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(allergy.allergen)
                .font(.headline)
            if !allergy.severity.isEmpty {
                Text("Severity: \(allergy.severity)")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            if !allergy.reaction.isEmpty {
                Text("Reaction: \(allergy.reaction)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if !allergy.treatment.isEmpty {
                Text("Treatment: \(allergy.treatment)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Mental Health Row
struct MentalHealthRow: View {
    let condition: MedicalInfo.MentalHealthCondition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(condition.condition)
                .font(.headline)
            if !condition.diagnosis.isEmpty {
                Text("Diagnosed: \(condition.diagnosis)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if !condition.provider.isEmpty {
                Text("Provider: \(condition.provider)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if !condition.treatment.isEmpty {
                Text("Treatment: \(condition.treatment)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            if !condition.notes.isEmpty {
                Text(condition.notes)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Guideline Tag Model
struct GuidelineTag: Identifiable, Codable {
    let id: UUID
    var name: String
    var color: Color
    
    // Custom coding keys
    enum CodingKeys: String, CodingKey {
        case id, name, colorRed, colorGreen, colorBlue, colorAlpha
    }
    
    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        
        // Convert Color to components
        let components = color.components
        try container.encode(components.red, forKey: .colorRed)
        try container.encode(components.green, forKey: .colorGreen)
        try container.encode(components.blue, forKey: .colorBlue)
        try container.encode(components.alpha, forKey: .colorAlpha)
    }
    
    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        // Reconstruct Color from components
        let red = try container.decode(Double.self, forKey: .colorRed)
        let green = try container.decode(Double.self, forKey: .colorGreen)
        let blue = try container.decode(Double.self, forKey: .colorBlue)
        let alpha = try container.decode(Double.self, forKey: .colorAlpha)
        
        color = Color(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    // Regular initializer
    init(id: UUID = UUID(), name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

// MARK: - Guideline Model
struct Guideline: Identifiable, Codable {
    let id: UUID
    var name: String
    var url: String
    var description: String
    var tags: [GuidelineTag]
    
    init(id: UUID = UUID(), name: String, url: String, description: String, tags: [GuidelineTag] = []) {
        self.id = id
        self.name = name
        self.url = url
        self.description = description
        self.tags = tags
    }
}

// MARK: - Guideline Manager
class GuidelineManager: ObservableObject {
    static let shared = GuidelineManager()
    
    @Published var guidelines: [Guideline] = []
    @Published var tags: [GuidelineTag] = []
    private let guidelinesKey = "savedGuidelines"
    private let tagsKey = "savedGuidelineTags"
    
    init() {
        loadGuidelines()
        loadTags()
    }
    
    func loadGuidelines() {
        if let savedData = UserDefaults.standard.data(forKey: guidelinesKey),
           let savedGuidelines = try? JSONDecoder().decode([Guideline].self, from: savedData) {
            guidelines = savedGuidelines
        }
    }
    
    func loadTags() {
        if let savedData = UserDefaults.standard.data(forKey: tagsKey),
           let savedTags = try? JSONDecoder().decode([GuidelineTag].self, from: savedData) {
            tags = savedTags
        }
    }
    
    func saveGuideline(_ guideline: Guideline) {
        if let index = guidelines.firstIndex(where: { $0.id == guideline.id }) {
            guidelines[index] = guideline
        } else {
            guidelines.append(guideline)
        }
        saveGuidelines()
    }
    
    func addTag(_ tag: GuidelineTag) {
        if !tags.contains(where: { $0.id == tag.id }) {
            tags.append(tag)
            saveTags()
        }
    }
    
    func removeTag(_ tag: GuidelineTag) {
        tags.removeAll { $0.id == tag.id }
        // Remove tag from all guidelines
        for i in guidelines.indices {
            guidelines[i].tags.removeAll { $0.id == tag.id }
        }
        saveTags()
        saveGuidelines()
    }
    
    func deleteGuideline(_ guideline: Guideline) {
        guidelines.removeAll { $0.id == guideline.id }
        saveGuidelines()
    }
    
    private func saveGuidelines() {
        if let encoded = try? JSONEncoder().encode(guidelines) {
            UserDefaults.standard.set(encoded, forKey: guidelinesKey)
        }
    }
    
    private func saveTags() {
        if let encoded = try? JSONEncoder().encode(tags) {
            UserDefaults.standard.set(encoded, forKey: tagsKey)
        }
    }
}

// MARK: - Guideline Edit View
struct GuidelineEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var guidelineManager = GuidelineManager.shared
    @State private var name: String = ""
    @State private var url: String = ""
    @State private var description: String = ""
    @State private var selectedTags: [GuidelineTag] = []
    @State private var showingTagEditor = false
    @State private var newTagName = ""
    @State private var selectedColor: Color = .blue
    @State private var showingColorPicker = false
    
    let guideline: Guideline?
    let availableColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Guideline Details")) {
                    TextField("Name", text: $name)
                    TextField("URL", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Tags")) {
                    Button(action: { showingTagEditor = true }) {
                        HStack {
                            Text("Edit Tags")
                            Spacer()
                            Image(systemName: "tag.fill")
                        }
                    }
                    
                    if !selectedTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(selectedTags) { tag in
                                    Text(tag.name)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(tag.color.opacity(0.2))
                                        .foregroundColor(tag.color)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(guideline == nil ? "Add Guideline" : "Edit Guideline")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveGuideline()
                }
            )
            .sheet(isPresented: $showingTagEditor) {
                NavigationView {
                    Form {
                        Section(header: Text("Current Tags")) {
                            if guidelineManager.tags.isEmpty {
                                Text("No tags added")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(guidelineManager.tags) { tag in
                                    HStack {
                                        Circle()
                                            .fill(tag.color)
                                            .frame(width: 12, height: 12)
                                        Text(tag.name)
                                        Spacer()
                                        Button(action: {
                                            toggleTag(tag)
                                        }) {
                                            Image(systemName: selectedTags.contains(where: { $0.id == tag.id }) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedTags.contains(where: { $0.id == tag.id }) ? .blue : .gray)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Add New Tag")) {
                            TextField("Tag Name", text: $newTagName)
                            
                            HStack {
                                Text("Color")
                                Spacer()
                                Circle()
                                    .fill(selectedColor)
                                    .frame(width: 24, height: 24)
                                    .onTapGesture {
                                        showingColorPicker = true
                                    }
                            }
                            
                            if showingColorPicker {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(availableColors, id: \.self) { color in
                                            Circle()
                                                .fill(color)
                                                .frame(width: 30, height: 30)
                                                .onTapGesture {
                                                    selectedColor = color
                                                    showingColorPicker = false
                                                }
                                        }
                                    }
                                }
                            }
                            
                            Button(action: addTag) {
                                Label("Add Tag", systemImage: "plus.circle.fill")
                            }
                            .disabled(newTagName.isEmpty)
                        }
                    }
                    .navigationTitle("Edit Tags")
                    .navigationBarItems(
                        trailing: Button("Done") {
                            showingTagEditor = false
                        }
                    )
                }
            }
            .onAppear {
                if let guideline = guideline {
                    name = guideline.name
                    url = guideline.url
                    description = guideline.description
                    selectedTags = guideline.tags
                }
            }
        }
    }
    
    private func saveGuideline() {
        let newGuideline = Guideline(
            id: guideline?.id ?? UUID(),
            name: name,
            url: url,
            description: description,
            tags: selectedTags
        )
        
        guidelineManager.saveGuideline(newGuideline)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func toggleTag(_ tag: GuidelineTag) {
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
    
    private func addTag() {
        let newTag = GuidelineTag(name: newTagName, color: selectedColor)
        guidelineManager.addTag(newTag)
        selectedTags.append(newTag)
        newTagName = ""
    }
}

// MARK: - Guideline View
struct GuidelineView: View {
    @StateObject private var guidelineManager = GuidelineManager.shared
    @State private var showingAddGuideline = false
    @State private var editingGuideline: Guideline?
    @State private var showingDeleteAlert = false
    @State private var guidelineToDelete: Guideline?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(guidelineManager.guidelines) { guideline in
                    GuidelineRow(guideline: guideline) {
                        editingGuideline = guideline
                    } onDelete: {
                        guidelineToDelete = guideline
                        showingDeleteAlert = true
                    }
                }
            }
            .navigationTitle("Guidelines")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGuideline = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGuideline) {
                GuidelineEditView(guideline: nil)
            }
            .sheet(item: $editingGuideline) { guideline in
                GuidelineEditView(guideline: guideline)
            }
            .alert("Delete Guideline", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let guideline = guidelineToDelete {
                        guidelineManager.deleteGuideline(guideline)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this guideline? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Guideline Row
struct GuidelineRow: View {
    let guideline: Guideline
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(guideline.name)
                    .font(.headline)
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            Text(guideline.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if !guideline.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(guideline.tags) { tag in
                            Text(tag.name)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(tag.color.opacity(0.2))
                                .foregroundColor(tag.color)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            Button(action: {
                if let url = URL(string: guideline.url) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "link")
                    Text("Open Link")
                }
                .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }
}

// MARK: - Profile Model
struct Profile: Codable {
    var personalInfo: PersonalInfo
    var address: Address
    var cars: [Car]
    
    struct PersonalInfo: Codable {
        var firstName: String
        var lastName: String
        var dateOfBirth: String
        var phoneNumber: String
        var email: String
    }
    
    struct Address: Codable {
        var street: String
        var city: String
        var state: String
        var zipCode: String
        var country: String
    }
    
    static var empty: Profile {
        Profile(
            personalInfo: PersonalInfo(
                firstName: "",
                lastName: "",
                dateOfBirth: "",
                phoneNumber: "",
                email: ""
            ),
            address: Address(
                street: "",
                city: "",
                state: "",
                zipCode: "",
                country: ""
            ),
            cars: []
        )
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @State private var profile: Profile = .empty
    @State private var isEditing = false
    @State private var showingEditSheet = false
    @State private var showingAddCarSheet = false
    @State private var editingCar: Car?
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Personal Information")) {
                    InfoRow(title: "Name", value: "\(profile.personalInfo.firstName) \(profile.personalInfo.lastName)")
                    InfoRow(title: "Date of Birth", value: profile.personalInfo.dateOfBirth)
                    InfoRow(title: "Phone", value: profile.personalInfo.phoneNumber)
                    InfoRow(title: "Email", value: profile.personalInfo.email)
                }
                
                Section(header: Text("Address")) {
                    InfoRow(title: "Street", value: profile.address.street)
                    InfoRow(title: "City", value: profile.address.city)
                    InfoRow(title: "State", value: profile.address.state)
                    InfoRow(title: "Zip Code", value: profile.address.zipCode)
                    InfoRow(title: "Country", value: profile.address.country)
                }
                
                Section(header: Text("Vehicles")) {
                    if profile.cars.isEmpty {
                        Text("No vehicles added")
                            .foregroundColor(.gray)
                    } else {
                        ForEach($profile.cars) { $car in
                            CarRow(car: car) {
                                editingCar = car
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingEditSheet = true }) {
                        Text("Edit")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                ProfileEditView(profile: $profile)
            }
            .sheet(item: $editingCar) { car in
                CarEditView(car: .constant(car)) { updatedCar in
                    if let index = profile.cars.firstIndex(where: { $0.id == updatedCar.id }) {
                        profile.cars[index] = updatedCar
                        // Save the updated profile
                        if let encoded = try? JSONEncoder().encode(profile) {
                            UserDefaults.standard.set(encoded, forKey: "savedProfile")
                        }
                    }
                }
            }
            .onAppear(perform: loadProfile)
        }
    }
    
    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: "savedProfile"),
           let savedProfile = try? JSONDecoder().decode(Profile.self, from: data) {
            profile = savedProfile
        }
    }
}

// MARK: - Profile Edit View
struct ProfileEditView: View {
    @Binding var profile: Profile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $profile.personalInfo.firstName)
                    TextField("Last Name", text: $profile.personalInfo.lastName)
                    TextField("Date of Birth", text: $profile.personalInfo.dateOfBirth)
                    TextField("Phone Number", text: $profile.personalInfo.phoneNumber)
                    TextField("Email", text: $profile.personalInfo.email)
                }
                
                Section(header: Text("Address")) {
                    TextField("Street", text: $profile.address.street)
                    TextField("City", text: $profile.address.city)
                    TextField("State", text: $profile.address.state)
                    TextField("Zip Code", text: $profile.address.zipCode)
                    TextField("Country", text: $profile.address.country)
                }
                
                Section(header: Text("Vehicles")) {
                    ForEach($profile.cars) { $car in
                        NavigationLink(destination: CarEditView(car: $car) { updatedCar in
                            if let index = profile.cars.firstIndex(where: { $0.id == updatedCar.id }) {
                                profile.cars[index] = updatedCar
                            }
                        }) {
                            Text("\(car.make) \(car.model)")
                        }
                    }
                    .onDelete { indexSet in
                        profile.cars.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Vehicle") {
                        let newCar = Car()
                        profile.cars.append(newCar)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let encoded = try? JSONEncoder().encode(profile) {
                            UserDefaults.standard.set(encoded, forKey: "savedProfile")
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value.isEmpty ? "Not Set" : value)
                .foregroundColor(value.isEmpty ? .gray : .primary)
        }
    }
}

// MARK: - Car Model
struct Car: Identifiable, Codable {
    let id: UUID
    var make: String
    var model: String
    var year: String
    var color: String
    var licensePlate: String
    var vin: String
    var insuranceProvider: String
    var insurancePolicyNumber: String
    
    init(id: UUID = UUID(), make: String = "", model: String = "", year: String = "", color: String = "", licensePlate: String = "", vin: String = "", insuranceProvider: String = "", insurancePolicyNumber: String = "") {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.color = color
        self.licensePlate = licensePlate
        self.vin = vin
        self.insuranceProvider = insuranceProvider
        self.insurancePolicyNumber = insurancePolicyNumber
    }
}

// MARK: - Car Edit View
struct CarEditView: View {
    @Binding var car: Car
    var onSave: (Car) -> Void
    @State private var editedCar: Car
    @Environment(\.dismiss) private var dismiss
    
    init(car: Binding<Car>, onSave: @escaping (Car) -> Void) {
        _car = car
        self.onSave = onSave
        _editedCar = State(initialValue: car.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vehicle Information")) {
                    TextField("Make", text: $editedCar.make)
                    TextField("Model", text: $editedCar.model)
                    TextField("Year", text: $editedCar.year)
                    TextField("Color", text: $editedCar.color)
                    TextField("License Plate", text: $editedCar.licensePlate)
                    TextField("VIN", text: $editedCar.vin)
                }
                
                Section(header: Text("Insurance Information")) {
                    TextField("Insurance Provider", text: $editedCar.insuranceProvider)
                    TextField("Policy Number", text: $editedCar.insurancePolicyNumber)
                }
            }
            .navigationTitle(editedCar.make.isEmpty ? "Add Vehicle" : "Edit Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        car = editedCar
                        onSave(editedCar)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Car Row
struct CarRow: View {
    let car: Car
    var onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(car.year) \(car.make) \(car.model)")
                    .font(.headline)
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Text("Color: \(car.color)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("Plate: \(car.licensePlate)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("Insurance: \(car.insuranceProvider)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("Policy: \(car.insurancePolicyNumber)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
