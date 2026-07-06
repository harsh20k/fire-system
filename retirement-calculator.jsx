import React, { useState, useMemo } from "react";

const fmt = (n) => "$" + Math.round(n).toLocaleString("en-CA");
const fmtK = (n) => (Math.abs(n) >= 1e6 ? "$" + (n / 1e6).toFixed(2) + "M" : "$" + Math.round(n / 1000) + "k");
const fmtAnnualMo = (n) => `${fmt(n)} (${fmt(n / 12)}/mo)`;
const fmtMoYr = (n) => `${fmt(n)}/mo (${fmt(n * 12)}/yr)`;

function Tip({ text }) {
  const [open, setOpen] = useState(false);
  return (
    <span
      onMouseEnter={() => setOpen(true)}
      onMouseLeave={() => setOpen(false)}
      onClick={(e) => { e.stopPropagation(); setOpen((o) => !o); }}
      style={{ position: "relative", display: "inline-flex", marginLeft: 5 }}
    >
      <span style={{ cursor: "help", color: "#7a8a80", fontSize: 11, border: "1px solid #b8c0b4", borderRadius: "50%", width: 14, height: 14, display: "inline-flex", alignItems: "center", justifyContent: "center", lineHeight: 1 }}>
        i
      </span>
      {open && (
        <span style={{
          position: "absolute", bottom: "150%", left: 0, zIndex: 30,
          width: 240, background: "#1c2b23", color: "#f2f0e8",
          fontFamily: "'Source Serif 4', Georgia, serif", fontSize: 13, lineHeight: 1.5,
          padding: "10px 12px", borderRadius: 4, boxShadow: "0 4px 14px rgba(0,0,0,0.25)",
          whiteSpace: "normal", textTransform: "none", letterSpacing: "normal",
        }}>
          {text}
        </span>
      )}
    </span>
  );
}

