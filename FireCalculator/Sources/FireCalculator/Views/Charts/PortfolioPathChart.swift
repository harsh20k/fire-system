import SwiftUI
import Charts

struct PortfolioPathChart: View {
    @Environment(\.colorScheme) private var scheme
    let results: FireResults
    let showReal: Bool
    @State private var selectedAge: Double?

    private var fireTarget: Double { showReal ? results.fireNumberReal : results.fireNumberNominal }

    var body: some View {
        Chart {
            ForEach(results.path) { point in
                let balance = showReal ? point.realBalance : point.nominalBalance
                LineMark(x: .value("Age", point.age), y: .value("Balance", balance))
                    .foregroundStyle(Theme.primary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.monotone)
                AreaMark(x: .value("Age", point.age), y: .value("Balance", balance))
                    .foregroundStyle(Theme.primary.opacity(0.12))
                    .interpolationMethod(.monotone)
            }
            RuleMark(y: .value("FIRE number", fireTarget))
                .foregroundStyle(Theme.ochre)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .annotation(position: .top, alignment: .trailing) {
                    BrutalText(text: "FIRE: \(Fmt.moneyK(fireTarget))", variant: .caption, color: Theme.ochre)
                }
            if let selectedAge, let point = results.path.nearest(by: \.age, to: selectedAge) {
                RuleMark(x: .value("Selected", point.age))
                    .foregroundStyle(Theme.mutedText(scheme).opacity(0.45))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let d = value.as(Double.self) { Text(Fmt.moneyK(d)) }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let d = value.as(Double.self) { Text("age \(Int(d))") }
                }
            }
        }
        .chartXSelection(value: $selectedAge)
        .chartOverlay { proxy in
            GeometryReader { geo in
                if let plotAnchor = proxy.plotFrame {
                    let plotFrame = geo[plotAnchor]
                    if let selectedAge,
                       let point = results.path.nearest(by: \.age, to: selectedAge),
                       let xPos = proxy.position(forX: point.age) {
                        let balance = showReal ? point.realBalance : point.nominalBalance
                        let gap = fireTarget - balance
                        let yPos = proxy.position(forY: balance) ?? plotFrame.height / 2
                        let anchor = CGPoint(x: plotFrame.origin.x + xPos, y: plotFrame.origin.y + yPos)
                        ChartCursorOverlay(anchor: anchor, bounds: geo.size) {
                            ChartHoverCard {
                                ChartHoverRow(label: "Age", value: Fmt.age(point.age))
                                ChartHoverRow(
                                    label: showReal ? "Balance (real)" : "Balance (nominal)",
                                    value: Fmt.money(balance)
                                )
                                if gap > 0 {
                                    ChartHoverRow(label: "To FIRE", value: Fmt.moneyK(gap), accent: Theme.ochre)
                                } else {
                                    ChartHoverRow(label: "To FIRE", value: "Reached", accent: Theme.primary)
                                }
                            }
                        }
                    }
                }
            }
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
