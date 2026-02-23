import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Task> { $0.isDaily }, sort: \Task.sortOrder) private var dailyTasks: [Task]

    @State private var title = ""
    @State private var isDaily = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task name", text: $title)
                }
                Section {
                    Toggle("Daily task", isOn: $isDaily)
                } footer: {
                    Text("Daily tasks repeat every day and are managed in Settings.")
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addTask() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addTask() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let order = isDaily ? (dailyTasks.map(\.sortOrder).max() ?? -1) + 1 : 0
        let task = Task(title: trimmed, isDaily: isDaily, sortOrder: order)
        modelContext.insert(task)
        dismiss()
    }
}
