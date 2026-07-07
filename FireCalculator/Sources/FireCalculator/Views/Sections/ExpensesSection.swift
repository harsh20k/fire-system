import SwiftUI

struct ExpensesSection: View {
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let r = store.results
        let i = store.inputs
        FireSection(number: "04", title: "Expenses", accent: Theme.brick,
                    summary: "\(Fmt.money(r.totalMonthlyExpenses))/mo · \(Fmt.money(r.currentMonthlySavings))/mo saved") {

            HStack {
                StatView(label: "Total monthly expenses", value: Fmt.money(r.totalMonthlyExpenses),
                          tip: "Mortgage payment + all Needs + all Wants, in today's dollars.")
                Spacer()
                StatView(label: "Saved every month", value: Fmt.money(r.currentMonthlySavings),
                          tip: "Take-home pay ÷ 12, minus total monthly expenses. This is what's left to invest toward FIRE right now.",
                          accent: r.currentMonthlySavings >= 0 ? Theme.primary : Theme.accent)
            }
            .padding(.bottom, 10)

            FireSubHead(label: "N — Needs", accent: Theme.brick)

            FireSlider(label: "Groceries", tip: "Scales with household size — expect roughly +30% once you add a child.",
                       systemImage: "cart",
                       value: store.binding(\.groceries, field: "groceries"), range: 300...2_000, step: 25, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "groceries", from: $0, to: $1) })

            FireSlider(label: "Utilities", tip: "Electricity, water, home utilities. NS electricity rates run a bit above the national average.",
                       systemImage: "bolt",
                       value: store.binding(\.utilities, field: "utilities"), range: 0...400, step: 10, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "utilities", from: $0, to: $1) })

            FireSlider(label: "Internet & phone", tip: "Combined internet bill, phone bill, and mobile plans for both of you.",
                       systemImage: "wifi",
                       value: store.binding(\.internetPhone, field: "internetPhone"), range: 0...400, step: 10, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "internetPhone", from: $0, to: $1) })

            FireSlider(label: "Number of cars", tip: "Two cars is typical for a suburban Halifax household without full transit access. Dropping to one frees meaningful monthly cash.",
                       systemImage: "car",
                       value: store.binding(\.numCars, field: "numCars"), range: 0...4, step: 1, format: { Fmt.age($0) },
                       onCommit: { store.commitChange(field: "numCars", from: $0, to: $1) })

            FireSlider(label: "Cost per car", tip: "Payment, insurance, gas, maintenance combined. NS insurance and driving distances push this above urban Ontario averages.",
                       systemImage: "fuelpump",
                       value: store.binding(\.costPerCar, field: "costPerCar"), range: 200...1_200, step: 50, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "costPerCar", from: $0, to: $1) })

            FireSlider(label: "Rideshare / transit", tip: "Uber, taxis, or transit passes on top of car ownership.",
                       systemImage: "bus",
                       value: store.binding(\.rideshare, field: "rideshare"), range: 0...600, step: 25, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "rideshare", from: $0, to: $1) })

            FireSlider(label: "Medicine & healthcare", tip: "Out-of-pocket health costs not covered by public healthcare — dental, vision, prescriptions, supplemental insurance.",
                       systemImage: "cross.case",
                       value: store.binding(\.medicine, field: "medicine"), range: 0...400, step: 10, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "medicine", from: $0, to: $1) })

            FireSlider(label: "Personal care", tip: "Haircuts, grooming, cosmetics.",
                       systemImage: "scissors",
                       value: store.binding(\.personalCare, field: "personalCare"), range: 0...300, step: 10, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "personalCare", from: $0, to: $1) })

            FireSlider(label: "Essential subscriptions", tip: "Digital tools and services you'd keep regardless — not discretionary streaming or entertainment.",
                       systemImage: "rectangle.stack",
                       value: store.binding(\.subscriptions, field: "subscriptions"), range: 0...300, step: 10, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "subscriptions", from: $0, to: $1) })

            if i.kids > 0 {
                FireSlider(label: "Childcare, per kid", tip: "Monthly cost per child after any subsidy. NS's $10-a-day program target was missed — province average is closer to $12/day, and Halifax preschool fees average $22.25/day. Cost drops to $0 once your childcare end age slider is reached.",
                           systemImage: "figure.and.child.holdinghands",
                           value: store.binding(\.childcarePerKid, field: "childcarePerKid"), range: 0...1_500, step: 50, format: { Fmt.monthlyWithAnnual($0) },
                           onCommit: { store.commitChange(field: "childcarePerKid", from: $0, to: $1) })
            }

            FireSubHead(label: "W — Wants", accent: Theme.ochre)

            FireSlider(label: "Eating out", tip: "Restaurants, takeout, delivery. Often the single most compressible line item in a household budget.",
                       systemImage: "fork.knife",
                       value: store.binding(\.eatingOut, field: "eatingOut"), range: 0...1_200, step: 25, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "eatingOut", from: $0, to: $1) })

            FireSlider(label: "Shopping + tech", tip: "Non-essential shopping, gadgets, gaming, tech upgrades.",
                       systemImage: "bag",
                       value: store.binding(\.shoppingTech, field: "shoppingTech"), range: 0...1_000, step: 25, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "shoppingTech", from: $0, to: $1) })

            FireSlider(label: "Entertainment", tip: "Streaming, outings, hobbies, travel-adjacent spend.",
                       systemImage: "tv",
                       value: store.binding(\.entertainment, field: "entertainment"), range: 0...600, step: 25, format: { Fmt.monthlyWithAnnual($0) },
                       onCommit: { store.commitChange(field: "entertainment", from: $0, to: $1) })
        }
    }
}
