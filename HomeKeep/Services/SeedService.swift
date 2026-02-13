import Foundation
import SwiftData

struct SeedService {
    static func seedIfNeeded(context: ModelContext) {
        // Check if we already have zones
        let descriptor = FetchDescriptor<Zone>()
        let existingZones = (try? context.fetch(descriptor)) ?? []
        guard existingZones.isEmpty else { return }
        
        // Create zones
        var zoneMap: [String: Zone] = [:]
        for (index, (name, symbol)) in Zone.defaultZones.enumerated() {
            let zone = Zone(name: name, sfSymbol: symbol, sortOrder: index)
            context.insert(zone)
            zoneMap[name] = zone
        }
        
        // Create tasks from library
        for template in TaskLibrary.templates {
            let task = MaintenanceTask(
                name: template.name,
                taskDescription: template.description,
                frequency: template.frequency,
                season: template.season,
                isEnabled: true,
                isCustom: false,
                sfSymbol: template.sfSymbol
            )
            task.zone = zoneMap[template.zone]
            context.insert(task)
        }
        
        try? context.save()
    }
}
