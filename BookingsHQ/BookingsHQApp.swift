//
//  BookingsHQApp.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import SwiftUI
import CoreData

@main
struct BookingsHQApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
