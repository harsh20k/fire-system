import Foundation

/// One year of the simulated portfolio path.
struct YearPoint: Identifiable, Equatable {
    var id: Double { age }
    let year: Int
    let age: Double
    let nominalBalance: Double
    /// Balance expressed in today's dollars (nominal discounted by cumulative inflation).
    let realBalance: Double
    let nominalContribution: Double
    let pensionIncomeAnnual: Double
}

/// Aggregate results for the current `FireInputs`, recomputed on every change.
struct FireResults: Equatable {
    var downPayment: Double = 0
    var monthlyMortgagePayment: Double = 0
    var needsMonthly: Double = 0
    var wantsMonthly: Double = 0
    var totalMonthlyExpenses: Double = 0
    var workingExpensesAnnual: Double = 0
    var currentTakeHome: Double = 0
    var currentMonthlySavings: Double = 0
    var marginalTaxRate: Double = 0

    /// FIRE number in nominal dollars at the projected retirement year.
    var fireNumberNominal: Double = 0
    /// FIRE number restated in today's purchasing power.
    var fireNumberReal: Double = 0

    var fireAge: Double? = nil
    var yearsToFire: Int? = nil
    var path: [YearPoint] = []

    var displayedFireNumber: Double { 0 } // overwritten by engine call site with real/nominal choice
}

enum FireCalculationEngine {

    /// Simple progressive-bracket approximation of combined federal + Nova Scotia tax,
    /// used instead of the flat 32% deduction from the original prototype.
    /// Bracket thresholds/rates approximate 2026 combined NS + federal marginal rates cited in the
    /// research report (23.79% -> 54%).
    ///
    /// Returns the household's EFFECTIVE (blended) tax rate — not a marginal rate. Income is
    /// split evenly between two earners; tax is computed per bracket segment on each partner's
    /// share, doubled for the household, then expressed as a fraction of total household income.
    static func estimatedTaxRate(householdIncome: Double) -> Double {
        guard householdIncome > 0 else { return 0 }
        let perPerson = householdIncome / 2
        let brackets: [(threshold: Double, rate: Double)] = [
            (0, 0.24),
            (55_000, 0.30),
            (80_000, 0.358),
            (110_000, 0.38),
            (150_000, 0.415),
            (220_000, 0.47),
            (300_000, 0.54),
        ]
        var taxPerPerson = 0.0
        for (index, bracket) in brackets.enumerated() {
            guard perPerson > bracket.threshold else { break }
            let nextThreshold = index + 1 < brackets.count ? brackets[index + 1].threshold : Double.infinity
            let segmentIncome = min(perPerson, nextThreshold) - bracket.threshold
            taxPerPerson += segmentIncome * bracket.rate
        }
        let totalTax = taxPerPerson * 2
        return totalTax / householdIncome
    }

    static func mortgage(inputs: FireInputs) -> (downPayment: Double, monthlyPayment: Double, principal: Double) {
        let downPayment = inputs.homePrice * (inputs.downPct / 100)
        let principal = inputs.homePrice - downPayment
        let mRate = inputs.mortgageRate / 100 / 12
        let n = inputs.amort * 12
        let monthlyPayment: Double
        if mRate == 0 {
            monthlyPayment = principal / n
        } else {
            monthlyPayment = (principal * mRate) / (1 - pow(1 + mRate, -n))
        }
        return (downPayment, monthlyPayment, principal)
    }

    /// Monthly needs/wants expenses at a given number of years from today, inflated by `inflationRate`.
    /// Childcare drops to zero once the (oldest-proxy) kid ages out at `childcareEndAge`.
    static func livingExpenses(inputs: FireInputs, yearsFromNow: Int) -> (needs: Double, wants: Double) {
        let inflationFactor = pow(1 + inputs.inflationRate / 100, Double(yearsFromNow))

        let childKidAge = inputs.age + Double(yearsFromNow) // proxy: treat as elapsed time vs childcare window
        let childcareActive = inputs.kids > 0 && Double(yearsFromNow) < inputs.childcareEndAge
        let childcareMonthly = childcareActive ? inputs.kids * inputs.childcarePerKid : 0
        _ = childKidAge

        let baseNeeds = inputs.groceries + inputs.utilities + inputs.internetPhone
            + inputs.numCars * inputs.costPerCar + inputs.rideshare + inputs.medicine
            + inputs.personalCare + inputs.subscriptions
        let needs = (baseNeeds + childcareMonthly) * inflationFactor

        let baseWants = inputs.eatingOut + inputs.shoppingTech + inputs.entertainment
        let wants = baseWants * inflationFactor

        return (needs, wants)
    }

