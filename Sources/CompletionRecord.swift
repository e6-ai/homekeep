import Foundation
import SwiftData

@Model
final class CompletionRecord {
    var id: UUID
    var completedAt: Date
    var notes: String
    var task: MaintenanceTask?
    
    init(task: MaintenanceTask, notes: String = "") {
        self.id = UUID()
        self.completedAt = Date()
        self.notes = notes
        self.task = task
    }
}
