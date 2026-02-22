import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var tasks: [MaintenanceTask]
    @Query private var records: [CompletionRecord]
    @AppStorage("globalReminders") private var globalReminders = true
    @AppStorage("reminderHour") private var reminderHour = 9
    @State private var showingResetAlert = false
    @State private var notificationsAuthorized = true
    
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
                    .onChange(of: globalReminders) { _, enabled in
                        Task {
                            if enabled {
                                _ = await NotificationService.shared.requestAuthorization()
                            }
                            await refreshNotificationAuthorization()
                            NotificationService.shared.rescheduleAll(tasks: tasks)
                        }
                    }
                    
                    if globalReminders {
                        Picker(selection: $reminderHour) {
                            ForEach(6..<22) { hour in
                                Text(hourString(hour)).tag(hour)
                            }
                        } label: {
                            Label("Reminder Time", systemImage: "clock.fill")
                        }
                        .onChange(of: reminderHour) { _, _ in
                            rescheduleAllReminders()
                        }

                        if !notificationsAuthorized {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Notifications are disabled in iOS Settings.", systemImage: "exclamationmark.triangle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                                Button("Open Settings") {
                                    openSystemSettings()
                                }
                            }
                            .padding(.vertical, 4)
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
                    SeedService.resetDefaultsPreservingCustomAndHistory(context: modelContext)
                    NotificationService.shared.rescheduleAll(tasks: fetchAllTasks())
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset all pre-loaded tasks to their defaults. Custom tasks and completion history will be preserved.")
            }
            .task {
                await refreshNotificationAuthorization()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task {
                        await refreshNotificationAuthorization()
                    }
                }
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

    private func fetchAllTasks() -> [MaintenanceTask] {
        (try? modelContext.fetch(FetchDescriptor<MaintenanceTask>())) ?? tasks
    }

    @MainActor
    private func refreshNotificationAuthorization() async {
        notificationsAuthorized = await NotificationService.shared.checkAuthorizationStatus()
    }

    private func rescheduleAllReminders() {
        NotificationService.shared.rescheduleAll(tasks: tasks)
    }

    private func openSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
}
