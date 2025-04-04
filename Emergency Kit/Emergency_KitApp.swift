//
//  Emergency_KitApp.swift
//  Emergency Kit
//
//  Created by Arjun Maganti on 4/4/25.
//

import SwiftUI

@main
struct Emergency_KitApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
