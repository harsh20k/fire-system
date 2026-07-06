import SwiftUI

struct ResultsPanel: View {
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @AppStorage("resultsPanelExpanded") private var expanded = true
    @State private var chartTab: ChartTab = .portfolio

    enum ChartTab: String, CaseIterable, Identifiable {
        case portfolio = "Portfolio"
        case breakdown = "Breakdown"
        case incomeVsExpense = "Income vs Spend"
        case pensionBridge = "Pension Bridge"
        var id: String { rawValue }
    }

    var body: some View {
        let r = store.results
        let showReal = store.inputs.showRealDollars
        let fireValue = Fmt.moneyK(showReal ? r.fireNumberReal : r.fireNumberNominal)
        let ageValue = r.fireAge.map { Fmt.age($0) } ?? "60+"

        GlassPaperCard(accent: Theme.pine, padding: 26) {
            VStack(alignment: .leading, spacing: expanded ? 20 : 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
                } label: {
                    HStack(spacing: 12) {
                        Text("Results")
                            .font(Theme.mono)
                            .foregroundStyle(Theme.pine)
                            .textCase(.uppercase)
                            .tracking(1.2)
                        Spacer()
                        if !expanded {
                            Text("\(fireValue) · age \(ageValue)")
                                .font(Theme.mono)
                                .foregroundStyle(Theme.mutedText(scheme))
                                .lineLimit(1)
                        }
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.pine)
                            .rotationEffect(.degrees(expanded ? 0 : -90))
                    }
                    .contentShape(Rectangle())
                    .padding(.vertical, 4)
                    .padding(.horizontal, -4)
                }
                .buttonStyle(.plain)

                if expanded {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        StatView(label: "FIRE number", value: fireValue,
                                  tip: "Net-of-pension retirement spend ÷ withdrawal rate, at the year you reach FIRE. \(showReal ? "Shown in today's purchasing power (real dollars)." : "Shown in future, inflated dollars (nominal).")")
                        StatView(label: "Age you hit it", value: ageValue,
                                  tip: "The first simulated year where portfolio balance ≥ that year's FIRE number, starting from your current age and compounding contributions + growth annually.",
                                  accent: Theme.ochre)
                        StatView(label: "Monthly savings today", value: Fmt.money(r.currentMonthlySavings),
                                  tip: "Current take-home ÷ 12, minus total current monthly expenses (mortgage + needs + wants).")
                        StatView(label: "Monthly mortgage", value: Fmt.monthlyWithAnnual(r.monthlyMortgagePayment),
                                  tip: "Standard amortization formula applied to your home price, down payment, rate, and amortization length.")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Picker("", selection: $chartTab) {
                            ForEach(ChartTab.allCases) { tab in Text(tab.rawValue).tag(tab) }
                        }
                        .pickerStyle(.segmented)

                        switch chartTab {
                        case .portfolio:
                            PortfolioPathChart(results: r, showReal: showReal)
                        case .breakdown:
                            ExpenseBreakdownChart(results: r)
                        case .incomeVsExpense:
                            IncomeVsExpenseChart(results: r)
                        case .pensionBridge:
                            PensionBridgeChart(inputs: store.inputs, results: r)
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Take-home (after tax/CPP/EI):")
                            Spacer()
                            Text(Fmt.annualWithMonthly(r.currentTakeHome)).bold()
                        }
                        HStack {
                            Text("Needs:")
                            Spacer()
                            Text(Fmt.monthlyWithAnnual(r.needsMonthly)).bold()
                        }
                        HStack {
                            Text("Wants:")
                            Spacer()
                            Text(Fmt.monthlyWithAnnual(r.wantsMonthly)).bold()
                        }
                    }
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(Theme.mutedText(scheme))
                }
            }
        }

        if expanded {
            Text(Personalization.resultsDisclaimer)
                .font(Theme.monoSmall)
                .foregroundStyle(Theme.mutedText(scheme))
                .padding(.top, 4)
        }
    }
}
