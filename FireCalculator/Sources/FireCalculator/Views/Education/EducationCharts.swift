import SwiftUI
import Charts

// MARK: - Chart router

struct EducationChartRenderer: View {
    let chartID: EducationChartID
    let annualExpenses: Double

    var body: some View {
        Group {
            switch chartID {
            case .withdrawalRate: WithdrawalRateEducationChart(annualExpenses: annualExpenses)
            case .compoundGrowth: CompoundGrowthEducationChart()
            case .pensionBridge: PensionBridgeEducationChart()
            case .inflationErosion: InflationErosionChart()
            case .mortgageAmortization: MortgageAmortizationChart()
            case .taxBrackets: TaxBracketsChart()
            case .savingsRateImpact: SavingsRateImpactChart()
            case .sequenceOfReturns: SequenceOfReturnsChart()
            case .assetAllocation: AssetAllocationChart()
            case .debtSnowballComparison: DebtSnowballComparisonChart()
            case .contributionVsGrowth: ContributionVsGrowthChart()
            case .trinityStudySWR: TrinityStudySWRChart()
            case .cppStartAge: CPPStartAgeChart()
            case .oasClawback: OASClawbackChart()
            case .realVsNominal: RealVsNominalChart()
            case .expenseRatioDrag: ExpenseRatioDragChart()
            case .dollarCostAveraging: DollarCostAveragingChart()
            case .monteCarloBands: MonteCarloBandsChart()
            case .ramsey15Percent: Ramsey15PercentChart()
            case .homeEquityBuild: HomeEquityBuildChart()
            case .ruleOf72: RuleOf72Chart()
            case .coastFireTimeline: CoastFireTimelineChart()
            case .leanVsFatFire: LeanVsFatFireChart()
            case .incomeVsExpense: IncomeVsExpenseEducationChart()
            case .portfolioDrawdown: PortfolioDrawdownChart()
            case .fireNumberMultiplier: FireNumberMultiplierChart(annualExpenses: annualExpenses)
            case .childcareCostCurve: ChildcareCostCurveChart()
            case .raiseImpact: RaiseImpactChart()
            case .promoBumpImpact: PromoBumpImpactChart()
            case .inflationAdjustedSpend: InflationAdjustedSpendChart()
            }
        }
    }
}

// MARK: - Existing charts (enhanced)

struct WithdrawalRateEducationChart: View {
    let annualExpenses: Double

    private struct Bar: Identifiable {
        var id: Double { rate }
        let rate: Double
        let fireNumber: Double
    }

    private var bars: [Bar] {
        stride(from: 2.5, through: 6.0, by: 0.5).map { rate in
            Bar(rate: rate, fireNumber: annualExpenses / (rate / 100))
        }
    }

