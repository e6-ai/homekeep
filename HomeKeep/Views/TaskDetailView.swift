import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Bindable var task: MaintenanceTask
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingCompleteConfirm = false
    @State private var completionNote = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header card
                VStack(spacing: 16) {
                    Image(systemName: task.sfSymbol)
                        .font(.system(size: 44))
                        .foregroundStyle(Color("AccentColor"))
                        .frame(width: 80, height: 80)
                        .background(Color("AccentColor").opacity(0.12), in: Circle())
                    
                    Text(task.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    if !task.taskDescription.isEmpty {
                        Text(task.taskDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Status pill
                    if let days = task.daysUntilDue {
                        HStack {
                            Circle()
                                .fill(days < 0 ? .red : days <= 7 ? .orange : .green)
                                .frame(width: 8, height: 8)
                            Text(statusText(days: days))
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                
                // Details
                VStack(spacing: 0) {
                    DetailRow(icon: "repeat", label: "Frequency", value: task.frequency.rawValue)
                    Divider().padding(.leading, 44)
                    
                    if let zone = task.zone {
                        DetailRow(icon: zone.sfSymbol, label: "Zone", value: zone.name)
                        Divider().padding(.leading, 44)
                    }
                    
                    if let season = task.season {
                        DetailRow(icon: season.icon, label: "Season", value: season.rawValue)
                        Divider().padding(.leading, 44)
                    }
                    
                    DetailRow(icon: "calendar", label: "Next Due", value: task.nextDue?.formatted(date: .abbreviated, time: .omitted) ?? "Not set")
                    Divider().padding(.leading, 44)
                    
                    DetailRow(icon: "checkmark.circle", label: "Last Done", value: task.lastCompleted?.formatted(date: .abbreviated, time: .omitted) ?? "Never")
                    Divider().padding(.leading, 44)
                    
                    DetailRow(icon: "bell", label: "Reminder", value: task.remindersEnabled ? task.reminderTiming.rawValue : "Off")
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Settings
                VStack(spacing: 0) {
                    Toggle(isOn: $task.isEnabled) {
                        Label("Enabled", systemImage: "power")
                    }
                    .padding()
                    .onChange(of: task.isEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.scheduleReminder(for: task)
                        } else {
                            NotificationService.shared.cancelReminder(for: task)
                        }
                    }
                    
                    Divider().padding(.leading)
                    
                    Toggle(isOn: $task.remindersEnabled) {
                        Label("Reminders", systemImage: "bell.fill")
                    }
                    .padding()
                    .onChange(of: task.remindersEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.scheduleReminder(for: task)
                        } else {
                            NotificationService.shared.cancelReminder(for: task)
                        }
                    }
                    
                    if task.remindersEnabled {
                        Divider().padding(.leading)
                        Picker("Timing", selection: $task.reminderTiming) {
                            ForEach(ReminderTiming.allCases) { timing in
                                Text(timing.rawValue).tag(timing)
                            }
                        }
                        .padding()
                        .onChange(of: task.reminderTiming) { _, _ in
                            NotificationService.shared.scheduleReminder(for: task)
                        }
                    }
                    
                    Divider().padding(.leading)
                    
                    Picker("Frequency", selection: $task.frequency) {
                        ForEach(TaskFrequency.allCases) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .padding()
                    .onChange(of: task.frequency) { _, _ in
                        task.nextDue = Calendar.current.date(byAdding: .day, value: task.frequency.days, to: task.lastCompleted ?? Date())
                        NotificationService.shared.scheduleReminder(for: task)
                    }
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    TextField("Add notes...", text: $task.notes, axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                }
                
                // History
                if !task.completionHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Completion History")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(task.completionHistory.sorted(by: { $0.completedAt > $1.completedAt }).prefix(10)) { record in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text(record.completedAt.formatted(date: .abbreviated, time: .shortened))
                                    Spacer()
                                    if !record.notes.isEmpty {
                                        Text(record.notes)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                
                                if record.id != task.completionHistory.sorted(by: { $0.completedAt > $1.completedAt }).prefix(10).last?.id {
                                    Divider().padding(.leading, 44)
                                }
                            }
                        }
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    }
                }
                
                // Mark complete button
                Button {
                    showingCompleteConfirm = true
                } label: {
                    Label("Mark Complete", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green, in: RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
                
                // Delete if custom
                if task.isCustom {
                    Button(role: .destructive) {
                        modelContext.delete(task)
                        dismiss()
                    } label: {
                        Label("Delete Task", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .alert("Mark Complete", isPresented: $showingCompleteConfirm) {
            TextField("Note (optional)", text: $completionNote)
            Button("Complete") {
                let record = CompletionRecord(task: task, notes: completionNote)
                task.completionHistory.append(record)
                task.lastCompleted = Date()
                task.nextDue = Calendar.current.date(byAdding: .day, value: task.frequency.days, to: Date())
                NotificationService.shared.scheduleReminder(for: task)
                completionNote = ""
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Mark \"\(task.name)\" as completed today?")
        }
    }
    
    private func statusText(days: Int) -> String {
        if days < 0 { return "\(abs(days)) days overdue" }
        if days == 0 { return "Due today" }
        if days == 1 { return "Due tomorrow" }
        return "Due in \(days) days"
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 28)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}
