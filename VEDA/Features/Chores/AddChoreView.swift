import SwiftUI
import SwiftData

struct AddChoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var recurrenceType: RecurrenceType = .interval
    @State private var intervalDays = 7
    @State private var selectedWeekdays: Set<Int> = []
    @State private var firstDueDate = Date()

    private let weekdayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Chore name", text: $title)
                }

                Section("Recurrence") {
                    Picker("Type", selection: $recurrenceType) {
                        Text("Every N days").tag(RecurrenceType.interval)
                        Text("Day of week").tag(RecurrenceType.weekdays)
                    }
                    .pickerStyle(.segmented)

                    if recurrenceType == .interval {
                        Stepper("Every \(intervalDays) day\(intervalDays == 1 ? "" : "s")", value: $intervalDays, in: 1...365)
                    } else {
                        weekdayPicker
                    }
                }

                Section("First due") {
                    DatePicker("Due date", selection: $firstDueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addChore() }
                        .disabled(!canAdd)
                }
            }
        }
    }

    private var weekdayPicker: some View {
        HStack(spacing: 8) {
            ForEach(1...7, id: \.self) { day in
                let name = weekdayNames[day - 1]
                let selected = selectedWeekdays.contains(day)
                Button {
                    if selected { selectedWeekdays.remove(day) }
                    else { selectedWeekdays.insert(day) }
                } label: {
                    Text(name)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(selected ? Color.accentColor : Color(.systemGray5))
                        .foregroundStyle(selected ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    private var canAdd: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return false }
        if recurrenceType == .weekdays && selectedWeekdays.isEmpty { return false }
        return true
    }

    private func addChore() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard canAdd else { return }
        let chore = Chore(
            title: trimmed,
            recurrenceType: recurrenceType,
            intervalDays: intervalDays,
            weekdays: Array(selectedWeekdays).sorted(),
            nextDue: firstDueDate
        )
        modelContext.insert(chore)
        NotificationService.shared.scheduleChoreOverdueNotification(for: chore)
        dismiss()
    }
}
