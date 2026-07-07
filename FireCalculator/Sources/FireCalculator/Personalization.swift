import Foundation

/// Edit these two lines — the rest of the app picks them up automatically.
enum Personalization {
    static let person1 = "Harsh"
    static let person2 = "Suman" // Edit with your wife's name if different

    static var coupleNames: String { "\(person1) & \(person2)" }

    static var coupleGreeting: String {
        "Hey \(coupleNames) — when can you two ditch the 9-to-5?"
    }

    static var nestEggTagline: String { "Your nest egg path, together" }

    static var headerSubtitle: String {
        "Every lever below feeds the chart — income growth, mortgage, needs, wants, inflation, and the CPP/OAS bridge all net out into what you two save each month."
    }

    static var assistantTitle: String { "FIRE Co-pilot" }

    static var assistantWelcome: String {
        "Ask me anything — \"What if we buy at $500k?\" or \"Set withdrawal rate to 3.3%\" — I'll explain the numbers or tweak sliders for you two."
    }

    static var checkpointEmpty: String {
        "Save a snapshot before one of you moves a slider too far 😄"
    }

    static var historyEmpty: String {
        "No changes yet — tweak a slider together and we'll log who moved what."
    }

    static var resultsDisclaimer: String {
        "Rough model for \(coupleNames)'s plan — not financial advice. Living expenses inflate at your chosen inflation rate; income grows with your raise/promotion sliders; CPP/OAS bridge is a simplified estimate."
    }

    static var aboutBlurb: String {
        "Built for \(coupleNames): a Halifax household's path to Financial Independence, with inflation-adjusted projections, a CPP/OAS pension bridge, checkpointed scenarios, and an AI co-pilot that can explain or adjust the plan with you."
    }

    static var reportCoverTitle: String { coupleGreeting }

    static var reportCoverKicker: String {
        "\(coupleNames) · Halifax, Nova Scotia"
    }

    static var exportPreviewTitle: String { "\(coupleNames)'s FIRE Report" }
}
