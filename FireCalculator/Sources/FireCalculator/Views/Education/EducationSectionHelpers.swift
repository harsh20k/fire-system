import SwiftUI

/// Helpers for building education section blueprints with consistent structure.
enum EducationSectionHelpers {

    static func section(
        _ title: String,
        _ summary: String,
        paragraphs: [String],
        formula: String? = nil,
        appReference: String? = nil,
        subsections: [(String, String)] = [],
        chart: EducationChartID? = nil
    ) -> EducationSectionBlueprint {
        EducationSectionBlueprint(
            title: title,
            summary: summary,
            paragraphs: paragraphs,
            formula: formula,
            appReference: appReference,
            subsections: subsections,
            chartID: chart
        )
    }

    static func page(
        id: String,
        number: String,
        title: String,
        subtitle: String,
        icon: String,
        accent: Color,
        sections: [EducationSectionBlueprint]
    ) -> EducationPageBlueprint {
        precondition(sections.count >= 30, "Page \(title) must have ≥30 sections, got \(sections.count)")
        return EducationPageBlueprint(
            id: id, number: number, title: title, subtitle: subtitle,
            icon: icon, accent: accent, sections: sections
        )
    }
}