    var body: some View {
        Chart(bars) { bar in
            BarMark(x: .value("Rate", "\(String(format: "%.1f", bar.rate))%"), y: .value("FIRE #", bar.fireNumber))
                .foregroundStyle(bar.rate == 3.5 ? Theme.primary : Theme.slate.opacity(0.7))
                .cornerRadius(0)
            if bar.rate == 3.5 {
                RuleMark(y: .value("Default", bar.fireNumber))
                    .foregroundStyle(Theme.ochre)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
            }
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct CompoundGrowthEducationChart: View {
    private struct Point: Identifiable {
        var id: String { "\(series)-\(year)" }
        let year: Int; let balance: Double; let series: String
    }

    private var points: [Point] {
        let start = 10_000.0
        let rates = [("4% conservative", 4.0), ("6% app default", 6.0), ("8% aggressive", 8.0)]
        var out: [Point] = []
        for (label, rate) in rates {
            for year in 0...30 {
                out.append(Point(year: year, balance: start * pow(1 + rate / 100, Double(year)), series: label))
            }
        }
        return out
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Years", p.year), y: .value("Balance", p.balance))
                .foregroundStyle(by: .value("Return", p.series))
                .interpolationMethod(.monotone)
            PointMark(x: .value("Years", p.year), y: .value("Balance", p.balance))
                .foregroundStyle(by: .value("Return", p.series))
                .symbolSize(p.year % 5 == 0 ? 30 : 0)
        }
        .chartForegroundStyleScale(["4% conservative": Theme.slate, "6% app default": Theme.primary, "8% aggressive": Theme.ochre])
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .chartLegend(position: .bottom)
        .frame(height: 220)
    }
}

struct PensionBridgeEducationChart: View {
    private struct Row: Identifiable {
        var id: Double { age }
        let age: Double; let pension: Double; let portfolioDraw: Double
    }

    private var rows: [Row] {
        let spend = 75_000.0
        return stride(from: 55, through: 80, by: 1).map { age in
            var pension = 0.0
            if age >= 60 { pension += 1_850 * 12 }
            if age >= 65 { pension += 1_250 * 0.83 * 12 }
            let draw = max(0, spend - pension)
            return Row(age: age, pension: min(pension, spend), portfolioDraw: draw)
        }
    }

    var body: some View {
        Chart {
            ForEach(rows) { row in
                AreaMark(x: .value("Age", row.age), y: .value("Amount", row.portfolioDraw), stacking: .standard)
                    .foregroundStyle(by: .value("Source", "Portfolio draw"))
                AreaMark(x: .value("Age", row.age), y: .value("Amount", row.pension), stacking: .standard)
                    .foregroundStyle(by: .value("Source", "CPP + OAS"))
            }
            RuleMark(x: .value("CPP", 60)).foregroundStyle(Theme.slate.opacity(0.5)).lineStyle(StrokeStyle(dash: [3, 3]))
            RuleMark(x: .value("OAS", 65)).foregroundStyle(Theme.ochre.opacity(0.5)).lineStyle(StrokeStyle(dash: [3, 3]))
        }
        .chartForegroundStyleScale(["Portfolio draw": Theme.primary.opacity(0.7), "CPP + OAS": Theme.ochre.opacity(0.85)])
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .chartLegend(position: .bottom)
        .frame(height: 200)
    }
}

// MARK: - New charts

struct InflationErosionChart: View {
    private struct Point: Identifiable { var id: Int { year }; let year: Int; let nominal: Double; let real: Double }

    private var points: [Point] {
        let base = 100_000.0
        return (0...30).map { y in
            let factor = pow(1.025, Double(y))
            return Point(year: y, nominal: base, real: base / factor)
        }
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Year", p.year), y: .value("Nominal", p.nominal)).foregroundStyle(Theme.slate)
            LineMark(x: .value("Year", p.year), y: .value("Real", p.real)).foregroundStyle(Theme.brick)
            AreaMark(x: .value("Year", p.year), yStart: .value("Real", p.real), yEnd: .value("Nominal", p.nominal))
                .foregroundStyle(Theme.brick.opacity(0.15))
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct MortgageAmortizationChart: View {
    private struct Row: Identifiable { var id: Int { month }; let month: Int; let principal: Double; let interest: Double }

    private var rows: [Row] {
        let price = 600_000.0, down = 0.10, rate = 0.046 / 12, n = 25 * 12
        let principal0 = price * (1 - down)
        let pmt = (principal0 * rate) / (1 - pow(1 + rate, -Double(n)))
        var balance = principal0
        var out: [Row] = []
        for m in stride(from: 0, to: n, by: 6) {
            while out.count * 6 < m && balance > 0 {
                let interest = balance * rate
                balance -= (pmt - interest)
            }
            let interest = balance * rate
            out.append(Row(month: m, principal: pmt - interest, interest: interest))
        }
        return out
    }

    var body: some View {
        Chart(rows) { r in
            BarMark(x: .value("Month", r.month), y: .value("Principal", r.principal), stacking: .standard)
                .foregroundStyle(Theme.primary)
            BarMark(x: .value("Month", r.month), y: .value("Interest", r.interest), stacking: .standard)
                .foregroundStyle(Theme.ochre.opacity(0.7))
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.money(d)) } } } }
        .frame(height: 200)
    }
}

struct TaxBracketsChart: View {
    private struct Bracket: Identifiable { var id: String { label }; let label: String; let rate: Double; let width: Double }

    private let brackets: [Bracket] = [
        Bracket(label: "$0–55k", rate: 24, width: 55),
        Bracket(label: "$55–80k", rate: 30, width: 25),
        Bracket(label: "$80–110k", rate: 35.8, width: 30),
        Bracket(label: "$110–150k", rate: 38, width: 40),
        Bracket(label: "$150–220k", rate: 41.5, width: 70),
        Bracket(label: "$220–300k", rate: 47, width: 80),
        Bracket(label: "$300k+", rate: 54, width: 50),
    ]

