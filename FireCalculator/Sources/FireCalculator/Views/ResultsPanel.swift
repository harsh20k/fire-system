import SwiftUI

struct ResultsPanel: View {
    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var contentWidth: CGFloat = 1000

    var body: some View {
        let r = store.results
        let showReal = store.inputs.showRealDollars

        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
            header

            GeometryReader { geo in
                let tileWidth = geo.size.width * 0.5
                let tileHeight = geo.size.height

                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top, spacing: Theme.Spacing.inline) {
                        chartTile("Portfolio", width: tileWidth, height: tileHeight) {
                            PortfolioPathChart(results: r, showReal: showReal)
                        }
                        chartTile("Breakdown", width: tileWidth, height: tileHeight) {
                            ExpenseBreakdownChart(results: r)
                        }
                        chartTile("Income vs Spend", width: tileWidth, height: tileHeight) {
                            IncomeVsExpenseChart(results: r)
                        }
                        chartTile("Pension Bridge", width: tileWidth, height: tileHeight) {
                            PensionBridgeChart(inputs: store.inputs, results: r)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .scrollClipDisabled()
            }
            .frame(maxHeight: .infinity)

            HStack(spacing: Theme.Spacing.inline) {
                detailRow("Take-home", Fmt.annualWithMonthly(r.currentTakeHome))
                detailRow("Needs", Fmt.monthlyWithAnnual(r.needsMonthly))
                detailRow("Wants", Fmt.monthlyWithAnnual(r.wantsMonthly))
            }

            BrutalText(
                text: Personalization.resultsDisclaimer,
                variant: .caption,
                color: Theme.mutedText(scheme)
            )
            .lineLimit(2)
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.vertical, Theme.Spacing.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            GeometryReader { proxy in
                Color.clear.onChange(of: proxy.size.width, initial: true) { _, w in
                    contentWidth = w
                }
            }
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BrutalText(text: Personalization.coupleGreeting, variant: .body, bold: true)
            BrutalText(
                text: Personalization.nestEggTagline,
                variant: .caption,
                color: Theme.mutedText(scheme),
                uppercase: true,
                tracking: 1.5
            )
            BrutalText(
                text: Personalization.headerSubtitle,
                variant: .caption,
                color: Theme.mutedText(scheme)
            )
            .lineLimit(1)
        }
    }

    private func chartTile<Content: View>(
        _ title: String,
        width: CGFloat,
        height: CGFloat,
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(Theme.Spacing.inline)
                .background(Theme.neutral(scheme))
                .brutalistBorder()
        }
        .frame(width: width, height: height, alignment: .topLeading)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            BrutalText(text: label, variant: .caption, color: Theme.mutedText(scheme))
            Spacer()
            BrutalText(text: value, variant: .caption, bold: true)
        }
        .frame(maxWidth: .infinity)
    }
}
