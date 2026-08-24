# Gap-analysis checklist

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `prototype/`.

**What this file is.** A flat, complete list of the work required to bring the
Flutter app up to the prototype. It exists so the whole build can be seen at
once and checked against the app mechanically — something the prose sections
cannot do.

**How it is used.** As the input to issue generation, consumed once. The real
tracker is GitHub Issues on `maximsan/brewpath` (see
[`docs/agents/issue-tracker.md`](../agents/issue-tracker.md)); this is the
staging list that feeds it, not a living board. Nothing ticks these boxes.

**The contract every line holds to:**

- It is a **build task** — something a developer can do and a reviewer can verify against the running app.
- It is **not a decision.** Decisions live in [§5](05-mechanics.md) with their reasoning.
- It is **not an open question.** Unresolved calls live in [§11](11-open-items.md). A line here is blocked work, not a prompt to think.
- It **cross-links rather than re-explains.** Where a line carries a count or a rule, the linked section is the source of truth; if the two disagree, the section wins.

> Before generating issues, read [§11](11-open-items.md) first — several lines
> below are blocked on decisions recorded there, and a few (the three duplicate
> collectible titles, the `intro`/`takeaway` renderers, `cq-recent-terms`) are
> deliberately absent from this list because they are questions, not tasks.

---

## Foundation
- [ ] Two-mood colour token system + theme preference (light/dark/system, follows OS live, no flash on launch) ([§3](03-design-system.md))
- [ ] Illustration palette as a **separate** set from theme tokens — 8 bean/roast + 6 cherry tokens
- [ ] 9-step type ladder, 3 font families bundled
- [ ] Icon set (all inline SVG, ~20 marks) with one shared stroke-weight token
- [ ] Roasty component: parametric (roast/hat/gear/sprout) + 9 animation states (`points`, not `xp`)
- [ ] 10 tree-stage assets + `CoffeePersona` + `AnimatedTree` cross-fade
- [ ] iOS large-title collapsing header
- [ ] Bottom sheets: confirm, time picker, plan picker, term peek, card sheet, log result, recap, gate, share
- [ ] `ConfirmSheet.body` renders **multiple paragraphs** — a single `<p>` today, which blocks the approved delete copy ([§5](05-mechanics.md) 5.12)
- [ ] 44px minimum tap targets on edge controls
- [ ] **Two radius languages** — 2px editorial / 14px chrome / 999px pill, not a single scale
- [ ] Hairline-first separation; shadows only on sheets and floating buttons; selection as a double stroke, never a fill
- [ ] Port the **19 component state sets + 38 pattern rules** from `Design System.html` ([§3](03-design-system.md)) — the actual UI spec
- [ ] Empty states for every list, grid and drill — specified in the design system ([§3](03-design-system.md))

## Data model & persistence
- [ ] Persist + sync `progression` (streak, points, completed set, bestResults) — **not persisted in the prototype** ([§5](05-mechanics.md) 5.10)
- [ ] Persist `frozenDays` / `freezesSpent` separately
- [ ] The Saved shelf with prefixed keys and the `l|t|g` filter
- [ ] Brew state (active + startedAt + completed + saved)
- [ ] Plus / trial / subscription state, read from StoreKit rather than local flags
- [ ] Grove state as **two axes** (`variety` + `light`) + the `migrateGrove` legacy upgrade
- [ ] Offline: keep opened modules on device, sync when online (promised in the FAQ)
- [ ] Replace all frozen prototype dates/values — **including the second, dictionary-only frozen date** ([§5](05-mechanics.md) 5.11)

