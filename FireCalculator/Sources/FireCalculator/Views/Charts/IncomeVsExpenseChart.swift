import SwiftUI
import Charts

/// Annual contribution to the portfolio over time — shows how the savings gap
/// (take-home minus inflated expenses) grows as raises/promotions compound.
struct IncomeVsExpenseChart: View {
    @Environment(\.colorScheme) private var scheme
    let results: FireResults
    @State private var selectedAge: Double?

    private var points: [YearPoint] { Array(results.path.dropFirst()) }

    var body: some View {
        Chart {
            ForEach(points) { point in
                LineMark(x: .value("Age", point.age), y: .value("Annual contribution", point.nominalContribution))
                    .foregroundStyle(by: .value("Series", "Annual savings contribution"))
                    .interpolationMethod(.monotone)
                if point.pensionIncomeAnnual > 0 {
                    LineMark(x: .value("Age", point.age), y: .value("Pension income", point.pensionIncomeAnnual))
                        .foregroundStyle(by: .value("Series", "CPP + OAS income"))
                        .interpolationMethod(.monotone)
                }
            }
            if let selectedAge, let point = points.nearest(by: \.age, to: selectedAge) {
                RuleMark(x: .value("Selected", point.age))
                    .foregroundStyle(Theme.mutedText(scheme).opacity(0.45))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
        }
        .chartForegroundStyleScale([
            "Annual savings contribution": Theme.slate,
            "CPP + OAS income": Theme.ochre,
        ])
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
        .chartOverlay(alignment: .bottomLeading) { _ in
            if let selectedAge, let point = points.nearest(by: \.age, to: selectedAge) {
                ChartHoverCard {
                    ChartHoverRow(label: "Age", value: Fmt.age(point.age))
                    ChartHoverRow(label: "Contribution", value: Fmt.money(point.nominalContribution))
                    if point.pensionIncomeAnnual > 0 {
                        ChartHoverRow(label: "CPP + OAS", value: Fmt.money(point.pensionIncomeAnnual), accent: Theme.ochre)
                    }
                }
                .padding(8)
            }
        }
        .chartLegend(position: .bottom)
        .frame(height: 200)
    }
}

/// Visualizes the CPP/OAS pension bridge: how much of retirement spend is covered by
/// government pensions vs the portfolio, once the household starts drawing at 60/65.
struct PensionBridgeChart: View {
    @Environment(\.colorScheme) private var scheme
    let inputs: FireInputs
    let results: FireResults
    @State private var selectedAge: Double?

    private struct Row: Identifiable {
        let id = UUID()
        let age: Double
        let pension: Double
        let portfolioDraw: Double
    }

    private var rows: [Row] {
        guard let fireAge = results.fireAge else { return [] }
        let endAge = fireAge + 30
        return stride(from: fireAge, through: endAge, by: 1).map { age in
            let pension = FireCalculationEngine.pensionIncomeMonthly(inputs: inputs, age: age) * 12
            let totalSpend = inputs.annualExpenses
            let draw = max(0, totalSpend - pension)
            return Row(age: age, pension: min(pension, totalSpend), portfolioDraw: draw)
        }
    }

    var body: some View {
        if results.fireAge == nil {
            Text("Reach FIRE within the 60-year horizon to preview the pension bridge.")
                .font(.callout).foregroundStyle(.secondary)
                .frame(height: 160)
        } else {
            Chart {
                ForEach(rows) { row in
                    AreaMark(x: .value("Age", row.age), y: .value("Amount", row.portfolioDraw), stacking: .standard)
                        .foregroundStyle(by: .value("Source", "Portfolio draw"))
                    AreaMark(x: .value("Age", row.age), y: .value("Amount", row.pension), stacking: .standard)
                        .foregroundStyle(by: .value("Source", "CPP + OAS"))
                }
                if let selectedAge, let row = rows.nearest(by: \.age, to: selectedAge) {
                    RuleMark(x: .value("Selected", row.age))
                        .foregroundStyle(Theme.mutedText(scheme).opacity(0.45))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                }
            }
            .chartForegroundStyleScale([
                "Portfolio draw": Theme.pine.opacity(0.55),
                "CPP + OAS": Theme.ochre.opacity(0.75),
            ])
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
            .chartOverlay(alignment: .bottomLeading) { _ in
                if let selectedAge, let row = rows.nearest(by: \.age, to: selectedAge) {
                    ChartHoverCard {
                        ChartHoverRow(label: "Age", value: Fmt.age(row.age))
                        ChartHoverRow(label: "Portfolio draw", value: Fmt.money(row.portfolioDraw), accent: Theme.pine)
                        ChartHoverRow(label: "CPP + OAS", value: Fmt.money(row.pension), accent: Theme.ochre)
                        ChartHoverRow(label: "Total spend", value: Fmt.money(row.pension + row.portfolioDraw))
                    }
                    .padding(8)
                }
            }
            .chartLegend(position: .bottom)
            .frame(height: 200)
        }
    }
}
