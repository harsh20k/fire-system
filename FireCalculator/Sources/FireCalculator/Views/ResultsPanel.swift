import SwiftUI

struct ResultsPanel: View {
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var contentWidth: CGFloat = 1000

    private enum ChartGridLayout {
        case oneColumn, twoColumn, fourColumn

        init(width: CGFloat) {
            if width >= 1200 { self = .fourColumn }
            else if width >= 640 { self = .twoColumn }
            else { self = .oneColumn }
        }

        var columnCount: Int {
            switch self {
            case .oneColumn: 1
            case .twoColumn: 2
            case .fourColumn: 4
            }
        }
    }

    var body: some View {
        let r = store.results
        let showReal = store.inputs.showRealDollars
        let layout = ChartGridLayout(width: contentWidth)

        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
            chartsGrid(results: r, showReal: showReal, layout: layout)
                .frame(maxHeight: .infinity)

            HStack(spacing: Theme.Spacing.inline) {
                detailRow("Take-home", Fmt.annualWithMonthly(r.currentTakeHome))
                detailRow("Needs", Fmt.monthlyWithAnnual(r.needsMonthly))
                detailRow("Wants", Fmt.monthlyWithAnnual(r.wantsMonthly))
            }

            BrutalText(
                text: Personalization.resultsDisclaimer,
                variant: .caption,
                color: Theme.mutedText(scheme)
            )
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.vertical, Theme.Spacing.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            GeometryReader { proxy in
                Color.clear.onChange(of: proxy.size.width, initial: true) { _, w in
                    contentWidth = w
                }
            }
        )
    }

    @ViewBuilder
    private func chartsGrid(results: FireResults, showReal: Bool, layout: ChartGridLayout) -> some View {
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: Theme.Spacing.inline, alignment: .top),
            count: layout.columnCount
        )

        LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.Spacing.inline) {
            chartTile("Portfolio") {
                PortfolioPathChart(results: results, showReal: showReal)
            }
            chartTile("Breakdown") {
                ExpenseBreakdownChart(results: results)
            }
            chartTile("Income vs Spend") {
                IncomeVsExpenseChart(results: results)
            }
            chartTile("Pension Bridge") {
                PensionBridgeChart(inputs: store.inputs, results: results)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func chartTile<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            BrutalText(
                text: title,
                variant: .sectionLabel,
                color: Theme.primary,
                uppercase: true,
                tracking: 1.2
            )
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(Theme.Spacing.inline)
                .background(Theme.neutral(scheme))
                .brutalistBorder()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            BrutalText(text: label, variant: .caption, color: Theme.mutedText(scheme))
            Spacer()
            BrutalText(text: value, variant: .caption, bold: true)
        }
        .frame(maxWidth: .infinity)
    }
}