## Core loop
- [ ] Lesson player with 13 authored card kinds + the help drawer (10 entries, not one per kind — [§6](06-content.md) 6.2)
- [ ] `bagpick` card: green-bean rendering from process cues, sample draw, cue inspection
- [ ] Cherry cross-section (`CherrySection`) as both a lesson visual and a visual guide
- [ ] `RoastBean` progress + counter + save-lesson
- [ ] Term auto-linkification → peek sheet
- [x] Points rules: +10 first completion only (per-lesson value), +5 first coffee-challenge completion, 0 for replays, no perfect bonus, no mid-lesson toast ([§5](05-mechanics.md) 5.1) — [#160](https://github.com/maximsan/brewpath/issues/160)
- [ ] Mastery: best-ever percentage, `MASTERY_PASS = 0.8`, three states, never downgrades
- [ ] Review-confirm sheet + no-points review mode
- [ ] Reward routing incl. "next lesson only if authored" fallback
- [ ] Tree growth: **all 32 lessons core**, 10 stages, `CORE_TOTAL` derived from `MODULES` rather than hardcoded ([§5](05-mechanics.md) 5.3)
- [ ] Module/lesson gating recomputation
- [ ] Collectible unlock sync — grid shows **37** (training filtered out), earned cards plus exactly one locked teaser, then a "{n} more to collect" footer ([§5](05-mechanics.md) 5.6)
- [ ] Path: completed modules collapse and default to collapsed; in-progress and locked cannot collapse
- [ ] Reward screens are two-phase — `RoastyMoment` then content; module complete auto-advances at 2200 ms
- [ ] Lesson complete: card preview overlay, Practice again, challenge suggestion (and the Duel link in v2)
- [ ] Module complete: reward-card flip

## Streak
- [ ] Earn 1 per 7 days, cap 2, spend automatically
- [ ] Derived held count (never drifts)
- [ ] Week strip derived from real streak
- [ ] One-time dismissible save notice
- [ ] Streak screen + share sheet

## Content
- [ ] 5 modules / 32 lessons / 257 cards ported with typographic punctuation intact ([§6](06-content.md) 6.1)
- [ ] 72 dictionary terms (46 full) + 8 categories + cross-links + sources
- [ ] Dictionary third state (**Reference**): glyph, chip, To-learn filter exclusion, `REFERENCE ONLY` block, 8 terms
- [ ] Dictionary home: alias-matching search (deep-linkable + auto-focus), status filter with live counts, category grid, Term-of-Day banner, quick chips
- [ ] Flashcards: flip, prev/next, shuffle, jump-to-term, empty state
- [ ] Vocab game: setup phase (deck picker + round length with a `capped` guard), play, results with missed terms openable
- [ ] Saved screen: three groups (terms · lessons · guides), each hidden when empty, plus the "study as flashcards" row
- [ ] 37 collectible cards + 8 visual guides, all with bespoke art (**art complete — port, don't draw**)
- [ ] 13 mini-games over 7 kinds with content banks (69 rounds; [ADR-0005](../adr/0005-mini-games-are-many-games-per-kind-gated-by-topic.md))
- [ ] 12 coffee challenges
- [ ] Studio: 3 species × 4 light treatments, 8 visual guides, Roasty option tables

## Monetization

> ⚠️ **Every line in this block was written against the superseded feature-gating
> model.** The shipping model is a **content gate**: the first three lessons free ([ADR-0007](../adr/0007-free-tier-is-the-first-three-lessons.md)),
> permanently, the other twenty-nine paid, plus a cap of two learning/practice
> activities a day, a free Saved cap of **5**, and a dictionary tiered by depth
> ([PRODUCT.md](PRODUCT.md) §11, `docs/decisions.md` §7–§8, §11–§12). What
> **BrewPath Plus** buys is now **settled** on
> [Monetization shape](https://github.com/maximsan/brewpath/issues/29); the
> *offer* — trial, plan shape, paywall copy — is open at
> [Offers, plans and the paywall pitch](https://github.com/maximsan/brewpath/issues/55).
>
> **The lines below still under-describe the work**, because lesson gating is
> greenfield in both codebases and nothing here covers it. Generate issues from
> the decisions, not from this block.

- [ ] Paywall: single one-time purchase, no trial ([ADR-0003](../adr/0003-one-time-purchase-no-trial.md)), Restore/Terms/Privacy
- [ ] StoreKit: purchase, receipt validation, restore, real trial counter
- [ ] Restore Purchases with all **three** outcomes — restored / nothing to restore / failed — plus pending and error-retry ([§7](07-components.md) 7.3)
- [ ] Plus entitlement read from **StoreKit, not local state** — after delete + reinstall a paying subscriber must not see a paywall
- [ ] New account + Restore on the same Apple Account re-applies the subscription; deleted progress does not return
- [ ] Saved free cap of 5 → gate sheet at the cap, removal always allowed
- [ ] Studio as the only true v1 gate
- [ ] Subscription + Account screens, change plan, cancel (four labels: Cancel trial / Keep trialling / Cancel subscription / Keep Plus)
- [ ] Plus welcome screen
- [ ] **One** price list, not two — `customize.jsx` and `settings.jsx` currently each hold one

## Settings & compliance
- [ ] All 5 settings sections ([§6](06-content.md) 6.8)
- [ ] Reset progress: clear progression + brew (**including `saved`**) + `frozenDays` + `freezesSpent` + **the Saved shelf** + `recentTerms`; keep entitlement, Studio, theme ([§5](05-mechanics.md) 5.12)
- [ ] Reset confirm sheet: itemise **all** of what is lost — not just streak / points / lessons / tree, and now the Saved shelf too
- [ ] Account deletion is **permanent and immediate** — no recovery period ([§5](05-mechanics.md) 5.12)
- [ ] Deletion clears **everything**, including `brew`, the Saved shelf and Studio config
- [ ] Drive both wipes from **one registry**, never a hand-list at the call site, and port the prototype's dev guard as a build-failing test ([§5](05-mechanics.md) 5.12)
- [ ] Delete sheet warns rather than gates — no forced cancellation, exactly two actions
- [ ] Ship the approved delete body: permanent + irreversible, then the App Store subscription warning ([§5](05-mechanics.md) 5.12)
- [ ] Help FAQ (4 entries — the answers are spec)
- [ ] **About screen: 6 rows** — Privacy policy · Terms of use · Acknowledgements · Open-source licenses · Rate BrewPath · Say hello
- [ ] **Help screen: 2 contact rows** — Email support · Report a problem
- [ ] Real destinations for all 8 of the above: two legal URLs, an App Store review link, two mail composers, a licenses screen, an acknowledgements screen — every one is a `() => {}` stub today
- [ ] Privacy + Terms resolve to the **same** URLs from both About and the paywall
- [ ] Account and sync: status pill, plan line, "Sync over cellular" toggle, "This iPhone" row, Manage/Upgrade, Sign out
- [ ] Profile: 7 tappable blocks (tree, streak, mastery rollup → Path practice, brew stat, Studio, Saved, Duel in v2) — a menu, not a dashboard ([§7](07-components.md) 7.2)
- [ ] Mastery rollup hides entirely until at least one lesson has been played
- [ ] Local notifications for the daily reminder (8 preset times)

## Release hygiene
- [ ] Tweaks panel excluded from the store binary
- [ ] Verify `isV1`-gated code paths are either removed or correctly dark
- [ ] Drop the 8 dead props before porting — `ProfileTab` (`theme`, `onTheme`), `LearnTab` (6) ([§11](11-open-items.md))

---

← [Known open items](11-open-items.md) · [Contents](README.md) · [Suggested epics](13-epics.md) →
