import SwiftUI

struct TargetSection: View {
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let r = store.results
        FireSection(number: "01", title: "Target", accent: Theme.pine,
                    summary: "\(Fmt.moneyK(r.fireNumberNominal)) target · \(Fmt.percent(store.inputs.withdrawalRate)) withdrawal") {

            FireSlider(label: "Investment growth",
                       tip: "Expected long-run annual return on a diversified portfolio (historically ~6-7% nominal). Lower it to stress-test a bad-market scenario.",
                       systemImage: "chart.line.uptrend.xyaxis",
                       value: store.binding(\.growthRate, field: "growthRate"),
                       range: 2...10, step: 0.5, format: { Fmt.percent($0) },
                       onCommit: { store.commitChange(field: "growthRate", from: $0, to: $1) })

            FireSlider(label: "Withdrawal rate",
                       tip: "% of your portfolio drawn each year in retirement. 4% (Trinity study) suits ~30 years; a 40+ year horizon like retiring in your 40s-50s is safer at 3-3.5%. Lower = bigger nest egg needed, but less risk of running out.",
                       systemImage: "percent",
                       value: store.binding(\.withdrawalRate, field: "withdrawalRate"),
                       range: 2.5...5, step: 0.25, format: { Fmt.percent($0, decimals: 2) },
                       onCommit: { store.commitChange(field: "withdrawalRate", from: $0, to: $1) })

            FireSlider(label: "Retirement annual spend",
                       tip: "Expected spending once retired, in today's dollars. Default $75k assumes a paid-off home and a modest but comfortable NS lifestyle. Lower spend = smaller FIRE number = earlier retirement.",
                       systemImage: "banknote",
                       value: store.binding(\.annualExpenses, field: "annualExpenses"),
                       range: 40_000...150_000, step: 5_000, format: { Fmt.annualWithMonthly($0) },
                       onCommit: { store.commitChange(field: "annualExpenses", from: $0, to: $1) })

            FireSlider(label: "Inflation rate",
                       tip: "Long-run consumer price inflation applied to your living expenses every year (needs + wants). This is what makes the calculator's numbers \"inflation-adjusted\": the portfolio path can be viewed in today's dollars (real) instead of future, inflated dollars (nominal).",
                       systemImage: "arrow.up.right",
                       value: store.binding(\.inflationRate, field: "inflationRate"),
                       range: 0...6, step: 0.25, format: { Fmt.percent($0) },
                       onCommit: { store.commitChange(field: "inflationRate", from: $0, to: $1) })

            Toggle(isOn: store.boolBinding(\.showRealDollars, field: "showRealDollars")) {
                TooltipLabel(label: "Show real (inflation-adjusted) dollars", tip: "When on, the FIRE number and portfolio chart are restated in today's purchasing power by discounting away cumulative inflation. When off, values are shown in nominal (future, un-adjusted) dollars.")
            }
            .toggleStyle(.switch)
            .tint(Theme.pine)
            .padding(.bottom, 8)

            Divider().padding(.vertical, 6)

            Toggle(isOn: store.boolBinding(\.pensionBridgeEnabled, field: "pensionBridgeEnabled")) {
                TooltipLabel(label: "Include CPP + OAS bridge", tip: "Models Canada Pension Plan (from age 60+) and Old Age Security (from 65+, reduced for late-arriving residents) as income that offsets your retirement spend, shrinking the portfolio needed to fully self-fund retirement.")
            }
            .toggleStyle(.switch)
            .tint(Theme.pine)
            .padding(.bottom, 8)

            if store.inputs.pensionBridgeEnabled {
                FireSlider(label: "Combined CPP (monthly)",
                           tip: "Average new-beneficiary CPP is about $925/mo per person (Jan 2026); the maximum is $1,507.65/mo per person. This is the combined household amount, available from your CPP start age.",
                           systemImage: "building.columns",
                           value: store.binding(\.cppMonthlyCombined, field: "cppMonthlyCombined"),
                           range: 0...3_000, step: 50, format: { Fmt.money($0) + "/mo" },
                           onCommit: { store.commitChange(field: "cppMonthlyCombined", from: $0, to: $1) })

                FireSlider(label: "Combined OAS (monthly, before residency factor)",
                           tip: "Full OAS max is ~$742.31/mo per person (ages 65-74) if you have 40 years of Canadian residence after age 18. This is the combined full-rate amount before applying your residency factor below.",
                           systemImage: "shield.checkered",
                           value: store.binding(\.oasMonthlyCombined, field: "oasMonthlyCombined"),
                           range: 0...1_600, step: 25, format: { Fmt.money($0) + "/mo" },
                           onCommit: { store.commitChange(field: "oasMonthlyCombined", from: $0, to: $1) })

                FireSlider(label: "OAS residency factor",
                           tip: "Late-arriving immigrants accrue OAS at 1/40th per year of Canadian residence after age 18. Arriving around 31-33 gives roughly 80-85% of full OAS by 65 — this slider applies that reduction.",
                           systemImage: "map",
                           value: store.binding(\.oasResidencyFactor, field: "oasResidencyFactor"),
                           range: 0...1, step: 0.01, format: { Fmt.percent($0 * 100) },
                           onCommit: { store.commitChange(field: "oasResidencyFactor", from: $0, to: $1) })
            }

            BrutalText(
                text: "What's a withdrawal rate? The % of your nest egg you sell off and spend each year in retirement. 3.5% on a $2M portfolio means drawing ~$70k/yr while the rest keeps growing. Lower rate = bigger pile needed, but safer over a long retirement.",
                variant: .caption,
                color: Theme.mutedText(scheme)
            )
            .padding(Theme.Spacing.inline)
            .background(Theme.neutral(scheme))
            .brutalistBorder()
        }
    }
}
