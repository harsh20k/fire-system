import SwiftUI

/// Styled tooltip card for chart hover selections — brutalist bordered block.
struct ChartHoverCard<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Theme.surface(scheme))
        .brutalistBorder()
    }
}

struct ChartHoverRow: View {
    @Environment(\.colorScheme) private var scheme
    let label: String
    let value: String
    var accent: Color? = nil

    var body: some View {
        HStack(spacing: 8) {
            BrutalText(text: label, variant: .caption, color: Theme.mutedText(scheme))
            Spacer(minLength: 12)
            BrutalText(text: value, variant: .caption, bold: true, color: accent ?? Theme.ink(scheme))
        }
    }
}

extension Array {
    func nearest(by keyPath: KeyPath<Element, Double>, to value: Double) -> Element? {
        guard !isEmpty else { return nil }
        return self.min(by: { abs($0[keyPath: keyPath] - value) < abs($1[keyPath: keyPath] - value) })
    }
}