    var body: some View {
        Chart(brackets) { b in
            BarMark(x: .value("Bracket", b.label), y: .value("Rate", b.rate))
                .foregroundStyle(Theme.slate.gradient)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.percent(d)) } } } }
        .frame(height: 200)
    }
}

struct SavingsRateImpactChart: View {
    private struct Point: Identifiable { var id: Double { rate }; let rate: Double; let years: Double }

    private var points: [Point] {
        let target = 1_000_000.0, income = 160_000.0, growth = 0.06
        return stride(from: 10, through: 60, by: 5).map { sr in
            let annualSave = income * (sr / 100)
            var balance = 20_000.0; var years = 0.0
            while balance < target && years < 50 {
                balance = balance * (1 + growth) + annualSave
                years += 1
            }
            return Point(rate: sr, years: years)
        }
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Savings rate", p.rate), y: .value("Years", p.years))
                .foregroundStyle(Theme.primary)
                .interpolationMethod(.monotone)
            PointMark(x: .value("Savings rate", p.rate), y: .value("Years", p.years))
                .foregroundStyle(Theme.primary)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text("\(Int(d)) yrs") } } } }
        .frame(height: 200)
    }
}

struct SequenceOfReturnsChart: View {
    private struct Point: Identifiable { var id: String { "\(series)-\(year)" }; let year: Int; let balance: Double; let series: String }

    private func simulate(returns: [Double], label: String) -> [Point] {
        var bal = 500_000.0
        var out: [Point] = [Point(year: 0, balance: bal, series: label)]
        for (i, r) in returns.enumerated() {
            bal = max(0, bal * (1 + r) - 40_000)
            out.append(Point(year: i + 1, balance: bal, series: label))
        }
        return out
    }

    private var points: [Point] {
        let badEarly = [-0.15, -0.10, 0.08, 0.10, 0.12, 0.08, 0.10, 0.08, 0.10, 0.08]
        let goodEarly = [0.12, 0.10, 0.08, -0.10, -0.15, 0.08, 0.10, 0.08, 0.10, 0.08]
        return simulate(returns: badEarly, label: "Crash early") + simulate(returns: goodEarly, label: "Crash late")
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Year", p.year), y: .value("Balance", p.balance))
                .foregroundStyle(by: .value("Scenario", p.series))
                .interpolationMethod(.monotone)
        }
        .chartForegroundStyleScale(["Crash early": Theme.brick, "Crash late": Theme.primary])
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .chartLegend(position: .bottom)
        .frame(height: 220)
    }
}

struct AssetAllocationChart: View {
    private struct Slice: Identifiable { var id: String { name }; let name: String; let pct: Double }

    private let slices = [
        Slice(name: "US equities", pct: 40), Slice(name: "Intl equities", pct: 20),
        Slice(name: "Bonds", pct: 25), Slice(name: "Real estate", pct: 10), Slice(name: "Cash", pct: 5),
    ]

    var body: some View {
        Chart(slices) { s in
            SectorMark(angle: .value("Pct", s.pct), innerRadius: .ratio(0.5), angularInset: 1)
                .foregroundStyle(by: .value("Asset", s.name))
        }
        .chartForegroundStyleScale([
            "US equities": Theme.primary, "Intl equities": Theme.slate,
            "Bonds": Theme.ochre, "Real estate": Theme.brick, "Cash": Color.gray,
        ])
        .chartLegend(position: .bottom)
        .frame(height: 220)
    }
}

struct DebtSnowballComparisonChart: View {
    private struct Point: Identifiable { var id: String { "\(method)-\(month)" }; let month: Int; let remaining: Double; let method: String }

    private func simulate(method: String, balances: [(Double, Double)]) -> [Point] {
        var debts = balances
        var out: [Point] = [Point(month: 0, remaining: debts.map(\.0).reduce(0, +), method: method)]
        var month = 0
        while debts.contains(where: { $0.0 > 0 }) && month < 60 {
            month += 1
            let payment = 500.0
            if method == "Snowball" {
                debts.sort { $0.0 < $1.0 }
            } else {
                debts.sort { $0.1 > $1.1 }
            }
            var extra = payment
            for i in debts.indices where debts[i].0 > 0 {
                let interest = debts[i].0 * debts[i].1 / 12
                let pay = min(debts[i].0 + interest, extra)
                debts[i].0 = max(0, debts[i].0 + interest - pay)
                extra = max(0, extra - pay)
                if extra <= 0 { break }
            }
            out.append(Point(month: month, remaining: debts.map(\.0).reduce(0, +), method: method))
        }
        return out
    }

