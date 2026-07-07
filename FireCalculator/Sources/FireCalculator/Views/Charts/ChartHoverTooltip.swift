import SwiftUI

struct ChartHoverCard<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minWidth: 140, alignment: .leading)
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

/// Positions chart tooltip from plot-space anchor; does not intercept pointer events.
struct ChartCursorOverlay<Content: View>: View {
    let anchor: CGPoint?
    let bounds: CGSize
    @ViewBuilder var content: () -> Content

    var body: some View {
        if let anchor {
            let pos = clampedPosition(
                anchor: anchor,
                tooltipSize: CGSize(width: 160, height: 80),
                in: bounds
            )
            content()
                .position(x: pos.x, y: pos.y)
                .zIndex(1)
        }
    }

    private func clampedPosition(anchor: CGPoint, tooltipSize: CGSize, in size: CGSize) -> CGPoint {
        var x = anchor.x + 16
        var y = anchor.y - 24
        if x + tooltipSize.width / 2 > size.width {
            x = anchor.x - tooltipSize.width / 2 - 8
        }
        if y - tooltipSize.height / 2 < 0 {
            y = anchor.y + tooltipSize.height / 2 + 12
        }
        x = max(tooltipSize.width / 2 + 4, min(x, size.width - tooltipSize.width / 2 - 4))
        y = max(tooltipSize.height / 2 + 4, min(y, size.height - tooltipSize.height / 2 - 4))
        return CGPoint(x: x, y: y)
    }
}

extension Array {
    func nearest(by keyPath: KeyPath<Element, Double>, to value: Double) -> Element? {
        guard !isEmpty else { return nil }
        return self.min(by: { abs($0[keyPath: keyPath] - value) < abs($1[keyPath: keyPath] - value) })
    }
}
