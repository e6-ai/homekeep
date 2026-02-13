import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var hasSeeded = false
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            TaskLibraryView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
            
            SeasonalView()
                .tabItem {
                    Label("Seasonal", systemImage: "calendar")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color("AccentColor"))
        .onAppear {
            if !hasSeeded {
                SeedService.seedIfNeeded(context: modelContext)
                hasSeeded = true
            }
        }
    }
}
