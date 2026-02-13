import SwiftUI

struct TaskRow: View {
    let task: MaintenanceTask
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: task.sfSymbol)
                .font(.title3)
                .foregroundStyle(urgencyColor)
                .frame(width: 36, height: 36)
                .background(urgencyColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if let zone = task.zone {
                        Text(zone.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("·")
                        .foregroundStyle(.secondary)
                    
                    Text(task.frequency.shortLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Due info
            VStack(alignment: .trailing, spacing: 2) {
                if let days = task.daysUntilDue {
                    if days < 0 {
                        Text("\(abs(days))d late")
                            .font(.caption.bold())
                            .foregroundStyle(.red)
                    } else if days == 0 {
                        Text("Today")
                            .font(.caption.bold())
                            .foregroundStyle(.orange)
                    } else {
                        Text("\(days)d")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Complete button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    task.markComplete()
                    NotificationService.shared.scheduleReminder(for: task)
                }
            } label: {
                Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }
    
    private var urgencyColor: Color {
        guard let days = task.daysUntilDue else { return .secondary }
        if days < 0 { return .red }
        if days <= 7 { return .orange }
        if days <= 30 { return .blue }
        return .green
    }
}
