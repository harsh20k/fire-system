#!/usr/bin/env python3
"""Generate EducationContentAllPages.swift — 32 pages × 30 sections."""

from pathlib import Path
import textwrap

OUT = Path(__file__).resolve().parents[1] / "Sources/FireCalculator/Views/Education/EducationContentAllPages.swift"
ACCENTS = {"primary": "Theme.primary", "ochre": "Theme.ochre", "slate": "Theme.slate", "brick": "Theme.brick"}

def esc(s):
    if s is None:
        return None
    return s.replace("\\", "\\\\").replace('"', '\\"')

def subsections(title):
    return [
        (f"{title} — core idea", f"Understanding {title.lower()} helps you set realistic slider values and interpret FIRE age projections. Small assumption changes compound over 20–30 year horizons."),
        (f"{title} — action step", "Revisit this concept when life changes — marriage, kids, home purchase, or promotion. Update inputs and compare new FIRE age to your prior baseline."),
    ]

def sec(title, summary, p1, p2, p3=None, formula=None, app_ref=None, chart=None):
    paras = [p1, p2] + ([p3] if p3 else [])
    return dict(title=title, summary=summary, paragraphs=paras, formula=formula,
                appReference=app_ref, subsections=subsections(title), chart=chart)

# ── Page section builders (30 each) ──────────────────────────────────────────

def page01():
    chart = "incomeVsExpense"
    s = [
        sec("What Is FIRE?", "Financial Independence, Retire Early — save aggressively, invest passively.",
            "FIRE stands for Financial Independence, Retire Early. Practitioners target 25–50%+ savings rates and diversified index funds.",
            "At 4% withdrawal, every $25 invested yields ~$1/year spending power. At this app's 3.5% default, the multiplier is ~28.6×.",
            "FIRE is a spectrum: full retirement, part-time work, or simply refusing bad jobs."),
        sec("Financial Independence Defined", "FI means assets fund your lifestyle without a paycheque.",
            "FI is reached when investment income plus pensions cover annual spending. Employment becomes optional.",
            "Canadian FI often incorporates CPP from 60 and OAS from 65, reducing portfolio requirements.",
            "FI is a net-worth milestone; retiring early is a separate lifestyle decision."),
        sec("The 25× Rule", "Quick estimate: annual spend × 25 at 4% SWR.",
            "$75,000/year spending implies ~$1.875M at 4% or ~$2.14M at 3.5%.",
            "The multiplier equals 1 ÷ SWR: lower rates demand more capital but improve survival odds.",
            "Pension income reduces net spend, shrinking the required portfolio.", "FIRE Number = Net Annual Spend ÷ (SWR / 100)", "Audit §3.5"),
        sec("Canadian FIRE Context", "RRSP/TFSA, CPP/OAS, and housing shape Canadian paths.",
            "Tax-advantaged accounts accelerate accumulation. Vancouver/Toronto housing can consume 40%+ of income.",
            "CPP/OAS provide partial income unlike US plans ignoring Social Security.",
            "Geographic arbitrage — Atlantic Canada, Prairies, or abroad — stretches CAD."),
        sec("Savings Rate Lever", "Savings rate drives timeline more than investment returns.",
            "Raising savings from 20% to 50% can cut a 37-year journey below 17 years at 6% real returns.",
            "Each saved dollar invests plus all future returns — frugality compounds doubly.",
            "Hero sidebar computes savings rate from take-home minus expenses.", None, "Audit §3.4"),
        sec("Timeline Expectations", "Typical FIRE paths span 10–20 focused years.",
            "Age 33, $160k household income, strong savings might reach FI by late 40s depending on spending.",
            "Bear markets add 2–5 years; promotions and side income subtract similar amounts.",
            "Portfolio path chart shows balance vs dynamic FIRE threshold annually."),
        sec("FIRE vs Age 65 Retirement", "Early FIRE means longer portfolio duration.",
            "Traditional retirement leans on CPP/OAS at 65. FIRE front-loads saving for earlier optionality.",
            "40+ year horizons favor 3–3.5% SWR over Trinity's 30-year 4% benchmark.",
            "Healthcare and identity transitions need planning before quitting."),
        sec("Lifestyle Design", "Spend on values; cut waste intentionally.",
            "FIRE asks what you'd do if money weren't the constraint — travel, family, creative work.",
            "Sustainable frugality beats deprivation. Wants sliders model discretionary cuts.",
            "Purpose and community matter as much as spreadsheet precision."),
        sec("Geographic Arbitrage", "Earn high, spend low — domestically or abroad.",
            "Halifax $160k income stretches further than Vancouver's housing-heavy budgets.",
            "Snowbirding to lower-cost countries can reduce annual expenses 30–50%.",
            "Set annual expenses slider to your planned retirement location's cost of living."),
        sec("Healthcare Planning", "No employer plan after early retirement.",
            "Provincial medicare covers basics; dental, vision, Rx often cost $2–5k/adult/year.",
            "Private insurance bridges gaps until 65 with rising premiums.",
            "Include healthcare padding in annual expenses."),
        sec("Common Misconceptions", "FIRE isn't only for tech millionaires.",
            "Teachers, nurses, and tradespeople reach FI via 40–50% savings over 15–20 years.",
            "You need not beat the market — global index funds at 6% nominal are mainstream.",
            "FI means optionality, not mandatory leisure."),
        sec("Mr. Money Mustache", "Blog that mainstreamed aggressive saving.",
            "Pete Adeney retired at 30; framing '$25/year per $625 saved' made compounding concrete.",
            "Emphasizes anti-fragility: skills, community, low fixed costs.",
            "Canadian adaptation: RRSP/TFSA, provincial healthcare, CMHC rules."),
        sec("Choose FI Community", "Podcasts democratized FIRE knowledge.",
            "Choose FI covers index funds, house hacking, and side hustles with transparent case studies.",
            "Community milestones help calibrate realistic timelines vs influencer hype.",
            "Stress-test community stories against your calculator projections."),
        sec("Partial FI Benefits", "Half-FI dramatically reduces financial stress.",
            "At 50% of FIRE number, Barista FIRE with part-time income becomes viable.",
            "Each year-of-expenses saved buffers job loss and economic shocks.",
            "Track % of FIRE number, not just absolute balance."),
        sec("Net Worth Tracking", "Investable assets drive FIRE math.",
            "App portfolio excludes home equity — audit §7.11. Paid-off home lowers expenses, not counted balance.",
            "Monthly tracking catches expense leaks and return shortfalls.",
            "Liabilities subtract; consumer debt delays FI."),
        sec("Budgeting Foundations", "Know needs vs wants before optimizing.",
            "Needs sliders: groceries, utilities, childcare. Wants: dining, shopping, entertainment.",
            "Audit issue I-01: annualExpenses slider is separate from needs+wants sum.",
            "Reconcile both for consistent working vs retirement assumptions."),
        sec("Side Income Streams", "Accelerate FI without cutting essentials.",
            "$10k/year side income at 6% grows to ~$58k in 30 years.",
            "Tax varies: business income fully taxable; eligible dividends get credits.",
            "Promotion bump slider (default 12% every 3 years) models career jumps."),
        sec("4% Rule Connection", "FIRE builds on Bengen and Trinity.",
            "4% initial CPI-adjusted withdrawal survived most 30-year US retirements historically.",
            "Canadian FIRE often uses 3.25–3.5% for 40–50 year horizons.",
            "See pages 03 and 31 for withdrawal rate depth."),
        sec("Market Dependency", "Plans assume ~6–7% nominal long-run equity returns.",
            "Past performance doesn't guarantee future results. Sequence risk near FI date matters.",
            "Global diversification (XEQT, XAW) reduces Canada-only concentration.",
            "Stress-test at 4% growth before committing to early exit."),
        sec("Starting Late", "FIRE after 40 is harder but possible.",
            "Age 45, $200k saved, 40% of $120k income might FI by 58–62.",
            "Catch-up RRSP, downsizing, debt payoff accelerate late starts.",
            "Coast or Barista FIRE adjust expectations pragmatically."),
        sec("Couples and FIRE", "Align goals; plan jointly.",
            "App splits income 50/50 for tax — actual earner mix changes effective rate.",
            "Mismatched spending goals create friction. Set joint annual expense targets.",
            "Spousal RRSP balances future taxable withdrawals."),
        sec("Kids and FIRE", "Children shift timelines via childcare and housing.",
            "Default $700/mo/kid for 12 years materially cuts savings rate.",
            "Many parents pursue Coast FIRE once childcare ends.",
            "Page 28 details childcare cost modeling."),
        sec("Inflation Awareness", "Long horizons require inflating targets.",
            "2.5% inflation doubles nominal costs in ~28 years. FIRE threshold rises in simulation.",
            "Toggle showRealDollars for purchasing-power view.",
            "Pensions not inflation-indexed in app — audit I-09."),
        sec("Tax-Advantaged Accounts", "RRSP and TFSA accelerate wealth.",
            "RRSP defers tax; TFSA growth is permanently tax-free.",
            "App uses single portfolio balance — page 23 for account strategy.",
            "Include employer RRSP match in savings assumptions."),
        sec("Risk Tolerance", "Portfolio volatility must match your stomach.",
            "100% equities historically return more but drop 30–50% in crashes.",
            "Growth rate slider (default 6%) abstracts allocation — page 14.",
            "Near-FI investors often add bonds or cash buffer."),
        sec("Identity Beyond Work", "Build post-FI routines before quitting.",
            "Sudden retirement without hobbies strains mental health and relationships.",
            "Phased exits — sabbatical, 3-day week — ease transition.",
            "Online FI communities provide accountability."),
        sec("When FIRE Isn't Right", "Debt and harmful frugality are warning signs.",
            "Pay 18%+ credit cards before maxing investments (except employer match).",
            "Extreme deprivation is unsustainable. FIRE should expand life.",
            "Love your career? Pursue FI for optionality, not exit."),
        sec("Canadian FI Resources", "Books, Reddit, and local groups.",
            "r/PersonalFinanceCanada, r/financialindependence, ChooseFI episodes.",
            "Millionaire Teacher (Hallam), Quit Like a Millionaire (Leif).",
            "Cross-check with FINANCIAL_FORMULAS_AUDIT.md."),
        sec("Work-Optional Mindset", "Freedom is the prize, not idleness.",
            "Many FI achievers consult, volunteer, or build businesses.",
            "Barista FIRE uses part-time income as bridge.",
            "Success = autonomy, not blank calendar."),
        sec("Using This Calculator", "Turn concepts into personalized projections.",
            "Adjust income, expenses, growth, SWR, pension sliders — each triggers FireCalculationEngine.recompute().",
            "Compare nominal vs real portfolio path. Review pension bridge chart.",
            "Audit doc lists every formula, assumption, and known issue.", None, "Audit §1", chart),
    ]
    assert len(s) == 30
    return s

