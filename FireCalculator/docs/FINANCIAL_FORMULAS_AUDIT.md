# Financial Formulas Audit

**App:** FireCalculator (Swift)  
**Primary engine:** `FireCalculationEngine.swift`  
**Inputs model:** `FireInputs.swift`  
**Last audited:** 2026-07-07  

This document is the source of truth for how the app calculates FIRE, mortgages, taxes, expenses, inflation, and the CPP/OAS pension bridge.

---

## 1. Architecture Overview

```
FireInputs (user sliders)
       │
       ▼
FireCalculationEngine.compute(inputs:)
       │
       ├── estimatedTaxRate()      → effective household tax rate
       ├── mortgage()              → down payment, monthly P&I
       ├── livingExpenses()        → inflated needs + wants (+ childcare)
       ├── pensionIncomeMonthly()  → CPP + OAS at a given age
       └── year-by-year simulation → FireResults (path, FIRE age, FIRE number)
```

**Recompute trigger:** `AppStore.inputs` `didSet` calls `recompute()` on every slider change.

**Currency:** CAD (`Fmt.currency` uses `en_CA` locale).

**Simulation horizon:** 60 years (`maxYears = 60`). If portfolio never crosses the dynamic FIRE threshold within 60 years, `fireAge` and `yearsToFire` are `nil`.

---

## 2. Input Fields & Ranges

| Category | Field | Default | Range | Unit |
|----------|-------|---------|-------|------|
| Household | `age` | 33 | 25–55 | years |
| | `savings` | $20,000 | $0–$200k | CAD |
| | `income` | $160,000 | $60k–$300k | CAD/yr gross |
| | `raisePct` | 4% | 0–10% | %/yr |
| | `promoBumpPct` | 12% | 0–30% | % one-time |
| | `promoCycle` | 3 | 1–6 | years |
| | `kids` | 1 | 0–3 | count |
| | `childcareEndAge` | 12 | 0–16 | **years from now** (misnamed — see §10) |
| Needs | `groceries` … `subscriptions` | various | per slider | CAD/mo |
| | `childcarePerKid` | $700 | $0–$1,500 | CAD/mo per kid |
| Wants | `eatingOut` … `entertainment` | various | per slider | CAD/mo |
| Home | `homeBuyYearsFromNow` | 0 | 0–15 | years (0 = now) |
| | `homePrice` | $600,000 | $400k–$1M | CAD |
| | `downPct` | 10% | 5–35% | % of price |
| | `mortgageRate` | 4.6% | 2–8% | % APR |
| | `amort` | 25 | 15–30 | years |
| Target | `growthRate` | 6% | 2–10% | %/yr portfolio return |
| | `withdrawalRate` | 3.5% | 2.5–5% | % of portfolio/yr |
| | `annualExpenses` | $75,000 | $40k–$150k | CAD/yr in **today's dollars** |
| | `inflationRate` | 2.5% | 0–6% | %/yr CPI |
| | `showRealDollars` | true | bool | display toggle |
| Pension | `pensionBridgeEnabled` | true | bool | |
| | `cppMonthlyCombined` | $1,850 | $0–$3,000 | CAD/mo |
| | `cppStartAge` | 60 | — | years |
| | `oasMonthlyCombined` | $1,250 | $0–$1,600 | CAD/mo (pre-residency factor) |
| | `oasStartAge` | 65 | — | years |
| | `oasResidencyFactor` | 0.83 | 0–1 | fraction of full OAS |

---

## 3. Formula Reference

### 3.1 Mortgage (standard amortizing loan)

**Location:** `FireCalculationEngine.mortgage(inputs:)`

**Inputs:** `homePrice`, `downPct`, `mortgageRate`, `amort`

**Outputs:**
- `downPayment = homePrice × (downPct / 100)`
- `principal = homePrice − downPayment`
- `monthlyPayment` via standard fixed-rate amortization:

```
mRate = mortgageRate / 100 / 12
n     = amort × 12

if mRate == 0:
    monthlyPayment = principal / n
else:
    monthlyPayment = (principal × mRate) / (1 − (1 + mRate)^(−n))
```

**Mathematical correctness:** ✅ Standard PMT formula for fixed-rate, fully amortizing loans.

