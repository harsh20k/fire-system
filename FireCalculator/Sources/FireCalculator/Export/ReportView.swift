import SwiftUI

/// Print-friendly brutalist layout for PDF export.
struct ReportView: View {
    let inputs: FireInputs
    let results: FireResults
    let generatedAt: Date = .now

    private let pageWidth: CGFloat = 700
    private let exportInk = Color(red: 0.067, green: 0.067, blue: 0.067)
    private let exportMuted = Color(red: 0.420, green: 0.447, blue: 0.502)
    private let exportGreen = Color(red: 0.086, green: 0.639, blue: 0.290)

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            cover
            keyStats
            chartSection("Portfolio Path to FIRE") {
                PortfolioPathChart(results: results, showReal: inputs.showRealDollars)
            }
            chartSection("Monthly Expense Breakdown") {
                ExpenseBreakdownChart(results: results)
            }
            chartSection("Income Growth vs. Pension Bridge") {
                IncomeVsExpenseChart(results: results)
            }
            methodology
            disclaimer
        }
        .padding(40)
        .frame(width: pageWidth)
        .background(Color.white)
        .foregroundStyle(exportInk)
    }

    private var cover: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Personalization.reportCoverKicker.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(2)
                .foregroundStyle(exportMuted)
            Text(Personalization.reportCoverTitle)
                .font(.system(size: 32, weight: .heavy))
            Text("Generated \(generatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.system(size: 13))
                .foregroundStyle(exportMuted)
        }
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) {
            Rectangle().fill(exportInk).frame(height: 2.5)
        }
    }

    private var keyStats: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SUMMARY")
                .font(.system(size: 13, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(exportGreen)
            HStack(spacing: 16) {
                statCell("FIRE number", Fmt.moneyK(inputs.showRealDollars ? results.fireNumberReal : results.fireNumberNominal))
                statCell("Age you hit it", results.fireAge.map { Fmt.age($0) } ?? "60+")
                statCell("Monthly savings", Fmt.money(results.currentMonthlySavings))
            }
            HStack(spacing: 16) {
                statCell("Monthly mortgage", Fmt.money(results.monthlyMortgagePayment))
                statCell("Take-home (annual)", Fmt.money(results.currentTakeHome))
                statCell("Total expenses/mo", Fmt.money(results.totalMonthlyExpenses))
            }
        }
        .padding(20)
        .overlay {
            RoundedRectangle(cornerRadius: 2)
                .strokeBorder(exportInk, lineWidth: 2.5)
        }
    }

    private func statCell(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(exportMuted)
            Text(value)
                .font(.system(size: 20, weight: .heavy))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func chartSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .bold))
                .tracking(1)
            content()
                .padding(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(exportInk, lineWidth: 2)
                }
        }
    }

    private var methodology: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("METHODOLOGY & ASSUMPTIONS")
                .font(.system(size: 13, weight: .bold))
                .tracking(1)
            Group {
                bullet("FIRE number", "Net-of-pension annual retirement spend ÷ withdrawal rate (\(Fmt.percent(inputs.withdrawalRate, decimals: 2))).")
                bullet("Inflation adjustment", "Living expenses compound at \(Fmt.percent(inputs.inflationRate)) per year.")
                bullet("Mortgage", "Amortization on \(Fmt.money(inputs.homePrice)) home, \(Fmt.percent(inputs.downPct, decimals: 0)) down, \(String(format: "%.1f", inputs.mortgageRate))% rate.")
                bullet("Take-home pay", "Simplified progressive bracket approximation of federal + NS marginal tax.")
                bullet("Income growth", "Annual raise of \(Fmt.percent(inputs.raisePct)), plus \(Fmt.percent(inputs.promoBumpPct, decimals: 0)) promotion bump every \(Fmt.years(inputs.promoCycle)).")
                if inputs.pensionBridgeEnabled {
                    bullet("CPP / OAS bridge", "CPP \(Fmt.money(inputs.cppMonthlyCombined))/mo from age \(Fmt.age(inputs.cppStartAge)); OAS \(Fmt.money(inputs.oasMonthlyCombined))/mo × \(Fmt.percent(inputs.oasResidencyFactor * 100, decimals: 0)) residency factor.")
                }
            }
        }
    }

    private func bullet(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 14, weight: .bold))
            Text(text).font(.system(size: 12)).foregroundStyle(exportMuted)
        }
    }

    private var disclaimer: some View {
        Text("Simplified planning model — not financial, tax, or immigration advice.")
            .font(.system(size: 11))
            .foregroundStyle(exportMuted)
            .padding(.top, 8)
    }
}