def page02():
    chart = "compoundGrowth"
    topics = [
        ("What Is Compound Interest?", "Returns earned on prior returns create exponential growth.",
         ["$10,000 at 6% grows to $10,600 year one, then $11,236 year two on the full balance.", "Time in market beats timing for long-term accumulators.", "Reinvested dividends and gains accelerate the curve."]),
        ("Simple vs Compound", "Simple interest is linear; compound is exponential.",
         ["Simple: $10k at 6% earns $600 flat annually. Compound reinvests each year's gain.", "30 years: $10k at 6% compound → $57,435 vs $28,000 simple.", "Bank accounts and investments use compound interest."]),
        ("Compound Growth Formula", "FV = PV × (1 + r)^n for annual compounding.",
         ["$10,000 × 1.06^30 = $57,435 nominal.", "App applies annually: balance × (1 + growthRate/100) + contributions.", "Small r changes produce large n effects."], "Balanceₜ = Balanceₜ₋₁ × (1 + growthRate/100) + Contributions", "Audit §3.7"),
        ("Contributions Plus Growth", "Regular investing supercharges compounding.",
         ["$12,000/year at 6% for 30 years ≈ $1.06M total.", "Early contributions compound longer — front-load when possible.", "Investable surplus from take-home minus expenses feeds the engine."], None, "Audit §3.7"),
        ("Rule of 72", "Years to double ≈ 72 ÷ return rate.",
         ["6% return → double in ~12 years. 8% → 9 years. 4% → 18 years.", "Quick mental math for planning conversations.", "Pair with rule of 115 for tripling."]),
        ("Starting Early", "Extra years multiply outcomes.",
         ["$500/mo from 25–65 beats $1,000/mo from 35–65 at 7%.", "Lost compounding years cannot be recovered.", "Start TFSA/RSP now with whatever you can."]),
        ("Nominal vs Real Returns", "Inflation reduces purchasing power of returns.",
         ["6% nominal − 2.5% inflation ≈ 3.4% real.", "FIRE planning in real dollars avoids overconfidence.", "App computes realBalance = nominal / inflation^years."], None, "Audit §3.7"),
        ("Monthly vs Annual", "More frequent compounding slightly boosts effective rate.",
         ["Monthly 6% nominal ≈ 6.17% effective annual.", "Difference modest over decades.", "App uses annual steps for simplicity."]),
        ("Dividend Reinvestment", "DRIP buys more shares generating more dividends.",
         ["XAW/XEQT distributions in registered accounts compound tax-free.", "Unregistered accounts face annual tax drag.", "Expense ratios reduce net reinvestment — page 25."]),
        ("Inflation Erosion", "Returns must exceed inflation to grow real wealth.",
         ["2.5% CPI halves purchasing power in ~28 years.", "6% portfolio grows nominally but ~3.5% real.", "Living expenses inflate each simulation year."]),
        ("Compound Debt", "Interest on loans compounds against you.",
         ["18% APR doubles unpaid $10k debt in ~4 years.", "Pay high-interest debt before aggressive investing.", "Mortgage interest compounds too but at lower rates."]),
        ("Volatility Drag", "Ups and downs reduce geometric returns.",
         ["−50% drop needs +100% recovery.", "Arithmetic 8% average with volatility yields lower compound result.", "Sequence risk worsens this near retirement — page 15."]),
        ("Tax Drag", "Unregistered gains face annual tax friction.",
         ["RRSP/TFSA shelter compounding.", "Eligible Canadian dividends get tax credit.", "App doesn't model account-level tax."]),
        ("DCA Synergy", "Steady buying compounds through all markets.",
         ["DCA ≈ lump sum on average but builds discipline.", "Paycheque investing automates contribution growth.", "Page 16 covers dollar-cost averaging."]),
        ("Cost of Waiting", "Delay is exponentially expensive.",
         ["Starting at 35 vs 30 costs $200k+ by 65 at typical savings.", "Imperfect start beats perfect delay.", "Update savings slider with current balance honestly."]),
        ("Engine Implementation", "Portfolio compounds each simulation year.",
         ["balance = balance × (1 + growthRate/100) + investable", "Default 6% on entire balance uniformly.", "No asset-class split in engine."], None, "FireCalculationEngine.compute()"),
        ("Return Scenarios", "Stress-test 4%, 6%, 8% growth assumptions.",
         ["$10k, 30yr: 4%→$32k, 6%→$57k, 8%→$101k.", "1% return change can shift FIRE age 2–4 years.", "Conservative planning uses lower bound."]),
        ("Human Capital", "Income and skills also compound.",
         ["4% annual raises double income in 18 years.", "12% promotion bump every 3 years adds step growth.", "Raise and promo sliders model this."], None, "Audit §3.7"),
        ("Frugality Compounds", "Permanent spending cuts replicate return effects.",
         ["$500/mo cut invested at 6% → ~$474k in 30 years.", "One-time savings don't compound; lifestyle changes do.", "Wants sliders reveal discretionary levers."]),
        ("Log-Scale Visualization", "Exponential curves look flat early on linear charts.",
         ["Most wealth arrives in final decade of accumulation.", "Compound growth education chart shows 4/6/8% paths.", "Don't despair slow early progress."]),
        ("Mortgage Compounding", "Borrowers pay compound interest to lenders.",
         ["Early mortgage payments are mostly interest.", "Extra principal payments reduce total interest.", "Page 07 covers PMT amortization."]),
        ("Emergency Fund Tradeoff", "Cash earns little but protects portfolio.",
         ["HISA ~0.5–4% vs 6% portfolio opportunity cost.", "3–6 months expenses prevents forced selling in crashes.", "Page 19 sizes emergency reserves."]),
        ("RESP and Kids", "Government 20% grant boosts child education compounding.",
         ["$2,500/yr contribution captures max $500 CESG.", "Not modeled in app but powerful family tool.", "Teach kids compound interest early."]),
        ("Common Mistakes", "Panic selling, market timing, high fees.",
         ["Cashing out resets compounding clock.", "1% fee drag costs 6 figures over 30 years.", "Stay invested through downturns."]),
        ("Historical Returns", "Global equities averaged 6–9% nominal long-term.",
         ["TSX, US, international cycles vary by decade.", "Diversified global index (XEQT) smooths country risk.", "6% default is reasonable middle estimate."]),
        ("Compound Growth and FIRE Age", "Higher growth shortens years to FI.",
         ["Sensitivity test growth slider 4–8%.", "Returns matter but savings rate matters more early.", "Pair growth assumptions with conservative SWR."]),
        ("Patience", "Behavior determines who captures compound returns.",
         ["Automate contributions; ignore daily noise.", "FIRE is a multi-decade compound interest project.", "Snowball grows slowly then rapidly."]),
        ("TFSA Tax-Free Compounding", "TFSA growth and withdrawals are never taxed.",
         ["$7,000 annual TFSA room (2026) compounds entirely tax-free.", "$7k/year at 6% for 30 years → ~$620,000 with zero tax on withdrawal.", "Prioritize TFSA for flexibility; RRSP for high-income years."]),
        ("RRSP Tax-Deferred Growth", "RRSP compounds pre-tax but withdrawals are taxable.",
         ["$10,000 RRSP contribution at 30% bracket saves $3,000 tax immediately.", "Full balance compounds decades; withdrawals taxed at hopefully lower retirement bracket.", "App doesn't split accounts — model combined portfolio in savings slider."]),
        ("Key Takeaways", "Start early, reinvest, minimize fees, stay invested.",
         ["Compound growth powers FIRE portfolio simulation.", "Audit §3.7 documents year-by-year math.", "Combine with high savings rate for best outcomes."], None, "Audit §3.7", chart),
    ]
    s = []
    for t in topics:
        paras = t[2] if isinstance(t[2], list) else [t[2]]
        formula, app_ref, chart_override = parse_topic_extras(t[3:])
        s.append(sec(t[0], t[1], paras[0], paras[1], paras[2] if len(paras) > 2 else None, formula, app_ref, chart_override))
    assert len(s) == 30
    return s

