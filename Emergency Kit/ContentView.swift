import SwiftUI
import MapKit
import PDFKit
import CoreData


// MARK: - ContentView
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
