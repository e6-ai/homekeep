import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Int
    @State private var hasSeeded = false

    init() {
        _selectedTab = State(initialValue: AppMediaMode.initialTab)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            TaskLibraryView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(1)
            
            SeasonalView()
                .tabItem {
                    Label("Seasonal", systemImage: "calendar")
                }
                .tag(2)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(Color("AccentColor"))
        .onAppear {
            guard !hasSeeded else { return }
            hasSeeded = true

            if AppMediaMode.enabled {
                AppMediaSeeder.seedIfNeeded(context: modelContext)
            } else {
                SeedService.seedIfNeeded(context: modelContext)
            }
        }
        .task(id: AppMediaMode.videoAutoplay) {
            guard AppMediaMode.videoAutoplay else { return }
            await runMediaAutoplayLoop()
        }
    }

    @MainActor
    private func runMediaAutoplayLoop() async {
        let sequence = [0, 1, 2, 3, 4, 0]

        while !Task.isCancelled {
            for tabIndex in sequence {
                if Task.isCancelled { return }

                withAnimation(.easeInOut(duration: 0.8)) {
                    selectedTab = tabIndex
                }

                try? await Task.sleep(for: .seconds(4))
            }
        }
    }
}