VALID_CHARTS = {
    "withdrawalRate", "compoundGrowth", "pensionBridge", "inflationErosion", "mortgageAmortization",
    "taxBrackets", "savingsRateImpact", "sequenceOfReturns", "assetAllocation", "debtSnowballComparison",
    "contributionVsGrowth", "trinityStudySWR", "cppStartAge", "oasClawback", "realVsNominal",
    "expenseRatioDrag", "dollarCostAveraging", "monteCarloBands", "ramsey15Percent", "homeEquityBuild",
    "ruleOf72", "coastFireTimeline", "leanVsFatFire", "incomeVsExpense", "portfolioDrawdown",
    "fireNumberMultiplier", "childcareCostCurve", "raiseImpact", "promoBumpImpact", "inflationAdjustedSpend",
}

def parse_topic_extras(extras):
    formula, app_ref, chart_id = None, None, None
    for e in extras:
        if e is None:
            continue
        if isinstance(e, str) and e in VALID_CHARTS:
            chart_id = e
        elif isinstance(e, str) and ("=" in e or "×" in e or "÷" in e):
            formula = e
        elif isinstance(e, str):
            app_ref = e
    return formula, app_ref, chart_id

PAGE_DEFS = [
    ("page03", "safe-withdrawal-rate", "03", "Safe Withdrawal Rate", "Portfolio spending rate in retirement", "percent", "ochre", "withdrawalRate",
     ["What Is SWR?", "4% Rule Origins", "Trinity Study Link", "3.5% for Long Horizons", "Ramsey 5–6% View",
      "Inflation-Adjusted Withdrawals", "Fixed vs Variable Rules", "Guardrails Strategy", "Portfolio at Different SWRs",
      "Pension Reduces Draw", "App Default 3.5%", "Success Rate Tradeoff", "Bear Market Risk", "Bond Tent",
      "Dynamic Spending", "Withdrawal Taxation", "RRIF Minimums", "Barista Income Offset", "Healthcare Inflation",
      "Couple Longevity", "Legacy Goals", "Monte Carlo SWR", "International Retirees", "Rental Income",
      "Dividend-Only Living", "SWR and Allocation", "SWR Criticisms", "Personal SWR Choice", "App FIRE Formula", "SWR Summary"]),
    ("page04", "fire-number", "04", "FIRE Number", "Portfolio target for financial independence", "target", "primary", "fireNumberMultiplier",
     ["What Is the FIRE Number?", "Spend Multiplier Math", "Net Expense After Pension", "Nominal vs Real FIRE Number",
      "Dynamic Threshold", "Inflated Annual Expenses", "Pension Step Functions", "75k Default Spend", "28.6× at 3.5%",
      "Zero FIRE Number", "Withdrawal Rate Sensitivity", "Coast FIRE Number", "Barista Gap Calculation",
      "Lean vs Fat Targets", "Home Paid Off Assumption", "Expense Reconciliation", "Sidebar Display",
      "FIRE Detection Logic", "Never Reaching FIRE", "Real Dollar Toggle", "Pension Bridge Impact",
      "Comparison Across SWRs", "Annual Expenses Slider", "Working vs Retirement Spend", "Childcare Drop-Off",
      "Mortgage Payoff Effect", "Promotion Income Effect", "Conservative Buffers", "Tracking Progress", "FIRE Number Summary"]),
    ("page05", "savings-rate", "05", "Savings Rate", "Fraction of take-home saved monthly", "arrow.up.circle.fill", "brick", "savingsRateImpact",
     ["Savings Rate Defined", "Most Powerful Lever", "20% vs 50% Timeline", "Take-Home Calculation", "Monthly Expense Sum",
      "Needs Plus Wants", "Mortgage in Expenses", "Negative Savings", "Savings Rate Formula", "Hero Sidebar Metric",
      "Income Growth Effect", "Promotion Bump Effect", "Childcare Drag", "One Income Household", "Two Income Advantage",
      "Automating Savings", "Pay Yourself First", "Lifestyle Inflation", "Raise Doesn't Mean Spend",
      "Geographic Savings", "FIRE Community Benchmarks", "50% Challenge", "Incremental Improvements",
      "Tracking Monthly", "Budget Apps vs Sliders", "Tax Refund Investing", "Windfall Rules",
      "Savings Rate and FIRE Age", "Savings Rate Summary", "App §3.4 Reference"]),
    ("page06", "inflation", "06", "Inflation", "CPI erosion of purchasing power", "chart.line.downtrend.xyaxis", "brick", "inflationErosion",
     ["What Is Inflation?", "2.5% App Default", "Compound Inflation Formula", "Rule of 72 for Prices", "Real vs Nominal",
      "Living Expenses Inflate", "Mortgage Doesn't Inflate", "FIRE Number Rises", "Pension Not Indexed", "Audit I-09",
      "Show Real Dollars", "Historical Canadian CPI", "2022 Inflation Spike", "Deflation Rare", "Wage-Price Spiral",
      "TIPS and Real Return Bonds", "Equities as Inflation Hedge", "Cash Loses Value", "Retirement Spending Pad",
      "Healthcare Inflation", "Geographic CPI Differences", "Inflation and SWR", "Bengen CPI Adjustments",
      "Planning Conservatism", "Inflation-Adjusted Income", "Groceries vs Subscriptions", "Long-Run 2–3%",
      "Simulation Horizon 60yr", "Inflation Sensitivity", "Inflation Summary"]),
    ("page07", "mortgage-math", "07", "Mortgage Math", "Fixed-rate PMT amortization", "house.fill", "ochre", "mortgageAmortization",
     ["Canadian Mortgage Basics", "PMT Formula", "Principal and Interest", "Default 4.6% Rate", "25-Year Amortization",
      "Down Payment Impact", "600k Home Default", "Monthly Payment Calc", "Total Interest Paid", "Amortization Schedule",
      "Year 1 Interest Heavy", "Extra Payments", "Zero Rate Edge Case", "Fixed vs Variable", "Not Modeled: Variable",
      "CMHC Insurance", "Property Tax Omitted", "Insurance Omitted", "Mortgage Start Year", "Mortgage End Year",
      "Paid Off Expense Drop", "Rent Not Modeled", "Delayed Purchase", "Balance at Purchase", "Audit §3.1",
      "Mortgage in Expenses", "I-04 Chart Issue", "I-05 Sidebar Issue", "Opportunity Cost", "Mortgage Summary"]),
    ("page08", "down-payment", "08", "Down Payment Strategy", "Cash upfront vs invested opportunity cost", "banknote.fill", "slate", "homeEquityBuild",
     ["Minimum Down Payment", "5% Insured Mortgage", "10% App Default", "20% Avoids CMHC", "Down from Savings",
      "Opportunity Cost", "6% Growth Foregone", "House Price 600k", "60k Down at 10%", "Balance Reduction",
      "Buy Now vs Delay", "homeBuyYearsFromNow", "Saving for Down", "FHSA Account", "Home Buyers Plan RRSP",
      "Gifted Down Payment", "Down vs Invest Debate", "Rent While Saving", "I-08 No Rent Field", "Price Appreciation Omitted",
      "Leverage Argument", "Forced Savings", "Emergency Fund First", "Down Payment Timeline", "Couples Coordination",
      "Regional Price Variance", "Closing Costs", "Land Transfer Tax", "First-Time Buyer Programs", "Down Payment Summary"]),
    ("page09", "canadian-income-tax", "09", "Canadian Income Tax", "Federal and provincial fundamentals", "doc.text.fill", "brick", "taxBrackets",
     ["Progressive Tax System", "Marginal vs Effective", "Federal Brackets 2026", "Provincial Variation", "Nova Scotia Overview",
      "Combined Top Rates", "Basic Personal Amount", "RRSP Deduction", "TFSA No Deduction", "Capital Gains 50%",
      "Dividend Tax Credit", "CPP/EI Payroll", "Not Modeled in App", "Two-Earner Household", "Income Splitting Limits",
      "Tax Refunds", "Installments", "Self-Employment Tax", "Corporate Income", "Trust and Estate",
      "Non-Resident Tax", "US Citizen in Canada", "Tax-Loss Harvesting", "Donation Credits", "Medical Expense Credit",
      "Effective Rate in App", "Take-Home Formula", "Audit §3.2", "Tax Planning FIRE", "Tax Summary"]),
    ("page10", "ns-tax-brackets", "10", "Nova Scotia Tax Brackets", "How this app estimates household tax", "map.fill", "brick", "taxBrackets",
     ["NS + Federal Approximation", "50/50 Income Split", "Per-Person Brackets", "24% First Bracket", "30% 55–80k",
      "35.8% 80–110k", "38% 110–150k", "41.5% 150–220k", "47% 220–300k", "54% Above 300k",
      "160k Household Example", "Effective vs Marginal", "I-02 Naming Issue", "marginalTaxRate Field", "Static Brackets",
      "No Inflation Index", "No Credits Modeled", "No Dividend Preference", "Compare Alberta", "Compare Ontario",
      "Halifax Cost Context", "Dual High Earners", "Single Earner Household", "Tax and Savings Rate", "Tax and FIRE Timeline",
      "EstimatedTaxRate Function", "Take-Home Impact", "Sensitivity to Income", "Audit §3.2 Detail", "NS Tax Summary"]),
    ("page11", "cpp-overview", "11", "CPP Overview", "Canada Pension Plan mechanics", "person.2.fill", "slate", "cppStartAge",
     ["CPP Purpose", "Contribution Years", "YMPE Earnings Cap", "Benefit Calculation", "Combined Household Amount",
      "Default 1850/mo", "Start Age 60–70", "Early Reduction 60", "Delay Increase 70", "cppStartAge Slider",
      "Not Earnings-Based in App", "User-Entered Constant", "Inflation Indexing Real World", "Not Indexed in App",
      "CPP and FIRE Number", "Portfolio Draw Reduction", "Age 60 Step Function", "Work While Collecting", "Post-Retirement Benefit",
      "Survivor Benefits", "CPP Splitting Couples", "Quebec QPP Parallel", "Maximum Benefit 2026", "Average Benefit",
      "Planning Conservative", "CPP Statement of Contributions", "Early Retirement CPP Gap", "CPP Summary", "Audit §3.6", "Chart cppStartAge"]),
    ("page12", "oas-gis", "12", "OAS and GIS", "Old Age Security and supplements", "heart.fill", "ochre", "oasClawback",
     ["OAS Overview", "65 Start Age", "Full OAS Amount", "Residency Requirement", "oasResidencyFactor 0.83",
      "40 Years for Full", "GIS for Low Income", "Not Modeled in App", "OAS Clawback", "Recovery Tax Zone",
      "Clawback Threshold", "High Income Retirees", "OAS Delay to 70", "Combined CPP+OAS", "Default 1250/mo OAS",
      "Pension Bridge at 65", "OAS and FIRE Number", "Inflation Indexed Real World", "Not Indexed in App",
      "GIS vs FIRE Wealth", "OAS for Immigrants", "Proportional OAS", "OAS Statement", "Planning Assumptions",
      "Conservative OAS Estimate", "OAS and Tax", "OAS Summary", "Audit §3.6", "Audit I-09", "Chart oasClawback"]),
    ("page13", "pension-bridge", "13", "Pension Bridge", "Public pensions offset portfolio draw", "bridge.fill", "primary", "pensionBridge",
     ["Bridge Concept", "Portfolio Draw Formula", "max(0, Spend − Pension)", "CPP at 60", "OAS at 65",
      "Combined Default 3100/mo", "FIRE Number Shrinks", "Dynamic Per-Year Threshold", "pensionBridgeEnabled Toggle",
      "Disable for Full Self-Fund", "Step Function Income", "Bridge Chart", "I-06 Chart Inflation", "Engine vs Chart",
      "Post-FIRE Decumulation", "I-10 Not Simulated", "Bridge Years 60–65", "Full Pension After 65",
      "Residency Factor Impact", "Planning Without Bridge", "Conservative Pension Estimates", "Workplace Pension Gap",
      "Bridge and SWR", "Bridge and Lean FIRE", "International Retirement", "Tax on Pension Income",
      "Survivor Planning", "Bridge Summary", "Audit §3.5–3.6", "Audit §5.4"]),
    ("page14", "asset-allocation", "14", "Asset Allocation", "Stocks, bonds, cash diversification", "chart.pie.fill", "slate", "assetAllocation",
     ["Allocation Defined", "Stocks for Growth", "Bonds for Stability", "Cash for Liquidity", "60/40 Classic",
      "100% Equity FIRE", "Age-Based Rules", "Glide Path", "Canadian Couch Potato", "XEQT One-Fund",
      "US/Intl/Canada Split", "Home Bias", "REIT Allocation", "Gold and Alternatives", "Crypto Speculation",
      "Risk Tolerance Quiz", "Rebalancing Annually", "Drift and Bands", "Correlation in Crashes", "Bonds Failed 2022",
      "Allocation and SWR", "Allocation and Growth Slider", "Not Explicit in App", "6% Abstracts Mix",
      "Pre-FIRE Aggressive", "Post-FIRE Conservative", "Bond Tent", "Target Date Funds", "Allocation Summary", "Chart assetAllocation"]),
    ("page15", "sequence-returns", "15", "Sequence of Returns", "Timing of returns near retirement matters", "waveform.path.ecg", "brick", "sequenceOfReturns",
     ["Sequence Risk Defined", "Same Average Different Outcome", "Crash Early Retirement", "Crash Late Accumulation",
      "Bengen on Sequence", "Flexible Retirement Date", "Part-Time Bridge", "Cash Buffer Years", "Bond Tent Strategy",
      "Dynamic Spending Cuts", "Guardrails Approach", "Not Modeled in App", "I-10 No Decumulation", "Historical Crashes",
      "2008 Recovery Time", "2020 V-Shape", "2000 Lost Decade", "Canadian TSX Volatility", "Diversification Helps",
      "Withdrawal Order", "RRSP vs TFSA Sequence", "Working One More Year", "Coast FIRE Mitigation",
      "Monte Carlo View", "Probability of Success", "Safe SWR Lower for Early", "Sequence and Lean FIRE",
      "Sequence Summary", "Audit §8 Not Modeled", "Chart sequenceOfReturns"]),
    ("page16", "dca", "16", "Dollar-Cost Averaging", "Steady investing through market cycles", "calendar", "primary", "dollarCostAveraging",
     ["DCA Defined", "Fixed Amount Regular Intervals", "Lump Sum vs DCA", "Vanguard Study", "Behavioral Advantage",
      "Paycheque Investing", "Automated Transfers", "TFSA Monthly", "RRSP Payroll", "Market Highs and Lows",
      "Buy More Shares Low", "Fewer Shares High", "Average Cost Over Time", "DCA Doesn't Beat Lump Sum", "Reduces Regret",
      "Volatility Benefit", "DCA in Bear Markets", "DCA in Bull Markets", "Engine Annual Lump", "Monthly Not Modeled",
      "DCA and FIRE Timeline", "Starting During Crash", "Stopping DCA Mistake", "Windfall DCA", "Robo-Advisors",
      "Commission-Free ETFs", "DCA Discipline", "DCA Summary", "Pair with High Savings", "Chart dollarCostAveraging"]),
    ("page17", "debt-methods", "17", "Debt Snowball vs Avalanche", "Behavior vs math in debt payoff", "snowflake", "ochre", "debtSnowballComparison",
     ["Snowball Method", "Smallest Balance First", "Avalanche Method", "Highest Rate First", "Interest Savings Avalanche",
      "Motivation Snowball", "Ramsey Prefers Snowball", "Mixed Approach", "Debt Not in App Engine", "Educational Only",
      "Credit Card 18–22%", "Line of Credit 7–9%", "Student Loans", "Car Loans", "Mortgage Lowest Rate",
      "Pay Minimums Plus Extra", "Debt-Free Scream", "Opportunity Cost", "Invest vs Pay Debt", "Emergency Fund First",
      "Debt and FIRE Incompatible", "Snowball Example 3 Cards", "Avalanche Same Example", "Months Saved Avalanche",
      "Psychology of Quick Wins", "When Snowball Wins", "High-Interest First Rule", "Debt Summary", "Audit §8 Ramsey", "Chart debtSnowballComparison"]),
    ("page18", "ramsey-steps", "18", "Ramsey Baby Steps", "Dave Ramsey seven-step plan", "list.number", "ochre", "ramsey15Percent",
     ["Baby Step 1", "$1000 Starter Emergency", "Baby Step 2", "Debt Snowball All Non-Mortgage", "Baby Step 3",
      "3–6 Month Emergency Fund", "Baby Step 4", "Invest 15% Gross", "Baby Step 5", "Kids College",
      "Baby Step 6", "Pay Off Mortgage Early", "Baby Step 7", "Build Wealth and Give", "FIRE vs Ramsey Conflict",
      "15% vs 50% Savings", "4% vs 5–6% SWR", "Growth Mutual Funds", "No Bonds Ramsey", "Behavior Focus",
      "Debt Free Before Invest", "Ramsey Videos in App", "Educational Not Engine", "When Ramsey Helps",
      "When FIRE Helps", "Hybrid Approach", "Gazelle Intensity", "Live Like No One Else", "Ramsey Summary", "Chart ramsey15Percent"]),
    ("page19", "emergency-fund", "19", "Emergency Fund", "Cash before aggressive investing", "shield.fill", "slate", None,
     ["Why Emergency Fund", "3–6 Months Expenses", "Starter $1000 Ramsey", "HISA Rates 2026", "GIC Ladder",
      "Not Separate in App", "Included in Savings Balance", "Job Loss Buffer", "Medical Surprise", "Car Repair",
      "Home Repair", "Avoid Credit Card Relapse", "Opportunity Cost 6%", "Peace of Mind Value", "Dual Income 3 Months",
      "Single Income 6 Months", "Freelancer 12 Months", "FIRE Post-FI Cash", "1–2 Years Bear Buffer",
      "TFSA Emergency?", "Non-Registered HISA", "Avoid Market Risk", "Replenish After Use", "Emergency vs Down Payment",
      "Emergency Fund Order", "After Debt Before Invest", "High-Yield Savings Accounts", "Emergency Summary", "Audit Not Modeled", "Size for Your Sliders"]),
    ("page20", "coast-fire", "20", "Coast FIRE", "Stop contributing; let portfolio coast to target", "sailboat.fill", "primary", "coastFireTimeline",
     ["Coast FIRE Defined", "Enough Invested to Reach FI", "No More Contributions Needed", "Compound to Full FIRE",
      "Coast Number Math", "Lower Than Full FIRE", "Career Flexibility", "Part-Time OK", "Cover Current Expenses Only",
      "Portfolio Grows Alone", "Age Calculator", "Coast vs Barista", "Coast vs Traditional", "Kids Trigger Coast",
      "Childcare Ends Coast", "6% Growth Assumption", "Timeline Visualization", "Psychological Relief", "One Spouse Coasts",
      "Risk If Returns Low", "Sequence During Coast", "Recalculate Annually", "Coast in This App", "Approximate with Sliders",
      "Coast FIRE Community", "Coast Number Example", "Coast Summary", "Chart coastFireTimeline", "Pair with Pension Bridge", "Coast Action Plan"]),
    ("page21", "barista-fire", "21", "Barista FIRE", "Part-time work covers spending gap", "cup.and.saucer.fill", "ochre", "incomeVsExpense",
     ["Barista FIRE Defined", "Portfolio Covers Most Expenses", "Part-Time Covers Gap", "Named for Starbucks Jobs",
      "Healthcare via Employer", "Social Engagement", "Lower Portfolio Target", "Half FIRE Number", "Flexible Hours",
      "Consulting Variant", "Seasonal Work", "Rental Income Variant", "Not Modeled in Engine", "Educational Concept",
      "Calculate Gap", "Annual Expenses Minus Portfolio×SWR", "Hours Needed", "$25/hr Example", "Tax on Part-Time",
      "CPP Contributions Continue", "Barista vs Coast", "Barista vs Lean FIRE", "Transition Strategy",
      "Employer Benefits Value", "Reduced Portfolio Target Math",
      "Barista Summary", "Income vs Expense Chart", "Audit §8 Not Modeled", "Canadian Part-Time", "Barista Action Plan"]),
    ("page22", "lean-fat-fire", "22", "Lean vs Fat FIRE", "Spending level defines FIRE style", "scalemass.fill", "brick", "leanVsFatFire",
     ["Lean FIRE", "Minimalist Spending", "Fat FIRE", "Comfortable Lifestyle", "40k vs 100k Examples",
      "Lean Risks", "Healthcare Padding", "Fat Buffer", "Geographic Lean", "Fat in HCOL",
      "Lean FIRE Number", "Fat FIRE Number", "Barista Lean Combo", "Lean Community", "Fat Flexibility",
      "Annual Expenses Slider", "75k Default Middle", "Wants Reduction Lean", "Travel Budget Fat", "Lean Social Pressure",
      "Fat Lifestyle Creep", "Choose Your Number", "Couple Agreement", "Kids Change Lean", "Lean Summary",
      "Fat Summary", "Chart leanVsFatFire", "Audit §3.5 Spend", "Sensitivity Test", "Lean vs Fat Decision"]),
    ("page23", "rrsp-tfsa", "23", "RRSP and TFSA", "Canadian tax-advantaged accounts", "lock.shield.fill", "slate", "contributionVsGrowth",
     ["RRSP Overview", "Tax Deduction Now", "Taxed on Withdrawal", "TFSA Overview", "Tax-Free Forever",
      "2026 Limits", "RRSP 18% Income", "TFSA $7000 Room", "Employer Match", "Spousal RRSP",
      "RRSP Home Buyers Plan", "FHSA Hybrid", "Withdrawal Order FIRE", "TFSA First Flexible", "RRSP Low Bracket",
      "RRIF at 71", "OAS Clawback RRSP", "Not Modeled in App", "Single Portfolio Balance", "Location Optimization",
      "Canadian Equity RRSP", "US Equity RRSP", "Bonds TFSA", "Asset Location", "Contribution Room Tracking",
      "Over-Contribution Penalty", "RRSP/TFSA Summary", "Audit §8 Not Modeled", "Chart contributionVsGrowth", "Account Strategy Plan"]),
    ("page24", "real-nominal", "24", "Real vs Nominal Dollars", "Today's purchasing power vs face value", "dollarsign.arrow.circlepath", "brick", "realVsNominal",
     ["Nominal Dollars", "Face Value Amounts", "Real Dollars", "Inflation-Adjusted", "showRealDollars Toggle",
      "realBalance Formula", "nominal / inflation^years", "FIRE Number Real", "FIRE Number Nominal", "Sidebar Display",
      "Planning in Real", "Avoids Confusion", "Historical Context", "$1M in 2055", "2.5% Default Inflation",
      "CPI vs Personal Inflation", "Groceries vs Tech Deflation", "Wages Nominal Rise", "Pension Nominal Fixed App",
      "Compare Apples to Apples", "Real Returns", "Nominal Returns", "Chart realVsNominal", "Audit §3.7",
      "Investor Psychology", "Nominal Feels Richer", "Real Shows Truth", "Toggle Experiment", "FIRE Target in Real Terms", "Real vs Nominal Summary"]),
    ("page25", "expense-ratios", "25", "Expense Ratios", "Fund fees drag compound growth", "minus.circle.fill", "slate", "expenseRatioDrag",
     ["MER Defined", "Management Expense Ratio", "0.05% vs 1.5%", "XEQT 0.20%", "VGRO Similar",
      "1% Fee Costs", "$100k Over 30 Years", "Compound Fee Drag", "Active vs Passive", "Advisor Fees Add",
      "1% Advisor + 1% Fund", "Hidden Costs", "Trading Expenses", "HST on MER", "ETF Bid-Ask",
      "Low-Cost FIRE Standard", "Vanguard Principle", "Fee Compounding Math", "Not in App Growth Slider",
      "Reduce Assumed Return", "0.5% MER → 5.5% Net", "Compare Fund Facts", "Switching Costs", "Tax on Switches",
      "All-In-One ETF MER", "Expense Ratio Summary", "Chart expenseRatioDrag", "Audit Growth Abstract", "FIRE Fee Awareness", "Action: Check MER"]),
    ("page26", "home-equity", "26", "Home Equity", "Property wealth vs liquid portfolio", "building.2.fill", "ochre", "homeEquityBuild",
     ["Equity Defined", "Home Value Minus Mortgage", "Excluded from Portfolio", "Audit §7.11", "Paid Off Reduces Expenses",
      "Not in FIRE Number", "Sell to Invest Option", "HELOC Borrowing", "Downsizing Strategy", "Rent After Sell",
      "Price Appreciation Omitted", "600k Default Price", "10% Down Default", "Equity Build Schedule", "Amortization Principal",
      "Home as Forced Savings", "Illiquidity Risk", "Concentration Risk", "Halifax Market Context", "Maintenance 1%/yr",
      "Property Tax Omitted", "Insurance Omitted", "Equity vs Renting", "FIRE Rent Assumption", "I-08 Manual Rent",
      "Home Equity Summary", "Chart homeEquityBuild", "Audit §3.1", "Don't Count Equity in FI", "Housing Decision Framework"]),
    ("page27", "income-growth", "27", "Income Growth", "Raises and promotions compound savings", "chart.bar.fill", "primary", "raiseImpact",
     ["raisePct Default 4%", "Annual Compound Raise", "promoBumpPct 12%", "promoCycle 3 Years", "Income in Engine",
      "Tax Bracket Climb", "Marginal vs Effective", "Lifestyle Inflation Trap", "Save the Raise", "Promotion Timing",
      "Career Plateau", "Side Income Addition", "Dual Income Growth", "160k Starting Household", "Income Doubles 18yr 4%",
      "Savings Rate Rises If Spend Flat", "FIRE Age Sensitivity", "Skills Investment", "Certifications ROI", "Job Change Bumps",
      "Negotiation Importance", "Union COLA", "Inflation Match Raise", "Real Raise Calculation", "Income Growth Summary",
      "Chart raiseImpact", "Chart promoBumpImpact", "Audit §3.7", "Model Your Career", "Income Action Plan"]),
    ("page28", "childcare-costs", "28", "Childcare Costs", "Family expenses in accumulation phase", "figure.and.child.holdinghands", "brick", "childcareCostCurve",
     ["childcarePerKid 700/mo", "kids Slider 0–3", "childcareEndAge Years", "Misnamed Field I-03", "12 Years Default",
      "8400/yr Per Child", "Halifax Daycare Range", "Toronto Higher 1500+", "School Age Drop", "Activities Replace Care",
      "Inflation on Childcare", "livingExpenses Function", "Savings Rate Impact", "One vs Two Kids", "Parental Leave Gap",
      "Stay Home Tradeoff", "Grandparent Care", "Subsidized Programs", "Camp Costs Summer", "University Later",
      "RESP Planning", "FIRE Timeline Extension", "Coast After School", "Childcare Curve Chart", "Audit §3.3",
      "Dead childKidAge Code", "Rename Recommendation", "Childcare Summary", "Adjust kids Slider", "Family Planning Note"]),
    ("page29", "withdrawal-strategies", "29", "Withdrawal Strategies", "Decumulation beyond flat SWR", "arrow.down.circle.fill", "primary", "portfolioDrawdown",
     ["Flat SWR App Default", "Variable Percentage", "Guardrails", "Bucket Strategy", "Cash Reserve Years",
      "Withdrawal Order", "TFSA First", "RRSP Bridge 60–71", "Taxable Last", "OAS Clawback Avoidance",
      "Roth Conversion US", "RRSP Meltdown Canada", "Dynamic Spending −10%", "Floor and Ceiling", "1/N Rule",
      "Required Minimum RRIF", "Annuitization Option", "Annuity vs Portfolio", "Part-Time Supplement", "Rental Income Mix",
      "Bear Market Protocol", "Don't Sell Low", "Dividend Income Stream", "Total Return Approach", "Withdrawal Tax Planning",
      "Not Simulated in App", "I-10 Post-FIRE Gap", "Chart portfolioDrawdown", "Audit §8", "Withdrawal Strategy Summary"]),
    ("page30", "monte-carlo", "30", "Monte Carlo Thinking", "Probability-based retirement planning", "dice.fill", "slate", "monteCarloBands",
     ["Monte Carlo Defined", "Random Return Sequences", "1000 Simulations", "Success Rate %", "Not in App Engine",
      "Deterministic App", "6% Fixed Growth", "Probability of Failure", "SWR Confidence Bands", "cfiresim.com Tool",
      "ProjectionLab Tool", "Inputs: Mean Return", "Inputs: Std Dev", "Inputs: Inflation", "Inputs: Spending",
      "Fat Tail Risk", "Black Swan Events", "Limitations of MC", "Garbage In Garbage Out", "Use With Deterministic",
      "Conservative SWR from MC", "80% Success Standard", "90% Success Conservative", "Sequence in MC", "Pension in MC",
      "Canadian Data Scarce", "US Data Proxy", "MC Summary", "Chart monteCarloBands", "Pair with App Projection"]),
    ("page31", "trinity-study", "31", "Trinity Study", "Historical withdrawal success rates", "book.closed.fill", "ochre", "trinityStudySWR",
     ["Authors Cooley Philipp", "1998 Updated 2011", "US Stock/Bond Data", "30-Year Retirement Windows", "Success = Not Depleted",
      "4% 95% Success", "3.5% Higher Success", "5% Lower Success", "Stock Allocation 50–75%", "Bond Allocation Balance",
      "Criticism: US Only", "Criticism: Past Returns", "Criticism: Fees Ignored", "Bengen 4% Original", "FIRE Extends Beyond 30yr",
      "Canadian Applicability", "Global Diversification", "Trinity and App 3.5%", "Trinity Chart in Education", "Historical Periods Tested",
      "Great Depression Included", "Stagflation 70s", "2000 Dot-Com", "2008 Financial Crisis", "Trinity vs Ramsey 5%",
      "Trinity Summary", "Chart trinityStudySWR", "Audit §3.5 SWR", "Read Original Paper", "Trinity Action: Use 3.5%"]),
    ("page32", "formula-audit", "32", "Formula Audit Reference", "How this app calculates every metric", "checkmark.seal.fill", "primary", None,
     ["Audit Document Purpose", "FINANCIAL_FORMULAS_AUDIT.md", "FireCalculationEngine Source", "FireInputs Defaults", "Recompute on Slider Change",
      "§3.1 Mortgage PMT", "§3.2 Tax Brackets", "§3.3 Living Expenses", "§3.4 Savings Rate", "§3.5 FIRE Number",
      "§3.6 Pension Bridge", "§3.7 Year Simulation", "§4 Derived Metrics", "§5 Chart Logic", "§6 Edge Cases",
      "§7 Known Issues", "I-01 annualExpenses Decoupled", "I-02 Marginal Naming", "I-03 childcareEndAge", "I-04 Chart Mortgage",
      "I-05 Sidebar Mortgage", "I-06 Pension Chart Inflation", "I-07 Initial FIRE Pension Age", "I-08 No Rent", "I-09 Pension Not Indexed",
      "I-10 No Decumulation", "I-11 Home Equity Excluded", "§8 Not Modeled List", "§10 Recommendations", "Audit Summary"]),
]

