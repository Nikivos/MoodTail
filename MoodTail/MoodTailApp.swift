//
//  MoodTailApp.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import SwiftUI

@main
struct MoodTailApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                MoodLoggerView()
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Добавить")
                    }
                
                HistoryView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("История")
                    }
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Настройки")
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