    /// Combined monthly CPP+OAS pension income available at a given age, per the bridge model.
    static func pensionIncomeMonthly(inputs: FireInputs, age: Double) -> Double {
        guard inputs.pensionBridgeEnabled else { return 0 }
        var total = 0.0
        if age >= inputs.cppStartAge { total += inputs.cppMonthlyCombined }
        if age >= inputs.oasStartAge { total += inputs.oasMonthlyCombined * inputs.oasResidencyFactor }
        return total
    }

    static func compute(inputs: FireInputs) -> FireResults {
        var results = FireResults()

        let (downPayment, monthlyPayment, _) = mortgage(inputs: inputs)
        results.downPayment = downPayment
        results.monthlyMortgagePayment = monthlyPayment

        let buyYear = Int(inputs.homeBuyYearsFromNow.rounded())
        let mortgageStartYear = buyYear == 0 ? 1 : buyYear
        let mortgageEndYear = mortgageStartYear + Int(inputs.amort) - 1

        let (needs0, wants0) = livingExpenses(inputs: inputs, yearsFromNow: 0)
        results.needsMonthly = needs0
        results.wantsMonthly = wants0
        let currentMortgage = buyYear == 0 ? monthlyPayment : 0
        results.totalMonthlyExpenses = currentMortgage + needs0 + wants0
        results.workingExpensesAnnual = results.totalMonthlyExpenses * 12

        let taxRate = estimatedTaxRate(householdIncome: inputs.income)
        results.marginalTaxRate = taxRate
        let takeHomeFraction = 1 - taxRate
        results.currentTakeHome = inputs.income * takeHomeFraction
        results.currentMonthlySavings = results.currentTakeHome / 12 - results.totalMonthlyExpenses

        // FIRE number: retirement spend net of any pension bridge income, divided by withdrawal rate.
        let retirementAnnualPensionAtStart = pensionIncomeMonthly(inputs: inputs, age: inputs.age) * 12
        let netExpenseForPortfolio = max(0, inputs.annualExpenses - retirementAnnualPensionAtStart)
        results.fireNumberNominal = netExpenseForPortfolio / (inputs.withdrawalRate / 100)
        results.fireNumberReal = results.fireNumberNominal // updated per-year below once fireAge is known

        var currentIncome = inputs.income
        var balance = buyYear == 0 ? max(0, inputs.savings - downPayment) : inputs.savings
        var years = 0
        var path: [YearPoint] = [YearPoint(year: 0, age: inputs.age, nominalBalance: balance, realBalance: balance, nominalContribution: 0, pensionIncomeAnnual: 0)]

        var fireYear: Int? = nil
        let maxYears = 60

        while years < maxYears {
            years += 1
            if years == buyYear, buyYear > 0 {
                balance = max(0, balance - downPayment)
            }
            currentIncome *= 1 + inputs.raisePct / 100
            if inputs.promoCycle > 0, Int(inputs.promoCycle) > 0, years % Int(inputs.promoCycle) == 0 {
                currentIncome *= 1 + inputs.promoBumpPct / 100
            }
            let yearTaxRate = estimatedTaxRate(householdIncome: currentIncome)
            let takeHome = currentIncome * (1 - yearTaxRate)

            let (needsY, wantsY) = livingExpenses(inputs: inputs, yearsFromNow: years)
            let mortgageStillActive = years >= mortgageStartYear && years <= mortgageEndYear
            let annualMortgage = mortgageStillActive ? monthlyPayment * 12 : 0
            let workingExpensesThisYear = (needsY + wantsY) * 12 + annualMortgage

            let investable = max(0, takeHome - workingExpensesThisYear)
            balance = balance * (1 + inputs.growthRate / 100) + investable

            let ageThisYear = inputs.age + Double(years)
            let inflationFactor = pow(1 + inputs.inflationRate / 100, Double(years))
            let realBalance = balance / inflationFactor
            let pensionAnnual = pensionIncomeMonthly(inputs: inputs, age: ageThisYear) * 12

            path.append(YearPoint(year: years, age: ageThisYear, nominalBalance: balance, realBalance: realBalance, nominalContribution: investable, pensionIncomeAnnual: pensionAnnual))

            // Recompute the FIRE number at this year: pension income reduces the required portfolio draw.
            let netExpenseThisYear = max(0, inputs.annualExpenses * inflationFactor - pensionAnnual)
            let fireNumberThisYear = netExpenseThisYear / (inputs.withdrawalRate / 100)

            if fireYear == nil, balance >= fireNumberThisYear {
                fireYear = years
                results.fireNumberNominal = fireNumberThisYear
                results.fireNumberReal = fireNumberThisYear / inflationFactor
            }
        }

        results.path = path
        if let fy = fireYear {
            results.fireAge = inputs.age + Double(fy)
            results.yearsToFire = fy
        } else {
            results.fireAge = nil
            results.yearsToFire = nil
        }

        return results
    }
}
