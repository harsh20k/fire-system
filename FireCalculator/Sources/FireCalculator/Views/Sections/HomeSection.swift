import SwiftUI

struct HomeSection: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        let i = store.inputs
        let buySummary = i.homeBuyYearsFromNow == 0 ? "buy now" : "buy in \(Int(i.homeBuyYearsFromNow)) yrs"
        FireSection(number: "02", title: "Home", accent: Theme.ochre,
                    summary: "\(buySummary) · \(Fmt.moneyK(i.homePrice)) · \(Fmt.percent(i.downPct, decimals: 0)) down · \(String(format: "%.1f", i.mortgageRate))% rate") {

            FireSlider(label: "When we buy home",
                       tip: "Years from today until you close on the home. Delaying the purchase keeps your full savings invested longer and postpones the down payment and mortgage — but you still carry rent or other housing costs in Needs/Wants until then.",
                       systemImage: "calendar.badge.clock",
                       value: store.binding(\.homeBuyYearsFromNow, field: "homeBuyYearsFromNow"),
                       range: 0...15, step: 1, format: { $0 == 0 ? "Now" : Fmt.years($0) },
                       onCommit: { store.commitChange(field: "homeBuyYearsFromNow", from: $0, to: $1) })

            FireSlider(label: "Home price",
                       tip: "Nova Scotia home prices range roughly $500k-$1M by area. Buying lower frees more cash to invest instead of servicing a mortgage.",
                       systemImage: "house",
                       value: store.binding(\.homePrice, field: "homePrice"),
                       range: 400_000...1_000_000, step: 10_000, format: { Fmt.moneyK($0) },
                       onCommit: { store.commitChange(field: "homePrice", from: $0, to: $1) })

            FireSlider(label: "Down payment",
                       tip: "Typically 5-20% depending on price and insurer rules. A bigger down payment shrinks the mortgage and grows your surplus faster, but drains today's savings.",
                       systemImage: "arrow.down.circle",
                       value: store.binding(\.downPct, field: "downPct"),
                       range: 5...35, step: 1, format: { Fmt.percent($0, decimals: 0) },
                       onCommit: { store.commitChange(field: "downPct", from: $0, to: $1) })

            FireSlider(label: "Mortgage rate",
                       tip: "Current Canadian 5-yr fixed benchmark. You can't move the market rate, but shopping lenders and stronger credit can shave off fractions.",
                       systemImage: "percent",
                       value: store.binding(\.mortgageRate, field: "mortgageRate"),
                       range: 2...8, step: 0.1, format: { String(format: "%.1f%%", $0) },
                       onCommit: { store.commitChange(field: "mortgageRate", from: $0, to: $1) })

            FireSlider(label: "Amortization",
                       tip: "Longer amortization = lower monthly payment but more total interest and slower payoff. The simulation assumes the mortgage ends and this payment drops out of your expenses after this many years.",
                       systemImage: "calendar",
                       value: store.binding(\.amort, field: "amort"),
                       range: 15...30, step: 1, format: { Fmt.years($0) },
                       onCommit: { store.commitChange(field: "amort", from: $0, to: $1) })

            HStack {
                StatView(label: "Down payment", value: Fmt.money(store.results.downPayment),
                          tip: "Home price × down payment %. Deducted from savings when you buy — at the start of the simulation if buying now, or in the purchase year if delayed.")
                Spacer()
                StatView(label: "Monthly payment", value: Fmt.money(store.results.monthlyMortgagePayment),
                          tip: "Standard amortizing mortgage formula once you own the home. Included in monthly expenses starting in the purchase year and ending after your amortization period.",
                          accent: Theme.ochre)
            }
            .padding(.top, 6)
        }
    }
}
