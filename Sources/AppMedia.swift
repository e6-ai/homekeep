import Foundation
import SwiftData

enum AppMediaMode {
    private enum Flag {
        static let enabled = "-media-mode"
        static let tab = "-media-tab"
        static let video = "-media-video"
        static let reset = "-media-reset"
    }

    enum Tab: String {
        case home
        case tasks
        case seasonal
        case history
        case settings

        var index: Int {
            switch self {
            case .home: return 0
            case .tasks: return 1
            case .seasonal: return 2
            case .history: return 3
            case .settings: return 4
            }
        }
    }

    static var enabled: Bool {
        ProcessInfo.processInfo.arguments.contains(Flag.enabled)
    }

    static var videoAutoplay: Bool {
        ProcessInfo.processInfo.arguments.contains(Flag.video)
    }

    static var resetStore: Bool {
        ProcessInfo.processInfo.arguments.contains(Flag.reset)
    }

    static var initialTab: Int {
        guard let tabValue = value(after: Flag.tab),
              let tab = Tab(rawValue: tabValue.lowercased()) else {
            return Tab.home.index
        }

        return tab.index
    }

    private static func value(after flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag), args.indices.contains(index + 1) else {
            return nil
        }
        return args[index + 1]
    }
}

@MainActor
enum AppMediaSeeder {
    static func seedIfNeeded(context: ModelContext) {
        guard AppMediaMode.enabled else { return }

        if AppMediaMode.resetStore {
            resetStore(context: context)
        }

        SeedService.seedIfNeeded(context: context)
        applyDeterministicDemoState(context: context)
    }

    private static func resetStore(context: ModelContext) {
        let records = (try? context.fetch(FetchDescriptor<CompletionRecord>())) ?? []
        for record in records {
            context.delete(record)
        }

        let tasks = (try? context.fetch(FetchDescriptor<MaintenanceTask>())) ?? []
        for task in tasks {
            context.delete(task)
        }

        let zones = (try? context.fetch(FetchDescriptor<Zone>())) ?? []
        for zone in zones {
            context.delete(zone)
        }

        try? context.save()
    }

    private static func applyDeterministicDemoState(context: ModelContext) {
        let descriptor = FetchDescriptor<MaintenanceTask>(sortBy: [SortDescriptor(\MaintenanceTask.name)])
        guard let tasks = try? context.fetch(descriptor), !tasks.isEmpty else { return }

        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let dayOffsets = [-9, -3, 0, 2, 5, 10, 16, 24, 35]

        for (index, task) in tasks.enumerated() {
            task.isEnabled = true
            task.remindersEnabled = false

            let dueOffset = dayOffsets[index % dayOffsets.count]
            task.nextDue = calendar.date(byAdding: .day, value: dueOffset, to: today)
            task.lastCompleted = calendar.date(byAdding: .day, value: dueOffset - task.frequency.days, to: today)
        }

        let existingRecords = (try? context.fetch(FetchDescriptor<CompletionRecord>())) ?? []
        if existingRecords.isEmpty {
            let historyTasks = Array(tasks.prefix(4))
            let historyOffsets = [1, 3, 6, 11]

            for (index, task) in historyTasks.enumerated() {
                let record = CompletionRecord(task: task, notes: index == 0 ? "Completed as part of weekend routine." : "")
                record.completedAt = calendar.date(byAdding: .day, value: -historyOffsets[index], to: now) ?? now
                context.insert(record)
            }
        }

        try? context.save()
    }
}
