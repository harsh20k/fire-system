import SwiftUI

struct HouseholdSection: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        let i = store.inputs
        FireSection(number: "03", title: "Household & Income", accent: Theme.slate,
                    summary: "\(Fmt.moneyK(i.income)) income · \(Fmt.percent(i.raisePct)) raises · \(Int(i.kids)) kid\(i.kids == 1 ? "" : "s")") {

            FireSlider(label: "Current age (both)", tip: "Your FIRE-path starting point.",
                       systemImage: "person.2",
                       value: store.binding(\.age, field: "age"), range: 25...55, step: 1, format: { Fmt.age($0) },
                       onCommit: { store.commitChange(field: "age", from: $0, to: $1) })

            FireSlider(label: "Current savings",
                       tip: "Liquid net worth today. Raising this shortens your path by easing the dent your down payment leaves.",
                       systemImage: "banknote.fill",
                       value: store.binding(\.savings, field: "savings"), range: 0...200_000, step: 5_000, format: { Fmt.money($0) },
                       onCommit: { store.commitChange(field: "savings", from: $0, to: $1) })

            FireSlider(label: "Combined income (today)",
                       tip: "Combined household gross income right now. Usually the fastest lever — it compounds through take-home and savings rate.",
                       systemImage: "dollarsign.circle",
                       value: store.binding(\.income, field: "income"), range: 60_000...300_000, step: 5_000, format: { Fmt.annualWithMonthly($0) },
                       onCommit: { store.commitChange(field: "income", from: $0, to: $1) })

            FireSlider(label: "Kids",
                       tip: "Each child adds a monthly childcare cost, tracked under Needs, until they reach the childcare end age below. NS's subsidized daycare can lower the per-kid cost.",
                       systemImage: "figure.2.and.child.holdinghands",
                       value: store.binding(\.kids, field: "kids"), range: 0...3, step: 1, format: { Fmt.age($0) },
                       onCommit: { store.commitChange(field: "kids", from: $0, to: $1) })

            if i.kids > 0 {
                FireSlider(label: "Childcare end (years from now)",
                           tip: "Number of years from today before childcare costs age out entirely (e.g. child starts subsidized public school). After this many years, childcare cost drops to $0 in the simulation.",
                           systemImage: "clock",
                           value: store.binding(\.childcareEndAge, field: "childcareEndAge"), range: 0...16, step: 1, format: { Fmt.years($0) },
                           onCommit: { store.commitChange(field: "childcareEndAge", from: $0, to: $1) })
            }

            FireSubHead(label: "Income growth", accent: Theme.slate)

            FireSlider(label: "Average annual raise",
                       tip: "Typical IT-sector cost-of-living + merit raise. Canadian tech averages roughly 3-5% a year outside promotions.",
                       systemImage: "arrow.up.right",
                       value: store.binding(\.raisePct, field: "raisePct"), range: 0...10, step: 0.5, format: { Fmt.percent($0) },
                       onCommit: { store.commitChange(field: "raisePct", from: $0, to: $1) })

            FireSlider(label: "Promotion bump",
                       tip: "Extra one-time jump when you move up a seniority level (e.g. Developer → Senior → Lead). IT promotions typically bring 8-20% on top of the regular raise.",
                       systemImage: "star",
                       value: store.binding(\.promoBumpPct, field: "promoBumpPct"), range: 0...30, step: 1, format: { Fmt.percent($0, decimals: 0) },
                       onCommit: { store.commitChange(field: "promoBumpPct", from: $0, to: $1) })

            FireSlider(label: "Promotion cycle",
                       tip: "How often a seniority-level jump happens. 2-3 years is typical early career; it often stretches to 4-5 years at senior levels.",
                       systemImage: "repeat",
                       value: store.binding(\.promoCycle, field: "promoCycle"), range: 1...6, step: 1, format: { Fmt.years($0) },
                       onCommit: { store.commitChange(field: "promoCycle", from: $0, to: $1) })

            HStack {
                StatView(label: "Est. marginal tax rate", value: Fmt.percent(store.results.marginalTaxRate * 100, decimals: 1),
                          tip: "A simplified progressive-bracket approximation of combined federal + Nova Scotia marginal tax (23.79%–54% per the 2026 NS brackets), based on income split evenly between two earners. Replaces the flat 32% deduction used by simpler models.")
                Spacer()
                StatView(label: "Take-home", value: Fmt.annualWithMonthly(store.results.currentTakeHome),
                          tip: "Combined income × (1 − estimated marginal tax rate).", accent: Theme.slate)
            }
            .padding(.top, 6)
        }
    }
}
