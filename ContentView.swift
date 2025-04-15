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
                        .foregroundColor(.white)
                }
                
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemGreen).darker())
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
    }
}

struct AddContactView: View {
    @Environment(\.presentationMode) var presentationMode
    let viewContext: NSManagedObjectContext
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var relationship = ""
    @State private var isPrimary = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Relationship", text: $relationship)
                }
                
                Section {
                    Toggle("Primary Emergency Contact", isOn: $isPrimary)
                }
                
                Section {
                    Button("Save Contact") {
                        saveContact()
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func saveContact() {
        let contact = Contact(context: viewContext)
        contact.id = UUID()
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.relationship = relationship
        contact.isPrimary = isPrimary
        contact.dateAdded = Date()
        contact.sortOrder = Int16(Date().timeIntervalSince1970)
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving contact: \(error)")
        }
    }
}

struct ContactsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Contact.sortOrder, ascending: true)],
        animation: .default)
    private var contacts: FetchedResults<Contact>
    @State private var showingAddContact = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Emergency Services (Fixed)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Emergency Services")
                            .font(.headline)
                            .padding(.bottom, 6)
                        
                        ContactItem(name: "Emergency (Police, Fire, Medical)", 
                                  number: "911", 
                                  isEditable: false)
                        ContactItem(name: "Poison Control", 
                                  number: "1-800-222-1222", 
                                  isEditable: false)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                    
                    // Personal Contacts (Editable)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Personal Emergency Contacts")
                                .font(.headline)
                            
                            Spacer()
                            
                            EditButton()
                        }
                        .padding(.bottom, 6)
                        
                        if contacts.isEmpty {
                            EmptyContactsView()
                        } else {
                            ForEach(contacts) { contact in
                                ContactItemEditable(contact: contact, 
                                                  isEditing: editMode.isEditing)
                            }
                            .onMove(perform: moveContact)
                            .onDelete(perform: deleteContact)
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
            .environment(\.editMode, $editMode)
            .sheet(isPresented: $showingAddContact) {
                AddContactView(viewContext: viewContext)
            }
        }
    }
    
    private func moveContact(from source: IndexSet, to destination: Int) {
        // Update sort order in CoreData
        var updatedContacts = contacts.map { $0 }
        updatedContacts.move(fromOffsets: source, toOffset: destination)
        
        for (index, contact) in updatedContacts.enumerated() {
            contact.sortOrder = Int16(index)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    private func deleteContact(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(contacts[index])
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting contact: \(error)")
        }
    }
}

struct ContactItemEditable: View {
    @ObservedObject var contact: Contact
    let isEditing: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(contact.name ?? "")
                    .font(.system(size: 16, weight: .medium))
                
                if let relationship = contact.relationship {
                    Text(relationship)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if isEditing {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            } else {
                Button(action: {
                    guard let number = contact.phoneNumber else { return }
                    callPhoneNumber(number)
                }) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "phone.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingEditSheet) {
            EditContactView(contact: contact)
        }
    }
    
    private func callPhoneNumber(_ number: String) {
        guard let url = URL(string: "tel://\(number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))") else { return }
        UIApplication.shared.open(url)
    }
}

struct EmptyContactsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No Emergency Contacts")
                .font(.headline)
            
            Text("Add contacts that should be notified in case of emergency")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct EmergencyContact: Identifiable {
    let id: UUID
    var name: String
    var phoneNumber: String
    var relationship: String
    var isPrimary: Bool  // To mark primary emergency contacts
    var sortOrder: Int   // To maintain user's preferred order
} 
