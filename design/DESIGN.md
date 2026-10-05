# EZ Heart Zones — Design Spec (v1)

This document captures the approved visual design and interaction model for the three core screens of EZ Heart Zones, produced through iterative review in a design canvas. It is meant to be handed to an implementer (e.g. Claude Code working in this SwiftUI project) to build the SwiftUI views.

Static HTML mockups live alongside this file in `design/mockups/` (`home.html`, `day-detail.html`, `week-detail.html`, `goal-reached.html`) — open them in a browser at their native size (390×844, iPhone width, except `goal-reached.html` which is cropped to 390×400) for exact colors, spacing, and live animation timing. Treat this document as the explanation of *why* those mockups look the way they do; treat the mockups as the pixel/motion source of truth for spacing/sizing/colors/timing.

## 1. Core concept: points, not minutes

The app already computes standard 5-zone heart-rate ranges from `220 - age` (per the existing README). The key product decision made during design: **the unit the user sees and tracks toward their goal is "points," not raw minutes.**

- `points = minutes_in_zone × multiplier(zone)`
- Multiplier table:
  | Zone | Label | Multiplier |
  |---|---|---|
  | 1 | Very Light | 0× |
  | 2 | Light | 1× |
  | 3 | Moderate | 1× |
  | 4 | Hard | 2× |
  | 5 | Maximum | 2× |
- The weekly goal (default 150, user-configurable per the README) is a **points** goal, not a minutes goal.
- Zone 1 time is still recorded and still shown in the UI (never hidden), but it always contributes 0 points. Every place Zone 1 appears, it's visually de-emphasized (reduced opacity / muted color) and labeled `0× (not counted)` so it reads as "logged but doesn't count," not as an error or missing data.
- Raw minutes are still shown in a few places (mainly the per-zone breakdown lists) so the user can see "the work" behind a points number, but the **Home screen only ever shows points** — no raw minute totals there. This was an explicit simplification: mixing minutes and points on the same screen was found to be confusing given the multiplier.

## 2. Two simplification tiers for zones

The app has two different levels of granularity depending on context:

- **Medium Intensity** = Zone 2 + Zone 3 (both 1× multiplier)
- **High Intensity** = Zone 4 + Zone 5 (both 2× multiplier)
- Zone 1 never appears in this simplified view (it never contributes).

Home screen and the "Medium vs High Intensity" summary card use only this 2-color simplification. The full 5-zone breakdown (with Zone 1 shown-but-disclaimed) only appears on the Day Detail and Week Detail screens. This is intentional: Home is a glanceable list, Detail screens are where you go to understand *why* a number is what it is.

## 3. Screens & navigation

```
Home  ──tap a day row──▶  Day Detail (for that day)
Home  ──tap the goal card──▶  Week Detail
Day Detail / Week Detail  ──back chevron──▶  Home
```

Only these three screens are designed here. Settings (weekly goal override, week-start-day, custom zone ranges) from the original README are **not yet designed** — flagged as a follow-up, not in scope for this handoff.

## 4. Visual language

- **Frame**: iPhone content area, 390×844pt, safe-area-ish padding of ~20–22px on all sides. No fake status bar is drawn — assume this sits below the real one.
- **Type**: system font throughout (San Francisco via `-apple-system`/`system-ui`). Numeric figures (minutes, points) use a monospaced/tabular-numeral style so digits align in lists — use SwiftUI's `.monospacedDigit()` modifier or the `ui-monospace` family.
- **Background**: `#FAF9F6` (warm off-white) app background; `#FFFFFF` cards with a 1px `#E8E5DE` border and 14–16px corner radius.
- **Primary text**: `#1F2430`. **Secondary/muted text**: `#8B8F98`. **Hairline dividers**: `#EEECE6`.
- **Accent (goal progress only)**: `#2E7D6B` (deep teal). This color is reserved for "progress toward the real weekly goal" — the Home goal card's fill bar, its "N pts left" text, and the "Today" row highlight. Don't reuse it elsewhere; it should stay a distinct signal for "this is the goal mechanic."

### Color roles (important — three separate palettes, don't mix them)

