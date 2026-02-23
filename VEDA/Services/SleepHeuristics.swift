import Foundation

struct SleepHeuristics {
    static let minimumEntries = 3

    static func averageDuration(from entries: [SleepEntry]) -> TimeInterval? {
        let weighted = entries.compactMap { entry -> (duration: TimeInterval, weight: Double)? in
            guard let duration = entry.duration else { return nil }
            let weight = Double((entry.emojiRating ?? 2) + 1)
            return (duration, weight)
        }
        guard weighted.count >= minimumEntries else { return nil }
        let weightedSum = weighted.reduce(0.0) { $0 + $1.duration * $1.weight }
        let totalWeight = weighted.reduce(0.0) { $0 + $1.weight }
        return weightedSum / totalWeight
    }

    static func suggestedSleepTime(wakeTarget: Date, entries: [SleepEntry]) -> Date? {
        guard let avg = averageDuration(from: entries) else { return nil }
        let raw = wakeTarget.addingTimeInterval(-avg)
        return roundToNearestQuarterHour(raw)
    }

    static func suggestedWakeTime(sleepTime: Date, entries: [SleepEntry]) -> Date? {
        guard let avg = averageDuration(from: entries) else { return nil }
        let raw = sleepTime.addingTimeInterval(avg)
        return roundToNearestQuarterHour(raw)
    }

    private static func roundToNearestQuarterHour(_ date: Date) -> Date {
        let interval: TimeInterval = 15 * 60
        let rounded = (date.timeIntervalSinceReferenceDate / interval).rounded() * interval
        return Date(timeIntervalSinceReferenceDate: rounded)
    }
}
