import Foundation
import SwiftData

@Model
final class CompletionRecord {
    var id: UUID
    var completedAt: Date
    var notes: String
    var task: MaintenanceTask?
    
    init(task: MaintenanceTask, notes: String = "", completedAt: Date = Date()) {
        self.id = UUID()
        self.completedAt = completedAt
        self.notes = notes
        self.task = task
    }
}
