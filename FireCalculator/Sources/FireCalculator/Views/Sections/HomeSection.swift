import SwiftUI

struct HomeSection: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        let i = store.inputs
        FireSection(number: "02", title: "Home", accent: Theme.ochre,
                    summary: "\(Fmt.moneyK(i.homePrice)) · \(Fmt.percent(i.downPct, decimals: 0)) down · \(String(format: "%.1f", i.mortgageRate))% rate") {

            FireSlider(label: "Home price",
                       tip: "Nova Scotia home prices range roughly $500k-$1M by area. Buying lower frees more cash to invest instead of servicing a mortgage.",
                       value: store.binding(\.homePrice, field: "homePrice"),
                       range: 400_000...1_000_000, step: 10_000, format: { Fmt.moneyK($0) },
                       onCommit: { store.commitChange(field: "homePrice", from: $0, to: $1) })

            FireSlider(label: "Down payment",
                       tip: "Typically 5-20% depending on price and insurer rules. A bigger down payment shrinks the mortgage and grows your surplus faster, but drains today's savings.",
                       value: store.binding(\.downPct, field: "downPct"),
                       range: 5...35, step: 1, format: { Fmt.percent($0, decimals: 0) },
                       onCommit: { store.commitChange(field: "downPct", from: $0, to: $1) })

            FireSlider(label: "Mortgage rate",
                       tip: "Current Canadian 5-yr fixed benchmark. You can't move the market rate, but shopping lenders and stronger credit can shave off fractions.",
                       value: store.binding(\.mortgageRate, field: "mortgageRate"),
                       range: 2...8, step: 0.1, format: { String(format: "%.1f%%", $0) },
                       onCommit: { store.commitChange(field: "mortgageRate", from: $0, to: $1) })

            FireSlider(label: "Amortization",
                       tip: "Longer amortization = lower monthly payment but more total interest and slower payoff. The simulation assumes the mortgage ends and this payment drops out of your expenses after this many years.",
                       value: store.binding(\.amort, field: "amort"),
                       range: 15...30, step: 1, format: { Fmt.years($0) },
                       onCommit: { store.commitChange(field: "amort", from: $0, to: $1) })

            HStack {
                StatView(label: "Down payment", value: Fmt.money(store.results.downPayment),
                          tip: "Home price × down payment %. Deducted from your current savings at the start of the simulation.")
                Spacer()
                StatView(label: "Monthly payment", value: Fmt.money(store.results.monthlyMortgagePayment),
                          tip: "Standard amortizing mortgage formula: M = P × r / (1 − (1+r)^−n), where P is the loan principal after your down payment, r is the monthly rate, and n is the number of monthly payments over your amortization.",
                          accent: Theme.ochre)
            }
            .padding(.top, 6)
        }
    }
}
