//
//  ContentView.swift
//  VEDA
//
//  Created by Johnny Lau on 2026-02-22.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            TasksView()
                .tabItem { Label("Tasks", systemImage: "checklist") }
            ChoresView()
                .tabItem { Label("Chores", systemImage: "repeat") }
            SleepView()
                .tabItem { Label("Sleep", systemImage: "moon.fill") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Task.self, Chore.self, SleepEntry.self], inMemory: true)
}
