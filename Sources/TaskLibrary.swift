import Foundation

struct TaskTemplate {
    let name: String
    let description: String
    let frequency: TaskFrequency
    let zone: String
    let season: Season?
    let sfSymbol: String
}

struct TaskLibrary {
    static let templates: [TaskTemplate] = [
        // HVAC
        TaskTemplate(name: "Replace HVAC Filter", description: "Replace air filter in furnace/AC unit. Check size before purchasing.", frequency: .monthly, zone: "HVAC", season: nil, sfSymbol: "fan.fill"),
        TaskTemplate(name: "HVAC Professional Service", description: "Schedule annual professional HVAC inspection and tune-up.", frequency: .annual, zone: "HVAC", season: .fall, sfSymbol: "wrench.and.screwdriver.fill"),
        TaskTemplate(name: "Clean AC Condenser Coils", description: "Spray down exterior AC unit coils with garden hose.", frequency: .annual, zone: "HVAC", season: .spring, sfSymbol: "snowflake"),
        TaskTemplate(name: "Check Thermostat Batteries", description: "Replace batteries in thermostat if not hardwired.", frequency: .biannual, zone: "HVAC", season: nil, sfSymbol: "battery.75percent"),
        
        // Plumbing
        TaskTemplate(name: "Flush Water Heater", description: "Drain sediment from water heater tank to maintain efficiency.", frequency: .annual, zone: "Plumbing", season: .fall, sfSymbol: "flame.fill"),
        TaskTemplate(name: "Check for Leaks", description: "Inspect under sinks, around toilets, and near water heater for leaks.", frequency: .quarterly, zone: "Plumbing", season: nil, sfSymbol: "drop.fill"),
        TaskTemplate(name: "Clean Garbage Disposal", description: "Run ice cubes and citrus peels through disposal to clean and deodorize.", frequency: .monthly, zone: "Plumbing", season: nil, sfSymbol: "arrow.3.trianglepath"),
        TaskTemplate(name: "Test Sump Pump", description: "Pour water into sump pit to verify pump activates and drains.", frequency: .quarterly, zone: "Plumbing", season: .spring, sfSymbol: "arrow.up.circle.fill"),
        TaskTemplate(name: "Inspect Water Softener", description: "Check salt levels and clean brine tank.", frequency: .monthly, zone: "Plumbing", season: nil, sfSymbol: "drop.triangle.fill"),
        
        // Exterior
        TaskTemplate(name: "Clean Gutters", description: "Remove leaves and debris from gutters and downspouts.", frequency: .biannual, zone: "Roof & Gutters", season: .fall, sfSymbol: "cloud.rain.fill"),
        TaskTemplate(name: "Inspect Roof", description: "Check for damaged, loose, or missing shingles.", frequency: .annual, zone: "Roof & Gutters", season: .spring, sfSymbol: "house.fill"),
        TaskTemplate(name: "Power Wash Exterior", description: "Power wash siding, deck, driveway, and walkways.", frequency: .annual, zone: "Exterior", season: .spring, sfSymbol: "water.waves"),
        TaskTemplate(name: "Seal Driveway", description: "Apply sealant to asphalt driveway to prevent cracks.", frequency: .annual, zone: "Exterior", season: .summer, sfSymbol: "road.lanes"),
        TaskTemplate(name: "Check Exterior Caulking", description: "Inspect and repair caulking around windows, doors, and trim.", frequency: .annual, zone: "Exterior", season: .fall, sfSymbol: "rectangle.and.hand.point.up.left.fill"),
        TaskTemplate(name: "Inspect Deck/Patio", description: "Check for loose boards, popped nails, and signs of rot.", frequency: .annual, zone: "Exterior", season: .spring, sfSymbol: "square.grid.3x3.fill"),
        
        // Safety
        TaskTemplate(name: "Test Smoke Detectors", description: "Press test button on all smoke detectors.", frequency: .monthly, zone: "Safety", season: nil, sfSymbol: "sensor.fill"),
        TaskTemplate(name: "Replace Smoke Detector Batteries", description: "Replace batteries in all smoke and CO detectors.", frequency: .annual, zone: "Safety", season: .fall, sfSymbol: "battery.100percent.bolt"),
        TaskTemplate(name: "Test CO Detectors", description: "Press test button on carbon monoxide detectors.", frequency: .monthly, zone: "Safety", season: nil, sfSymbol: "exclamationmark.triangle.fill"),
        TaskTemplate(name: "Check Fire Extinguisher", description: "Verify pressure gauge is in green zone and check expiry date.", frequency: .annual, zone: "Safety", season: nil, sfSymbol: "flame.circle.fill"),
        TaskTemplate(name: "Test GFCIs", description: "Press test/reset buttons on all GFCI outlets.", frequency: .monthly, zone: "Electrical", season: nil, sfSymbol: "bolt.circle.fill"),
        
        // Kitchen
        TaskTemplate(name: "Clean Range Hood Filter", description: "Remove and soak range hood grease filters in hot soapy water.", frequency: .quarterly, zone: "Kitchen", season: nil, sfSymbol: "oven.fill"),
        TaskTemplate(name: "Clean Refrigerator Coils", description: "Vacuum dust from refrigerator condenser coils (underneath or behind).", frequency: .biannual, zone: "Kitchen", season: nil, sfSymbol: "refrigerator.fill"),
        TaskTemplate(name: "Deep Clean Oven", description: "Run self-clean cycle or manually clean oven interior.", frequency: .quarterly, zone: "Kitchen", season: nil, sfSymbol: "flame.fill"),
        TaskTemplate(name: "Clean Dishwasher", description: "Run empty cycle with dishwasher cleaner. Clean filter and spray arms.", frequency: .monthly, zone: "Kitchen", season: nil, sfSymbol: "dishwasher.fill"),
        
        // Laundry
        TaskTemplate(name: "Clean Dryer Vent", description: "Disconnect and clean entire dryer vent duct. Critical fire safety task.", frequency: .annual, zone: "Laundry", season: nil, sfSymbol: "wind"),
        TaskTemplate(name: "Clean Washing Machine", description: "Run empty hot cycle with washer cleaner. Wipe door gasket.", frequency: .monthly, zone: "Laundry", season: nil, sfSymbol: "washer.fill"),
        TaskTemplate(name: "Inspect Washing Machine Hoses", description: "Check for bulges, cracks, or leaks. Replace every 5 years.", frequency: .annual, zone: "Laundry", season: nil, sfSymbol: "pipe.and.drop.fill"),
        
        // Lawn & Garden
        TaskTemplate(name: "Fertilize Lawn", description: "Apply seasonal fertilizer appropriate for grass type.", frequency: .quarterly, zone: "Lawn & Garden", season: .spring, sfSymbol: "leaf.fill"),
        TaskTemplate(name: "Aerate Lawn", description: "Core aerate lawn to reduce compaction and improve growth.", frequency: .annual, zone: "Lawn & Garden", season: .fall, sfSymbol: "circle.grid.3x3.fill"),
        TaskTemplate(name: "Winterize Sprinklers", description: "Blow out irrigation lines before first freeze.", frequency: .annual, zone: "Lawn & Garden", season: .fall, sfSymbol: "snowflake"),
        TaskTemplate(name: "Trim Trees & Shrubs", description: "Prune dead branches and shape hedges.", frequency: .annual, zone: "Lawn & Garden", season: .spring, sfSymbol: "tree.fill"),
        
        // General
        TaskTemplate(name: "Inspect Attic/Crawlspace", description: "Check for moisture, pests, insulation damage, and ventilation.", frequency: .biannual, zone: "General", season: nil, sfSymbol: "magnifyingglass"),
        TaskTemplate(name: "Lubricate Door Hinges", description: "Apply WD-40 or silicone spray to squeaky door hinges.", frequency: .annual, zone: "General", season: nil, sfSymbol: "door.left.hand.open"),
        TaskTemplate(name: "Touch Up Interior Paint", description: "Fix scuffs, nail holes, and chips in interior paint.", frequency: .annual, zone: "General", season: .spring, sfSymbol: "paintbrush.fill"),
        TaskTemplate(name: "Clean Windows", description: "Wash all interior and exterior window surfaces.", frequency: .biannual, zone: "General", season: .spring, sfSymbol: "window.vertical.open"),
        TaskTemplate(name: "Replace Water Filters", description: "Replace refrigerator water filter and any whole-house filters.", frequency: .biannual, zone: "Kitchen", season: nil, sfSymbol: "line.3.crossed.swirl.circle.fill"),
        
        // Garage
        TaskTemplate(name: "Lubricate Garage Door", description: "Spray silicone lubricant on garage door tracks, rollers, and hinges.", frequency: .biannual, zone: "Garage", season: nil, sfSymbol: "door.garage.open"),
        TaskTemplate(name: "Test Garage Door Auto-Reverse", description: "Place object under door to verify auto-reverse safety feature works.", frequency: .monthly, zone: "Garage", season: nil, sfSymbol: "arrow.up.arrow.down"),
        
        // Bathroom
        TaskTemplate(name: "Re-caulk Shower/Tub", description: "Inspect and replace caulking around tub, shower, and sink.", frequency: .annual, zone: "Bathroom", season: nil, sfSymbol: "shower.fill"),
        TaskTemplate(name: "Clean Bathroom Exhaust Fan", description: "Remove cover and vacuum dust from exhaust fan.", frequency: .biannual, zone: "Bathroom", season: nil, sfSymbol: "fan.fill"),
    ]
}
