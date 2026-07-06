import SwiftUI

/// A labeled slider row matching the original prototype's mono-label + right-aligned value layout,
/// with an optional info tooltip explaining what the dial does.
struct FireSlider: View {
    @Environment(\.colorScheme) private var scheme
    let label: String
    var tip: String? = nil
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var format: (Double) -> String = { "\(Int($0))" }
    /// Called once the user releases the slider — used to commit change-tracking events.
    var onCommit: ((Double, Double) -> Void)? = nil

    @State private var dragStartValue: Double? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TooltipLabel(label: label, tip: tip)
                    .font(Theme.mono)
                    .foregroundStyle(Theme.mutedText(scheme))
                Spacer()
                Text(format(value))
                    .font(Theme.mono)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.ink(scheme))
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
            .tint(Theme.pine)
        }
        .padding(.bottom, 12)
    }
}

/// A single result statistic, right-sized for the summary panel, with a tooltip
/// explaining exactly how it was computed.
struct StatView: View {
    @Environment(\.colorScheme) private var scheme
    let label: String
    let value: String
    var tip: String? = nil
    var accent: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TooltipLabel(label: label, tip: tip)
                .font(Theme.monoSmall)
                .textCase(.uppercase)
                .foregroundStyle(Theme.mutedText(scheme))
            Text(value)
                .font(.system(.title2, design: .serif)).bold()
                .foregroundStyle(accent ?? Theme.ink(scheme))
        }
    }
}
