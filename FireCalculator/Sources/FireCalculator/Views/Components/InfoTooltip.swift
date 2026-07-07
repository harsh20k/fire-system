import SwiftUI

/// A small "i" affordance with brutalist popover styling.
struct InfoTooltip: View {
    @Environment(\.colorScheme) private var scheme
    let text: String
    var title: String? = nil
    @State private var showPopover = false

    var body: some View {
        Button {
            showPopover.toggle()
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 12))
                .foregroundStyle(Theme.mutedText(scheme))
        }
        .buttonStyle(.plain)
        .help(text)
        .popover(isPresented: $showPopover, arrowEdge: .top) {
            VStack(alignment: .leading, spacing: 8) {
                if let title {
                    BrutalText(text: title, variant: .body, bold: true)
                }
                BrutalText(text: text, variant: .caption, color: Theme.mutedText(scheme))
            }
            .padding(Theme.Spacing.inline)
            .frame(width: 280, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct TooltipLabel: View {
    let label: String
    let tip: String?
    var titleForPopover: String? = nil

    var body: some View {
        HStack(spacing: 5) {
            Text(label)
            if let tip {
                InfoTooltip(text: tip, title: titleForPopover ?? label)
            }
        }
    }
}
