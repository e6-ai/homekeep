import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var tasks: [MaintenanceTask]
    @Query private var records: [CompletionRecord]
    @AppStorage("globalReminders") private var globalReminders = true
    @AppStorage("reminderHour") private var reminderHour = 9
    @State private var showingResetAlert = false
    
    private var activeTasks: Int {
        tasks.filter { $0.isEnabled }.count
    }
    
    private var customTasks: Int {
        tasks.filter { $0.isCustom }.count
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Notifications") {
                    Toggle(isOn: $globalReminders) {
                        Label("Enable Reminders", systemImage: "bell.fill")
                    }
                    
                    if globalReminders {
                        Picker(selection: $reminderHour) {
                            ForEach(6..<22) { hour in
                                Text(hourString(hour)).tag(hour)
                            }
                        } label: {
                            Label("Reminder Time", systemImage: "clock.fill")
                        }
                    }
                }
                
                Section("Your Home") {
                    HStack {
                        Label("Active Tasks", systemImage: "checklist")
                        Spacer()
                        Text("\(activeTasks)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Custom Tasks", systemImage: "plus.circle")
                        Spacer()
                        Text("\(customTasks)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Completions", systemImage: "checkmark.circle")
                        Spacer()
                        Text("\(records.count)")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Data") {
                    Button {
                        showingResetAlert = true
                    } label: {
                        Label("Reset All Tasks to Defaults", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "house.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color("AccentColor"))
                        Text("HomeKeep")
                            .font(.headline)
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Made with ❤️ for homeowners")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Tasks?", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) {
                    // Reset is handled by deleting and re-seeding
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset all pre-loaded tasks to their defaults. Custom tasks and completion history will be preserved.")
            }
        }
    }
    
    private func hourString(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}
