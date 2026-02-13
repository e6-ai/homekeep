import SwiftUI
import SwiftData

struct TaskLibraryView: View {
    @Query(sort: \Zone.sortOrder) private var zones: [Zone]
    @Query private var tasks: [MaintenanceTask]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTask = false
    @State private var searchText = ""
    
    private var filteredTasks: [MaintenanceTask] {
        if searchText.isEmpty { return tasks }
        return tasks.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func tasksForZone(_ zone: Zone) -> [MaintenanceTask] {
        filteredTasks.filter { $0.zone?.id == zone.id }.sorted { $0.name < $1.name }
    }
    
    private var unzonedTasks: [MaintenanceTask] {
        filteredTasks.filter { $0.zone == nil }.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(zones) { zone in
                    let zoneTasks = tasksForZone(zone)
                    if !zoneTasks.isEmpty {
                        Section {
                            ForEach(zoneTasks) { task in
                                NavigationLink(destination: TaskDetailView(task: task)) {
                                    TaskLibraryRow(task: task)
                                }
                            }
                        } header: {
                            Label(zone.name, systemImage: zone.sfSymbol)
                        }
                    }
                }
                
                if !unzonedTasks.isEmpty {
                    Section("Other") {
                        ForEach(unzonedTasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                TaskLibraryRow(task: task)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search tasks...")
            .navigationTitle("All Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(zones: zones)
            }
        }
    }
}

struct TaskLibraryRow: View {
    @Bindable var task: MaintenanceTask
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.sfSymbol)
                .foregroundStyle(Color("AccentColor"))
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 4) {
                    Text(task.frequency.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if task.isCustom {
                        Text("· Custom")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $task.isEnabled)
                .labelsHidden()
                .onChange(of: task.isEnabled) { _, enabled in
                    if enabled {
                        if task.nextDue == nil {
                            task.nextDue = Calendar.current.date(byAdding: .day, value: task.frequency.days, to: Date())
                        }
                        NotificationService.shared.scheduleReminder(for: task)
                    } else {
                        NotificationService.shared.cancelReminder(for: task)
                    }
                }
        }
    }
}