**Assumptions:**
- Payment is constant (nominal dollars) for the life of the loan.
- No property tax, insurance, CMHC, or maintenance in the mortgage line item.
- No refinancing or rate changes.
- Interest is not tax-deductible (appropriate for Canadian primary residence).

**Edge cases:**
- `mRate == 0`: falls back to straight-line principal repayment. ✅
- `amort` is a `Double` but cast to `Int` for month count — fractional years truncate. ⚠️

---

### 3.2 Progressive income tax (Nova Scotia + federal approximation)

**Location:** `FireCalculationEngine.estimatedTaxRate(householdIncome:)`

**Method:**
1. Split household income evenly between two earners: `perPerson = householdIncome / 2`
2. Apply progressive brackets per person (approximate 2026 combined NS + federal **marginal** rates):
   - $0–$55k: 24%
   - $55k–$80k: 30%
   - $80k–$110k: 35.8%
   - $110k–$150k: 38%
   - $150k–$220k: 41.5%
   - $220k–$300k: 47%
   - $300k+: 54%
3. Sum tax for both earners, divide by total household income.

**Output:** Effective (average) tax rate as a fraction ∈ [0, 1].

**Mathematical correctness:** ✅ Bracket math is correct for a piecewise-linear tax function.

**Naming issue:** ⚠️ Stored as `results.marginalTaxRate` and labeled "Est. marginal tax rate" in UI, but the function returns the **effective** (blended) rate, not the marginal rate on the next dollar.

**Assumptions not modeled:**
- No RRSP/TFSA deductions, credits, or dividend/capital-gains preferential rates
- No CPP/EI payroll deductions
- Income split 50/50 regardless of actual earner mix
- Brackets are static (not inflation-indexed over the simulation)
- Tax applied to gross income only (no benefit clawbacks)

**Edge cases:**
- `householdIncome ≤ 0` → returns 0. ✅

---

### 3.3 Living expenses (needs + wants + childcare)

**Location:** `FireCalculationEngine.livingExpenses(inputs:yearsFromNow:)`

