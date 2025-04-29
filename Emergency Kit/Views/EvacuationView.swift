import SwiftUI
import MapKit

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

// MARK: - Evacuation Item
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
