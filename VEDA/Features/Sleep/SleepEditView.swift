import SwiftUI
import SwiftData
import WidgetKit

struct SleepEditView: View {
    @Bindable var entry: SleepEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRating: Int? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Sleep") {
                    DatePicker("Fell asleep", selection: $entry.sleepTime)
                }
                Section("Wake") {
                    DatePicker("Woke up", selection: Binding(
                        get: { entry.wakeTime ?? Date() },
                        set: { entry.wakeTime = $0 }
                    ))
                }
                Section("Quality") {
                    EmojiRatingPicker(selected: selectedRating) { rating in
                        entry.emojiRating = rating
                        selectedRating = rating
                    }
                }
                Section {
                    Button(role: .destructive) {
                        modelContext.delete(entry)
                        WidgetCenter.shared.reloadAllTimelines()
                        dismiss()
                    } label: {
                        Label("Delete Entry", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        WidgetCenter.shared.reloadAllTimelines()
                        dismiss()
                    }
                }
            }
            .onAppear { selectedRating = entry.emojiRating }
        }
    }
}
