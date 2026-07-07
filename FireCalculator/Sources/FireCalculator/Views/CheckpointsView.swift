import SwiftUI
import SwiftData

struct CheckpointsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var checkpoints: [Checkpoint] = []
    @State private var newName: String = ""
    @State private var selectedForDiff: Checkpoint?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
            BrutalText(text: "Checkpoints", variant: .title)

            HStack(spacing: 12) {
                TextField("Checkpoint name (e.g. \"Buy at $500k\")", text: $newName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(saveCheckpoint)
                ShortcutLabeledButton(
                    title: "Save",
                    shortcut: AppShortcut(key: .return, modifiers: .command),
                    variant: .primary,
                    action: saveCheckpoint
                )
            }

            if checkpoints.isEmpty {
                ContentUnavailableView("No checkpoints yet", systemImage: "clock.arrow.circlepath", description: Text(Personalization.checkpointEmpty))
            } else {
                ScrollView {
                    VStack(spacing: Theme.Spacing.inline) {
                        ForEach(checkpoints) { checkpoint in
                            checkpointCard(checkpoint)
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
        .frame(minWidth: 480, minHeight: 420)
        .background(Theme.neutral(scheme))
        .onAppear(perform: refresh)
        .onExitCommand { dismiss() }
    }

    private func saveCheckpoint() {
        let name = newName.isEmpty ? "Checkpoint \(checkpoints.count + 1)" : newName
        store.createCheckpoint(name: name)
        newName = ""
        refresh()
    }

    @ViewBuilder
    private func checkpointCard(_ checkpoint: Checkpoint) -> some View {
        BrutalCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        BrutalText(text: checkpoint.name, variant: .body, bold: true)
                        BrutalText(
                            text: checkpoint.createdAt.formatted(date: .abbreviated, time: .shortened),
                            variant: .caption,
                            color: Theme.mutedText(scheme)
                        )
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        BrutalButton(title: "Diff", variant: .secondary) {
                            selectedForDiff = checkpoint
                        }
                        .frame(width: 72)
                        BrutalButton(title: "Revert", variant: .secondary) {
                            store.revert(to: checkpoint)
                        }
                        .frame(width: 88)
                        Button(role: .destructive) {
                            store.deleteCheckpoint(checkpoint)
                            refresh()
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                    }
                }
                if selectedForDiff?.id == checkpoint.id {
                    diffView(for: checkpoint)
                }
            }
        }
    }

    private func refresh() {
        checkpoints = store.allCheckpoints()
    }

    @ViewBuilder
    private func diffView(for checkpoint: Checkpoint) -> some View {
        let differences = store.diff(against: checkpoint)
        if differences.isEmpty {
            BrutalText(text: "No differences from current scenario.", variant: .caption, color: Theme.mutedText(scheme))
        } else {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(differences, id: \.field) { d in
                    HStack {
                        BrutalText(text: d.field, variant: .caption)
                        Spacer()
                        BrutalText(text: String(format: "%.1f", d.checkpoint), variant: .caption, color: Theme.ochre)
                        Image(systemName: "arrow.right").font(.system(size: 9))
                        BrutalText(text: String(format: "%.1f", d.current), variant: .caption, color: Theme.primary)
                    }
                }
            }
            .padding(Theme.Spacing.inline)
            .background(Theme.neutral(scheme))
            .brutalistBorder()
        }
    }
}
