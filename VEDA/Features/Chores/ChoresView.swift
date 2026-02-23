import SwiftUI
import SwiftData

struct ChoresView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Chore.nextDue) private var chores: [Chore]
    @State private var showingAddChore = false

    var body: some View {
        NavigationStack {
            Group {
                if chores.isEmpty {
                    ContentUnavailableView("No Chores", systemImage: "repeat", description: Text("Tap + to add a recurring chore."))
                } else {
                    List {
                        ForEach(chores) { chore in
                            ChoreRowView(chore: chore, onComplete: { markComplete(chore) })
                        }
                        .onDelete(perform: deleteChores)
                    }
                }
            }
            .navigationTitle("Chores")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddChore = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddChore) {
                AddChoreView()
            }
        }
    }

    private func markComplete(_ chore: Chore) {
        let now = Date()
        NotificationService.shared.cancelNotification(for: chore.id)
        chore.lastCompleted = now
        chore.nextDue = chore.calculateNextDue(from: now)
        NotificationService.shared.scheduleChoreOverdueNotification(for: chore)
    }

    private func deleteChores(offsets: IndexSet) {
        for index in offsets {
            NotificationService.shared.cancelNotification(for: chores[index].id)
            modelContext.delete(chores[index])
        }
    }
}

struct ChoreRowView: View {
    let chore: Chore
    let onComplete: () -> Void

    private var relativeDue: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(chore.nextDue) { return "Due today" }
        if calendar.isDateInYesterday(chore.nextDue) { return "Due yesterday" }
        if chore.isOverdue {
            let days = calendar.dateComponents([.day], from: chore.nextDue, to: Date()).day ?? 0
            return "\(days) day\(days == 1 ? "" : "s") overdue"
        }
        if calendar.isDateInTomorrow(chore.nextDue) { return "Due tomorrow" }
        let days = calendar.dateComponents([.day], from: Date(), to: chore.nextDue).day ?? 0
        return "Due in \(days) days"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(chore.title)
                    .font(.body)
                Text(relativeDue)
                    .font(.caption)
                    .foregroundStyle(chore.isOverdue ? .red : .secondary)
            }
            Spacer()
            Button {
                withAnimation { onComplete() }
            } label: {
                Image(systemName: "checkmark.circle")
                    .imageScale(.large)
                    .foregroundStyle(.green)
            }
            .buttonStyle(.plain)
        }
        .listRowBackground(chore.isOverdue ? Color.red.opacity(0.07) : Color.clear)
    }
}
