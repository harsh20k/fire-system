import SwiftUI

/// A small "i" affordance that shows a short hover hint via `.help()` and a fuller
/// explanation in a popover on click — attached to every slider and every derived
/// calculated statistic so the user always knows how a number was produced.
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
                .font(.system(size: 11))
                .foregroundStyle(Theme.mutedText(scheme))
        }
        .buttonStyle(.plain)
        .help(text)
        .popover(isPresented: $showPopover, arrowEdge: .top) {
            VStack(alignment: .leading, spacing: 6) {
                if let title {
                    Text(title)
                        .font(.system(.subheadline, design: .serif)).bold()
                }
                Text(text)
                    .font(.system(.footnote, design: .serif))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(width: 260, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Attaches an `InfoTooltip` after a label, used inline in slider rows and stat headers.
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
