import SwiftUI
import Charts

struct ExpenseBreakdownChart: View {
    @Environment(\.colorScheme) private var scheme
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

    private var legendText: String {
        guard total > 0 else { return "—" }
        return slices
            .map { "\($0.name) \(Fmt.percent($0.amount / total * 100))" }
            .joined(separator: " · ")
    }

    var body: some View {
        VStack(spacing: 8) {
            Chart(slices) { slice in
                SectorMark(angle: .value("Amount", slice.amount), innerRadius: .ratio(0.62), angularInset: 2)
                    .foregroundStyle(by: .value("Category", slice.name))
                    .cornerRadius(0)
            }
            .chartForegroundStyleScale([
                "Mortgage": Theme.ochre, "Needs": Theme.brick, "Wants": Theme.slate,
            ])
            .chartLegend(.hidden)
            .chartAngleSelection(value: $selectedAmount)
            .chartOverlay { _ in
                ChartCursorOverlay {
                    if let slice = selectedSlice, total > 0 {
                        ChartHoverCard {
                            ChartHoverRow(label: slice.name, value: Fmt.money(slice.amount))
                            ChartHoverRow(label: "Share", value: Fmt.percent(slice.amount / total * 100))
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)

            BrutalText(text: legendText, variant: .caption, color: Theme.mutedText(scheme))
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
