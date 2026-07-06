import SwiftUI
import SwiftData

/// Named, revertable checkpoints — "source control" for the slider scenario.
struct CheckpointsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var checkpoints: [Checkpoint] = []
    @State private var newName: String = ""
    @State private var selectedForDiff: Checkpoint?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Checkpoints")
                .font(Theme.serifTitle.weight(.bold))
                .font(.title2)

            HStack {
                TextField("Checkpoint name (e.g. \"Buy at $500k\")", text: $newName)
                    .textFieldStyle(.roundedBorder)
                Button("Save Checkpoint") {
                    let name = newName.isEmpty ? "Checkpoint \(checkpoints.count + 1)" : newName
                    store.createCheckpoint(name: name)
                    newName = ""
                    refresh()
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.pine)
            }

            if checkpoints.isEmpty {
                ContentUnavailableView("No checkpoints yet", systemImage: "clock.arrow.circlepath", description: Text(Personalization.checkpointEmpty))
            } else {
                List {
                    ForEach(checkpoints) { checkpoint in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(checkpoint.name).font(.headline)
                                    Text(checkpoint.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button("Diff") { selectedForDiff = checkpoint }
                                    .buttonStyle(.bordered)
                                Button("Revert") { store.revert(to: checkpoint) }
                                    .buttonStyle(.bordered).tint(Theme.ochre)
                                Button(role: .destructive) {
                                    store.deleteCheckpoint(checkpoint)
                                    refresh()
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.plain)
                            }
                            if selectedForDiff?.id == checkpoint.id {
                                diffView(for: checkpoint)
                            }
                        }
                        .padding(.vertical, 4)
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
        .frame(minWidth: 480, minHeight: 420)
        .background(Theme.paper(scheme))
        .onAppear(perform: refresh)
    }

    private func refresh() {
        checkpoints = store.allCheckpoints()
    }

    @ViewBuilder
    private func diffView(for checkpoint: Checkpoint) -> some View {
        let differences = store.diff(against: checkpoint)
        if differences.isEmpty {
            Text("No differences from current scenario.").font(.caption).foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 3) {
                ForEach(differences, id: \.field) { d in
                    HStack {
                        Text(d.field).font(Theme.monoSmall)
                        Spacer()
                        Text(String(format: "%.1f", d.checkpoint)).font(Theme.monoSmall).foregroundStyle(Theme.ochre)
                        Image(systemName: "arrow.right").font(.system(size: 9))
                        Text(String(format: "%.1f", d.current)).font(Theme.monoSmall).foregroundStyle(Theme.pine)
                    }
                }
            }
            .padding(10)
            .background(.quaternary.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