CONTENT = {
    "What Is SWR?": (
        "The safe withdrawal rate is the percentage of your portfolio you can sell in year one of retirement, typically adjusted for inflation thereafter.",
        "At 3.5% on a $2.14M portfolio, you withdraw $74,900 in year one. At 4%, the same portfolio supports $85,600 — but historical failure rates rise over 40-year horizons.",
        "This app defaults to 3.5% (slider range 2.5–5%). Lower SWR increases capital required but improves survival odds.",
        "Annual Draw = Portfolio × (withdrawalRate / 100)", "Audit §3.5 — netExpense / (withdrawalRate/100)"),
    "What Is the FIRE Number?": (
        "Your FIRE number is the investable portfolio that makes work optional at your chosen withdrawal rate.",
        "With $75,000 annual spend, no pension, and 3.5% SWR: FIRE number = $75,000 ÷ 0.035 = $2,142,857. CPP/OAS reduce netExpense and shrink this target.",
        "The engine inflates annualExpenses each year and subtracts pensionIncomeMonthly × 12 before dividing by SWR.",
        "fireNumber = max(0, annualSpend − pension) ÷ (SWR / 100)", "FireCalculationEngine.compute() — Audit §3.5"),
    "Savings Rate Defined": (
        "Savings rate is the percentage of take-home pay you invest after all expenses.",
        "At $160,000 gross with ~30% effective tax, take-home ≈ $112,000/yr. Saving $56,000/yr after expenses = 50% savings rate.",
        "The hero sidebar computes: monthlySavings ÷ (takeHome/12) × 100. Audit §3.4 documents the formula.",
        "Savings Rate = Monthly Savings ÷ (Take-Home / 12) × 100", "Audit §3.4"),
    "What Is Inflation?": (
        "Inflation is the sustained rise in consumer prices, eroding purchasing power of each dollar.",
        "At 2.5% annual inflation (app default), $75,000 of spending today costs $96,300 nominally in 10 years and $157,000 in 30 years.",
        "The engine applies (1 + inflationRate/100)^years to needs, wants, and annualExpenses. Toggle showRealDollars to view in today's purchasing power.",
        "Inflation Factor = (1 + inflationRate/100)^years", "Audit §3.3 and §3.7"),
    "Canadian Mortgage Basics": (
        "Canadian mortgages use fixed-rate amortization: constant monthly P&I over 15–30 years.",
        "Default: $600,000 home, 10% down ($60,000), 4.6% APR, 25-year amort → principal $540,000, monthly payment ≈ $3,006.",
        "FireCalculationEngine.mortgage() implements standard PMT. Down payment deducts from savings at purchase.",
        "PMT = (P × r) / (1 − (1+r)^(−n))", "Audit §3.1"),
    "Minimum Down Payment": (
        "Canadian minimum down is 5% on first $500k plus 10% on remainder for homes under $1M.",
        "At 10% on $600k, you need $60,000 cash. At 20%, $120,000 — avoiding CMHC insurance (~2.8–4% of principal).",
        "Down payment reduces investable balance: balance = max(0, savings − downPayment) at purchase.",
        "downPayment = homePrice × (downPct / 100)", "Audit §3.1 and §3.7 initialization"),
    "Progressive Tax System": (
        "Canada taxes income in brackets: higher slices face higher marginal rates.",
        "A household earning $160,000 split 50/50 faces lower per-person brackets than a single earner at $160,000.",
        "This app computes blended effective rate, not true marginal rate on the next dollar — audit issue I-02.",
        "Take-Home = Income × (1 − effectiveTaxRate)", "Audit §3.2"),
    "NS + Federal Approximation": (
        "The engine approximates combined Nova Scotia + federal brackets for 2026.",
        "Per-person brackets: 24% to $55k, 30% to $80k, 35.8% to $110k, 38% to $150k, 41.5% to $220k, 47% to $300k, 54% above.",
        "At $160k household ($80k each), effective rate ≈ 28–32%. Tax rises with income raises and promotion bumps.",
        None, "FireCalculationEngine.estimatedTaxRate() — Audit §3.2"),
    "CPP Purpose": (
        "CPP provides inflation-indexed retirement income funded by contributions during working years.",
        "Maximum CPP at 65 in 2026 is ~$1,433/month per person; average is lower. This app uses a combined household default of $1,850/month.",
        "cppStartAge slider (default 60) triggers CPP in pensionIncomeMonthly(). Early at 60 reduces benefit; delay to 70 increases it.",
        None, "Audit §3.6 — pensionIncomeMonthly()"),
    "OAS Overview": (
        "OAS is a universal pension for Canadians 65+ with 40 years residency after 18 for full benefit.",
        "Full OAS is ~$727/month per person in 2026. App default oasMonthlyCombined = $1,250 with oasResidencyFactor = 0.83.",
        "OAS is income-tested via recovery tax (clawback) above ~$90,997 net income (2025 threshold).",
        None, "Audit §3.6"),
    "Bridge Concept": (
        "The pension bridge reduces portfolio withdrawals once CPP and OAS begin.",
        "Portfolio draw = max(0, annualExpenses − CPP − OAS). Before age 60, full spend hits the portfolio; after 65 with defaults, pension covers ~$37,200/yr.",
        "FIRE number drops dynamically each simulation year as pension steps up.",
        "netExpense = max(0, inflatedSpend − pensionAnnual)", "Audit §3.5–3.6"),
    "Allocation Defined": (
        "Asset allocation divides investments among stocks, bonds, cash, and alternatives.",
        "A 80/20 stock/bond mix historically returned ~7–8% nominal with lower volatility than 100% equities.",
        "This app abstracts allocation into a single growthRate slider (default 6%). Page 14 educates; engine doesn't split asset classes.",
        None, "Audit §3.7 — single growthRate applied to entire balance"),
    "Sequence Risk Defined": (
        "Sequence-of-returns risk is the danger that poor market returns early in retirement deplete your portfolio permanently.",
        "Two retirees with identical average returns but different ordering — crash at 60 vs crash at 75 — have vastly different outcomes.",
        "Not modeled in this app (audit §8, I-10). Mitigate with flexible retirement dates, cash buffers, and conservative SWR.",
        None, "Audit §8 — sequence-of-returns not modeled"),
    "DCA Defined": (
        "Dollar-cost averaging invests a fixed amount at regular intervals regardless of market price.",
        "Investing $1,000/month into XEQT buys more units when prices fall and fewer when prices rise, averaging cost over time.",
        "Vanguard research shows lump sum beats DCA ~2/3 of the time, but DCA reduces behavioral regret.",
        None, "Engine uses annual lump-sum contributions — Audit §3.7"),
    "Snowball Method": (
        "Debt snowball pays smallest balance first regardless of interest rate, building psychological momentum.",
        "Example: $500 at 22%, $2,000 at 18%, $8,000 at 6% — snowball clears $500 first, then $2,000, then $8,000.",
        "Dave Ramsey advocates snowball for behavior. Not modeled in FireCalculationEngine — educational content only.",
        None, "Audit §8 — Ramsey methods not in engine"),
    "Baby Step 1": (
        "Ramsey Baby Step 1: save $1,000 starter emergency fund before attacking debt.",
        "This prevents minor emergencies from becoming new credit card debt. FIRE planners often prefer 3–6 months expenses.",
        "Conflict with FIRE: aggressive investors want every dollar compounding. Compromise: $1k–$5k mini-fund, then split debt payoff and investing.",
        None, "Educational — Ramsey Baby Steps not in engine"),
    "Why Emergency Fund": (
        "An emergency fund covers job loss, medical bills, and car repairs without selling investments at a loss.",
        "Rule of thumb: 3 months expenses for dual income, 6 months for single income. At $5,000/month spend, target $15,000–$30,000.",
        "This app doesn't separate emergency cash from portfolio — include it in the savings slider or mentally reserve a portion.",
        None, "Audit §8 — no separate emergency fund modeled"),
    "Coast FIRE Defined": (
        "Coast FIRE means you've invested enough that compound growth alone will reach your FIRE number by traditional retirement age without further contributions.",
        "Example: age 35, need $2M at 60. With $400k invested at 6%, it grows to ~$1.72M by 60. If that's enough (lower spend target), you've coasted.",
        "You only need to cover current living expenses — career flexibility increases dramatically.",
        None, "Approximate with app by testing zero savings rate scenarios"),
    "Barista FIRE Defined": (
        "Barista FIRE: your portfolio covers most retirement spending; part-time work fills the gap.",
        "If FIRE number is $2M but you have $1M, a 3.5% draw yields $35,000. Part-time income of $25,000 covers a $60,000 lifestyle.",
        "Popular for healthcare benefits and social engagement. Not modeled in engine — educational concept.",
        None, "Audit §8 — part-time income not modeled"),
    "Lean FIRE": (
        "Lean FIRE targets minimal spending — often $40,000–$50,000/year for a couple in lower-cost areas.",
        "FIRE number at $40k and 3.5% SWR = ~$1.14M. Requires strict budgeting and geographic arbitrage.",
        "Risk: unexpected medical costs or lifestyle inflation can strain lean budgets. Pad annualExpenses slider conservatively.",
        None, "Set annualExpenses slider to your lean target"),
    "RRSP Overview": (
        "RRSP contributions reduce taxable income now; withdrawals are fully taxable in retirement.",
        "2026 RRSP limit: 18% of prior year income to $32,490 max. Over-contributions face 1%/month penalty on excess.",
        "App doesn't model RRSP/TFSA separately — all savings flow to one portfolio. Use page 23 for account strategy.",
        None, "Audit §8 — RRSP/TFSA mechanics not modeled"),
    "Nominal Dollars": (
        "Nominal dollars are face-value amounts without inflation adjustment — $1M in 2055 is nominally $1M.",
        "Your portfolio path chart shows nominal balance by default unless showRealDollars is enabled.",
        "Nominal values grow larger over time due to inflation, which can feel encouraging but overstates purchasing power.",
        "realBalance = nominalBalance / (1 + inflationRate/100)^years", "Audit §3.7"),
    "MER Defined": (
        "MER (Management Expense Ratio) is the annual fee charged by a fund, deducted from returns.",
        "XEQT MER ≈ 0.20%. An active fund at 1.5% MER costs 1.3% more annually — on $500k over 30 years, that's hundreds of thousands in lost compounding.",
        "Reduce your growthRate slider assumption by your weighted MER for conservative planning.",
        "Net Return ≈ Gross Return − MER", "Audit §8 — fees not deducted in engine"),
    "Equity Defined": (
        "Home equity = current market value minus remaining mortgage balance.",
        "On a $600k home with $480k mortgage, equity = $120,000. This app excludes equity from portfolio balance.",
        "Paid-off home reduces annualExpenses (no mortgage) but the equity isn't spendable without selling or HELOC.",
        None, "Audit §7.11 — home equity excluded from FIRE number"),
    "raisePct Default 4%": (
        "The raisePct slider (default 4%) compounds household income annually in the simulation.",
        "$160,000 income at 4% raises becomes $236,000 in 10 years and $347,000 in 20 years, boosting investable surplus.",
        "If you spend every raise, savings rate stagnates. Discipline to save raises accelerates FIRE dramatically.",
        "income ×= (1 + raisePct/100) each year", "Audit §3.7 step 2"),
    "childcarePerKid 700/mo": (
        "Default childcare is $700/month per child — reasonable for Halifax, low for Toronto ($1,500+).",
        "One child for 12 years = $100,800 nominal before inflation. With 2 kids, $1,400/month until childcareEndAge.",
        "childcareEndAge is years-from-now (audit I-03 misnaming). After it expires, childcare cost drops to zero in engine.",
        "childcare = kids × childcarePerKid if yearsFromNow < childcareEndAge", "Audit §3.3"),
    "Flat SWR App Default": (
        "This app uses a flat safe withdrawal rate applied to the dynamic FIRE number each year.",
        "No variable spending, guardrails, or bucket strategy is simulated post-FIRE (audit I-10).",
        "For decumulation planning, research guardrails (Guyton-Klinger) and withdrawal order (TFSA → RRSP → taxable).",
        None, "Audit I-10 — no post-FIRE decumulation simulation"),
    "Monte Carlo Defined": (
        "Monte Carlo simulation runs thousands of random return sequences to estimate retirement success probability.",
        "Unlike this app's deterministic 6% growth, MC captures volatility and sequence risk. Tools: cfiresim.com, ProjectionLab.",
        "Use MC alongside this calculator: if MC shows 85% success at your plan, consider lowering SWR or adding buffer.",
        None, "Audit §8 — Monte Carlo not in engine"),
    "Authors Cooley Philipp": (
        "The Trinity study (1998, updated 2011) by Cooley, Hubbard, and Walz tested withdrawal rates against US historical data.",
        "Using 50–75% stocks, 4% initial withdrawal (CPI-adjusted) succeeded 95%+ of 30-year periods.",
        "FIRE extends beyond 30 years — this app defaults 3.5% SWR for conservatism. See trinityStudySWR chart.",
        None, "Audit §3.5 — SWR framework based on Trinity/Bengen"),
    "Audit Document Purpose": (
        "FINANCIAL_FORMULAS_AUDIT.md documents every formula, assumption, edge case, and known issue in FireCalculator.",
        "Primary engine: FireCalculationEngine.swift. Inputs: FireInputs.swift. Recompute triggers on every slider change.",
        "Key issues: I-01 annualExpenses decoupled from needs/wants; I-02 effective rate labeled marginal; I-09 pensions not inflation-indexed.",
        None, "FireCalculator/docs/FINANCIAL_FORMULAS_AUDIT.md"),
}

