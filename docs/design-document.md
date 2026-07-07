# FIRE Calculator — Design Document

**One theme, one palette, five components, two screen templates.** Keep this doc short; everything else follows from it.

---

## 1. Theme (one sentence)

**Bold clarity for money that matters:** high contrast, blocky cards, oversized numbers, and green/red status so FIRE age and nest-egg targets are obvious at a glance — with enough breathing room that dense financial data never feels cramped.

---

## 2. Colors & type — we only use these

**Colors**

- **Primary** — On-track / success (positive savings, FIRE reached, main CTAs). Strong green.
- **Neutral** — Screen background. Warm off-white in light mode; deep charcoal in dark mode.
- **Surface** — Card background. White in light mode; slightly lifted dark in dark mode.
- **Accent** — Warnings, negative savings, destructive actions, high-priority attention. Strong red.

**Section accents** (derived from palette, not one-offs)

- Target → primary green
- Home → amber
- Household → blue
- Expenses → red

**Text sizes (exactly three)**

- **Title** — Screen headers, hero numbers, main headings. 28pt bold sans-serif.
- **Body** — Labels, slider text, button text. 17pt sans-serif.
- **Caption** — Timestamps, disclaimers, secondary info. 13pt sans-serif.

**Rule:** Only these colors and three text sizes on feature screens. No serif, no glass, no one-off font sizes.

---

## 3. Spacing — we only use these

| Token | Value | Use |
|---|---|---|
| `screen` | 32px | Outer screen padding |
| `section` | 40px | Gap between major blocks |
| `card` | 28px | Inner card padding |
| `inline` | 16px | Within-card element gaps |

---

## 4. Shared components — everyone uses these

Wrap the basics and use them everywhere. No raw styled `Text` or `Button` on feature screens.

| Component | Purpose |
|---|---|
| **BrutalText** | All text. Variants: `title`, `body`, `caption`. Optional `bold`. |
| **BrutalButton** | All actions. Variants: `primary`, `secondary`. Press-in shadow animation. |
| **BrutalScreen** | Root wrapper: neutral background + standard padding. |
| **BrutalCard** | Content blocks: sections, results, list rows. Black border + offset shadow. |
| **HeroStat** | Oversized glanceable metric (FIRE age, FIRE number, savings rate). |

**Rule:** No raw `Text` / `Button` styling on feature screens — always go through these.

---

## 5. Component APIs (short reference)

**BrutalText**

- `variant`: `.title` | `.body` | `.caption`
- `bold?: Bool`
- `children`, optional `color` override

**BrutalButton**

- `variant`: `.primary` | `.secondary`
- `title: String`, `action: () -> Void`
- Optional `disabled`

**BrutalScreen**

- `children`
- Optional `padding` override

**BrutalCard**

- `children`
- Optional `accent` (colored left stripe)
- Optional `padding` override

**HeroStat**

- `label: String`, `value: String`
- Optional `tip`, optional `accent` color

---

## 6. Standard screens — copy these layouts

Two reference screens. New screens should copy one unless there's a strong reason not to.

### 6.1 Plan screen (main view)

- **Implementation:** `ContentView.swift` — single centered column (max ~780px), `BrutalScreen`, hero results first, then numbered input sections.
- **Header:** Uppercase caption tagline, bold title greeting, body subtitle. Generous top padding.
- **Hero row:** Three `HeroStat` blocks — FIRE age, FIRE number, savings rate. Full-width below header.
- **Charts:** Inside a `BrutalCard` below hero stats; segmented picker for chart tabs.
- **Input sections:** `FireSection` cards (01 Target → 04 Expenses), 40px apart, collapsible with summary when closed.
- **Disclaimer:** `BrutalText` caption below results card.

### 6.2 Sheet screen (Checkpoints / History / Settings)

- **Header:** `BrutalText` title at top.
- **Content:** List of `BrutalCard` rows or form fields inside `BrutalCard`.
- **Actions:** `BrutalButton` primary at bottom-right ("Done", "Save").
- **Background:** `Theme.neutral` — no glass, no blur.

---

## 7. Visual tokens (brutalist)

- **Border:** 2.5px solid `#111111` on all cards and buttons
- **Shadow:** 4px offset hard shadow (`#111111`), collapses on press
- **Corner radius:** 0px (square) or 2px max — no soft rounded glass
- **Section labels:** Uppercase, letter-spacing 1.2, body weight

---

## 8. Theme bullet list (paste for team)

- **Theme:** Bold clarity for money; blocky cards, oversized numbers, glanceable status.
- **Primary:** On-track / success / main CTAs.
- **Neutral:** Screen background (off-white / charcoal).
- **Surface:** Card fill (white / lifted dark).
- **Accent:** Warnings, negative, destructive.
- **Type:** Title, Body, Caption only. Sans-serif.
- **Spacing:** 32 / 40 / 28 / 16 px tokens only.
- **Components:** BrutalText, BrutalButton, BrutalScreen, BrutalCard, HeroStat.
- **Layout:** Single centered column; hero results above input sections.

---

*End of design document. One page.*
