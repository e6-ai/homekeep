import Foundation
import SwiftData
import os

struct SeedService {
    private static let logger = Logger(subsystem: "com.homekeep", category: "SeedService")
    private static let starterEnabledTaskNames: Set<String> = [
        "Replace HVAC Filter",
        "Test Smoke Detectors",
        "Test CO Detectors",
        "Check Fire Extinguisher",
        "Replace Smoke Detector Batteries"
    ]

    static func seedIfNeeded(context: ModelContext) {
        let zoneMap = upsertDefaultZones(context: context)
        upsertDefaultTasks(context: context, zoneMap: zoneMap, resetExistingDefaults: false)
        do { try context.save() } catch { logger.error("Failed to save after seeding: \(error)") }
    }

    static func resetDefaultsPreservingCustomAndHistory(context: ModelContext) {
        let zoneMap = upsertDefaultZones(context: context)
        upsertDefaultTasks(context: context, zoneMap: zoneMap, resetExistingDefaults: true)
        do { try context.save() } catch { logger.error("Failed to save after reset: \(error)") }
    }

    private static func upsertDefaultZones(context: ModelContext) -> [String: Zone] {
        let existingZones = (try? context.fetch(FetchDescriptor<Zone>())) ?? []
        var zonesByName = Dictionary(uniqueKeysWithValues: existingZones.map { ($0.name, $0) })

        for (index, (name, symbol)) in Zone.defaultZones.enumerated() {
            if let existing = zonesByName[name] {
                existing.sfSymbol = symbol
                existing.sortOrder = index
            } else {
                let zone = Zone(name: name, sfSymbol: symbol, sortOrder: index)
                context.insert(zone)
                zonesByName[name] = zone
            }
        }

        return zonesByName
    }

    private static func upsertDefaultTasks(
        context: ModelContext,
        zoneMap: [String: Zone],
        resetExistingDefaults: Bool
    ) {
        let allTasks = (try? context.fetch(FetchDescriptor<MaintenanceTask>())) ?? []
        var defaultTasksByName: [String: MaintenanceTask] = [:]

        for task in allTasks where !task.isCustom {
            if defaultTasksByName[task.name] == nil {
                defaultTasksByName[task.name] = task
            }
        }

        for template in TaskLibrary.templates {
            if let existingTask = defaultTasksByName[template.name] {
                if resetExistingDefaults {
                    applyTemplate(template, to: existingTask, zoneMap: zoneMap, resetTaskState: true)
                } else {
                    // Keep user-edited defaults intact during normal seeding, but heal missing zone links.
                    if existingTask.zone == nil {
                        existingTask.zone = zoneMap[template.zone]
                    }
                }
            } else {
                let task = MaintenanceTask(
                    name: template.name,
                    taskDescription: template.description,
                    frequency: template.frequency,
                    season: template.season,
                    isEnabled: starterEnabledTaskNames.contains(template.name),
                    isCustom: false,
                    reminderTiming: .dayBefore,
                    remindersEnabled: true,
                    sfSymbol: template.sfSymbol
                )
                task.zone = zoneMap[template.zone]
                context.insert(task)
            }
        }
    }

    private static func applyTemplate(
        _ template: TaskTemplate,
        to task: MaintenanceTask,
        zoneMap: [String: Zone],
        resetTaskState: Bool
    ) {
        task.taskDescription = template.description
        task.frequency = template.frequency
        task.season = template.season
        task.zone = zoneMap[template.zone]
        task.sfSymbol = template.sfSymbol

        guard resetTaskState else { return }

        task.isEnabled = starterEnabledTaskNames.contains(template.name)
        task.remindersEnabled = true
        task.reminderTiming = .dayBefore
        task.refreshNextDueFromLastCompleted()
    }
}
