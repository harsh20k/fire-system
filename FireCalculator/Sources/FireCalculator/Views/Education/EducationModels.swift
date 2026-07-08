import SwiftUI

// MARK: - Chart catalog

enum EducationChartID: String, CaseIterable, Identifiable, Hashable {
    case withdrawalRate, compoundGrowth, pensionBridge
    case inflationErosion, mortgageAmortization, taxBrackets
    case savingsRateImpact, sequenceOfReturns, assetAllocation
    case debtSnowballComparison, contributionVsGrowth, trinityStudySWR
    case cppStartAge, oasClawback, realVsNominal
    case expenseRatioDrag, dollarCostAveraging, monteCarloBands
    case ramsey15Percent, homeEquityBuild, ruleOf72
    case coastFireTimeline, leanVsFatFire, incomeVsExpense
    case portfolioDrawdown, fireNumberMultiplier, childcareCostCurve
    case raiseImpact, promoBumpImpact, inflationAdjustedSpend

    var id: String { rawValue }

    var title: String {
        switch self {
        case .withdrawalRate: "Withdrawal Rate vs FIRE Number"
        case .compoundGrowth: "Compound Growth Scenarios"
        case .pensionBridge: "CPP/OAS Pension Bridge"
        case .inflationErosion: "Inflation Erosion of Purchasing Power"
        case .mortgageAmortization: "Mortgage Amortization Schedule"
        case .taxBrackets: "Progressive Tax Brackets"
        case .savingsRateImpact: "Savings Rate vs Years to FIRE"
        case .sequenceOfReturns: "Sequence-of-Returns Risk"
        case .assetAllocation: "Sample Asset Allocation"
        case .debtSnowballComparison: "Debt Snowball vs Avalanche"
        case .contributionVsGrowth: "Contributions vs Growth"
        case .trinityStudySWR: "Trinity Study Success Rates"
        case .cppStartAge: "CPP Start Age Comparison"
        case .oasClawback: "OAS Recovery Tax Zone"
        case .realVsNominal: "Real vs Nominal Portfolio"
        case .expenseRatioDrag: "Expense Ratio Drag"
        case .dollarCostAveraging: "Dollar-Cost Averaging"
        case .monteCarloBands: "Monte Carlo Confidence Bands"
        case .ramsey15Percent: "Ramsey 15% Investing Rule"
        case .homeEquityBuild: "Home Equity Build-Up"
        case .ruleOf72: "Rule of 72 Doubling Times"
        case .coastFireTimeline: "Coast FIRE Timeline"
        case .leanVsFatFire: "Lean vs Fat FIRE Spend"
        case .incomeVsExpense: "Income vs Expense Over Time"
        case .portfolioDrawdown: "Bear Market Drawdown Recovery"
        case .fireNumberMultiplier: "Spend Multiplier at Different SWRs"
        case .childcareCostCurve: "Childcare Cost Timeline"
        case .raiseImpact: "Annual Raise Impact on Savings"
        case .promoBumpImpact: "Promotion Bump Effect"
        case .inflationAdjustedSpend: "Inflation-Adjusted Retirement Spend"
        }
    }
}

// MARK: - Content models

struct EducationSubsectionData: Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
}

struct EducationSectionData: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let paragraphs: [String]
    let formula: String?
    let appReference: String?
    let subsections: [EducationSubsectionData]
    let chartID: EducationChartID?
}

struct EducationPageData: Identifiable, Hashable {
    let id: String
    let number: String
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let sections: [EducationSectionData]

    var sectionCount: Int { sections.count }
}

// MARK: - Blueprint → section expansion

struct EducationSectionBlueprint {
    let title: String
    let summary: String
    let paragraphs: [String]
    let formula: String?
    let appReference: String?
    let subsections: [(title: String, body: String)]
    let chartID: EducationChartID?

    func makeSection(pageID: String, index: Int) -> EducationSectionData {
        EducationSectionData(
            id: "\(pageID)-s\(index)",
            title: title,
            summary: summary,
            paragraphs: paragraphs,
            formula: formula,
            appReference: appReference,
            subsections: subsections.enumerated().map { i, sub in
                EducationSubsectionData(id: "\(pageID)-s\(index)-sub\(i)", title: sub.title, body: sub.body)
            },
            chartID: chartID
        )
    }
}

struct EducationPageBlueprint {
    let id: String
    let number: String
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let sections: [EducationSectionBlueprint]

    func makePage() -> EducationPageData {
        EducationPageData(
            id: id,
            number: number,
            title: title,
            subtitle: subtitle,
            icon: icon,
            accent: accent,
            sections: sections.enumerated().map { $1.makeSection(pageID: id, index: $0) }
        )
    }
}
