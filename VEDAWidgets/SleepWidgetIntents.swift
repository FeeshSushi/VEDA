import AppIntents
import SwiftData
import WidgetKit

struct LogSleepIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Sleep"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        let container = try ModelContainer(
            for: Schema([Task.self, Chore.self, SleepEntry.self]),
            configurations: [sharedModelConfiguration()]
        )
        let context = ModelContext(container)

        let existing = try context.fetch(
            FetchDescriptor<SleepEntry>(predicate: #Predicate { $0.wakeTime == nil })
        )
        guard existing.isEmpty else { return .result() }

        context.insert(SleepEntry(sleepTime: Date()))
        try context.save()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct LogWakeIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Wake"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        let container = try ModelContainer(
            for: Schema([Task.self, Chore.self, SleepEntry.self]),
            configurations: [sharedModelConfiguration()]
        )
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<SleepEntry>(
            predicate: #Predicate { $0.wakeTime == nil },
            sortBy: [SortDescriptor(\.sleepTime, order: .reverse)]
        )
        guard let active = try context.fetch(descriptor).first else { return .result() }

        active.wakeTime = Date()
        try context.save()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
