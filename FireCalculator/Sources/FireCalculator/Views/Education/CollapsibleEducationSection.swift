import SwiftUI

/// Top-level collapsible section — collapsed by default.
struct CollapsibleEducationSection: View {
    @Environment(\.colorScheme) private var scheme
    let section: EducationSectionData
    let accent: Color
    let annualExpenses: Double

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
                ForEach(section.paragraphs, id: \.self) { paragraph in
                    BrutalText(text: paragraph, variant: .body, color: Theme.mutedText(scheme))
                }
                if let formula = section.formula {
                    formulaBlock(formula)
                }
                if let appRef = section.appReference {
                    appReferenceBlock(appRef)
                }
                ForEach(section.subsections) { sub in
                    CollapsibleEducationSubsection(subsection: sub, accent: accent)
                }
                if let chartID = section.chartID {
                    EducationChartContainer(chartID: chartID, annualExpenses: annualExpenses)
                }
            }
            .padding(.top, 8)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                BrutalText(text: section.title, variant: .body, bold: true)
                BrutalText(text: section.summary, variant: .caption, color: Theme.mutedText(scheme))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(accent)
        .padding(Theme.Spacing.inline)
        .background(Theme.neutral(scheme))
        .brutalistBorder()
    }

    private func formulaBlock(_ formula: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            BrutalText(text: "Formula", variant: .caption, bold: true, color: accent, uppercase: true, tracking: 1)
            BrutalText(text: formula, variant: .caption, bold: true)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface(scheme))
                .brutalistBorder()
        }
    }

    private func appReferenceBlock(_ ref: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "link.circle.fill")
                .foregroundStyle(accent)
            BrutalText(text: ref, variant: .caption, color: Theme.mutedText(scheme))
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accent.opacity(0.08))
        .brutalistBorder()
    }
}

/// Nested collapsible subsection — also collapsed by default.
struct CollapsibleEducationSubsection: View {
    @Environment(\.colorScheme) private var scheme
    let subsection: EducationSubsectionData
    let accent: Color

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            BrutalText(text: subsection.body, variant: .caption, color: Theme.mutedText(scheme))
                .padding(.top, 4)
        } label: {
            BrutalText(text: subsection.title, variant: .caption, bold: true, color: accent)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(accent.opacity(0.8))
        .padding(10)
        .background(Theme.surface(scheme))
        .brutalistBorder()
    }
}

/// Renders the chart catalog entry inside a section.
struct EducationChartContainer: View {
    @Environment(\.colorScheme) private var scheme
    let chartID: EducationChartID
    let annualExpenses: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BrutalText(text: chartID.title, variant: .caption, bold: true)
            EducationChartRenderer(chartID: chartID, annualExpenses: annualExpenses)
        }
        .padding(Theme.Spacing.inline)
        .background(Theme.surface(scheme))
        .brutalistBorder()
    }
}

/// Single page content — scrollable section list.
struct EducationPageDetailView: View {
    @Environment(\.colorScheme) private var scheme
    let page: EducationPageData
    let annualExpenses: Double

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.section) {
                pageHeader
                LazyVStack(alignment: .leading, spacing: Theme.Spacing.inline) {
                    ForEach(page.sections) { section in
                        CollapsibleEducationSection(
                            section: section,
                            accent: page.accent,
                            annualExpenses: annualExpenses
                        )
                    }
                }
            }
            .padding(Theme.Spacing.screen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.neutral(scheme))
        .navigationTitle(page.title)
    }

    private var pageHeader: some View {
        BrutalCard(accent: page.accent) {
            VStack(alignment: .leading, spacing: 8) {
                BrutalText(
                    text: "\(page.number) — \(page.title)",
                    variant: .sectionLabel,
                    color: page.accent,
                    uppercase: true,
                    tracking: 1.2
                )
                BrutalText(text: page.subtitle, variant: .body, color: Theme.mutedText(scheme))
                BrutalText(
                    text: "\(page.sectionCount) sections · expand any topic to learn more",
                    variant: .caption,
                    color: Theme.mutedText(scheme)
                )
            }
        }
    }
}
