//
//  dunApp.swift
//  Shared
//
//  Created by Luca Beetz on 06.01.22.
//

import SwiftUI

@main
struct dunApp: App {
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    @FetchRequest(
        entity: Progress.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Progress.name, ascending: true)
        ]
    ) var nutritionProgresses: FetchedResults<Progress>
    
    var body: some Scene {
        WindowGroup {
            SummaryView(persistenceController: persistenceController)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
