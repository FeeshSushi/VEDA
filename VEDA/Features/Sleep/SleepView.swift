import SwiftUI
import SwiftData
import WidgetKit

struct SleepView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepEntry.sleepTime, order: .reverse) private var entries: [SleepEntry]

    @State private var targetWakeTime = Date()
    @State private var showWakeTimePicker = false
    @State private var editingEntry: SleepEntry? = nil

    private var activeSession: SleepEntry? {
        entries.first(where: { $0.wakeTime == nil })
    }

    private var completedEntries: [SleepEntry] {
        entries.filter { $0.wakeTime != nil }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    sessionCard
                    predictionCard
                    historySection
                }
                .padding()
            }
            .navigationTitle("SleepyTime!")
            .sheet(item: $editingEntry) { entry in
                SleepEditView(entry: entry)
            }
        }
    }

    @ViewBuilder
    private var sessionCard: some View {
        if let session = activeSession {
            // Active session - show wake logging UI
            VStack(spacing: 16) {
                Text("Good morning! 🌅")
                    .font(.title2.bold())
                Text("You went to sleep at \(session.sleepTime.formatted(date: .omitted, time: .shortened))")
                    .foregroundStyle(.secondary)

                Text("How did you sleep?")
                    .font(.subheadline)

                EmojiRatingPicker { rating in
                    logWake(session: session, rating: rating)
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        } else {
            // No active session - show sleep button
            VStack(spacing: 12) {
                Text("Ready to sleep?")
                    .font(.title2.bold())
                Button {
                    logSleep()
                } label: {
                    Label("Going to Sleep", systemImage: "moon.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    @ViewBuilder
    private var predictionCard: some View {
        let avgDuration = SleepHeuristics.averageDuration(from: completedEntries)
        if avgDuration != nil {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sleep Predictor")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("I need to wake up at...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    DatePicker("Wake time", selection: $targetWakeTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    if let suggestion = SleepHeuristics.suggestedSleepTime(wakeTarget: targetWakeTime, entries: completedEntries) {
                        Label("Go to sleep around \(suggestion.formatted(date: .omitted, time: .shortened))", systemImage: "moon.stars")
                            .font(.subheadline)
                            .foregroundStyle(.indigo)
                    }
                }
                .padding()
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))

                if let wakeNow = SleepHeuristics.suggestedWakeTime(sleepTime: Date(), entries: completedEntries) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("If I sleep now...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Label("Set alarm for \(wakeNow.formatted(date: .omitted, time: .shortened))", systemImage: "alarm")
                            .font(.subheadline)
                            .foregroundStyle(.indigo)
                    }
                    .padding()
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    @ViewBuilder
    private var historySection: some View {
        if !completedEntries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("History")
                    .font(.headline)
                ForEach(completedEntries.prefix(10)) { entry in
                    SleepEntryRow(entry: entry)
                        .onTapGesture { editingEntry = entry }
                }
            }
        }
    }

    private func logSleep() {
        let entry = SleepEntry(sleepTime: Date())
        modelContext.insert(entry)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func logWake(session: SleepEntry, rating: Int) {
        session.wakeTime = Date()
        session.emojiRating = rating
        NotificationService.shared.scheduleWaterNotifications(from: Date())
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct EmojiRatingPicker: View {
    let onSelect: (Int) -> Void
    var selected: Int? = nil

    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<SleepEntry.emojiScale.count, id: \.self) { index in
                Button {
                    onSelect(index)
                } label: {
                    VStack(spacing: 4) {
                        Text(SleepEntry.emojiScale[index])
                            .font(.largeTitle)
                            .padding(6)
                            .background(
                                selected == index ? Color.indigo.opacity(0.2) : Color.clear,
                                in: Circle()
                            )
                        Text(SleepEntry.emojiLabels[index])
                            .font(.caption2)
                            .foregroundStyle(selected == index ? .indigo : .secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct SleepEntryRow: View {
    let entry: SleepEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.sleepTime.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline.bold())
                HStack(spacing: 4) {
                    Text(entry.sleepTime.formatted(date: .omitted, time: .shortened))
                    Text("→")
                    Text(entry.wakeTime?.formatted(date: .omitted, time: .shortened) ?? "—")
                    if let dur = entry.durationFormatted {
                        Text("(\(dur))")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            if let emoji = entry.ratingEmoji {
                Text(emoji)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
    }
}
