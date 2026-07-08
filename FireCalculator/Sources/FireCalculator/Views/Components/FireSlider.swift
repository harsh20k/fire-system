import SwiftUI

/// A labeled slider row with brutalist value pill, optional SF Symbol, and optional tooltip.
struct FireSlider: View {
    @Environment(\.colorScheme) private var scheme
    let label: String
    var tip: String? = nil
    var systemImage: String? = nil
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var format: (Double) -> String = { "\(Int($0))" }
    var onCommit: ((Double, Double) -> Void)? = nil

    @State private var dragStartValue: Double? = nil
    @State private var isHovered = false

    private var sliderTint: Color {
        scheme == .dark ? Color(white: 0.45) : Color(white: 0.75)
    }
    private var trackBackground: Color {
        scheme == .dark ? Color(white: 0.28) : Color(white: 0.90)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.mutedText(scheme))
                        .frame(width: 18, alignment: .center)
                }
                TooltipLabel(label: label, tip: tip)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.mutedText(scheme))
                Spacer(minLength: 0)
            }
            HStack {
                Spacer(minLength: 0)
                BrutalText(text: format(value), variant: .body, bold: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.neutral(scheme))
                    .brutalistBorder()
            }
            Slider(
                value: Binding(
                    get: { value },
                    set: { newValue in
                        if dragStartValue == nil { dragStartValue = value }
                        value = newValue
                    }
                ),
                in: range,
                step: step,
                onEditingChanged: { editing in
                    if !editing, let start = dragStartValue {
                        onCommit?(start, value)
                        dragStartValue = nil
                    }
                }
            )
            .tint(sliderTint)
            .background(trackBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            #if os(macOS)
            .overlay {
                ScrollWheelCapture(isActive: isHovered) { delta in
                    applyScrollDelta(delta)
                }
            }
            .onContinuousHover { phase in
                switch phase {
                case .active:
                    isHovered = true
                case .ended:
                    if let start = dragStartValue {
                        onCommit?(start, value)
                        dragStartValue = nil
                    }
                    isHovered = false
                }
            }
            #endif
        }
        .padding(.bottom, Theme.Spacing.inline)
    }

    #if os(macOS)
    private func applyScrollDelta(_ delta: CGFloat) {
        guard delta != 0 else { return }
        let direction = delta > 0 ? 1.0 : -1.0
        let magnitude = min(2, max(1, Int(abs(delta) / 28)))
        let increment = step * Double(magnitude) * direction
        let snapped = snapToStep(value + increment)
        let clamped = min(range.upperBound, max(range.lowerBound, snapped))
        guard clamped != value else { return }
        if dragStartValue == nil { dragStartValue = value }
        value = clamped
    }

    private func snapToStep(_ raw: Double) -> Double {
        guard step > 0 else { return raw }
        let steps = (raw - range.lowerBound) / step
        return range.lowerBound + (steps.rounded() * step)
    }
    #endif
}

/// A single result statistic with tooltip.
struct StatView: View {
    @Environment(\.colorScheme) private var scheme
    let label: String
    let value: String
    var tip: String? = nil
    var accent: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TooltipLabel(label: label, tip: tip)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.mutedText(scheme))
                .textCase(.uppercase)
            BrutalText(
                text: value,
                variant: .title,
                color: accent ?? Theme.ink(scheme)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