function Slider({ label, tip, value, setValue, min, max, step, format }) {
  return (
    <div style={{ marginBottom: 18 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", fontFamily: "'IBM Plex Mono', monospace", fontSize: 12, letterSpacing: 0.5, color: "#5b6b63", marginBottom: 6 }}>
        <span style={{ display: "flex", alignItems: "center" }}>{label}{tip && <Tip text={tip} />}</span>
        <span style={{ color: "#1c2b23", fontWeight: 600, textAlign: "right" }}>{format ? format(value) : value}</span>
      </div>
      <input type="range" min={min} max={max} step={step} value={value} onChange={(e) => setValue(Number(e.target.value))} style={{ width: "100%", accentColor: "#2f5d4e" }} />
    </div>
  );
}

function Section({ number, title, accent, summary, children }) {
  const [open, setOpen] = useState(true);
  return (
    <div style={{ background: "#faf8f2", border: "1px solid #e0dccb", borderLeft: `4px solid ${accent}`, borderRadius: 6, padding: "22px 24px", marginBottom: 28 }}>
      <div onClick={() => setOpen((o) => !o)} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", cursor: "pointer", marginBottom: open ? 18 : 0 }}>
        <h3 style={{ fontFamily: "'IBM Plex Mono', monospace", fontSize: 12, letterSpacing: 1.5, textTransform: "uppercase", color: accent, margin: 0 }}>
          {number} — {title}
        </h3>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          {!open && summary && (
            <span style={{ fontFamily: "'IBM Plex Mono', monospace", fontSize: 12, color: "#5b6b63" }}>{summary}</span>
          )}
          <span style={{ color: accent, fontSize: 12, transform: open ? "rotate(0deg)" : "rotate(-90deg)", transition: "transform 0.15s" }}>▾</span>
        </div>
      </div>
      {open && children}
    </div>
  );
}

function SubHead({ label, accent }) {
  return (
    <div style={{ fontFamily: "'IBM Plex Mono', monospace", fontSize: 11, letterSpacing: 1, color: accent, textTransform: "uppercase", margin: "18px 0 12px", paddingLeft: 10, borderLeft: `2px solid ${accent}` }}>
      {label}
    </div>
  );
}

export default function RetirementCalculator() {
  const [age, setAge] = useState(33);
  const [savings, setSavings] = useState(20000);
  const [income, setIncome] = useState(160000);
  const [raisePct, setRaisePct] = useState(4);
  const [promoBumpPct, setPromoBumpPct] = useState(12);
  const [promoCycle, setPromoCycle] = useState(3);
  const [kids, setKids] = useState(1);

  const [groceries, setGroceries] = useState(900);
  const [utilities, setUtilities] = useState(130);
  const [internetPhone, setInternetPhone] = useState(130);
  const [numCars, setNumCars] = useState(2);
  const [costPerCar, setCostPerCar] = useState(650);
  const [rideshare, setRideshare] = useState(150);
  const [medicine, setMedicine] = useState(100);
  const [personalCare, setPersonalCare] = useState(50);
  const [subscriptions, setSubscriptions] = useState(90);
  const [childcarePerKid, setChildcarePerKid] = useState(700);

  const [eatingOut, setEatingOut] = useState(550);
  const [shoppingTech, setShoppingTech] = useState(350);
  const [entertainment, setEntertainment] = useState(130);

  const [homePrice, setHomePrice] = useState(600000);
  const [downPct, setDownPct] = useState(10);
  const [mortgageRate, setMortgageRate] = useState(4.6);
  const [amort, setAmort] = useState(25);

  const [growthRate, setGrowthRate] = useState(6);
  const [withdrawalRate, setWithdrawalRate] = useState(3.5);
  const [annualExpenses, setAnnualExpenses] = useState(75000);

  const results = useMemo(() => {
    const downPayment = homePrice * (downPct / 100);
    const principal = homePrice - downPayment;
    const mRate = mortgageRate / 100 / 12;
    const n = amort * 12;
    const monthlyPayment = mRate === 0 ? principal / n : (principal * mRate) / (1 - Math.pow(1 + mRate, -n));
    const annualMortgage = monthlyPayment * 12;

    const childcareMonthly = kids * childcarePerKid;
    const needsMonthly = groceries + utilities + internetPhone + numCars * costPerCar + rideshare + medicine + personalCare + subscriptions + childcareMonthly;
    const wantsMonthly = eatingOut + shoppingTech + entertainment;
    const totalMonthlyExpenses = monthlyPayment + needsMonthly + wantsMonthly;
    const workingExpensesAnnual = totalMonthlyExpenses * 12;

    const currentTakeHome = income * 0.68;
    const currentMonthlySavings = currentTakeHome / 12 - totalMonthlyExpenses;

    const fireNumber = annualExpenses / (withdrawalRate / 100);

    let currentIncome = income;
    let balance = Math.max(0, savings - downPayment);
    let years = 0;
    const path = [{ age, balance }];
    while (balance < fireNumber && years < 60) {
      years++;
      currentIncome *= 1 + raisePct / 100;
      if (promoCycle > 0 && years % promoCycle === 0) currentIncome *= 1 + promoBumpPct / 100;
      const takeHome = currentIncome * 0.68;
      const investable = Math.max(0, takeHome - workingExpensesAnnual);
      balance = balance * (1 + growthRate / 100) + investable;
      path.push({ age: age + years, balance });
    }

    return {
      downPayment, monthlyPayment, needsMonthly, wantsMonthly, totalMonthlyExpenses, workingExpensesAnnual,
      currentTakeHome, currentMonthlySavings, fireNumber, fireAge: years >= 60 ? null : age + years, path,
    };
  }, [age, savings, income, raisePct, promoBumpPct, promoCycle, kids, groceries, utilities, internetPhone, numCars, costPerCar, rideshare, medicine, personalCare, subscriptions, childcarePerKid, eatingOut, shoppingTech, entertainment, homePrice, downPct, mortgageRate, amort, growthRate, withdrawalRate, annualExpenses]);

  const maxBalance = Math.max(...results.path.map((p) => p.balance), results.fireNumber);

  return (
    <div style={{ background: "#f2f0e8", minHeight: "100vh", fontFamily: "'Source Serif 4', Georgia, serif", color: "#1c2b23" }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Source+Serif+4:opsz,wght@8..60,400;8..60,600;8..60,700&family=IBM+Plex+Mono:wght@400;500;600&display=swap');
        input[type=range]{-webkit-appearance:none;height:4px;background:#cdd3c9;border-radius:2px;}
        input[type=range]::-webkit-slider-thumb{-webkit-appearance:none;width:16px;height:16px;border-radius:50%;background:#2f5d4e;cursor:pointer;border:2px solid #f2f0e8;box-shadow:0 0 0 1px #2f5d4e;}
        input[type=range]::-moz-range-thumb{width:16px;height:16px;border-radius:50%;background:#2f5d4e;cursor:pointer;border:2px solid #f2f0e8;}
      `}</style>

      <div style={{ maxWidth: 1140, margin: "0 auto", padding: "48px 24px 80px" }}>
        <div style={{ fontFamily: "'IBM Plex Mono', monospace", fontSize: 11, letterSpacing: 2, color: "#7a8a80", textTransform: "uppercase", marginBottom: 12 }}>
          Halifax, Nova Scotia — Household Model
        </div>
        <h1 style={{ fontSize: 42, lineHeight: 1.1, margin: "0 0 8px", fontWeight: 700 }}>When can you retire?</h1>
        <p style={{ fontSize: 16, color: "#4a5850", maxWidth: 600, margin: "0 0 40px" }}>
          Every lever below feeds the chart — income growth, mortgage, needs, and wants all net out into your monthly savings.
        </p>

        <div style={{ display: "grid", gridTemplateColumns: "minmax(300px, 420px) 1fr", gap: 40 }}>
          <div>
            <Section number="01" title="Target" accent="#2f5d4e" summary={`${fmtK(results.fireNumber)} target · ${withdrawalRate}% withdrawal`}>
              <Slider label="Investment growth" tip="Expected long-run annual return on a diversified portfolio (historically ~6-7% nominal). Lower it to stress-test a bad-market scenario." value={growthRate} setValue={setGrowthRate} min={2} max={10} step={0.5} format={(v) => v + "%"} />
              <Slider label="Withdrawal rate" tip="% of your portfolio drawn each year in retirement. 4% (Trinity study) suits ~30 years; a 40+ year horizon like retiring in your 40s-50s is safer at 3-3.5%. Lower = bigger nest egg needed, but less risk of running out." value={withdrawalRate} setValue={setWithdrawalRate} min={2.5} max={5} step={0.25} format={(v) => v + "%"} />
              <Slider label="Retirement annual spend" tip="Expected spending once retired. Default $75k assumes a paid-off home and a modest but comfortable NS lifestyle. Lower spend = smaller FIRE number = earlier retirement." value={annualExpenses} setValue={setAnnualExpenses} min={40000} max={150000} step={5000} format={fmtAnnualMo} />
              <p style={{ fontSize: 13, color: "#5b6b63", background: "#e9e6da", border: "1px solid #d8d4c4", borderRadius: 4, padding: "10px 12px", lineHeight: 1.5, marginTop: 4 }}>
                <b>What's a withdrawal rate?</b> The % of your nest egg you sell off and spend each year in retirement. 3.5% on a $2M portfolio means drawing ~$70k/yr while the rest keeps growing. Lower rate = bigger pile needed, but safer over a long retirement.
              </p>
            </Section>

            <Section number="02" title="Home" accent="#c9843f" summary={`${fmtK(homePrice)} · ${downPct}% down · ${mortgageRate.toFixed(1)}% rate`}>
              <Slider label="Home price" tip="Nova Scotia home prices range roughly $500k-$1M by area. Buying lower frees more cash to invest instead of servicing a mortgage." value={homePrice} setValue={setHomePrice} min={400000} max={1000000} step={10000} format={fmtK} />
              <Slider label="Down payment" tip="Typically 5-20% depending on price and insurer rules. A bigger down payment shrinks the mortgage and grows your surplus faster, but drains today's savings." value={downPct} setValue={setDownPct} min={5} max={35} step={1} format={(v) => v + "%"} />
              <Slider label="Mortgage rate" tip="Current Canadian 5-yr fixed benchmark. You can't move the market rate, but shopping lenders and stronger credit can shave off fractions." value={mortgageRate} setValue={setMortgageRate} min={2} max={8} step={0.1} format={(v) => v.toFixed(1) + "%"} />
              <Slider label="Amortization" tip="Longer amortization = lower monthly payment but more total interest and slower payoff." value={amort} setValue={setAmort} min={15} max={30} step={1} format={(v) => v + " yrs"} />
            </Section>

            <Section number="03" title="Household & Income" accent="#3f6ea8" summary={`${fmtK(income)} income · ${raisePct}% raises · ${kids} kid${kids === 1 ? "" : "s"}`}>
              <Slider label="Current age (both)" tip="Your FIRE-path starting point." value={age} setValue={setAge} min={25} max={55} step={1} format={(v) => v} />
              <Slider label="Current savings" tip="Liquid net worth today. Raising this shortens your path by easing the dent your down payment leaves." value={savings} setValue={setSavings} min={0} max={200000} step={5000} format={fmt} />
              <Slider label="Combined income (today)" tip="Combined household gross income right now. Usually the fastest lever — it compounds through take-home and savings rate." value={income} setValue={setIncome} min={60000} max={300000} step={5000} format={fmtAnnualMo} />
              <Slider label="Kids" tip="Each child adds a monthly childcare cost, tracked under Needs. NS's subsidized daycare can lower this." value={kids} setValue={setKids} min={0} max={3} step={1} format={(v) => v} />

              <SubHead label="Income growth" accent="#3f6ea8" />
              <Slider label="Average annual raise" tip="Typical IT-sector cost-of-living + merit raise. Canadian tech averages roughly 3-5% a year outside promotions." value={raisePct} setValue={setRaisePct} min={0} max={10} step={0.5} format={(v) => v + "%"} />
              <Slider label="Promotion bump" tip="Extra one-time jump when you move up a seniority level (e.g. Developer → Senior → Lead). IT promotions typically bring 8-20% on top of the regular raise." value={promoBumpPct} setValue={setPromoBumpPct} min={0} max={30} step={1} format={(v) => v + "%"} />
              <Slider label="Promotion cycle" tip="How often a seniority-level jump happens. 2-3 years is typical early career; it often stretches to 4-5 years at senior levels." value={promoCycle} setValue={setPromoCycle} min={1} max={6} step={1} format={(v) => v + " yrs"} />
            </Section>

            <Section number="04" title="Expenses" accent="#a8433f" summary={`${fmt(results.totalMonthlyExpenses)}/mo · ${fmt(results.currentMonthlySavings)}/mo saved`}>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 22, background: "#f2ede1", border: "1px solid #ddd5bd", borderRadius: 4, padding: "16px 18px" }}>
                <div>
                  <div style={{ fontFamily: "'IBM Plex Mono', monospace", fontSize: 10, letterSpacing: 1, color: "#7a8a80", textTransform: "uppercase", marginBottom: 4 }}>Total monthly expenses</div>
                  <div style={{ fontSize: 22, fontWeight: 700 }}>{fmt(results.totalMonthlyExpenses)}</div>
                </div>
                <div>
                  <div style={{ fontFamily: "'IBM Plex Mono', monospace", fontSize: 10, letterSpacing: 1, color: "#7a8a80", textTransform: "uppercase", marginBottom: 4 }}>Saved every month</div>
                  <div style={{ fontSize: 22, fontWeight: 700, color: results.currentMonthlySavings >= 0 ? "#2f5d4e" : "#a8433f" }}>{fmt(results.currentMonthlySavings)}</div>
                </div>
              </div>

              <SubHead label="N — Needs" accent="#a8433f" />
              <Slider label="Groceries" tip="Scales with household size — expect roughly +30% once you add a child." value={groceries} setValue={setGroceries} min={300} max={2000} step={25} format={fmtMoYr} />
              <Slider label="Utilities" tip="Electricity, water, home utilities. NS electricity rates run a bit above the national average." value={utilities} setValue={setUtilities} min={0} max={400} step={10} format={fmtMoYr} />
              <Slider label="Internet & phone" tip="Combined internet bill, phone bill, and mobile plans for both of you." value={internetPhone} setValue={setInternetPhone} min={0} max={400} step={10} format={fmtMoYr} />
              <Slider label="Number of cars" tip="Two cars is typical for a suburban Halifax household without full transit access. Dropping to one frees meaningful monthly cash." value={numCars} setValue={setNumCars} min={0} max={4} step={1} format={(v) => v} />
              <Slider label="Cost per car" tip="Payment, insurance, gas, maintenance combined. NS insurance and driving distances push this above urban Ontario averages." value={costPerCar} setValue={setCostPerCar} min={200} max={1200} step={50} format={fmtMoYr} />
              <Slider label="Rideshare / transit" tip="Uber, taxis, or transit passes on top of car ownership." value={rideshare} setValue={setRideshare} min={0} max={600} step={25} format={fmtMoYr} />
              <Slider label="Medicine & healthcare" tip="Out-of-pocket health costs not covered by public healthcare — dental, vision, prescriptions, supplemental insurance." value={medicine} setValue={setMedicine} min={0} max={400} step={10} format={fmtMoYr} />
              <Slider label="Personal care" tip="Haircuts, grooming, cosmetics." value={personalCare} setValue={setPersonalCare} min={0} max={300} step={10} format={fmtMoYr} />
              <Slider label="Essential subscriptions" tip="Digital tools and services you'd keep regardless — not discretionary streaming or entertainment." value={subscriptions} setValue={setSubscriptions} min={0} max={300} step={10} format={fmtMoYr} />
              {kids > 0 && (
                <Slider label="Childcare, per kid" tip="Monthly cost per child after any subsidy. NS's $10-a-day program can push this down for younger kids." value={childcarePerKid} setValue={setChildcarePerKid} min={0} max={1500} step={50} format={fmtMoYr} />
              )}

              <SubHead label="W — Wants" accent="#c9843f" />
              <Slider label="Eating out" tip="Restaurants, takeout, delivery. Often the single most compressible line item in a household budget." value={eatingOut} setValue={setEatingOut} min={0} max={1200} step={25} format={fmtMoYr} />
              <Slider label="Shopping + tech" tip="Non-essential shopping, gadgets, gaming, tech upgrades." value={shoppingTech} setValue={setShoppingTech} min={0} max={1000} step={25} format={fmtMoYr} />
              <Slider label="Entertainment" tip="Streaming, outings, hobbies, travel-adjacent spend." value={entertainment} setValue={setEntertainment} min={0} max={600} step={25} format={fmtMoYr} />
            </Section>
          </div>

          <div>
            <div style={{ position: "sticky", top: 24 }}>
              <div style={cardStyle}>
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 24, marginBottom: 32 }}>
                  <Stat label="FIRE number" value={fmtK(results.fireNumber)} />
                  <Stat label="Age you hit it" value={results.fireAge ? results.fireAge : "60+"} accent />
                  <Stat label="Monthly savings today" value={fmt(results.currentMonthlySavings)} />
                  <Stat label="Monthly mortgage" value={fmtMoYr(results.monthlyPayment)} />
                </div>

                <div style={{ fontFamily: "'IBM Plex Mono', monospace", fontSize: 11, letterSpacing: 1, color: "#7a8a80", marginBottom: 8, textTransform: "uppercase" }}>
                  Portfolio path to FIRE
                </div>
                <svg width="100%" height="220" viewBox="0 0 600 220" preserveAspectRatio="none" style={{ overflow: "visible" }}>
                  <line x1="0" y1={220 - (results.fireNumber / maxBalance) * 200} x2="600" y2={220 - (results.fireNumber / maxBalance) * 200} stroke="#c9843f" strokeWidth="1.5" strokeDasharray="4 4" />
                  <polyline fill="none" stroke="#2f5d4e" strokeWidth="2.5" points={results.path.map((p, i) => { const x = (i / (results.path.length - 1 || 1)) * 600; const y = 220 - Math.min(1, p.balance / maxBalance) * 200; return `${x},${y}`; }).join(" ")} />
                  <polygon fill="rgba(47,93,78,0.08)" points={results.path.map((p, i) => { const x = (i / (results.path.length - 1 || 1)) * 600; const y = 220 - Math.min(1, p.balance / maxBalance) * 200; return `${x},${y}`; }).join(" ") + " 600,220 0,220"} />
                </svg>
                <div style={{ display: "flex", justifyContent: "space-between", fontFamily: "'IBM Plex Mono', monospace", fontSize: 11, color: "#7a8a80" }}>
                  <span>age {age}</span>
                  <span>age {age + results.path.length - 1}</span>
                </div>

                <div style={{ marginTop: 32, paddingTop: 24, borderTop: "1px solid #d8d4c4", fontSize: 14, color: "#4a5850", lineHeight: 1.8 }}>
                  <p style={{ margin: "0 0 8px" }}>Take-home (after tax/CPP/EI): <b>{fmtAnnualMo(results.currentTakeHome)}</b></p>
                  <p style={{ margin: "0 0 8px" }}>Needs: <b>{fmtMoYr(results.needsMonthly)}</b></p>
                  <p style={{ margin: 0 }}>Wants: <b>{fmtMoYr(results.wantsMonthly)}</b></p>
                </div>
              </div>
              <p style={{ fontSize: 12, color: "#8a9088", marginTop: 16, fontFamily: "'IBM Plex Mono', monospace" }}>
                Rough model, not financial advice. Expenses held flat in nominal terms; income grows with your raise/promotion sliders.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

const cardStyle = { background: "#fbfaf5", border: "1px solid #d8d4c4", borderRadius: 4, padding: 32 };

function Stat({ label, value, accent }) {
  return (
    <div>
      <div style={{ fontFamily: "'IBM Plex Mono', monospace", fontSize: 11, letterSpacing: 1, color: "#7a8a80", textTransform: "uppercase", marginBottom: 4 }}>{label}</div>
      <div style={{ fontSize: 24, fontWeight: 700, color: accent ? "#c9843f" : "#1c2b23" }}>{value}</div>
    </div>
  );
}
