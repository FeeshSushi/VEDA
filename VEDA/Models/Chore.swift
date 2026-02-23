import Foundation
import SwiftData

enum RecurrenceType: String, Codable {
    case interval
    case weekdays
}

@Model
final class Chore {
    var id: UUID
    var title: String
    var recurrenceType: RecurrenceType
    var intervalDays: Int
    var weekdays: [Int]
    var lastCompleted: Date?
    var nextDue: Date

    init(title: String, recurrenceType: RecurrenceType, intervalDays: Int = 7, weekdays: [Int] = [], nextDue: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.recurrenceType = recurrenceType
        self.intervalDays = intervalDays
        self.weekdays = weekdays
        self.lastCompleted = nil
        self.nextDue = nextDue
    }

    var isOverdue: Bool {
        nextDue < Date()
    }

    func calculateNextDue(from completionDate: Date = Date()) -> Date {
        switch recurrenceType {
        case .interval:
            let calendar = Calendar.current
            return calendar.date(byAdding: .day, value: intervalDays, to: completionDate) ?? completionDate
        case .weekdays:
            guard !weekdays.isEmpty else { return completionDate }
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .weekday], from: completionDate)
            let today = components.weekday ?? 1
            let sortedWeekdays = weekdays.sorted()
            let next = sortedWeekdays.first(where: { $0 > today }) ?? sortedWeekdays[0]
            let daysUntil = next > today ? next - today : 7 - today + next
            return calendar.date(byAdding: .day, value: daysUntil, to: completionDate) ?? completionDate
        }
    }
}
