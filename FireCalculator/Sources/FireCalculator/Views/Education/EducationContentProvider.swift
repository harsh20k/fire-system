import SwiftUI

/// Assembles all education pages from blueprints.
enum EducationContentProvider {
    static let pages: [EducationPageData] = EducationContentAllPages.blueprints.map { $0.makePage() }

    static var pageCount: Int { pages.count }

    static func sectionsPerPage() -> [String: Int] {
        Dictionary(uniqueKeysWithValues: pages.map { ($0.title, $0.sectionCount) })
    }

    static var totalSections: Int { pages.reduce(0) { $0 + $1.sectionCount } }

    static var chartCount: Int { EducationChartID.allCases.count }
}
