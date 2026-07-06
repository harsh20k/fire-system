import SwiftUI

/// A print-friendly layout of the current scenario used for PDF export: cover, key stats,
/// charts, and a methodology/assumptions section explaining every calculation.
struct ReportView: View {
    let inputs: FireInputs
    let results: FireResults
    let generatedAt: Date = .now

    private let pageWidth: CGFloat = 700

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            cover
            keyStats
            VStack(alignment: .leading, spacing: 10) {
                Text("Portfolio Path to FIRE").font(.title3.bold())
                PortfolioPathChart(results: results, showReal: inputs.showRealDollars)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Monthly Expense Breakdown").font(.title3.bold())
                ExpenseBreakdownChart(results: results)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Income Growth vs. Pension Bridge").font(.title3.bold())
                IncomeVsExpenseChart(results: results)
            }
            methodology
            disclaimer
        }
        .padding(40)
        .frame(width: pageWidth)
        .background(Color.white)
        .foregroundStyle(Color.black)
    }

    private var cover: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Personalization.reportCoverKicker.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .tracking(2)
            Text(Personalization.reportCoverTitle)
                .font(.system(size: 34, weight: .bold, design: .serif))
            Text("Generated \(generatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var keyStats: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Summary").font(.title3.bold())
            Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 10) {
                GridRow {
                    statCell("FIRE number", Fmt.moneyK(inputs.showRealDollars ? results.fireNumberReal : results.fireNumberNominal))
                    statCell("Age you hit it", results.fireAge.map { Fmt.age($0) } ?? "60+")
                }
                GridRow {
                    statCell("Monthly savings today", Fmt.money(results.currentMonthlySavings))
                    statCell("Monthly mortgage", Fmt.money(results.monthlyMortgagePayment))
                }
                GridRow {
                    statCell("Take-home (annual)", Fmt.money(results.currentTakeHome))
                    statCell("Total monthly expenses", Fmt.money(results.totalMonthlyExpenses))
                }
            }
        }
    }

    private func statCell(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased()).font(.system(size: 9, weight: .medium, design: .monospaced)).foregroundStyle(.secondary)
            Text(value).font(.system(size: 18, weight: .bold, design: .serif))
        }
    }

    private var methodology: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Methodology & Assumptions").font(.title3.bold())
            Group {
                bullet("FIRE number", "Net-of-pension annual retirement spend ÷ withdrawal rate (\(Fmt.percent(inputs.withdrawalRate, decimals: 2))). Recomputed for every simulated year using that year's inflated expenses and pension income.")
                bullet("Inflation adjustment", "Living expenses (needs + wants) compound at \(Fmt.percent(inputs.inflationRate)) per year. Results can be viewed in real (today's purchasing power) or nominal (future) dollars.")
                bullet("Mortgage", "Standard amortization formula on \(Fmt.money(inputs.homePrice)) home price, \(Fmt.percent(inputs.downPct, decimals: 0)) down, \(String(format: "%.1f", inputs.mortgageRate))% rate, \(Fmt.years(inputs.amort)) amortization. Payment drops out of expenses once the mortgage is paid off.")
                bullet("Take-home pay", "Estimated using a simplified progressive bracket approximation of combined federal + Nova Scotia marginal tax, evaluated per-partner on half the household income each year as income grows.")
                bullet("Income growth", "Annual raise of \(Fmt.percent(inputs.raisePct)) compounding, plus a \(Fmt.percent(inputs.promoBumpPct, decimals: 0)) promotion bump every \(Fmt.years(inputs.promoCycle)).")
                if inputs.pensionBridgeEnabled {
                    bullet("CPP / OAS bridge", "Combined CPP of \(Fmt.money(inputs.cppMonthlyCombined))/mo from age \(Fmt.age(inputs.cppStartAge)), and OAS of \(Fmt.money(inputs.oasMonthlyCombined))/mo × \(Fmt.percent(inputs.oasResidencyFactor * 100, decimals: 0)) residency factor from age \(Fmt.age(inputs.oasStartAge)), offsetting the portfolio draw needed in retirement.")
                }
                bullet("Childcare age-out", "Childcare cost of \(Fmt.money(inputs.childcarePerKid))/mo per kid drops to $0 once \(Fmt.years(inputs.childcareEndAge)) have elapsed from today.")
            }
        }
    }

    private func bullet(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(.subheadline, design: .serif)).bold()
            Text(text).font(.system(.footnote, design: .serif)).foregroundStyle(.secondary)
        }
    }

    private var disclaimer: some View {
        Text("This is a simplified planning model, not financial, tax, or immigration advice. Tax brackets, CPP/OAS figures, and inflation are estimates and should be verified against My Service Canada Account and a licensed advisor before making decisions.")
            .font(.system(size: 9, design: .monospaced))
            .foregroundStyle(.secondary)
            .padding(.top, 10)
    }
}
