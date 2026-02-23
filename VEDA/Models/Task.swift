import Foundation
import SwiftData

@Model
final class Task {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var isDaily: Bool
    var createdAt: Date
    var sortOrder: Int

    init(title: String, isDaily: Bool = false, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.isDaily = isDaily
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }
}
