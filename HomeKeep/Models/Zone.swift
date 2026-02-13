import Foundation
import SwiftData

@Model
final class Zone {
    var id: UUID
    var name: String
    var sfSymbol: String
    var sortOrder: Int
    
    @Relationship(deleteRule: .nullify, inverse: \MaintenanceTask.zone)
    var tasks: [MaintenanceTask]
    
    init(name: String, sfSymbol: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.sfSymbol = sfSymbol
        self.sortOrder = sortOrder
        self.tasks = []
    }
}

extension Zone {
    static let defaultZones: [(String, String)] = [
        ("Kitchen", "refrigerator.fill"),
        ("Bathroom", "shower.fill"),
        ("HVAC", "fan.fill"),
        ("Plumbing", "drop.fill"),
        ("Electrical", "bolt.fill"),
        ("Exterior", "house.fill"),
        ("Garage", "car.fill"),
        ("Laundry", "washer.fill"),
        ("Safety", "shield.checkered"),
        ("Lawn & Garden", "leaf.fill"),
        ("Roof & Gutters", "cloud.rain.fill"),
        ("General", "wrench.and.screwdriver.fill")
    ]
}
