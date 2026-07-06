# FireCalculator

A native SwiftUI macOS 26+ (Tahoe) app for modeling a Halifax, Nova Scotia household's path to
Financial Independence / Retire Early (FIRE). Ports and extends the original
`retirement-calculator.jsx` prototype.

## Highlights

- **Inflation-adjusted calculations** — living expenses compound at a configurable inflation rate;
  results can be viewed in real (today's dollars) or nominal terms.
- **CPP/OAS pension bridge** — models Canadian government pensions offsetting retirement spend,
  including a residency-factor haircut for newcomers.
- **Tooltips everywhere** — every slider and every derived statistic has an info affordance
  explaining exactly how it's computed.
- **Liquid Glass design** — muted "paper" palette (light + dark) layered under native macOS 26
  glass materials.
- **Charts** — portfolio path to FIRE, expense breakdown, income vs. pension income, and a
  CPP/OAS bridge visualization, all via Swift Charts.
- **Persistence (SwiftData)** — the live scenario autosaves; named, revertable **checkpoints** act
  like source control for your sliders; every edit is logged as a **change event** for long-term
  history tracking.
- **PDF export** — a full report (summary, charts, methodology) exportable via `NSSavePanel`.
- **Gemini-powered assistant** — chat about your plan, get suggestions, and let the AI move
  sliders directly via function calling. The API key is stored in the macOS Keychain
  (Settings → Gemini API Key, or get one at https://aistudio.google.com/apikey).

## Running

```bash
cd FireCalculator
swift build
swift run FireCalculator
```

Or open `Package.swift` in Xcode 26+ and run the `FireCalculator` scheme.

## Structure

- `Models/` — `FireInputs` (all slider state)
- `Engine/` — `FireCalculationEngine` (pure simulation), formatting helpers
- `Persistence/` — SwiftData models + `AppStore` (central observable state)
- `Views/` — sections, results panel, charts, checkpoints/history/settings screens
- `Assistant/` — Keychain storage, Gemini REST client with function calling, chat controller
- `Export/` — PDF report view + exporter
