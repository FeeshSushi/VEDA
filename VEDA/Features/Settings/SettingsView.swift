import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Task> { $0.isDaily }, sort: \Task.sortOrder) private var dailyTasks: [Task]
    @State private var showingAddDailyTask = false
    @State private var newTaskTitle = ""

    @AppStorage("waterRemindersEnabled") private var waterRemindersEnabled = false
    @AppStorage("defaultWakeHour") private var defaultWakeHour = 8
    @AppStorage("defaultWakeMinute") private var defaultWakeMinute = 0

    private var defaultWakeTime: Binding<Date> {
        Binding(
            get: {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                components.hour = defaultWakeHour
                components.minute = defaultWakeMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                defaultWakeHour = components.hour ?? 8
                defaultWakeMinute = components.minute ?? 0
            }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Daily reminders", isOn: $waterRemindersEnabled)
                        .onChange(of: waterRemindersEnabled) { _, enabled in
                            if enabled {
                                scheduleWaterFallback()
                            } else {
                                NotificationService.shared.cancelWaterNotifications()
                            }
                        }
                    if waterRemindersEnabled {
                        DatePicker("Default wake time", selection: defaultWakeTime, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Water Reminders")
                } footer: {
                    Text("8 reminders scheduled from your wake time to 1:00 AM. The default wake time is used on days when no sleep is logged.")
                }

                Section {
                    ForEach(dailyTasks) { task in
                        Text(task.title)
                    }
                    .onDelete(perform: deleteDailyTasks)
                    .onMove(perform: moveDailyTasks)

                    Button {
                        showingAddDailyTask = true
                    } label: {
                        Label("Add Daily Task", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Daily Tasks")
                } footer: {
                    Text("These tasks appear every day in the Tasks tab and reset at 5:00 AM.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                EditButton()
            }
            .alert("New Daily Task", isPresented: $showingAddDailyTask) {
                TextField("Task name", text: $newTaskTitle)
                Button("Add") { addDailyTask() }
                Button("Cancel", role: .cancel) { newTaskTitle = "" }
            }
        }
    }

    private func scheduleWaterFallback() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = defaultWakeHour
        components.minute = defaultWakeMinute
        if let fallback = calendar.date(from: components) {
            NotificationService.shared.scheduleWaterNotifications(from: fallback)
        }
    }

    private func addDailyTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { newTaskTitle = ""; return }
        let order = (dailyTasks.map(\.sortOrder).max() ?? -1) + 1
        let task = Task(title: trimmed, isDaily: true, sortOrder: order)
        modelContext.insert(task)
        newTaskTitle = ""
    }

    private func deleteDailyTasks(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(dailyTasks[index])
        }
    }

    private func moveDailyTasks(from source: IndexSet, to destination: Int) {
        var reordered = dailyTasks
        reordered.move(fromOffsets: source, toOffset: destination)
        for (newOrder, task) in reordered.enumerated() {
            task.sortOrder = newOrder
        }
    }
}
