import Foundation

/// The full set of user-adjustable dials that drive the FIRE simulation.
/// Mirrors the sliders in the original retirement-calculator.jsx, extended
/// with inflation, pension-bridge, and childcare age-out fields called for
/// by the Nova Scotia FIRE research report.
struct FireInputs: Codable, Equatable, Identifiable {
    var id: UUID = UUID()

    // MARK: Household & income
    var age: Double = 33
    var savings: Double = 20_000
    var income: Double = 160_000
    var raisePct: Double = 4
    var promoBumpPct: Double = 12
    var promoCycle: Double = 3
    var kids: Double = 1
    var childcareEndAge: Double = 12 // child's age at which childcare cost drops to zero

    // MARK: Needs
    var groceries: Double = 900
    var utilities: Double = 130
    var internetPhone: Double = 130
    var numCars: Double = 2
    var costPerCar: Double = 650
    var rideshare: Double = 150
    var medicine: Double = 100
    var personalCare: Double = 50
    var subscriptions: Double = 90
    var childcarePerKid: Double = 700

    // MARK: Wants
    var eatingOut: Double = 550
    var shoppingTech: Double = 350
    var entertainment: Double = 130

    // MARK: Home
    var homePrice: Double = 600_000
    var downPct: Double = 10
    var mortgageRate: Double = 4.6
    var amort: Double = 25

    // MARK: Target / market assumptions
    var growthRate: Double = 6
    var withdrawalRate: Double = 3.5
    var annualExpenses: Double = 75_000

    // MARK: Inflation & real-vs-nominal (new)
    /// Long-run consumer price inflation applied to all living costs (needs/wants) each year.
    var inflationRate: Double = 2.5
    /// When true, the FIRE number / results are expressed in today's (real) dollars
    /// by discounting the nominal simulation back with `inflationRate`.
    var showRealDollars: Bool = true

    // MARK: CPP / OAS pension bridge (new)
    var pensionBridgeEnabled: Bool = true
    /// Combined monthly CPP for both partners, starting at `cppStartAge`.
    var cppMonthlyCombined: Double = 1_850 // ~ average couple, per compass report
    var cppStartAge: Double = 60
    /// Combined monthly OAS for both partners, starting at `oasStartAge`, adjusted by residency factor.
    var oasMonthlyCombined: Double = 1_250
    var oasStartAge: Double = 65
    /// Fraction of full OAS this couple qualifies for (late-arriving immigrants get < 1.0).
    var oasResidencyFactor: Double = 0.83

    static let `default` = FireInputs()
}

extension FireInputs {
    /// Field metadata used to drive generic UI (labels, change-tracking, AI function calling).
    static let fieldKeys: [String] = [
        "age", "savings", "income", "raisePct", "promoBumpPct", "promoCycle", "kids", "childcareEndAge",
        "groceries", "utilities", "internetPhone", "numCars", "costPerCar", "rideshare", "medicine",
        "personalCare", "subscriptions", "childcarePerKid",
        "eatingOut", "shoppingTech", "entertainment",
        "homePrice", "downPct", "mortgageRate", "amort",
        "growthRate", "withdrawalRate", "annualExpenses",
        "inflationRate", "showRealDollars",
        "pensionBridgeEnabled", "cppMonthlyCombined", "cppStartAge", "oasMonthlyCombined", "oasStartAge", "oasResidencyFactor",
    ]

    /// Valid numeric ranges per field key, mirroring the ranges enforced by the SwiftUI sliders
    /// across the various section views. Used to clamp AI-driven slider changes before they're applied.
    static let validRanges: [String: ClosedRange<Double>] = [
        "age": 25...55,
        "savings": 0...200_000,
        "income": 60_000...300_000,
        "raisePct": 0...10,
        "promoBumpPct": 0...30,
        "promoCycle": 1...6,
        "kids": 0...3,
        "childcareEndAge": 0...16,
        "groceries": 300...2_000,
        "utilities": 0...400,
        "internetPhone": 0...400,
        "numCars": 0...4,
        "costPerCar": 200...1_200,
        "rideshare": 0...600,
        "medicine": 0...400,
        "personalCare": 0...300,
        "subscriptions": 0...300,
        "childcarePerKid": 0...1_500,
        "eatingOut": 0...1_200,
        "shoppingTech": 0...1_000,
        "entertainment": 0...600,
        "homePrice": 400_000...1_000_000,
        "downPct": 5...35,
        "mortgageRate": 2...8,
        "amort": 15...30,
        "growthRate": 2...10,
        "withdrawalRate": 2.5...5,
        "annualExpenses": 40_000...150_000,
        "inflationRate": 0...6,
        "showRealDollars": 0...1,
        "pensionBridgeEnabled": 0...1,
        "cppMonthlyCombined": 0...3_000,
        "oasMonthlyCombined": 0...1_600,
        "oasResidencyFactor": 0...1,
    ]

    /// Get a numeric field value by key name (used by change tracking + AI tool calls).
    func numericValue(for key: String) -> Double? {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard child.label == key else { continue }
            if let d = child.value as? Double { return d }
            if let b = child.value as? Bool { return b ? 1 : 0 }
        }
        return nil
    }

    /// Returns a copy with `key` set to `value` (used by AI slider control + revert).
    func setting(_ key: String, to value: Double) -> FireInputs {
        var copy = self
        switch key {
        case "age": copy.age = value
        case "savings": copy.savings = value
        case "income": copy.income = value
        case "raisePct": copy.raisePct = value
        case "promoBumpPct": copy.promoBumpPct = value
        case "promoCycle": copy.promoCycle = value
        case "kids": copy.kids = value
        case "childcareEndAge": copy.childcareEndAge = value
        case "groceries": copy.groceries = value
        case "utilities": copy.utilities = value
        case "internetPhone": copy.internetPhone = value
        case "numCars": copy.numCars = value
        case "costPerCar": copy.costPerCar = value
        case "rideshare": copy.rideshare = value
        case "medicine": copy.medicine = value
        case "personalCare": copy.personalCare = value
        case "subscriptions": copy.subscriptions = value
        case "childcarePerKid": copy.childcarePerKid = value
        case "eatingOut": copy.eatingOut = value
        case "shoppingTech": copy.shoppingTech = value
        case "entertainment": copy.entertainment = value
        case "homePrice": copy.homePrice = value
        case "downPct": copy.downPct = value
        case "mortgageRate": copy.mortgageRate = value
        case "amort": copy.amort = value
        case "growthRate": copy.growthRate = value
        case "withdrawalRate": copy.withdrawalRate = value
        case "annualExpenses": copy.annualExpenses = value
        case "inflationRate": copy.inflationRate = value
        case "showRealDollars": copy.showRealDollars = value > 0.5
        case "pensionBridgeEnabled": copy.pensionBridgeEnabled = value > 0.5
        case "cppMonthlyCombined": copy.cppMonthlyCombined = value
        case "cppStartAge": copy.cppStartAge = value
        case "oasMonthlyCombined": copy.oasMonthlyCombined = value
        case "oasStartAge": copy.oasStartAge = value
        case "oasResidencyFactor": copy.oasResidencyFactor = value
        default: break
        }
        return copy
    }
}
