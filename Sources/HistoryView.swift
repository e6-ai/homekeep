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
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(record.task?.name ?? "Unknown Task")
                                            .font(.subheadline.weight(.medium))
                                        Text(record.completedAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if !record.notes.isEmpty {
                                        Image(systemName: "note.text")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("History")
            }
        }
    }
}
