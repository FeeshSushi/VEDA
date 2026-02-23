import Foundation
import SwiftData

@Model
final class SleepEntry {
    var id: UUID
    var sleepTime: Date
    var wakeTime: Date?
    var emojiRating: Int?

    static let emojiScale = ["😫", "😴", "😐", "🙂", "😄"]
    static let emojiLabels = ["Terrible", "Poor", "Okay", "Good", "Great"]

    init(sleepTime: Date = Date()) {
        self.id = UUID()
        self.sleepTime = sleepTime
        self.wakeTime = nil
        self.emojiRating = nil
    }

    var duration: TimeInterval? {
        guard let wake = wakeTime else { return nil }
        return wake.timeIntervalSince(sleepTime)
    }

    var durationFormatted: String? {
        guard let d = duration else { return nil }
        let hours = Int(d) / 3600
        let minutes = (Int(d) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    var ratingEmoji: String? {
        guard let r = emojiRating, r >= 0 && r < SleepEntry.emojiScale.count else { return nil }
        return SleepEntry.emojiScale[r]
    }
}
