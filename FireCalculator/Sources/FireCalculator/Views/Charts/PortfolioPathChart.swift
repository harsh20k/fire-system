import SwiftUI
import Charts

/// Portfolio balance path to FIRE — a direct chart port of the original prototype's SVG polyline,
/// now with a nominal/real toggle and a dashed FIRE-number reference line.
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
                    if let d = value.as(Double.self) {
                        Text(Fmt.moneyK(d))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let d = value.as(Double.self) {
                        Text("age \(Int(d))")
                    }
                }
            }
        }
        .chartXSelection(value: $selectedAge)
        .chartOverlay(alignment: .bottomLeading) { _ in
            if let selectedAge, let point = results.path.nearest(by: \.age, to: selectedAge) {
                let balance = showReal ? point.realBalance : point.nominalBalance
                let gap = fireTarget - balance
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
                .padding(8)
            }
        }
        .frame(height: 220)
    }
}
