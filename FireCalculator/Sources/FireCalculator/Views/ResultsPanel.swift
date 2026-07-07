import SwiftUI

struct ResultsPanel: View {
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var contentWidth: CGFloat = 1000

    private enum ChartLayout {
        case singleColumn
        case twoColumn
        case wideRow

        init(width: CGFloat) {
            if width >= 1000 {
                self = .wideRow
            } else if width >= 600 {
                self = .twoColumn
            } else {
                self = .singleColumn
            }
        }
    }

    var body: some View {
        let r = store.results
        let showReal = store.inputs.showRealDollars
        let fireValue = Fmt.moneyK(showReal ? r.fireNumberReal : r.fireNumberNominal)
        let ageValue = r.fireAge.map { Fmt.age($0) } ?? "60+"
        let savingsRate = savingsRatePercent(r)
        let layout = ChartLayout(width: contentWidth)

        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
            HStack(spacing: Theme.Spacing.inline) {
                HeroStat(
                    label: "FIRE age",
                    value: ageValue,
                    tip: "The first simulated year where portfolio balance ≥ that year's FIRE number.",
                    accent: Theme.ochre
                )
                HeroStat(
                    label: "FIRE number",
                    value: fireValue,
                    tip: "Net-of-pension retirement spend ÷ withdrawal rate. \(showReal ? "Today's purchasing power." : "Future inflated dollars.")"
                )
                HeroStat(
                    label: "Savings rate",
                    value: savingsRate,
                    tip: "Monthly savings ÷ monthly take-home. The master lever for how fast you reach FIRE.",
                    accent: r.currentMonthlySavings >= 0 ? Theme.primary : Theme.accent
                )
            }

            HStack(spacing: Theme.Spacing.inline) {
                StatView(
                    label: "Monthly savings",
                    value: Fmt.money(r.currentMonthlySavings),
                    tip: "Take-home ÷ 12 minus total monthly expenses."
                )
                StatView(
                    label: "Monthly mortgage",
                    value: Fmt.monthlyWithAnnual(r.monthlyMortgagePayment),
                    tip: "Amortization formula on home price, down payment, rate, and term.",
                    accent: Theme.ochre
                )
            }

            chartsArea(results: r, showReal: showReal, layout: layout)

            if layout == .wideRow {
                HStack(spacing: Theme.Spacing.inline) {
                    detailRow("Take-home (after tax/CPP/EI)", Fmt.annualWithMonthly(r.currentTakeHome))
                    detailRow("Needs", Fmt.monthlyWithAnnual(r.needsMonthly))
                    detailRow("Wants", Fmt.monthlyWithAnnual(r.wantsMonthly))
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    detailRow("Take-home (after tax/CPP/EI)", Fmt.annualWithMonthly(r.currentTakeHome))
                    detailRow("Needs", Fmt.monthlyWithAnnual(r.needsMonthly))
                    detailRow("Wants", Fmt.monthlyWithAnnual(r.wantsMonthly))
                }
            }

            BrutalText(
                text: Personalization.resultsDisclaimer,
                variant: .caption,
                color: Theme.mutedText(scheme)
            )
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.size.width, initial: true) { _, width in
                        contentWidth = width
                    }
            }
        )
    }

    @ViewBuilder
    private func chartsArea(results: FireResults, showReal: Bool, layout: ChartLayout) -> some View {
        switch layout {
        case .wideRow:
            VStack(spacing: Theme.Spacing.inline) {
                HStack(alignment: .top, spacing: Theme.Spacing.inline) {
                    chartTile("Portfolio") {
                        PortfolioPathChart(results: results, showReal: showReal)
                    }
                    chartTile("Breakdown") {
                        ExpenseBreakdownChart(results: results)
                    }
                    chartTile("Income vs Spend") {
                        IncomeVsExpenseChart(results: results)
                    }
                }
                chartTile("Pension Bridge") {
                    PensionBridgeChart(inputs: store.inputs, results: results)
                }
            }
        case .twoColumn:
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Theme.Spacing.inline),
                    GridItem(.flexible(), spacing: Theme.Spacing.inline),
                ],
                spacing: Theme.Spacing.inline
            ) {
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
        case .singleColumn:
            VStack(spacing: Theme.Spacing.inline) {
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
        }
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
                .padding(Theme.Spacing.inline)
                .background(Theme.neutral(scheme))
                .brutalistBorder()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            BrutalText(text: label, variant: .body, color: Theme.mutedText(scheme))
            Spacer()
            BrutalText(text: value, variant: .body, bold: true)
        }
    }

    private func savingsRatePercent(_ r: FireResults) -> String {
        let monthlyTakeHome = r.currentTakeHome / 12
        guard monthlyTakeHome > 0 else { return "—" }
        let rate = (r.currentMonthlySavings / monthlyTakeHome) * 100
        return Fmt.percent(max(0, rate))
    }
}
