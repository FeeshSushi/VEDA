import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.sortOrder) private var allTasks: [Task]
    @State private var showingAddTask = false

    private var dailyTasks: [Task] { allTasks.filter { $0.isDaily } }
    private var oneOffTasks: [Task] { allTasks.filter { !$0.isDaily }.sorted { !$0.isCompleted && $1.isCompleted } }

    var body: some View {
        NavigationStack {
            List {
                if !dailyTasks.isEmpty {
                    Section("Today") {
                        ForEach(dailyTasks) { task in
                            TaskRowView(task: task)
                        }
                    }
                }

                Section("To Do") {
                    if oneOffTasks.isEmpty {
                        Text("No tasks. Tap + to add one.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(oneOffTasks) { task in
                            TaskRowView(task: task)
                        }
                        .onDelete(perform: deleteOneOffTasks)
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddTask = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }

    private func deleteOneOffTasks(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(oneOffTasks[index])
        }
    }
}

struct TaskRowView: View {
    @Bindable var task: Task

    var body: some View {
        Button {
            withAnimation { task.isCompleted.toggle() }
        } label: {
            HStack {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .imageScale(.large)
                Text(task.title)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}
