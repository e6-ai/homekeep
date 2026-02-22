import SwiftUI
import SwiftData
import UserNotifications

@main
struct HomeKeepApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MaintenanceTask.self,
            CompletionRecord.self,
            Zone.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if !AppMediaMode.enabled && NotificationService.shared.globalRemindersEnabled {
                        Task {
                            _ = await NotificationService.shared.requestAuthorization()
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
        }
    }
}
