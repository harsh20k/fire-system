import SwiftUI
import Charts

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var events: [ChangeEvent] = []
    @State private var selectedField: String = "income"

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
            BrutalText(text: "Change History", variant: .title)

            Picker("Field", selection: $selectedField) {
                ForEach(FireInputs.fieldKeys, id: \.self) { key in
                    Text(key).tag(key)
                }
            }
            .frame(width: 260)
            .onChange(of: selectedField) { refresh() }

            BrutalCard {
                let fieldHistory = store.history(for: selectedField)
                if fieldHistory.isEmpty {
                    BrutalText(text: "No recorded changes for \(selectedField) yet.", variant: .body, color: Theme.mutedText(scheme))
                        .frame(height: 160)
                } else {
                    Chart(fieldHistory) { event in
                        LineMark(x: .value("Time", event.timestamp), y: .value("Value", event.newValue))
                            .foregroundStyle(Theme.primary)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .symbol(Circle())
                    }
                    .frame(height: 180)
                }
            }

            BrutalText(text: "All changes", variant: .body, bold: true)

            if events.isEmpty {
                ContentUnavailableView("No changes yet", systemImage: "clock", description: Text(Personalization.historyEmpty))
            } else {
                ScrollView {
                    VStack(spacing: Theme.Spacing.inline) {
                        ForEach(events) { event in
                            BrutalCard {
                                HStack {
                                    Image(systemName: event.source == "assistant" ? "sparkles" : "hand.point.up.left")
                                        .foregroundStyle(event.source == "assistant" ? Theme.slate : Theme.mutedText(scheme))
                                    VStack(alignment: .leading, spacing: 2) {
                                        BrutalText(text: event.fieldKey, variant: .body, bold: true)
                                        BrutalText(
                                            text: "\(String(format: "%.1f", event.oldValue)) → \(String(format: "%.1f", event.newValue))",
                                            variant: .caption,
                                            color: Theme.mutedText(scheme)
                                        )
                                    }
                                    Spacer()
                                    BrutalText(
                                        text: event.timestamp.formatted(date: .abbreviated, time: .shortened),
                                        variant: .caption,
                                        color: Theme.mutedText(scheme)
                                    )
                                }
                            }
                        }
                    }
                }
            }

            Spacer()
            HStack {
                Spacer()
                BrutalButton(title: "Done", variant: .secondary) { dismiss() }
                    .frame(width: 140)
            }
        }
        .padding(Theme.Spacing.screen)
        .frame(minWidth: 520, minHeight: 520)
        .background(Theme.neutral(scheme))
        .onAppear(perform: refresh)
        .onExitCommand { dismiss() }
    }

    private func refresh() {
        events = store.recentChanges(limit: 200)
    }
}
