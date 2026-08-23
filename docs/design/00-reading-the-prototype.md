# How to read the prototype

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `prototype/`.


## Where things live

| Thing | Where |
|---|---|
| App shell, phone frame, design tokens, CSS | `index.html` (1,350 lines) |
| Top-level state + routing + all flow wiring | `app.jsx` (1,436) |
| Course content (modules, lessons, cards, collectibles) | `data.jsx` (3,136) |
| Tab screens, streak, tree, card art, mini-game catalog | `screens.jsx` (2,883) |
| Lesson player + card renderers + mini-game player | `lesson.jsx` (1,512) |
| Dictionary data / screens / practice extras | `dictionary-data.jsx` (581) · `dictionary.jsx` (733) · `dictionary-extras.jsx` (488) |
| Mascot | `roasty.jsx` (868) |
| Icons, glyphs, stage names | `flavor-wheel.jsx` (503) |

## The eight files §0 used to omit

Everything below holds user-visible content or a card renderer, and none of it
was mapped before this pass.

| File | Lines | What it holds |
|---|---|---|
| `active-cards.jsx` | 297 | The three cards that replaced the read-only beats: `predict` (was `intro`), `decision` (was `practical`), `recall` (was `takeaway`). The rename is why `intro`/`takeaway` renderers sit unexercised ([§6.2](06-content.md)). |
| `practical.jsx` | 583 | `TasteFixCard`, the `VISUAL_GUIDE_CONTENT` guide content + art (8 guides), `VisualGuideCard`, `VisualGuideThumb`. |
| `bean-anatomy.jsx` | 345 | `CherrySection` (the interactive cross-section, `VISUAL_GUIDE_CONTENT.anatomy`), `GreenBean` (draws an unroasted seed from process cues), `BagPickCard` (card kind `bagpick`), `BAGPICK_ROUNDS`. **Load-order constraint: must evaluate before `lesson.jsx`,** which reads `BAGPICK_ROUNDS` at eval time. |
| `library.jsx` | 235 | The Saved / Favorites screen and shared bookmark affordances. **`ModuleScreen` and its two layouts were deleted** — module detail no longer exists as a screen. |
| `rewards.jsx` | 475 | Lesson complete, module complete, module reward card. |
| `settings.jsx` | 700 | `ConfirmSheet`, `TimeSheet`, About, Account-and-sync, `PLAN_OPTS`, `FAQ_ITEMS`, `REMINDER_TIMES`. |
| `customize.jsx` | 635 | Paywall, Studio hub, tree chooser, Roasty studio, mood player, and the option tables (`TREE_VARIETIES`, `GROVE_LIGHT`, `ROAST_OPTS`, `HAT_OPTS`, `GEAR_OPTS`, `SPROUT_OPTS`, `BACKDROPS`). |
| `gating.jsx` | 391 | `PLUS_FEATURES`, `PlusGateSheet`, `FeatureLock`, `RewardedAdScreen`, `RoastyGiftScreen`, `TrialBadge`. |

## Companion documents

| Thing | Where |
|---|---|
| Design-system documentation site | `Design System.html` + `ds-content.js` |
| Scope decision record | `v1 Readiness Audit.html` (reconciled Aug 2026; "Recommendation" is now "Decision") |
| QA record | `QA Findings.html` — rewritten Aug 2026 as *the state of the build, not its history* |
| **Content authoring rules** | **`CLAUDE.md`** — new. Seven rules governing what makes a good card ([§6](06-content.md) 6.9) |
| Tree-variety design proposal | `Tree Variety Proposal v2.html` — the two-axis grove model now in code ([§6.7](06-content.md)) |
| Screen gallery (live iframes) | `screens-overview.html` |
| Flow walkthroughs | `onboarding.html`, `lesson.html`, `module.html`, `challenge.html`, `dictionary.html`, `atlas.html`, `duel.html`, `customize.html`, `games.html`, `Coffee Tree.html`, `Mascot - Roasty.html`, `mascot-animations.html` |

**Deep links:** `index.html?screen=<slug>` routes straight to any of **104 states**
(`SCREEN_ROUTES`, `app.jsx:32`). `?screen=anim-<state>` renders a looping mascot
animation. This is the fastest way to see any screen.

**The `isV1` flag** (`app.jsx:172`, hardcoded `true`) is the master scope switch.
Everything gated by `!isV1` is deferred-to-v2 code that still exists in the
prototype.

> **Removed in `aa065bb`, so ignore any reference you find elsewhere:**
> `support.js` (the generated Claude Design authoring runtime),
> `ios-frame.jsx`, `Concept Card Interactivity.html`,
> `Tree Variety Proposal.html` (v1 of the proposal — v2 supersedes it),
> `Beans Review Plan.md`, `Modules 2-5 Review Plan.md`, and the untracked
> `screenshots/` and `scratch/` capture folders.

---

[Contents](README.md) · [Product in one paragraph](01-product.md) →