**Base needs (today's dollars):**
```
baseNeeds = groceries + utilities + internetPhone
          + numCars × costPerCar + rideshare + medicine
          + personalCare + subscriptions
```

**Childcare:**
```
childcareActive = kids > 0 AND yearsFromNow < childcareEndAge
childcareMonthly = childcareActive ? kids × childcarePerKid : 0
```

**Inflation:**
```
inflationFactor = (1 + inflationRate/100)^yearsFromNow
needs = (baseNeeds + childcareMonthly) × inflationFactor
wants = (eatingOut + shoppingTech + entertainment) × inflationFactor
```

**Mathematical correctness:** ✅ Compound inflation on expense categories.

**Assumptions:**
- All needs/wants inflate at the same `inflationRate`.
- Mortgage payment does **not** inflate (fixed nominal P&I — realistic for fixed-rate loans).
- `childcareEndAge` is interpreted as **years from today** until childcare ends (UI label confirms this; field name is misleading).

**Edge cases:**
- `kids == 0`: childcare always zero. ✅
- `inflationRate == 0`: factor = 1. ✅

---

### 3.4 Take-home pay & current savings rate

**Location:** `FireCalculationEngine.compute()` (initial snapshot)

```
taxRate = estimatedTaxRate(householdIncome: income)
currentTakeHome = income × (1 − taxRate)
totalMonthlyExpenses = currentMortgage + needs₀ + wants₀
currentMonthlySavings = currentTakeHome / 12 − totalMonthlyExpenses
```

Where `currentMortgage = monthlyPayment` if `homeBuyYearsFromNow == 0`, else `0`.

**Savings rate (UI):** `currentMonthlySavings / (currentTakeHome / 12) × 100`

**Mathematical correctness:** ✅ Arithmetic is consistent.

**Inconsistency:** ⚠️ `annualExpenses` (retirement spend target) is a **separate slider** and is **not** derived from needs + wants. Working-phase expenses use the detailed breakdown; retirement/FIRE math uses `annualExpenses`.

---

### 3.5 FIRE number (portfolio target)

**Location:** `FireCalculationEngine.compute()` — initial and per-year during simulation

**Formula:**
```
netExpense = max(0, annualSpend − pensionAnnual)
fireNumber = netExpense / (withdrawalRate / 100)
```

**Initial snapshot** (before simulation):
```
pensionAtStart = pensionIncomeMonthly(age: inputs.age) × 12
netExpenseForPortfolio = max(0, annualExpenses − pensionAtStart)
fireNumberNominal = netExpenseForPortfolio / (withdrawalRate / 100)
```

**Per simulation year `y`:**
```
inflationFactor_y = (1 + inflationRate/100)^y
pensionAnnual_y = pensionIncomeMonthly(age: age + y) × 12
netExpense_y = max(0, annualExpenses × inflationFactor_y − pensionAnnual_y)
fireNumber_y = netExpense_y / (withdrawalRate / 100)
```

**Mathematical correctness:** ✅ Classic "25× rule" variant: `Portfolio = AnnualSpend / SWR`.

**Interpretation:** This is the **4% rule / safe withdrawal rate** framework. At 3.5% SWR, FIRE number ≈ 28.6× net annual spend.

**Assumptions:**
- `annualExpenses` is entered in **today's dollars** and inflated forward each year.
- Pension income is **nominal** (not inflated in the model — treated as fixed monthly amounts).
- Portfolio draw needed = spend minus pension; if pension exceeds spend, draw = 0.
- No sequence-of-returns risk, taxes on withdrawals, or capital gains modeling post-FIRE.
- Home equity is **not** included in portfolio balance or FIRE number.

**Edge cases:**
- `withdrawalRate == 0` would divide by zero — prevented by slider range (min 2.5%). ✅
- Pension exceeds inflated spend → FIRE number = 0 at that age. ✅

---

### 3.6 CPP + OAS pension bridge

**Location:** `FireCalculationEngine.pensionIncomeMonthly(inputs:age:)`

```
if pensionBridgeEnabled:
    total = 0
    if age ≥ cppStartAge: total += cppMonthlyCombined
    if age ≥ oasStartAge: total += oasMonthlyCombined × oasResidencyFactor
    return total
else:
    return 0
```

**Mathematical correctness:** ✅ Simple step-function income model.

**Assumptions:**
- Combined household CPP/OAS amounts are user-entered constants (not earnings-based).
- No OAS clawback at high income.
- No GIS or workplace pension.
- CPP/OAS amounts are not inflation-indexed in the simulation (CRA does index benefits — this understates future real pension value).

---

### 3.7 Year-by-year portfolio simulation

**Location:** `FireCalculationEngine.compute()` main loop

**Initialization (year 0 path point):**
```
buyYear = round(homeBuyYearsFromNow)
balance = buyYear == 0 ? max(0, savings − downPayment) : savings
path[0] = { year: 0, age, balance, realBalance: balance, contribution: 0 }
```

**Each year `years` from 1 to 60:**

1. **Home purchase** (if delayed):
   ```
   if years == buyYear AND buyYear > 0:
       balance = max(0, balance − downPayment)
   ```

2. **Income growth:**
   ```
   currentIncome ×= (1 + raisePct/100)
   if promoCycle > 0 AND years % promoCycle == 0:
       currentIncome ×= (1 + promoBumpPct/100)
   ```

3. **Tax & take-home:**
   ```
   yearTaxRate = estimatedTaxRate(currentIncome)
   takeHome = currentIncome × (1 − yearTaxRate)
   ```

4. **Working expenses:**
   ```
   (needsY, wantsY) = livingExpenses(yearsFromNow: years)
   mortgageActive = years ≥ mortgageStartYear AND years ≤ mortgageEndYear
   annualMortgage = mortgageActive ? monthlyPayment × 12 : 0
   workingExpenses = (needsY + wantsY) × 12 + annualMortgage
   ```

   Where:
   ```
   mortgageStartYear = buyYear == 0 ? 1 : buyYear
   mortgageEndYear   = mortgageStartYear + amort − 1
   ```

5. **Investable surplus & portfolio growth:**
   ```
   investable = max(0, takeHome − workingExpenses)
   balance = balance × (1 + growthRate/100) + investable
   ```

6. **Real balance (display):**
   ```
   realBalance = balance / (1 + inflationRate/100)^years
   ```

7. **FIRE detection:**
   ```
   if fireYear is nil AND balance ≥ fireNumberThisYear:
       fireYear = years
       fireNumberNominal = fireNumberThisYear
       fireNumberReal = fireNumberThisYear / inflationFactor
   ```

**Mathematical correctness:**
- ✅ Compound portfolio growth with annual lump-sum contributions (end-of-year timing).
- ✅ Compound inflation on living expenses.
- ✅ Dynamic FIRE threshold that rises with inflated spend and falls as pension kicks in.

**Timing simplifications (not bugs, but material assumptions):**
- All income, expenses, and contributions are annual aggregates (no monthly cash-flow timing).
- Growth applied to full balance before adding contributions (equivalent to end-of-year contribution).
- Tax brackets do not shift with inflation.
- No separate emergency fund, cash drag, or asset allocation.

---

## 4. Derived UI Metrics

| Metric | Formula | Source |
|--------|---------|--------|
| Down payment | `homePrice × downPct/100` | `mortgage()` |
| Monthly mortgage | PMT formula | `mortgage()` |
| Total monthly expenses | `mortgage? + needs₀ + wants₀` | `compute()` |
| Working expenses annual | `totalMonthly × 12` | `compute()` |
| Savings rate | `monthlySavings / (takeHome/12)` | `HeroSidebar` |
| Displayed FIRE number | `showRealDollars ? fireNumberReal : fireNumberNominal` | `HeroSidebar` |
| FIRE age | `age + fireYear` | `compute()` |

---

## 5. Chart-Specific Logic

### 5.1 Portfolio path chart
Plots `nominalBalance` or `realBalance` vs age, with horizontal rule at FIRE target. Uses same `fireNumberReal/Nominal` as sidebar.

### 5.2 Expense breakdown chart
Pie of `monthlyMortgagePayment`, `needsMonthly`, `wantsMonthly` at year 0.

**Issue:** ⚠️ Always includes full mortgage payment even when `homeBuyYearsFromNow > 0` (home not yet purchased).

### 5.3 Income vs expense chart
Plots annual `nominalContribution` (investable surplus) and `pensionIncomeAnnual` per simulated year.

### 5.4 Pension bridge chart
From FIRE age to FIRE age + 30:
```
pension = pensionIncomeMonthly(age) × 12
portfolioDraw = max(0, annualExpenses − pension)   // today's dollars, NOT inflated
```

**Issue:** ⚠️ Uses static `annualExpenses` without inflation adjustment, inconsistent with the engine's per-year FIRE math.

---

## 6. Edge Cases & Boundary Behavior

| Scenario | Behavior |
|----------|----------|
| Negative monthly savings | `investable = max(0, …)` — portfolio still grows from prior balance × growth rate, but no new contributions |
| Savings < down payment at buy-now | `balance = max(0, savings − downPayment)` — can start at $0 |
| FIRE not reached in 60 years | `fireAge = nil`, sidebar shows "60+" |
| `pensionBridgeEnabled = false` | Full `annualExpenses` must be portfolio-funded |
| `promoCycle = 1` | Promotion bump every year |
| Delayed home purchase | No rent added; mortgage excluded until purchase year |
| Mortgage paid off | Payment drops from expenses after `mortgageEndYear` |

---

## 7. Issues, Inconsistencies & Questionable Assumptions

### 7.1 Confirmed issues / inconsistencies

| ID | Severity | Issue |
|----|----------|-------|
| I-01 | Medium | **`annualExpenses` decoupled from needs+wants.** Working phase uses detailed expense sliders; FIRE target uses a separate `annualExpenses` default ($75k). Users can set contradictory values. |
| I-02 | Low | **`marginalTaxRate` is effective rate.** Naming and UI tooltip say "marginal" but code computes blended effective rate. |
| I-03 | Low | **`childcareEndAge` misnamed.** Field stores years-from-now, not a child's age. Dead code computes `childKidAge` but never uses it. |
| I-04 | Low | **Expense breakdown chart shows mortgage before purchase.** When `homeBuyYearsFromNow > 0`, chart still includes future mortgage in today's pie. |
| I-05 | Low | **Hero sidebar always shows monthly mortgage.** Same as I-04 — shows payment even when not yet owning. |
| I-06 | Medium | **Pension bridge chart ignores inflation.** Post-FIRE draw uses today's `annualExpenses`, unlike engine's inflated spend. |
| I-07 | Low | **Initial FIRE number uses pension at current age.** Pre-simulation `fireNumberNominal` uses `pensionIncomeMonthly(age: inputs.age)`, not pension at projected retirement age. Overwritten once FIRE year is found. |
| I-08 | Info | **No rent modeling for delayed purchase.** Tip text mentions carrying rent in needs/wants, but no dedicated rent field — user must manually include it. |
| I-09 | Info | **CPP/OAS not inflation-indexed.** Real value of pension bridge erodes relative to inflated expenses over long horizons. |
| I-10 | Info | **No post-FIRE decumulation simulation.** Model stops at crossing the threshold; does not verify sustainability over 30+ year retirement. |
| I-11 | Info | **Home equity excluded.** Paid-off home reduces `annualExpenses` assumption but equity is not added to portfolio. |
| I-12 | Info | **buy-now mortgage starts year 1.** `mortgageStartYear = 1` when `buyYear == 0`, but current expenses include mortgage immediately — minor year-0 vs year-1 mismatch in path. |

### 7.2 Formula verification summary

| Formula | Status |
|---------|--------|
| Mortgage PMT | ✅ Correct |
| Compound inflation | ✅ Correct |
| Compound portfolio growth | ✅ Correct (annual, end-of-year contributions) |
| Progressive tax brackets | ✅ Correct math; simplified assumptions |
| Safe withdrawal / FIRE number | ✅ Correct application of SWR |
| Pension bridge offset | ✅ Correct subtraction |
| Savings rate | ✅ Correct |

---

## 8. Concepts Not Modeled

- Dave Ramsey Baby Steps (debt snowball, 15% investing rule) — educational only, not in engine
- Employer RRSP match, contribution limits
- RRSP/TFSA tax-advantaged account mechanics
- Capital gains tax on withdrawal
- Sequence-of-returns risk
- Variable / adjustable-rate mortgages
- Home price appreciation or depreciation
- Life insurance, disability, EI, CPP/EI payroll deductions
- Child age progression (only years-from-now proxy for childcare)
- Geographic tax differences beyond NS approximation
- Part-time work or barista-FIRE income in retirement

---

## 9. File Index

| File | Role |
|------|------|
| `Engine/FireCalculationEngine.swift` | All core financial formulas |
| `Models/FireInputs.swift` | Input defaults, ranges, field metadata |
| `Persistence/AppStore.swift` | Triggers recompute on input change |
| `Engine/Formatting.swift` | CAD display formatting |
| `Views/Components/HeroSidebar.swift` | Savings rate, FIRE display |
| `Views/Charts/PortfolioPathChart.swift` | Balance path visualization |
| `Views/Charts/ExpenseBreakdownChart.swift` | Needs/wants/mortgage pie |
| `Views/Charts/IncomeVsExpenseChart.swift` | Contributions + pension over time |
| `Views/Charts/IncomeVsExpenseChart.swift` (`PensionBridgeChart`) | Post-FIRE funding stack |
| `Export/ReportView.swift` | PDF report (references same results) |

---

## 10. Recommendations (future work)

1. **Link or reconcile `annualExpenses` with needs+wants** — e.g. auto-suggest retirement spend as paid-off-home subset of current expenses.
2. **Rename `marginalTaxRate` → `effectiveTaxRate`** and update UI copy.
3. **Rename `childcareEndAge` → `childcareEndYearsFromNow`** and remove dead `childKidAge` code.
4. **Gate mortgage in breakdown/sidebar** on `homeBuyYearsFromNow == 0` or purchase year reached.
5. **Inflate `annualExpenses` in PensionBridgeChart** to match engine logic.
6. **Inflation-index CPP/OAS** optionally (e.g. same `inflationRate`).

---

*This audit reflects the codebase as of 2026-07-07. Re-run when `FireCalculationEngine.swift` or `FireInputs.swift` change materially.*
