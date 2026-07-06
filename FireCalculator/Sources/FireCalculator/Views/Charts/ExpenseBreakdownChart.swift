import SwiftUI
import Charts

/// Needs vs wants breakdown, plus mortgage — donut chart matching the household budgeting model.
struct ExpenseBreakdownChart: View {
    let results: FireResults
    @State private var selectedAmount: Double?

    private struct Slice: Identifiable {
        var id: String { name }
        let name: String
        let amount: Double
        let color: Color
    }

    private var slices: [Slice] {
        [
            Slice(name: "Mortgage", amount: results.monthlyMortgagePayment, color: Theme.ochre),
            Slice(name: "Needs", amount: results.needsMonthly, color: Theme.brick),
            Slice(name: "Wants", amount: results.wantsMonthly, color: Theme.slate),
        ]
    }

    private var total: Double { slices.reduce(0) { $0 + $1.amount } }

    private var selectedSlice: Slice? {
        guard let selectedAmount else { return nil }
        return slices.min(by: { abs($0.amount - selectedAmount) < abs($1.amount - selectedAmount) })
    }

    var body: some View {
        Chart(slices) { slice in
            SectorMark(angle: .value("Amount", slice.amount), innerRadius: .ratio(0.62), angularInset: 1.5)
                .foregroundStyle(by: .value("Category", slice.name))
                .cornerRadius(3)
        }
        .chartForegroundStyleScale([
            "Mortgage": Theme.ochre, "Needs": Theme.brick, "Wants": Theme.slate,
        ])
        .chartLegend(position: .bottom, spacing: 12)
        .chartAngleSelection(value: $selectedAmount)
        .chartOverlay(alignment: .bottomLeading) { _ in
            if let slice = selectedSlice, total > 0 {
                ChartHoverCard {
                    ChartHoverRow(label: slice.name, value: Fmt.money(slice.amount))
                    ChartHoverRow(label: "Share", value: Fmt.percent(slice.amount / total * 100))
                }
                .padding(8)
            }
        }
        .frame(height: 200)
    }
}