1. **Zone colors** (used only on Detail screens' per-zone list + ring):
   - Zone 1 — `#A8B3C4` (muted slate)
   - Zone 2 — `#5B9BD5` (blue)
   - Zone 3 — `#4CAF8C` (green)
   - Zone 4 — `#E8934A` (orange)
   - Zone 5 — `#D9564B` (red)
2. **Medium/High intensity colors** (used on Home's daily bars, and the "Medium vs High Intensity" card on both Detail screens):
   - Medium — `#8D7EC7` (violet)
   - High — `#4F3F87` (deep plum/indigo)
   - These were deliberately chosen from a *different hue family* (violet, monochromatic ramp) than the zone colors above. Early drafts reused the zone greens/oranges for Medium/High and it read as ambiguous — "is this Zone 3's color or Medium's color?" A completely different palette makes it visually obvious these are two different lenses on the same data.
3. **Goal-progress accent** — `#2E7D6B` (teal), see above. Never used for zone or intensity encoding.
4. **Mascot palette** (goal-reached celebration only, see §8) — warm gold `#FFC94A` / `#F0A93A`, kept separate again from the above three; confetti borrows from all the app's existing accent colors rather than introducing new ones.

## 5. Home screen

- Header: app title + settings gear (settings screen not designed yet).
- Week selector: `‹  This Week / Sep 21 – 27  ›`.
- **Goal card** (tappable → Week Detail): shows `{points} / {goal} pts`, a horizontal progress bar (`#EEECE6` track, `#2E7D6B` fill, width = `points/goal`), and `"{remaining} pts left"` / `"{percent}%"`. This is the one place on Home where a fixed-target progress bar makes sense, because it's a real target. **When `points >= goal`, the card switches to its celebration state and the "Zoomie" mascot appears — see §8 for the full spec.**
- Legend row: two dots — Medium Intensity · 1×, High Intensity · 2× — using the violet palette.
- **Daily Breakdown list**, one row per day: day abbreviation + date, a colored bar, the day's point total, a chevron (tap → Day Detail for that day).
  - **Bar scaling — read carefully, this was iterated on twice:** the bar is *not* a percentage of any fixed cap or "daily target" (there is no such thing as a daily goal in this product — only a weekly one). The bar's width is scaled **relative to the highest-scoring day currently visible** (i.e. `dayWidth% = dayPoints / maxDayPointsInWeek`). The single highest day renders at ~100% width; others scale down proportionally. There's deliberately no grey track/background behind these bars — a track implies a capacity being filled toward some target, and there isn't one at this level. Recompute the max, and thus every bar's width, whenever the visible week's data changes.
  - A day with both Medium and High points splits the bar into two segments, left-to-right, sized proportionally to that day's Medium points vs High points (e.g. a day with 10 medium pts / 16 high pts splits ~38%/62% *within* its own bar length).
  - A day with zero points (no qualifying activity at all, or only Zone 1 activity) renders **no bar** and no point figure — just muted italic `(no points)` text in place of the bar. Don't distinguish "literally no workout" from "worked out but only in Zone 1" — both collapse to this same blank-day treatment; that distinction only matters on the Detail screens where Zone 1 is shown explicitly.
  - The current day gets a subtle highlight: tinted background, teal left border, "Today" label instead of the date number.

## 6. Day Detail & Week Detail (share the same component structure)

Both screens are built from the same three stacked components; Week Detail is simply the same components fed a week's aggregated totals instead of one day's:

1. **Header**: back chevron + title only. Day Detail title is the date (e.g. "Wed, Sep 23") — **no subtitle underneath it**, keep it to just the date. Week Detail title is "This Week" with a subtitle that is **just the date range** (e.g. "Sep 21 – 27") — no other stats crammed in there; the ring and list below carry the numbers.
2. **"Medium vs High Intensity" card**: a small white card with a two-color legend (dot + label + points + percent for each of Medium/High) and a single full-width stacked bar beneath it (two segments, no grey — they always sum to 100% since it's a part-of-whole breakdown, not a progress-to-target bar). Same violet palette as Home. This card is identical in structure on both screens, just fed different totals (one day's medium/high points vs the whole week's).
3. **Per-zone ring + "By Zone" list**:
   - The ring is a **full donut with no grey/uncovered segment**. It shows each *contributing* zone's share of the total points earned (Day Detail: that day's points; Week Detail: that week's points). Since Zone 1 always contributes 0 points, it never occupies any part of the ring — this is automatic from the math, not a special case to code around. Arc order goes low zone → high zone, starting at 12 o'clock, clockwise. Center label: the total points figure + "points" caption.
     - Arc length for a contributing zone = `(zonePoints / totalPoints) × fullCircumference`. Stack arcs in ascending zone order with each arc's start offset equal to the negative sum of the lengths of all lower zones already placed. If a zone has 0 points, it simply contributes a 0-length arc (no special-case rendering needed).
   - Below the ring, the **"By Zone · Low to High" list**, one row per zone (1 through 5, always all five, even at 0):
     - Left: colored dot + "Zone N" + a small muted qualifier. For Zones 2–5 the qualifier is `"{Label} · {mult}×"` (e.g. "Hard · 2×"). **Zone 1 is the one exception: its qualifier is `"0× (not counted)"` instead of a label**, replacing what would otherwise be a separate disclaimer line — this keeps Zone 1 to one line like every other row instead of needing extra vertical space.
     - Right: two fixed-width columns so numbers align down the whole list — **minutes column, left-aligned, then points column, right-aligned**, e.g. a row reads `Zone 4   Hard · 2×          8 min   16 pts`. Use fixed-width containers (not just inline text with a margin) for both columns so every row's minute figures start at the same x position and every row's point figures end at the same x position, regardless of digit count.
     - Point values are **bold for every zone except Zone 1**, where the point value stays regular weight and muted-colored (reinforcing "this number will always be zero, don't worry about reading it"). This holds even when another zone's value happens to be 0 (e.g. Zone 5 with no time logged still renders its "0 pts" in bold) — the boldness rule is about *which zone* it is, not whether the value is nonzero.
     - The whole Zone 1 row is rendered at reduced opacity (~55%) to further set it apart from the zones that actually count.

## 7. Worked example (the dataset used throughout the mockups)

Useful for spot-checking an implementation against the mockups. One sample week, Sep 21–27:

| Day | Zone 1 (min) | Zone 2 (min) | Zone 3 (min) | Zone 4 (min) | Zone 5 (min) | Points |
|---|---|---|---|---|---|---|
| Mon 21 | 5 | 15 | – | – | – | 15 |
| Tue 22 | 4 | 18 | – | – | – | 18 |
| Wed 23 | 6 | – | 10 | 8 | – | 26 |
| Thu 24 | – | – | – | – | – | 0 (blank day) |
| Fri 25 | 5 | 10 | 5 | – | – | 15 |
| Sat 26 | 4 | – | – | 10 | – | 20 |
| Sun 27 (today) | 3 | – | 16 | – | – | 16 |

Week totals: Zone 1 = 27 min → 0 pts · Zone 2 = 43 min → 43 pts · Zone 3 = 31 min → 31 pts · Zone 4 = 18 min → 36 pts · Zone 5 = 0 min → 0 pts. **Total = 110 pts** against a 150 pt goal (40 pts left, 73%). Medium (Z2+Z3) = 74 pts / 67%, High (Z4+Z5) = 36 pts / 33%.

Day Detail mockup uses Wednesday: 6 min Zone 1 (0 pts, not counted), 10 min Zone 3 (10 pts), 8 min Zone 4 (16 pts) → 26 pts total, Medium 10 pts (38%) / High 16 pts (62%).

The `goal-reached.html` mockup uses a separate, higher example week (162/150 pts, +12 over) purely to demonstrate the celebration state — it isn't meant to reconcile with the table above.

## 8. Goal-reached celebration: "Zoomie" the star

When the current week's points reach or exceed the goal, the Home goal card switches into a celebration state and a small animated mascot — **"Zoomie," a five-pointed gold star with a face** — pops up over its top-right corner. This was chosen from three prototyped options (a heart, this star, and an EKG-wave blob) as the best mix of energetic and cute without being over the top. See `design/mockups/goal-reached.html` for a live, actually-animating reference — the description below is a translation of that CSS into implementation terms, not a substitute for looking at it.

### Trigger

Purely derived from data already on screen: `weeklyPoints >= weeklyGoal` for the week currently shown. No new inputs needed.

**Recommended behavior (implementer's call if this needs adjusting):**
- The **mascot itself dances continuously** for as long as the celebration state is showing (i.e. every time Home is viewed with that week's points at/above goal — not just once). It's subtle and charming enough that it holds up as an ambient idle animation, and this is much simpler to implement correctly than a one-shot-then-freeze state machine.
- The **confetti should NOT loop indefinitely** the way the prototype's CSS does (the mockup uses `infinite` purely for demo convenience, so it's always visible when you open the file). In the real app, fire confetti as a short burst — the same ~6 particles, ~1.5–1.7s total lifespan — once per appearance of the celebration state (e.g. once when the view appears while `weeklyPoints >= weeklyGoal` and it wasn't already true last time the view was visible, or simplest: once per app-foreground while the state is true). Continuous confetti would get visually noisy if someone leaves Home open.
- Track a simple "already celebrated this week" flag (keyed by the week's start date) only if you want to avoid re-bursting confetti every single time Home reappears within the same session — optional polish, not required for a first pass.

### Card changes in the celebration state

- Big number row keeps its normal `{points} / {goal} pts` format, and gains a small pill badge showing the overage, e.g. `+12`: white bold text, teal (`#2E7D6B`) rounded-pill background (`border-radius` large enough to be a full pill, ~`padding: 2px 8px`). Omit the pill if `points == goal` exactly (0 overage).
- Progress bar fills to 100% width (never draw past the container even at >100%) and gains a **shimmer**: a diagonal semi-transparent white streak (~30% of the bar's width, skewed ~-20°, `rgba(255,255,255,0.4)`) sweeping left-to-right on a ~2.1s loop, ease-in-out, repeating. Same track (`#EEECE6`) and fill (`#2E7D6B`) colors as the normal state.
- The bottom row's `"{remaining} pts left"` text is replaced with **`"Goal reached — nice work!"`** in bold teal (`#2E7D6B`). The percentage on the right keeps showing, now ≥100% (e.g. `108%`).
- Everything else about the card (padding, corner radius, border, tap target → Week Detail) is unchanged.

This celebration state is Home-only — Week Detail is the "quiet expanded view" of the same numbers and doesn't need its own mascot.

### Zoomie — visual construction

Anchored to the goal card's top-right corner, sized roughly 76×88pt, positioned so about half the character overlaps upward past the card's top edge (i.e. it visually "pops up" out of the card).

- **Body**: a simple 5-point star, single flat fill `#FFC94A` (warm gold) — no gradient. Reference path (SVG, 80×90 viewBox): `M40,4 L49,28 L75,28 L54,44 L62,70 L40,54 L18,70 L26,44 L5,28 L31,28 Z`.
- **Face**: two white circles (eyes, r≈5.5–6) each with a small dark-navy (`#1F2430`) pupil (r≈2.4–2.6) offset slightly down-right for a look of gazing cheerfully off to the side; two pale-gold blush ellipses (`#FFDD9E` at ~90% opacity); a simple curved smile (a single stroked arc, `#1F2430`, ~2.5pt, round cap, no fill — not a closed shape).
- **Limbs**: four rounded-cap strokes, ~9pt wide, not separate shapes — two "arms" swept up and outward from the star's upper side-points, two "legs" swept down and outward from its lower side-points. Arms use the body's gold (`#FFC94A`); legs use a slightly darker gold (`#F0A93A`) for a touch of depth/shadow.
- Overall it should read as a cute, chibi/kawaii five-pointed star with a face doing "jazz hands" — an original character, not a reference to any existing IP.

### Zoomie — motion

Three independent looping animations layered together (this is what makes it read as "dancing" rather than one flat bounce):

1. **Body** — period ~0.9s, ease-in-out, repeat forever. A combined rotate + scale "wobble-pop": rest at `rotate(-10°) scale(1.0)` → `rotate(12°) scale(1.08)` at ~30% through the cycle → `rotate(-4°) scale(0.95)` at ~60% → back to rest. Pivot point is the star's center.
2. **Arms** — period ~0.75s (faster than the body, so it visually layers rather than moving in lockstep), ease-in-out, repeat forever. Left arm swings `rotate(-16°)` ↔ `rotate(30°)`; right arm mirrors it, `rotate(16°)` ↔ `rotate(-30°)`. Pivot at each arm's shoulder point (roughly the star's upper-left/upper-right points).
3. **Legs** — same ~0.75s period. Left leg `rotate(14°)` ↔ `rotate(-18°)`; right leg mirrors, `rotate(-14°)` ↔ `rotate(18°)`. Pivot at each leg's hip point (the star's lower-left/lower-right points).

**Implementation note for SwiftUI:** this is straightforward to build as three or four overlapping `.rotationEffect` / `.scaleEffect` modifiers, each driven by its own `Animation.easeInOut(duration:).repeatForever(autoreverses: true)` state variable (one Double per moving part is enough — body-phase, arm-phase, leg-phase). If the team would rather not hand-roll the easing curves above (they're closer to a 3-keyframe spring than a plain autoreverse), an alternative is authoring this as a small Lottie or Rive file once and dropping it in as a package dependency — either approach is fine; the SVG path and color values above are the reference art either way.

### Confetti

~6 small particles per burst, mixing shapes (circles and 2pt-rounded squares), 6–8pt in size, colors drawn from the app's *existing* palette rather than introducing new confetti-specific colors: `#2E7D6B` (teal), `#FFC94A` (gold), `#5B9BD5` (blue), `#FF6F91` (pink — new, confetti-only accent, not used to encode any zone or category elsewhere). Scatter them loosely around/above the mascot. Each particle: fades in over the first ~18% of its lifetime, translates upward ~50pt while rotating up to ~200°, then fades out — total lifetime ~1.5–1.7s, ease-in-out. Stagger start times across the 6 particles by 0–0.8s so the burst feels organic rather than synchronized.

## 9. Explicitly out of scope for this handoff

- Settings screen (goal override, week-start-day picker, custom zone range editor) — mentioned in the original README, not designed yet.
- Any HealthKit read/aggregation logic — these mockups assume the data above is already computed; implementer wires up the real aggregation separately.
- Light/dark mode variants — mockups are light-mode only; colors above should get sensible dark-mode equivalents but none were designed here.
- The two mascot alternatives that weren't chosen (a heart character and an EKG-wave blob) — not documented here in detail since they weren't selected, but they existed in the same canvas if anyone wants to revisit the decision later (see link below).

## Reference

Live, editable version of all screens and the three original mascot options (canvas view, comments-enabled): https://claude.ai/artifact/W5QA47FLKUxhcgNr2ZpHo9
