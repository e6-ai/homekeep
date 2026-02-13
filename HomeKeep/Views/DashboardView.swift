import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(filter: #Predicate<MaintenanceTask> { $0.isEnabled }, sort: \MaintenanceTask.nextDue)
    private var tasks: [MaintenanceTask]
    
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
                            "All Caught Up!",
                            systemImage: "checkmark.circle.fill",
                            description: Text("No tasks due this month. Great job keeping up!")
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
