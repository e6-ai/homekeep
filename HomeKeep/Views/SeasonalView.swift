import SwiftUI
import SwiftData

struct SeasonalView: View {
    @Query(filter: #Predicate<MaintenanceTask> { $0.isEnabled })
    private var allTasks: [MaintenanceTask]
    
    @State private var selectedSeason: Season = Season.current()
    
    private func tasks(for season: Season) -> [MaintenanceTask] {
        allTasks.filter { $0.season == season }.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Season picker
                HStack(spacing: 12) {
                    ForEach(Season.allCases) { season in
                        SeasonPill(
                            season: season,
                            isSelected: selectedSeason == season,
                            count: tasks(for: season).count
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSeason = season
                            }
                        }
                    }
                }
                .padding()
                
                // Tasks list
                let seasonTasks = tasks(for: selectedSeason)
                if seasonTasks.isEmpty {
                    ContentUnavailableView(
                        "No \(selectedSeason.rawValue) Tasks",
                        systemImage: selectedSeason.icon,
                        description: Text("Enable seasonal tasks from the Tasks tab")
                    )
                } else {
                    List {
                        ForEach(seasonTasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                HStack(spacing: 12) {
                                    Image(systemName: task.sfSymbol)
                                        .foregroundStyle(Color("AccentColor"))
                                        .frame(width: 28)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.name)
                                            .font(.subheadline.weight(.medium))
                                        if let zone = task.zone {
                                            Text(zone.name)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if let days = task.daysUntilDue {
                                        Text(days < 0 ? "\(abs(days))d late" : days == 0 ? "Today" : "\(days)d")
                                            .font(.caption)
                                            .foregroundStyle(days < 0 ? .red : days <= 7 ? .orange : .secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Seasonal")
        }
    }
}

struct SeasonPill: View {
    let season: Season
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: season.icon)
                    .font(.title3)
                Text(season.rawValue)
                    .font(.caption2.weight(.medium))
                Text("\(count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color("AccentColor").opacity(0.15) : Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(isSelected ? Color("AccentColor") : .secondary)
        }
        .buttonStyle(.plain)
    }
}