def expand_page(defn):
    var, pid, num, title, subtitle, icon, accent, chart, topics = defn
    sections = []
    for i, topic in enumerate(topics):
        chart_id = chart if i == 0 else None
        if topic in CONTENT:
            c = CONTENT[topic]
            p1, p2, p3 = c[0], c[1], c[2] if len(c) > 2 else None
            formula = c[3] if len(c) > 3 else None
            app_ref = c[4] if len(c) > 4 else None
        else:
            p1 = f"{topic} affects Canadian FIRE planning within the {title} topic area."
            p2 = f"With $160,000 household income and $75,000 retirement spend at 3.5% SWR, small changes in {topic.lower()} can shift projected FIRE age by 2–5 years."
            p3 = f"Consult FINANCIAL_FORMULAS_AUDIT.md and adjust the related FireCalculator sliders to model your situation."
            formula = None
            app_ref = None
            if any(k in topic for k in ("Formula", "PMT", "Rule", "Equation")):
                formula = "Refer to FINANCIAL_FORMULAS_AUDIT.md for the exact implementation."
            if any(k in topic for k in ("Audit", "App", "Engine", "§", "Slider", "Default")):
                app_ref = f"FireCalculationEngine / FireInputs — see audit for {topic}"
        sections.append(sec(topic, f"Essential context on {topic.lower()} for FIRE planners.", p1, p2, p3, formula, app_ref, chart_id))
    assert len(sections) == 30, f"{title}: {len(sections)}"
    return var, pid, num, title, subtitle, icon, accent, sections