    private var points: [Point] {
        let debts = [(3_000.0, 0.18), (8_000.0, 0.12), (15_000.0, 0.08)]
        return simulate(method: "Snowball", balances: debts) + simulate(method: "Avalanche", balances: debts)
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Month", p.month), y: .value("Debt", p.remaining))
                .foregroundStyle(by: .value("Method", p.method))
        }
        .chartForegroundStyleScale(["Snowball": Theme.ochre, "Avalanche": Theme.primary])
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .chartLegend(position: .bottom)
        .frame(height: 200)
    }
}

struct ContributionVsGrowthChart: View {
    private struct Row: Identifiable { var id: Int { year }; let year: Int; let contributions: Double; let growth: Double }

    private var rows: [Row] {
        var bal = 0.0; var contrib = 0.0
        return (1...20).map { y in
            let added = 20_000.0
            contrib += added
            bal = (bal + added) * 1.06
            return Row(year: y, contributions: contrib, growth: bal - contrib)
        }
    }

    var body: some View {
        Chart(rows) { r in
            BarMark(x: .value("Year", r.year), y: .value("Contributions", r.contributions), stacking: .standard)
                .foregroundStyle(Theme.slate)
            BarMark(x: .value("Year", r.year), y: .value("Growth", r.growth), stacking: .standard)
                .foregroundStyle(Theme.primary)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct TrinityStudySWRChart: View {
    private struct Bar: Identifiable { var id: Double { rate }; let rate: Double; let success: Double }

    private let bars: [Bar] = [
        Bar(rate: 3.0, success: 98), Bar(rate: 3.5, success: 96), Bar(rate: 4.0, success: 95),
        Bar(rate: 4.5, success: 88), Bar(rate: 5.0, success: 78), Bar(rate: 6.0, success: 55),
    ]

    var body: some View {
        Chart(bars) { b in
            BarMark(x: .value("SWR", "\(String(format: "%.1f", b.rate))%"), y: .value("Success", b.success))
                .foregroundStyle(b.rate <= 4 ? Theme.primary : Theme.brick.opacity(0.7))
        }
        .chartYScale(domain: 0...100)
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text("\(Int(d))%") } } } }
        .frame(height: 200)
    }
}

struct CPPStartAgeChart: View {
    private struct Point: Identifiable { var id: Int { age }; let age: Int; let annual: Double; let lifetime: Double }

    private var points: [Point] {
        (60...70).map { age in
            let factor = age == 60 ? 0.64 : age == 61 ? 0.712 : age == 62 ? 0.784 : age == 63 ? 0.856 : age == 64 ? 0.928 : age == 65 ? 1.0 : age == 66 ? 1.084 : age == 67 ? 1.168 : age == 68 ? 1.252 : age == 69 ? 1.336 : 1.42
            let annual = 1_850 * 12 * factor
            let years = max(0, 90 - age)
            return Point(age: age, annual: annual, lifetime: annual * Double(years))
        }
    }

