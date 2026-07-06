import Foundation

enum Fmt {
    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "CAD"
        f.maximumFractionDigits = 0
        f.locale = Locale(identifier: "en_CA")
        return f
    }()

    static func money(_ value: Double) -> String {
        currency.string(from: NSNumber(value: value.rounded())) ?? "$\(Int(value.rounded()))"
    }

    static func moneyK(_ value: Double) -> String {
        if abs(value) >= 1_000_000 {
            return String(format: "$%.2fM", value / 1_000_000)
        }
        return "$\(Int((value / 1000).rounded()))k"
    }

    static func annualWithMonthly(_ annual: Double) -> String {
        "\(money(annual)) (\(money(annual / 12))/mo)"
    }

    static func monthlyWithAnnual(_ monthly: Double) -> String {
        "\(money(monthly))/mo (\(money(monthly * 12))/yr)"
    }

    static func percent(_ value: Double, decimals: Int = 1) -> String {
        String(format: "%.\(decimals)f%%", value)
    }

    static func years(_ value: Double) -> String {
        "\(Int(value)) yrs"
    }

    static func age(_ value: Double) -> String {
        "\(Int(value))"
    }
}
