import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleChoreOverdueNotification(for chore: Chore) {
        let content = UNMutableNotificationContent()
        content.title = "Chore Due"
        content.body = "\(chore.title) is due today."
        content.sound = .default

        var triggerDate = Calendar.current.dateComponents([.year, .month, .day], from: chore.nextDue)
        triggerDate.hour = 9
        triggerDate.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: chore.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func cancelNotification(for choreID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [choreID.uuidString])
    }

    // MARK: - Water Reminders

    private static let waterMessages: [(String, String)] = [
        ("Drink water! 💧", "Time to hydrate."),
        ("Hydration check! 💧", "Have you had some water lately?"),
        ("Water break! 💧", "A glass of water keeps the brain sharp."),
        ("Stay hydrated! 💧", "Your body will thank you."),
        ("💧 Time to drink water!", "Keep sipping throughout the day."),
        ("Hydrate! 💧", "Don't forget your water today."),
        ("Water o'clock! 💧", "Time for another glass."),
        ("Drink up! 💧", "Staying hydrated boosts your energy.")
    ]

    func scheduleWaterNotifications(from wakeTime: Date) {
        cancelWaterNotifications()
        guard UserDefaults.standard.bool(forKey: "waterRemindersEnabled") else { return }

        let calendar = Calendar.current
        let now = Date()

        var endComponents = calendar.dateComponents([.year, .month, .day], from: wakeTime)
        endComponents.hour = 1
        endComponents.minute = 0
        endComponents.second = 0
        var endTime = calendar.date(from: endComponents)!
        if endTime <= wakeTime {
            endTime = calendar.date(byAdding: .day, value: 1, to: endTime)!
        }

        let interval = endTime.timeIntervalSince(wakeTime) / 8
        for i in 0..<8 {
            let fireTime = wakeTime.addingTimeInterval(interval * Double(i + 1))
            guard fireTime > now else { continue }

            let (title, body) = NotificationService.waterMessages[i % NotificationService.waterMessages.count]
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "water_\(i)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }

        UserDefaults.standard.set(calendar.startOfDay(for: now), forKey: "lastWaterScheduleDate")
    }

    func cancelWaterNotifications() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: (0..<8).map { "water_\($0)" })
    }
}
