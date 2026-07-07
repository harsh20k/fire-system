import SwiftUI

/// Fixed left sidebar: FIRE age, number, savings rate + compact monthly stats.
struct HeroSidebar: View {
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let r = store.results
        let showReal = store.inputs.showRealDollars
        let fireValue = Fmt.moneyK(showReal ? r.fireNumberReal : r.fireNumberNominal)
        let ageValue = r.fireAge.map { Fmt.age($0) } ?? "60+"
        let savingsRate = savingsRatePercent(r)

        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
            BrutalText(text: Personalization.coupleGreeting, variant: .body, bold: true)

            HeroStat(
                label: "FIRE age",
                value: ageValue,
                tip: "The first simulated year where portfolio balance ≥ that year's FIRE number.",
                accent: Theme.ochre
            )
            HeroStat(
                label: "FIRE number",
                value: fireValue,
                tip: "Net-of-pension retirement spend ÷ withdrawal rate.",
                accent: Theme.primary
            )
            HeroStat(
                label: "Savings rate",
                value: savingsRate,
                tip: "Monthly savings ÷ monthly take-home.",
                accent: r.currentMonthlySavings >= 0 ? Theme.primary : Theme.accent
            )

            VStack(alignment: .leading, spacing: 8) {
                compactStat("Monthly savings", Fmt.money(r.currentMonthlySavings))
                compactStat("Monthly mortgage", Fmt.monthlyWithAnnual(r.monthlyMortgagePayment))
            }
            .padding(Theme.Spacing.inline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface(scheme))
            .brutalistBorder()

            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.screen)
        .frame(width: Theme.sidebarWidth)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.neutral(scheme))
    }

    private func compactStat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            BrutalText(text: label, variant: .caption, color: Theme.mutedText(scheme), uppercase: true)
            BrutalText(text: value, variant: .body, bold: true)
        }
    }

    private func savingsRatePercent(_ r: FireResults) -> String {
        let monthlyTakeHome = r.currentTakeHome / 12
        guard monthlyTakeHome > 0 else { return "—" }
        return Fmt.percent(max(0, (r.currentMonthlySavings / monthlyTakeHome) * 100))
    }
}
