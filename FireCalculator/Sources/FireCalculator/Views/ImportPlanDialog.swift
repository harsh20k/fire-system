import SwiftUI

struct ImportPlanDialog: View {
    @Environment(\.colorScheme) private var scheme
    let bundle: FirePlanBundle
    let onReplace: () -> Void
    let onMerge: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
            BrutalText(text: "Import FIRE Plan", variant: .title)

            BrutalCard {
                VStack(alignment: .leading, spacing: 10) {
                    metaRow("Exported by", bundle.exportedBy)
                    metaRow("Exported at", bundle.exportedAt.formatted(date: .abbreviated, time: .shortened))
                    metaRow("Checkpoints", "\(bundle.checkpoints.count)")
                    metaRow("History events", "\(bundle.changeEvents.count)")
                    metaRow("Chat messages", "\(bundle.assistantMessages.count)")
                }
            }

            BrutalText(
                text: "Replace wipes your local plan and loads this file. Merge keeps your history and adds anything new from the file, while applying its slider values.",
                variant: .caption,
                color: Theme.mutedText(scheme)
            )

            HStack(spacing: 12) {
                BrutalButton(title: "Cancel", variant: .secondary, action: onCancel)
                    .frame(width: 120)
                Spacer()
                BrutalButton(title: "Merge", variant: .secondary, action: onMerge)
                    .frame(width: 120)
                BrutalButton(title: "Replace", variant: .primary, action: onReplace)
                    .frame(width: 120)
            }
        }
        .padding(Theme.Spacing.screen)
        .frame(width: 440)
        .background(Theme.neutral(scheme))
    }

    private func metaRow(_ label: String, _ value: String) -> some View {
        HStack {
            BrutalText(text: label, variant: .body, color: Theme.mutedText(scheme))
            Spacer()
            BrutalText(text: value, variant: .body, bold: true)
        }
    }
}
