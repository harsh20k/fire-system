import SwiftUI

/// Styled tooltip card for chart hover selections — matches Theme paper/glass aesthetic.
struct ChartHoverCard<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Theme.card(scheme).opacity(0.92))
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Theme.hairline(scheme), lineWidth: 1)
        }
    }
}

struct ChartHoverRow: View {
    @Environment(\.colorScheme) private var scheme
    let label: String
    let value: String
    var accent: Color? = nil

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(Theme.monoSmall)
                .foregroundStyle(Theme.mutedText(scheme))
            Spacer(minLength: 12)
            Text(value)
                .font(.system(.footnote, design: .serif))
                .foregroundStyle(accent ?? Theme.ink(scheme))
        }
    }
}

extension Array {
    /// Returns the element whose `keyPath` value is closest to `value`.
    func nearest(by keyPath: KeyPath<Element, Double>, to value: Double) -> Element? {
        guard !isEmpty else { return nil }
        return self.min(by: { abs($0[keyPath: keyPath] - value) < abs($1[keyPath: keyPath] - value) })
    }
}
