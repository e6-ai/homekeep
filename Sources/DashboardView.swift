import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(filter: #Predicate<MaintenanceTask> { $0.isEnabled }, sort: \MaintenanceTask.nextDue)
    private var tasks: [MaintenanceTask]
    @AppStorage("hasSeenStarterTasksHint") private var hasSeenStarterTasksHint = false
    
    private var overdueTasks: [MaintenanceTask] {
        tasks.filter { $0.isOverdue }
    }
    
    private var thisWeekTasks: [MaintenanceTask] {
        tasks.filter { $0.isDueThisWeek }
    }
    
    private var thisMonthTasks: [MaintenanceTask] {
        tasks.filter { $0.isDueThisMonth }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary card
                    SummaryCard(
                        overdueCount: overdueTasks.count,
                        weekCount: thisWeekTasks.count,
                        totalActive: tasks.count
                    )
                    .padding(.horizontal)

                    if !hasSeenStarterTasksHint && !tasks.isEmpty {
                        StarterTasksHint {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                hasSeenStarterTasksHint = true
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if !overdueTasks.isEmpty {
                        TaskSection(title: "Overdue", icon: "exclamationmark.circle.fill", color: .red, tasks: overdueTasks)
                    }
                    
                    if !thisWeekTasks.isEmpty {
                        TaskSection(title: "This Week", icon: "clock.fill", color: .orange, tasks: thisWeekTasks)
                    }
                    
                    if !thisMonthTasks.isEmpty {
                        TaskSection(title: "This Month", icon: "calendar", color: .blue, tasks: thisMonthTasks)
                    }
                    
                    if overdueTasks.isEmpty && thisWeekTasks.isEmpty && thisMonthTasks.isEmpty {
                        ContentUnavailableView(
                            tasks.isEmpty ? "Welcome to HomeKeep" : "All Caught Up!",
                            systemImage: tasks.isEmpty ? "house.fill" : "checkmark.circle.fill",
                            description: Text(tasks.isEmpty
                                ? "Enable tasks from the Tasks tab to get started."
                                : "No tasks due this month. Great job keeping up!")
                        )
                        .padding(.top, 40)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("HomeKeep")
        }
    }
}

private struct StarterTasksHint: View {
    let dismissAction: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AccentColor"))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Starter Tasks Enabled")
                    .font(.subheadline.weight(.semibold))
                Text("We started with 5 essential safety and HVAC tasks. Enable more anytime from Tasks.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Button("Got it", action: dismissAction)
                .font(.caption.weight(.semibold))
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct SummaryCard: View {
    let overdueCount: Int
    let weekCount: Int
    let totalActive: Int
    
    var body: some View {
        HStack(spacing: 0) {
            SummaryItem(count: overdueCount, label: "Overdue", color: overdueCount > 0 ? .red : .secondary)
            Divider().frame(height: 40)
            SummaryItem(count: weekCount, label: "This Week", color: weekCount > 0 ? .orange : .secondary)
            Divider().frame(height: 40)
            SummaryItem(count: totalActive, label: "Active", color: .blue)
        }
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct SummaryItem: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TaskSection: View {
    let title: String
    let icon: String
    let color: Color
    let tasks: [MaintenanceTask]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
                Text("(\(tasks.count))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(tasks) { task in
                    NavigationLink(destination: TaskDetailView(task: task)) {
                        TaskRow(task: task)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
