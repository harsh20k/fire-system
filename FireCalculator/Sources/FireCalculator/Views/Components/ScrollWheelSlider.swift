#if os(macOS)
import AppKit
import SwiftUI

/// Invisible overlay that forwards trackpad scroll-wheel events to a value callback.
struct ScrollWheelCapture: NSViewRepresentable {
    var isActive: Bool
    var onScroll: (CGFloat) -> Void

    func makeNSView(context: Context) -> ScrollWheelCaptureView {
        let view = ScrollWheelCaptureView()
        view.onScroll = onScroll
        return view
    }

    func updateNSView(_ nsView: ScrollWheelCaptureView, context: Context) {
        nsView.onScroll = onScroll
        nsView.isActive = isActive
    }
}

final class ScrollWheelCaptureView: NSView {
    var onScroll: ((CGFloat) -> Void)?
    var isActive = false {
        didSet { needsDisplay = true }
    }

    override var acceptsFirstResponder: Bool { isActive }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard isActive, bounds.contains(point) else { return nil }
        return self
    }

    override func scrollWheel(with event: NSEvent) {
        guard isActive else {
            super.scrollWheel(with: event)
            return
        }
        let delta = event.scrollingDeltaX != 0
            ? event.scrollingDeltaX
            : event.scrollingDeltaY
        onScroll?(delta)
    }
}
#endif
