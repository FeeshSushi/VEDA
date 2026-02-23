import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - Timeline Entry

struct SleepWidgetEntry: TimelineEntry {
    let date: Date
    let activeSleepTime: Date?
}

// MARK: - Timeline Provider

struct SleepWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SleepWidgetEntry {
        SleepWidgetEntry(date: Date(), activeSleepTime: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SleepWidgetEntry) -> Void) {
        completion(fetchEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SleepWidgetEntry>) -> Void) {
        let entry = fetchEntry()
        let minutes = entry.activeSleepTime != nil ? 1 : 15
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: minutes, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func fetchEntry() -> SleepWidgetEntry {
        do {
            let container = try ModelContainer(
                for: Schema([Task.self, Chore.self, SleepEntry.self]),
                configurations: [sharedModelConfiguration()]
            )
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<SleepEntry>(
                predicate: #Predicate { $0.wakeTime == nil },
                sortBy: [SortDescriptor(\.sleepTime, order: .reverse)]
            )
            let active = try context.fetch(descriptor).first
            return SleepWidgetEntry(date: Date(), activeSleepTime: active?.sleepTime)
        } catch {
            return SleepWidgetEntry(date: Date(), activeSleepTime: nil)
        }
    }
}

// MARK: - Entry View (dispatches by family)

struct SleepWidgetEntryView: View {
    let entry: SleepWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            LockScreenSleepView(entry: entry)
        default:
            MediumSleepView(entry: entry)
        }
    }
}

// MARK: - Medium (2×1) View

struct MediumSleepView: View {
    let entry: SleepWidgetEntry

    private var elapsed: String {
        guard let start = entry.activeSleepTime else { return "" }
        let s = Int(Date().timeIntervalSince(start))
        return "\(s / 3600)h \((s % 3600) / 60)m"
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                if let t = entry.activeSleepTime {
                    Text("Asleep since")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(t, style: .time)
                        .font(.headline)
                    Text(elapsed)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Ready to sleep?")
                        .font(.headline)
                    Text("🌙")
                        .font(.title2)
                }
            }
            Spacer()
            if entry.activeSleepTime != nil {
                Button(intent: LogWakeIntent()) {
                    Label("Wake Up ☀️", systemImage: "sun.max.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            } else {
                Button(intent: LogSleepIntent()) {
                    Label("Sleep", systemImage: "moon.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

// MARK: - Lock Screen (accessoryCircular) View

struct LockScreenSleepView: View {
    let entry: SleepWidgetEntry

    var body: some View {
        if entry.activeSleepTime != nil {
            Button(intent: LogWakeIntent()) { icon }
                .containerBackground(for: .widget) { Color.clear }
        } else {
            Button(intent: LogSleepIntent()) { icon }
                .containerBackground(for: .widget) { Color.clear }
        }
    }

    private var icon: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image(systemName: entry.activeSleepTime != nil ? "sun.max.fill" : "moon.fill")
                .font(.title2)
                .foregroundStyle(entry.activeSleepTime != nil ? .yellow : .indigo)
        }
    }
}

// MARK: - Widget Declaration

struct SleepWidget: Widget {
    let kind = "SleepWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SleepWidgetProvider()) { entry in
            SleepWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Sleep Tracker")
        .description("Log sleep and wake up from your home or lock screen.")
        .supportedFamilies([.systemMedium, .accessoryCircular])
    }
}

// MARK: - Previews

#Preview("Medium", as: .systemMedium) {
    SleepWidget()
} timeline: {
    SleepWidgetEntry(date: .now, activeSleepTime: nil)
    SleepWidgetEntry(date: .now, activeSleepTime: Calendar.current.date(byAdding: .hour, value: -6, to: .now))
}

#Preview("Lock Screen", as: .accessoryCircular) {
    SleepWidget()
} timeline: {
    SleepWidgetEntry(date: .now, activeSleepTime: nil)
    SleepWidgetEntry(date: .now, activeSleepTime: Calendar.current.date(byAdding: .hour, value: -2, to: .now))
}