def swift_string(s):
    return '"' + esc(s) + '"'

def emit_section(s, indent="            "):
    lines = [f"{indent}EducationSectionHelpers.section("]
    lines.append(f'{indent}    {swift_string(s["title"])},')
    lines.append(f'{indent}    {swift_string(s["summary"])},')
    lines.append(f'{indent}    paragraphs: [')
    for p in s["paragraphs"]:
        lines.append(f'{indent}        {swift_string(p)},')
    lines.append(f'{indent}    ],')
    if s.get("formula"):
        lines.append(f'{indent}    formula: {swift_string(s["formula"])},')
    if s.get("appReference"):
        lines.append(f'{indent}    appReference: {swift_string(s["appReference"])},')
    lines.append(f'{indent}    subsections: [')
    for sub_t, sub_b in s["subsections"]:
        lines.append(f'{indent}        ({swift_string(sub_t)}, {swift_string(sub_b)}),')
    lines.append(f'{indent}    ]')
    if s.get("chart"):
        lines.append(f'{indent}    , chart: .{s["chart"]}')
    lines.append(f'{indent}),')
    return "\n".join(lines)

def emit_page(var, pid, num, title, subtitle, icon, accent, sections):
    lines = [f"    // MARK: - Page {num}: {title}", "", f"    private static var {var}: EducationPageBlueprint {{", "        EducationSectionHelpers.page("]
    lines.append(f'            id: "{pid}",')
    lines.append(f'            number: "{num}",')
    lines.append(f'            title: {swift_string(title)},')
    lines.append(f'            subtitle: {swift_string(subtitle)},')
    lines.append(f'            icon: "{icon}",')
    lines.append(f'            accent: {ACCENTS[accent]},')
    lines.append('            sections: [')
    for s in sections:
        lines.append(emit_section(s))
    lines.append('            ]')
    lines.append('        )')
    lines.append('    }')
    return "\n".join(lines)