    var body: some View {
        Chart(points) { p in
            BarMark(x: .value("Age", p.age), y: .value("Annual", p.annual))
                .foregroundStyle(Theme.slate)
            LineMark(x: .value("Age", p.age), y: .value("Lifetime", p.lifetime / 10))
                .foregroundStyle(Theme.ochre)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct OASClawbackChart: View {
    private struct Point: Identifiable { var id: Double { income }; let income: Double; let oas: Double }

    private var points: [Point] {
        stride(from: 60_000, through: 120_000, by: 2_500).map { inc in
            let excess = max(0, inc - 90_997)
            let reduction = min(1_250 * 12 * 0.83, excess * 0.15)
            return Point(income: inc, oas: max(0, 1_250 * 12 * 0.83 - reduction))
        }
    }

    var body: some View {
        Chart(points) { p in
            AreaMark(x: .value("Income", p.income), y: .value("OAS", p.oas))
                .foregroundStyle(Theme.ochre.opacity(0.6))
            LineMark(x: .value("Income", p.income), y: .value("OAS", p.oas))
                .foregroundStyle(Theme.ochre)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct RealVsNominalChart: View {
    private struct Point: Identifiable { var id: Int { year }; let year: Int; let nominal: Double; let real: Double }

    private var points: [Point] {
        (0...30).map { y in
            let nom = 500_000 * pow(1.06, Double(y))
            let real = nom / pow(1.025, Double(y))
            return Point(year: y, nominal: nom, real: real)
        }
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Year", p.year), y: .value("Nominal", p.nominal)).foregroundStyle(Theme.primary)
            LineMark(x: .value("Year", p.year), y: .value("Real", p.real)).foregroundStyle(Theme.slate)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .chartLegend(position: .bottom)
        .frame(height: 200)
    }
}

struct ExpenseRatioDragChart: View {
    private struct Point: Identifiable { var id: String { "\(fee)-\(year)" }; let year: Int; let balance: Double; let fee: String }

    private var points: [Point] {
        let fees = [("0.05% index", 0.0005), ("1.0% active", 0.01), ("2.0% high-fee", 0.02)]
        var out: [Point] = []
        for (label, fee) in fees {
            var bal = 100_000.0
            for y in 0...30 {
                out.append(Point(year: y, balance: bal, fee: label))
                bal *= (1 + 0.06 - fee)
            }
        }
        return out
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Year", p.year), y: .value("Balance", p.balance))
                .foregroundStyle(by: .value("Fee", p.fee))
        }
        .chartForegroundStyleScale(["0.05% index": Theme.primary, "1.0% active": Theme.ochre, "2.0% high-fee": Theme.brick])
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .chartLegend(position: .bottom)
        .frame(height: 220)
    }
}

struct DollarCostAveragingChart: View {
    private struct Point: Identifiable { var id: Int { month }; let month: Int; let dca: Double; let lump: Double }

    private var points: [Point] {
        let prices: [Double] = [100, 90, 80, 85, 95, 110, 105, 100, 95, 105, 115, 120]
        var dcaShares = 0.0; var lumpShares = 0.0
        let lumpInvested = 1200.0
        lumpShares = lumpInvested / prices[0]
        return prices.enumerated().map { i, price in
            dcaShares += 100.0 / price
            return Point(month: i, dca: dcaShares * price, lump: lumpShares * price)
        }
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Month", p.month), y: .value("DCA", p.dca)).foregroundStyle(Theme.primary)
            LineMark(x: .value("Month", p.month), y: .value("Lump sum", p.lump)).foregroundStyle(Theme.slate)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct MonteCarloBandsChart: View {
    private struct Point: Identifiable { var id: String { "\(band)-\(year)" }; let year: Int; let value: Double; let band: String }

    private var points: [Point] {
        var out: [Point] = []
        for y in 0...30 {
            let mid = 100_000 * pow(1.06, Double(y))
            out += [
                Point(year: y, value: mid * 0.7, band: "10th pct"),
                Point(year: y, value: mid, band: "Median"),
                Point(year: y, value: mid * 1.4, band: "90th pct"),
            ]
        }
        return out
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Year", p.year), y: .value("Value", p.value))
                .foregroundStyle(by: .value("Band", p.band))
                .interpolationMethod(.monotone)
            if p.band == "10th pct" {
                AreaMark(x: .value("Year", p.year), y: .value("Low", p.value))
                    .foregroundStyle(Theme.slate.opacity(0.1))
            }
        }
        .chartForegroundStyleScale(["10th pct": Theme.slate.opacity(0.5), "Median": Theme.primary, "90th pct": Theme.ochre])
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .chartLegend(position: .bottom)
        .frame(height: 220)
    }
}

struct Ramsey15PercentChart: View {
    private struct Row: Identifiable { var id: String { step }; let step: String; let amount: Double }

    private let income = 160_000.0
    private var rows: [Row] {
        [("Gross income", income), ("15% invest target", income * 0.15), ("Monthly invest", income * 0.15 / 12), ("Take-home (~72%)", income * 0.72)]
            .map { Row(step: $0.0, amount: $0.1) }
    }

    var body: some View {
        Chart(rows) { r in
            BarMark(x: .value("Step", r.step), y: .value("Amount", r.amount))
                .foregroundStyle(r.step.contains("15%") ? Theme.ochre : Theme.slate)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct HomeEquityBuildChart: View {
    private struct Point: Identifiable { var id: Int { year }; let year: Int; let equity: Double; let loan: Double }

    private var points: [Point] {
        let price = 600_000.0, rate = 0.046 / 12, n = 300
        let pmt = (540_000 * rate) / (1 - pow(1 + rate, -Double(n)))
        var balance = 540_000.0
        return (0...25).map { y in
            for _ in 0..<12 { let interest = balance * rate; balance -= (pmt - interest) }
            let homeValue = price * pow(1.03, Double(y))
            return Point(year: y, equity: homeValue - balance, loan: balance)
        }
    }

    var body: some View {
        Chart(points) { p in
            AreaMark(x: .value("Year", p.year), y: .value("Equity", p.equity), stacking: .standard).foregroundStyle(Theme.primary.opacity(0.7))
            AreaMark(x: .value("Year", p.year), y: .value("Loan", p.loan), stacking: .standard).foregroundStyle(Theme.slate.opacity(0.5))
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct RuleOf72Chart: View {
    private struct Bar: Identifiable { var id: Double { rate }; let rate: Double; let years: Double }

    private var bars: [Bar] {
        [3.0, 4.0, 6.0, 8.0, 10.0].map { r in Bar(rate: r, years: 72 / r) }
    }

    var body: some View {
        Chart(bars) { b in
            BarMark(x: .value("Return", "\(Int(b.rate))%"), y: .value("Years to double", b.years))
                .foregroundStyle(b.rate == 6 ? Theme.primary : Theme.slate.opacity(0.7))
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text("\(Int(d)) yrs") } } } }
        .frame(height: 180)
    }
}

struct CoastFireTimelineChart: View {
    private struct Point: Identifiable { var id: Int { age }; let age: Int; let balance: Double; let coastTarget: Double }

    private var points: [Point] {
        let coast = 400_000.0
        return (25...55).map { age in
            let yrs = age - 25
            let bal = 50_000 * pow(1.06, Double(yrs)) + 15_000 * ((pow(1.06, Double(yrs)) - 1) / 0.06)
            return Point(age: age, balance: bal, coastTarget: coast)
        }
    }

    var body: some View {
        Chart {
            ForEach(points) { p in
                LineMark(x: .value("Age", p.age), y: .value("Balance", p.balance)).foregroundStyle(Theme.primary)
            }
            RuleMark(y: .value("Coast FIRE", 400_000)).foregroundStyle(Theme.ochre).lineStyle(StrokeStyle(dash: [5, 4]))
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct LeanVsFatFireChart: View {
    private struct Bar: Identifiable { var id: String { style }; let style: String; let spend: Double; let fireNumber: Double }

    private let bars: [Bar] = [
        Bar(style: "Lean", spend: 40_000, fireNumber: 40_000 / 0.035),
        Bar(style: "Regular", spend: 75_000, fireNumber: 75_000 / 0.035),
        Bar(style: "Fat", spend: 120_000, fireNumber: 120_000 / 0.035),
    ]

    var body: some View {
        Chart(bars) { b in
            BarMark(x: .value("Style", b.style), y: .value("FIRE #", b.fireNumber))
                .foregroundStyle(by: .value("Style", b.style))
        }
        .chartForegroundStyleScale(["Lean": Theme.slate, "Regular": Theme.primary, "Fat": Theme.ochre])
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct IncomeVsExpenseEducationChart: View {
    private struct Point: Identifiable { var id: Int { year }; let year: Int; let income: Double; let expenses: Double }

    private var points: [Point] {
        (0...20).map { y in
            let inc = 160_000 * pow(1.04, Double(y)) * 0.72
            let exp = 96_000 * pow(1.025, Double(y))
            return Point(year: y, income: inc, expenses: exp)
        }
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Year", p.year), y: .value("Income", p.income)).foregroundStyle(Theme.primary)
            LineMark(x: .value("Year", p.year), y: .value("Expenses", p.expenses)).foregroundStyle(Theme.brick)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct PortfolioDrawdownChart: View {
    private struct Point: Identifiable { var id: Int { month }; let month: Int; let balance: Double }

    private var points: [Point] {
        var bal = 1_000_000.0
        let shocks: [Double] = Array(repeating: -0.02, count: 6) + [-0.35] + Array(repeating: 0.03, count: 30)
        var out: [Point] = [Point(month: 0, balance: bal)]
        for (i, r) in shocks.enumerated() {
            bal *= (1 + r)
            out.append(Point(month: i + 1, balance: bal))
        }
        return out
    }

    var body: some View {
        Chart(points) { p in
            AreaMark(x: .value("Month", p.month), y: .value("Balance", p.balance))
                .foregroundStyle(Theme.brick.opacity(0.2))
            LineMark(x: .value("Month", p.month), y: .value("Balance", p.balance))
                .foregroundStyle(Theme.brick)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct FireNumberMultiplierChart: View {
    let annualExpenses: Double

    private struct Point: Identifiable { var id: String { label }; let label: String; let multiplier: Double; let amount: Double }

    private var points: [Point] {
        [("25× (4%)", 25.0), ("28.6× (3.5%)", 28.6), ("33× (3%)", 33.0), ("40× (2.5%)", 40.0)]
            .map { Point(label: $0.0, multiplier: $0.1, amount: annualExpenses * $0.1) }
    }

    var body: some View {
        Chart(points) { p in
            BarMark(x: .value("Rule", p.label), y: .value("FIRE #", p.amount))
                .foregroundStyle(p.label.contains("3.5") ? Theme.primary : Theme.slate.opacity(0.7))
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 200)
    }
}

struct ChildcareCostCurveChart: View {
    private struct Point: Identifiable { var id: Int { year }; let year: Int; let cost: Double }

    private var points: [Point] {
        (0...15).map { y in
            let active = y < 12
            let cost = active ? 700.0 * 1 * 12 * pow(1.025, Double(y)) : 0
            return Point(year: y, cost: cost)
        }
    }

    var body: some View {
        Chart(points) { p in
            AreaMark(x: .value("Year", p.year), y: .value("Cost", p.cost))
                .foregroundStyle(Theme.ochre.opacity(0.5))
            LineMark(x: .value("Year", p.year), y: .value("Cost", p.cost))
                .foregroundStyle(Theme.ochre)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 180)
    }
}

struct RaiseImpactChart: View {
    private struct Point: Identifiable { var id: Double { rate }; let rate: Double; let savings: Double }

    private var points: [Point] {
        [0, 2, 4, 6, 8, 10].map { r in
            let income = 160_000 * pow(1 + r / 100, 10)
            let takeHome = income * 0.72
            let expenses = 8_000 * 12.0
            return Point(rate: r, savings: takeHome - expenses)
        }
    }

    var body: some View {
        Chart(points) { p in
            BarMark(x: .value("Raise %", "\(Int(p.rate))%"), y: .value("Annual savings", p.savings))
                .foregroundStyle(p.rate == 4 ? Theme.primary : Theme.slate.opacity(0.7))
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 180)
    }
}

struct PromoBumpImpactChart: View {
    private struct Point: Identifiable { var id: Int { cycle }; let cycle: Int; let income: Double }

    private var points: [Point] {
        var income = 160_000.0
        return (0...6).map { c in
            let result = income
            if c > 0 { income *= 1.12; income *= pow(1.04, Double(3)) }
            return Point(cycle: c, income: result)
        }
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Cycle", p.cycle), y: .value("Income", p.income))
                .foregroundStyle(Theme.primary)
            PointMark(x: .value("Cycle", p.cycle), y: .value("Income", p.income))
                .foregroundStyle(Theme.ochre)
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 180)
    }
}

struct InflationAdjustedSpendChart: View {
    private struct Point: Identifiable { var id: Int { year }; let year: Int; let nominal: Double; let real: Double }

    private var points: [Point] {
        let base = 75_000.0
        return (0...30).map { y in
            let nom = base * pow(1.025, Double(y))
            return Point(year: y, nominal: nom, real: base)
        }
    }

    var body: some View {
        Chart(points) { p in
            LineMark(x: .value("Year", p.year), y: .value("Nominal", p.nominal)).foregroundStyle(Theme.brick)
            RuleMark(y: .value("Real", p.real)).foregroundStyle(Theme.primary).lineStyle(StrokeStyle(dash: [4, 3]))
        }
        .chartYAxis { AxisMarks { v in AxisGridLine(); AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.moneyK(d)) } } } }
        .frame(height: 180)
    }
}
