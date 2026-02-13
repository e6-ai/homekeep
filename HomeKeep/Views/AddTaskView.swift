import SwiftUI
import SwiftData

struct AddTaskView: View {
    let zones: [Zone]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var frequency: TaskFrequency = .monthly
    @State private var selectedZone: Zone?
    @State private var season: Season?
    @State private var reminderTiming: ReminderTiming = .dayBefore
    @State private var remindersEnabled = true
    @State private var sfSymbol = "wrench.fill"
    
    private let symbolOptions = [
        "wrench.fill", "hammer.fill", "paintbrush.fill", "scissors",
        "leaf.fill", "drop.fill", "flame.fill", "bolt.fill",
        "fan.fill", "lightbulb.fill", "house.fill", "key.fill",
        "star.fill", "heart.fill", "shield.fill", "gear"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Info") {
                    TextField("Task Name", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Schedule") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(TaskFrequency.allCases) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    
                    Picker("Zone", selection: $selectedZone) {
                        Text("None").tag(Zone?.none)
                        ForEach(zones) { zone in
                            Label(zone.name, systemImage: zone.sfSymbol).tag(Zone?.some(zone))
                        }
                    }
                    
                    Picker("Season", selection: $season) {
                        Text("Any").tag(Season?.none)
                        ForEach(Season.allCases) { s in
                            Label(s.rawValue, systemImage: s.icon).tag(Season?.some(s))
                        }
                    }
                }
                
                Section("Reminders") {
                    Toggle("Enable Reminders", isOn: $remindersEnabled)
                    if remindersEnabled {
                        Picker("Timing", selection: $reminderTiming) {
                            ForEach(ReminderTiming.allCases) { timing in
                                Text(timing.rawValue).tag(timing)
                            }
                        }
                    }
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(symbolOptions, id: \.self) { symbol in
                            Image(systemName: symbol)
                                .font(.title3)
                                .foregroundStyle(symbol == sfSymbol ? Color("AccentColor") : .secondary)
                                .frame(width: 36, height: 36)
                                .background(symbol == sfSymbol ? Color("AccentColor").opacity(0.15) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    sfSymbol = symbol
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let task = MaintenanceTask(
                            name: name,
                            taskDescription: description,
                            frequency: frequency,
                            season: season,
                            isEnabled: true,
                            isCustom: true,
                            reminderTiming: reminderTiming,
                            remindersEnabled: remindersEnabled,
                            sfSymbol: sfSymbol
                        )
                        task.zone = selectedZone
                        modelContext.insert(task)
                        NotificationService.shared.scheduleReminder(for: task)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