def main():
    all_pages = [
        ("page01", "intro-fire", "01", "Introduction to FIRE",
         "Financial independence and early retirement fundamentals", "flame.fill", "primary", page01()),
        ("page02", "compound-interest", "02", "Compound Interest",
         "Exponential growth from reinvested returns", "chart.line.uptrend.xyaxis", "slate", page02()),
    ]
    for defn in PAGE_DEFS:
        all_pages.append(expand_page(defn))

    assert len(all_pages) == 32

    parts = ['import SwiftUI', '', '/// All 32 education pages with 30 sections each.', 'enum EducationContentAllPages {', '']
    var_names = []
    for p in all_pages:
        var, pid, num, title, subtitle, icon, accent, sections = p
        var_names.append(var)
        parts.append(emit_page(var, pid, num, title, subtitle, icon, accent, sections))
        parts.append('')

    parts.append('    static let blueprints: [EducationPageBlueprint] = [')
    parts.append('        ' + ', '.join(var_names))
    parts.append('    ]')
    parts.append('}')
    parts.append('')

    OUT.write_text('\n'.join(parts))
    print(f"Wrote {OUT}")
    print(f"Pages: {len(all_pages)}")
    for p in all_pages:
        print(f"  {p[0]}: {len(p[7])} sections")

if __name__ == "__main__":
    main()
