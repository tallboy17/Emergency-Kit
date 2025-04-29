import SwiftUI

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

// MARK: - Contact Item
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