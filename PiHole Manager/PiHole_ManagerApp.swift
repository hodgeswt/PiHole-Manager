//
//  PiHole_ManagerApp.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
//

import SwiftUI

@main
struct PiHole_ManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
