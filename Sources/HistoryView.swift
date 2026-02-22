import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \CompletionRecord.completedAt, order: .reverse)
    private var records: [CompletionRecord]
    
    private var groupedRecords: [(String, [CompletionRecord])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        let grouped = Dictionary(grouping: records) { record in
            formatter.string(from: record.completedAt)
        }
        
        return grouped.sorted { lhs, rhs in
            guard let lhsDate = lhs.value.first?.completedAt,
                  let rhsDate = rhs.value.first?.completedAt else { return false }
            return lhsDate > rhsDate
        }
    }
    
    var body: some View {
        NavigationStack {
            if records.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock.fill",
                    description: Text("Complete tasks to see them here")
                )
                .navigationTitle("History")
            } else {
                List {
                    ForEach(groupedRecords, id: \.0) { month, monthRecords in
                        Section(month) {
                            ForEach(monthRecords) { record in
                                HistoryRow(record: record)
                            }
                        }
                    }
                }
                .navigationTitle("History")
            }
        }
    }
}

private struct HistoryRow: View {
    let record: CompletionRecord

    var body: some View {
        Group {
            if let task = record.task {
                NavigationLink(destination: TaskDetailView(task: task)) {
                    rowContent
                }
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            Image(systemName: record.task?.sfSymbol ?? "checkmark.circle.fill")
                .foregroundStyle(.green)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.task?.name ?? "Unknown Task")
                    .font(.subheadline.weight(.medium))
                Text(record.completedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !record.notes.isEmpty {
                    Text(record.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
    }
}
