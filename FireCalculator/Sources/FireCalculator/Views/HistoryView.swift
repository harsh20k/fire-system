import SwiftUI
import Charts

/// Long-term change tracking: a chronological log of every slider edit, plus a
/// per-field chart showing how a chosen value evolved over time.
struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var events: [ChangeEvent] = []
    @State private var selectedField: String = "income"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Change History").font(Theme.serifTitle).font(.title2)

            Picker("Field", selection: $selectedField) {
                ForEach(FireInputs.fieldKeys, id: \.self) { key in
                    Text(key).tag(key)
                }
            }
            .frame(width: 260)
            .onChange(of: selectedField) { refresh() }

            let fieldHistory = store.history(for: selectedField)
            if fieldHistory.isEmpty {
                Text("No recorded changes for \(selectedField) yet.")
                    .font(.callout).foregroundStyle(.secondary)
                    .frame(height: 160)
            } else {
                Chart(fieldHistory) { event in
                    LineMark(x: .value("Time", event.timestamp), y: .value("Value", event.newValue))
                        .foregroundStyle(Theme.pine)
                        .symbol(Circle())
                }
                .frame(height: 180)
            }

            Divider()

            Text("All changes").font(.headline)
            if events.isEmpty {
                ContentUnavailableView("No changes yet", systemImage: "clock", description: Text(Personalization.historyEmpty))
            } else {
                List(events) { event in
                    HStack {
                        Image(systemName: event.source == "assistant" ? "sparkles" : "hand.point.up.left")
                            .foregroundStyle(event.source == "assistant" ? Theme.slate : Theme.mutedText(scheme))
                        VStack(alignment: .leading) {
                            Text(event.fieldKey).font(.system(.body, design: .monospaced))
                            Text("\(String(format: "%.1f", event.oldValue)) → \(String(format: "%.1f", event.newValue))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
                .listStyle(.inset)
            }

            Spacer()
            HStack {
                Spacer()
                Button("Done") { dismiss() }
            }
        }
        .padding(24)
        .frame(minWidth: 520, minHeight: 520)
        .background(Theme.paper(scheme))
        .onAppear(perform: refresh)
    }

    private func refresh() {
        events = store.recentChanges(limit: 200)
    }
}
