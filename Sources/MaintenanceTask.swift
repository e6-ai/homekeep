import Foundation
import SwiftData

enum TaskFrequency: String, Codable, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case biweekly = "Every 2 Weeks"
    case monthly = "Monthly"
    case quarterly = "Every 3 Months"
    case biannual = "Every 6 Months"
    case annual = "Yearly"

    var id: String { rawValue }
    
    var days: Int {
        switch self {
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        case .quarterly: return 90
        case .biannual: return 182
        case .annual: return 365
        }
    }
    
    var shortLabel: String {
        switch self {
        case .weekly: return "1w"
        case .biweekly: return "2w"
        case .monthly: return "1mo"
        case .quarterly: return "3mo"
        case .biannual: return "6mo"
        case .annual: return "1yr"
        }
    }
}

enum Season: String, Codable, CaseIterable, Identifiable {
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
    case winter = "Winter"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .spring: return "leaf.fill"
        case .summer: return "sun.max.fill"
        case .fall: return "wind"
        case .winter: return "snowflake"
        }
    }
    
    static func current() -> Season {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .fall
        default: return .winter
        }
    }
}

enum ReminderTiming: String, Codable, CaseIterable, Identifiable {
    case dayOf = "Day of"
    case dayBefore = "1 day before"
    case weekBefore = "1 week before"
    
    var id: String { rawValue }
    
    var offsetDays: Int {
        switch self {
        case .dayOf: return 0
        case .dayBefore: return 1
        case .weekBefore: return 7
        }
    }
}

@Model
final class MaintenanceTask {
    var id: UUID
    var name: String
    var taskDescription: String
    var frequency: TaskFrequency
    var zone: Zone?
    var season: Season?
    var isEnabled: Bool
    var isCustom: Bool
    var lastCompleted: Date?
    var nextDue: Date?
    var reminderTiming: ReminderTiming
    var remindersEnabled: Bool
    var notes: String
    var sfSymbol: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \CompletionRecord.task)
    var completionHistory: [CompletionRecord]
    
    init(
        name: String,
        taskDescription: String = "",
        frequency: TaskFrequency = .monthly,
        season: Season? = nil,
        isEnabled: Bool = true,
        isCustom: Bool = false,
        reminderTiming: ReminderTiming = .dayBefore,
        remindersEnabled: Bool = true,
        notes: String = "",
        sfSymbol: String = "wrench.fill"
    ) {
        self.id = UUID()
        self.name = name
        self.taskDescription = taskDescription
        self.frequency = frequency
        self.season = season
        self.isEnabled = isEnabled
        self.isCustom = isCustom
        self.reminderTiming = reminderTiming
        self.remindersEnabled = remindersEnabled
        self.notes = notes
        self.sfSymbol = sfSymbol
        self.createdAt = Date()
        self.completionHistory = []
        self.nextDue = Calendar.current.date(byAdding: .day, value: frequency.days, to: Date())
    }
    
    var isOverdue: Bool {
        guard let nextDue else { return false }
        return nextDue < Date()
    }
    
    var isDueThisWeek: Bool {
        guard let nextDue else { return false }
        let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        return nextDue >= Date() && nextDue <= weekFromNow
    }
    
    var isDueThisMonth: Bool {
        guard let nextDue else { return false }
        let monthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        return nextDue > Calendar.current.date(byAdding: .day, value: 7, to: Date())! && nextDue <= monthFromNow
    }
    
    var daysUntilDue: Int? {
        guard let nextDue else { return nil }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextDue)).day
    }

    func ensureNextDueIfMissing(referenceDate: Date = Date()) {
        guard nextDue == nil else { return }
        let anchorDate = lastCompleted ?? referenceDate
        nextDue = Calendar.current.date(byAdding: .day, value: frequency.days, to: anchorDate)
    }

    func refreshNextDueFromLastCompleted(referenceDate: Date = Date()) {
        let anchorDate = lastCompleted ?? referenceDate
        nextDue = Calendar.current.date(byAdding: .day, value: frequency.days, to: anchorDate)
    }

    @discardableResult
    func markComplete(notes: String = "", completionDate: Date = Date()) -> CompletionRecord {
        let record = CompletionRecord(task: self, notes: notes, completedAt: completionDate)
        completionHistory.append(record)
        lastCompleted = completionDate
        nextDue = Calendar.current.date(byAdding: .day, value: frequency.days, to: completionDate)
        return record
    }
}
