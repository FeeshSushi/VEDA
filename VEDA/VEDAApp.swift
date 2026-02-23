//
//  VEDAApp.swift
//  VEDA
//
//  Created by Johnny Lau on 2026-02-22.
//

import SwiftUI
import SwiftData

@main
struct VEDAApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Task.self,
            Chore.self,
            SleepEntry.self,
        ])
        let modelConfiguration = sharedModelConfiguration()

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear { performDailyRefreshIfNeeded() }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    performDailyRefreshIfNeeded()
                    NotificationService.shared.requestPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func performDailyRefreshIfNeeded() {
        let calendar = Calendar.current
        let now = Date()

        var fiveAMComponents = calendar.dateComponents([.year, .month, .day], from: now)
        fiveAMComponents.hour = 5
        fiveAMComponents.minute = 0
        fiveAMComponents.second = 0
        guard let todayFiveAM = calendar.date(from: fiveAMComponents), now >= todayFiveAM else { return }

        let lastRefresh = UserDefaults.standard.object(forKey: "lastDailyRefresh") as? Date ?? .distantPast
        guard lastRefresh < todayFiveAM else { return }

        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<Task>(predicate: #Predicate { $0.isDaily })
        if let dailyTasks = try? context.fetch(descriptor) {
            for task in dailyTasks {
                task.isCompleted = false
            }
        }

        UserDefaults.standard.set(now, forKey: "lastDailyRefresh")

        scheduleWaterFallbackIfNeeded(calendar: calendar, now: now)
    }

    private func scheduleWaterFallbackIfNeeded(calendar: Calendar, now: Date) {
        guard UserDefaults.standard.bool(forKey: "waterRemindersEnabled") else { return }
        let lastSchedule = UserDefaults.standard.object(forKey: "lastWaterScheduleDate") as? Date ?? .distantPast
        guard !calendar.isDateInToday(lastSchedule) else { return }

        let hour = UserDefaults.standard.integer(forKey: "defaultWakeHour")
        let minute = UserDefaults.standard.integer(forKey: "defaultWakeMinute")
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = (hour == 0 && minute == 0) ? 8 : hour
        components.minute = minute
        if let fallbackWake = calendar.date(from: components) {
            NotificationService.shared.scheduleWaterNotifications(from: fallbackWake)
        }
    }
}
