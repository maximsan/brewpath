# BrewPath — v1 Design Reference

**Source:** the Claude Design prototype in this directory (`index.html` + 27 `.jsx` files, React 18 UMD + Babel-standalone, no build step).
**Purpose of this doc:** a single, complete inventory of what the prototype contains — screens, logic, content, assets, decisions — so it can be diffed against the mobile app and turned into implementation tickets.

Everything below is read out of the prototype source, not invented. Where the prototype and the design docs disagree, the source wins and the discrepancy is flagged.

> **Last re-derived against the source at commit `aa065bb` (Aug 2026).** The countable
> sections (§0 line counts, §4 routes, §6 content, §9 assets) come from a script
> that loads `dictionary-data.jsx` / `data.jsx` in a VM and walks the exported
> structures, not from reading prose. Re-run it after any design change rather
> than trusting the numbers here.

---

## Contents

| § | Section | Answers |
|---|---|---|
| **0** | [How to read the prototype](#0-how-to-read-the-prototype) | Which file holds what; what was deleted; how to deep-link a screen |
| **1** | [Product in one paragraph](#1-product-in-one-paragraph) | What BrewPath is |
| **2** | [Scope: what ships in v1](#2-scope-what-ships-in-v1) | v1 vs v2, counted by route; the tab bar |
| **3** | [Design system](#3-design-system) | Colour, type, radius, elevation, theming, Roasty, icons — **and the index of the 57 components specified in `Design System.html`** |
| **4** | [Information architecture](#4-information-architecture) | Tabs, header, **the four coming-soon modules shown to users**, the full 103-route list |
| **5** | [Core logic and mechanics](#5-core-logic-and-mechanics) | Points · mastery · tree · streak & freeze · gating · collectibles · Saved · brew challenges · Plus & trials · persistence · frozen values |
| **6** | [Content inventory](#6-content-inventory) | Course · card kinds · collectibles · dictionary · mini-games · brew challenges · Studio · settings |
| **7** | [Flows](#7-flows) | First run · daily loop · reward routing · replay · challenges · dictionary · paywall |
| **8** | [Deferred features — detail](#8-deferred-features--detail-for-v2-tickets) | Atlas · Duel · ads & trials · onboarding questions · mood player · Liberica art |
| **9** | [Assets](#9-assets) | What is raster, what is inline SVG, what the folders hold |
| **10** | [Known open items](#10-known-open-items) | QA re-verification · still open · closed · newly opened · the omission sweep |
| **11** | [Gap-analysis checklist](#11-gap-analysis-checklist) | The ticket-generation spine |
| **12** | [Suggested epics](#12-suggested-epics) | How to slice the build |

**Looking for something specific?**

| Question | Go to |
|---|---|
| What modules are we promising users next? | §4 — [the roadmap the Path tab shows](#the-roadmap-the-path-tab-shows-users-comingsoonpath-screensjsx1146) |
| How does a component look / behave? | **`Design System.html`**, indexed at §3 — not this doc |
| What changed in the last content pass? | §6.1 (two new lessons), §6.4 (dictionary tripled), §6.5 (three new mini-games) |
| What is deliberately *not* in v1? | §2 |
| What is broken or undecided? | §10 |
| What do I build first? | §11, then §12 |

---

## 0. How to read the prototype

### Where things live

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

### The eight files §0 used to omit

Everything below holds user-visible content or a card renderer, and none of it
was mapped before this pass.

| File | Lines | What it holds |
|---|---|---|
| `active-cards.jsx` | 297 | The three cards that replaced the read-only beats: `predict` (was `intro`), `decision` (was `practical`), `recall` (was `takeaway`). The rename is why `intro`/`takeaway` renderers sit unexercised (§6.2). |
| `practical.jsx` | 583 | `TasteFixCard`, the `TRAINING` guide content + art (8 guides), `TrainingCard`, `TrainingThumb`. |
| `bean-anatomy.jsx` | 345 | `CherrySection` (the interactive cross-section, `TRAINING.anatomy`), `GreenBean` (draws an unroasted seed from process cues), `BagPickCard` (card kind `bagpick`), `BAGPICK_ROUNDS`. **Load-order constraint: must evaluate before `lesson.jsx`,** which reads `BAGPICK_ROUNDS` at eval time. |
| `library.jsx` | 518 | Module detail (two layouts), the Saved / Favorites screen, shared bookmark affordances. |
| `rewards.jsx` | 475 | Lesson complete, module complete, module reward card. |
| `settings.jsx` | 700 | `ConfirmSheet`, `TimeSheet`, About, Account-and-sync, `PLAN_OPTS`, `FAQ_ITEMS`, `REMINDER_TIMES`. |
| `customize.jsx` | 635 | Paywall, Studio hub, tree chooser, Roasty studio, mood player, and the option tables (`TREE_VARIETIES`, `GROVE_LIGHT`, `ROAST_OPTS`, `HAT_OPTS`, `GEAR_OPTS`, `SPROUT_OPTS`, `BACKDROPS`). |
| `gating.jsx` | 391 | `PLUS_FEATURES`, `PlusGateSheet`, `FeatureLock`, `RewardedAdScreen`, `RoastyGiftScreen`, `TrialBadge`. |

### Companion documents

| Thing | Where |
|---|---|
| Design-system documentation site | `Design System.html` + `ds-content.js` |
| Scope decision record | `v1 Readiness Audit.html` |
| QA record | `QA Findings.html` (re-verified Aug 2026) |
| Tree-variety design proposal | `Tree Variety Proposal v2.html` — the two-axis grove model now in code (§6.7) |
| Screen gallery (live iframes) | `screens-overview.html` |
| Flow walkthroughs | `onboarding.html`, `lesson.html`, `module.html`, `challenge.html`, `dictionary.html`, `atlas.html`, `duel.html`, `customize.html`, `games.html`, `Coffee Tree.html`, `Mascot - Roasty.html`, `mascot-animations.html` |

**Deep links:** `index.html?screen=<slug>` routes straight to any of **103 states**
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

## 1. Product in one paragraph

BrewPath is a Duolingo-shaped coffee-education app. A short daily lesson made of swipeable cards teaches one coffee idea; finishing it pays points, ticks a streak, unlocks a collectible card, and grows a coffee tree that is the single visual metaphor for overall progress. A companion mascot (Roasty, an anthropomorphic coffee bean) reacts to every beat. A Coffee Dictionary sits one tap away and cross-links into lessons. Optional real-world "Brew Challenges" push the learning off-screen. Monetization is a generous free tier plus a **BrewPath Plus** subscription whose two levers are an unlimited Saved shelf and a personalization Studio.

---

## 2. Scope: what ships in v1

Locked in `v1 Readiness Audit.html` (June 2026, reconciled July 2026) and enforced by `isV1` in code.

### Counted by route

`SCREEN_ROUTES` holds **103 deep-link states**, of which **34 are `!isV1`**:
onboarding questions (8) · Atlas (10) · Duel (13) · trials (2) · mood player (1).
That leaves **69 v1 routes**.

Routes are not screens. Of the 69, **20 open the lesson player** at a given card
kind and **7 open the mini-game flow** — deep-link conveniences, not distinct
destinations. Collapsing those leaves roughly **44 distinct v1 destinations**.

> The previous "≈38 screens of ~64 built" could not be reproduced from any
> countable thing in the source and has been replaced by the route arithmetic
> above, which can. Treat "44" as *destinations you can navigate to*, not as a
> screen-file count.

### In v1
| Area | Notes |
|---|---|
| App intro | Welcome + Meet Roasty. Content only, no questions. |
| Learn + Path + Lesson player | The core loop. |
| Rewards + collectible cards | Lesson complete (3 variants), module complete, collectible card, module challenge. |
| Profile + progress + Settings | Profile, tree, streak, settings, about, help, account, subscription. |
| Coffee Dictionary | Home, term, term-locked, term-reference, term-of-day, flashcards, vocab game, peek sheet. |
| Plus + Studio + Saved | Paywall, Plus welcome, Studio hub, tree chooser, Roasty studio, Saved shelf. |
| Brew Challenge | Today card (3 states), log sheet, recap sheet, module challenge screen, path nodes, card stamps. |

### Deferred to v2 (built, but switched off)
| Feature | Routes | Why deferred |
|---|---|---|
| **Coffee Atlas** | 10 | Second content vertical: 15 origins, activities, regions, passport, stamps. Needs as much writing/art as the course. |
| **Coffee Duel** | 13 | Async social. Needs share + server infra: invites, pending/expired/error, rematch, link resolution, result sync. |
| **Rewarded ads + timed trials** | 2 | Needs an ad SDK. Includes the perfect-module gift unlock. |
| **Onboarding question flow** | 8 | Nothing reads the answers in v1. Welcome + Meet Roasty stay. |
| **Mood player** | 1 | Delightful extra; ships with Studio depth in v2. |
| Cosmetic IAPs, weekly-goal setting, data export | — | Explicitly deferred. |
| Lifetime tier, paid streak protection | — | **Dropped, not deferred.** Reasons recorded in the audit. |
| **Four future course modules** — Espresso Basics · Milk Drinks · Brewing Gear · Coffee Tasting | 0 built | Not built at all, but **named to users** on the Path tab by `ComingSoonPath` (§4). Unwritten content, not switched-off code. Two lessons have been pulled forward out of them into v1 (§4). |

### Tab bar
**v1: four tabs — Learn · Path · Cards · Profile.** Atlas is removed from the tab bar (`app.jsx` force-redirects `tab === 'atlas'` back to `learn`). Dictionary and Saved stay as pinned top-right header entries.

---

## 3. Design system

### Color tokens (two moods, one system)
Documented in `ds-content.js`; defined in `index.html`. **Unchanged since the last pass.**

| Token | Role | Cupping (light) | Dark Roast (dark) |
|---|---|---|---|
| `--bg` | Page canvas | `#F4EFE6` | `#1A130E` |
| `--surface` | Raised surface (cards, rows, sheets) | `#FBF7EE` | `#251B14` |
| `--surface-2` | Recessed fill (icon wells, card backs) | `#EFE8DA` | `#30231A` |
| `--ink` | Primary text | `#1B1614` | `#F3E7D2` |
| `--ink-mute` | Secondary text, all inactive icons | `#6B5F54` | `#B59E84` |
| `--rule` | 1px hairlines — the structural grid | `#D8CFBF` | `#44321E` |
| `--accent` | The one brand colour (crema orange). Actions, active tab, links, current step, needs-practice | `#B8533A` | `#E07A4F` |
| `--accent-ink` | Text on accent fill | `#FBF7EE` | `#1A130E` |
| `--sage` | Success = "learned". Correct answers, learned terms, pass mark. **Never an action.** | `#5F6E55` | `#97A285` |
| `--warn` | **Celebration only.** Streak flame, win crown, completion glow, fastest answer | `#9A5F1C` | `#E6A35C` |
| `--berry` | Alert. Wrong answers, cross mark, destructive | `#A8362A` | `#C75450` |
| `--cream` | (dark only) | — | `#F0DCB8` |

**Illustration palette** — literal coffee, identical in both moods, never theme tokens.
The cherry-anatomy work (§6.1, `m1l7`) added eight tokens to what was a six-token set:

| Group | Tokens |
|---|---|
| Bean / roast | `--art-raw #9FB088` · `--art-roast-light #C79A63` · `--art-roast-mid #A2703C` · `--art-roast-deep #7A4526` · `--art-roast-dark #54301C` · `--art-ripe #C8843A` · `--art-sour #B79A3C` · `--art-seed-crease #5C6B52` |
| Cherry cross-section | `--art-cherry-skin #A93227` · `--art-cherry-pulp #C9563A` · `--art-cherry-gel #D9A94C` · `--art-cherry-parchment #E3D2AE` · `--art-cherry-silverskin #F1E8D6` · `--art-cherry-seed #8FA184` |

The separation from theme tokens is deliberate: keeping cherry/bean colours out of `--warn` is what lets `--warn` mean exactly one thing.

### Typography — 3 families, one 9-step ladder, nothing off-ladder
- **Fraunces** (serif, variable) — display, weight 400
- **IBM Plex Sans** — body 400, controls 500
- **IBM Plex Mono** — numerals, labels, smallcaps, weight 500, tabular-nums

| Token | Size | Use |
|---|---|---|
| `--t-hero` | 56px | mono hero numeral, celebration only |
| `--t-display` | 30px | screen title |
| `--t-title` | 26px | card / section title |
| `--t-heading` | 19px | card & row heading |
| `--t-lead` | 17px | lead paragraph |
| `--t-body` | 15px | body, controls |
| `--t-support` | 13px | support text |
| `--t-label` | 11px | labels, smallcaps |
| `--t-micro` | 9.5px | micro |

### Frame & layout
- Phone: 393 × 852 (iPhone 15), 56px corner radius, dynamic island, status bar, home indicator.
- Horizontal gutter: `.px-24` (24px); tight layouts drop narrower.
- iOS large-title pattern: large in-flow title scrolls away, compact blurred sticky header appears at `scrollTop > 72`.
- Header edge controls are 44×44 (fixed during QA).

### Radius — two languages, deliberately

There is **one radius token** (`--r: 14px`). Everything else is a rule, not a scale:

| Radius | Language | Where |
|---|---|---|
| **2px** | Editorial | Cards, buttons, inputs, MCQ & match tiles. The sharp, print-like default. |
| **14px** (`--r`) | Soft chrome | Media frames, bottom sheets, icon wells, avatars, mini-game tiles. 14px is the token; 12–20 is the range other chrome may sit in. |
| **999px** | Pill / dot | Status dots, fav toggle, switch toggles, badges, home indicator. |

> **"Mixing them on one element is the tell of an off-system component."**
> Two radius languages run in parallel on purpose; they are not points on one scale.

> ⚠️ **Correction.** Earlier versions of this doc listed a "radius scale of
> 4 / 12 / 14 / 16 / 20 / 999". No such scale exists in the source — `--r` is
> the only radius token, and the editorial default is **2px, not 4px**. An
> implementation built from the old line would round every card and button
> wrong.

### Borders & elevation
- **Hairlines do the work.** 1px `--rule` separates almost everything; shadows are reserved for sheets and floating buttons only.
- **Selection = double stroke.** A selected card keeps its border and adds `inset 0 0 0 1px var(--accent)` — a crisper edge, never a fill.

### Theme handling
Preference is `light | dark | system`, stored in `localStorage['cq-theme']`, default `dark`. `system` follows `prefers-color-scheme` live. A pre-paint inline script in `index.html` applies it before first render to avoid flash. Cross-iframe sync via the `storage` event.
DOM contract: `data-mood="dark-roast" | "cupping"` on `<html>`, plus a legacy `data-theme="dark"` alias.

### Mascot — Roasty (`roasty.jsx`, 868 lines)
A pure-SVG coffee bean character, fully parametric. **9 animation states** (`ROASTY_ANIM_META`):

| State | Animation | Beat |
|---|---|---|
| `idle` | breathes, leaf sways | loops |
| `correct` | hop + sparkles | 1750ms |
| `wrong` | soft wobble | 1350ms |
| `points` | wink + points rise | 2150ms |
| `lesson` | jump + confetti | 1950ms |
| `module` | grow + rays | 1850ms |
| `card` | shimmer + glow | loops |
| `sleep` | slow breathe + Zzz | loops |
| `awake` | pop open | 1400ms |

> The state formerly called `xp` is now **`points`**, matching the rename of the
> currency throughout. `?screen=anim-points`, not `anim-xp`.

Roasty accepts `roast`, `hat`, `gear`, `sprout` props, read from `window.ROASTY_CONFIG`, so every instance app-wide reflects the user's Studio look.
Also in the file: `RoastyLoadingScreen` (branded splash, auto-advances), `RoastyMoment` (full-screen celebration beat), `ReplayButton`, `RoastyAnimScreen`.

### Icon set (`flavor-wheel.jsx`, all inline SVG)
`IconCup` (Learn) · `IconRoute` (Path) · `IconCards` (Cards) · `IconLeaf` (Profile) · `IconGlobe` (Atlas, v2) · `LockMark` · `Chevron` · `BackMark` · `CloseMark` · `CheckMark` · `Bookmark` · `FreezeMark` · `SteamMark` · `ProfileBean` · `PointsBean` · `RoastBean` (lesson progress) · `FlavorWheel` · `FlavorStamp` · `BrewCup` · `BrewStamp` · `LockGlyph`.

`GLYPH_STROKE` is the single source of truth for stroke weight across every 24×24 concept glyph (nav, duel types, dictionary categories) — added so the weight can't drift again.

The nav icons carry a rationale per shape ("one tab, one coffee-vocabulary
shape", 24×24, stroke 1.6, outlined `--ink-mute` inactive / filled `--accent`
active). Five concepts are drawn and v1 ships four — `IconGlobe` is kept so the
family stays whole.

> **An undocumented nav variant lives in the icon notes.** The Learn tab is
> labelled `TODAY` "in the shipped tab nav; it becomes `LEARN` only in the
> **merged nav model, where Path folds into it**." That merged model is
> referenced as though it exists but is specified nowhere else in the
> prototype — no route, no component. Treat it as an unresolved IA option, not
> a plan.

### The design system is specified far beyond this section

`Design System.html` + `ds-content.js` document **57 components and patterns**
across 9 sections — component states, interaction rules, and the reasoning for
each. §3 above covers only the foundations (colour, type, shape, icons). **For
any question about how a specific component looks or behaves, that site is the
source, not this doc.** Reproducing it here would double this file; what follows
is the index so you know what exists.

**Sections:** Intro · Colors · Type · Shape · Icons · Components · Games · Gating · Flags.

**19 components with documented state sets** (`compStates` — each lists every
state, its demo, when it applies, and its token spec):

> Buttons · Pick card · Pick tile · MCQ choice · Lesson row · Status chips ·
> Match tiles · Save toggle · Collectible card · Term status chip · Term row ·
> Term of the Day · Lesson reference card · Bean node · Roast meter ·
> Fill-in-the-blank · Taste Fix card · Sheet layers · Toggle

**38 patterns with documented rules** (`compRules` — purpose, example markup, and the rules that govern it):

| Group | Patterns |
|---|---|
| Forms & input | Form row · Slider · Search field · Segmented control · Settings / nav row |
| Dictionary | Term entry header · Pronunciation chip · Related chips · Knowledge check · Labelled block · In practice block · Sources list · Dictionary quick chips · Term peek sheet |
| Progress & reward | Mastery rollup · Points mark · Points chip · Sequence row · Brew challenge card |
| Layout & chrome | Card or section · **Empty state** · Screen top bar · Header buttons · Sticky action bar · Scrims and dims · Media frame · Media overlay button |
| Sheets | Bottom sheet · Result sheet |
| Plus & gating | Lock affordances · Plus gate sheet · Rewarded ad |
| Games | Card cue · Round length |
| Brand & boot | Roasty, the companion · Intro screen skeleton · Tap to continue · Brand mark · Loading sequence |

**Empty states are specified there and nowhere in this doc** — worth knowing before anyone writes an empty-state ticket from §11.

**The `FLAGS` register.** The design-system site carries its own audit register
(severity `high` → "NEEDS DECISION", `med` → "SHOULD FIX", `low` → "POLISH",
plus resolved entries with an `APPLIED` note). **It is currently empty —
`FLAGS = []`, rendering "No open flags".** The site's convention is that fixes
are folded into the rule they changed rather than logged, so the register only
ever holds live drift. An empty register means no known design drift, not that
nobody looked.

---

## 4. Information architecture

### Tabs (v1)
| Tab | Screen | Content |
|---|---|---|
| **Learn** ("Today") | `LearnTab` | Date header, freeze-save notice, Continue Learning card, active Brew Challenge, saved challenges, Practice Again (collapsible: Lessons, Mini-games) |
| **Path** | `PathTab` | Vertical module path with lesson nodes, mastery bean fill, brew-challenge nodes, and the four named coming-soon modules (`ComingSoonPath`) |
| **Cards** | `CardsTab` | Collectible card grid; tap → `CardSheet` |
| **Profile** | `ProfileTab` | Tree hero, streak card + week strip, points line, mastery rollup, brew-challenge stat, Studio card, Saved card, joined date |

### Global header (`AppHeader`)
Pinned top-right: **Saved** (with count badge, lock badge if gated) and **Dictionary**. Profile variant swaps in a gear → Settings. Duel entry is present but `showDuel={!isV1}`.

Per-tab eyebrow + title (`APP_HEADER_TITLES`, `screens.jsx:713`) — user-visible copy, declared in code rather than content:

| Tab | Eyebrow | Title |
|---|---|---|
| Learn | `TODAY` | The date, e.g. "Friday, May 8" (**frozen** to `new Date(2026, 4, 8)` — see §5.11) |
| Path | `YOUR PATH` | Beginner Foundations |
| Cards | `YOUR DECK` | Collection |
| Profile | `PROFILE` | `Hello, ` + `USER.name` + `.` — "Hello, Taster." with the seed user |

"Beginner Foundations" is the only name the five-module course is given anywhere in the product.

### The roadmap the Path tab shows users (`ComingSoonPath`, `screens.jsx:1146`)

The Path tab does not end at Brew. Below the last module it renders the app's
**own user-facing roadmap** — four named future modules, declared as a local
array in the component, not in `data.jsx`:

| id | Title | Category glyph |
|---|---|---|
| `espresso` | **Espresso Basics** | `espresso` |
| `milk` | **Milk Drinks** | `milk` |
| `gear` | **Brewing Gear** | `equipment` |
| `tasting` | **Coffee Tasting** | `sensory` |

> ### ⚠️ Those seven lines are the entire specification
>
> **Searched: every `.html`, `.js`, `.jsx` and `.md` in `brew-path/`, and the
> whole repository.** The strings "Espresso Basics", "Milk Drinks", "Brewing
> Gear" and "Coffee Tasting" appear in exactly **one** place —
> `screens.jsx:1147–1152`, the array above. (Two other hits are false positives:
> `dictionary-data.jsx` cites an external Perfect Daily Grind article *titled*
> "Espresso Basics", and `docs/17-glossary.md` uses "coffee tasting" as a common
> noun.)
>
> There is **no** lesson list, card count, ordering, learning objective, scope
> estimate, or written rationale for any of the four. Anywhere.
>
> **`v1 Readiness Audit.html` — the document that records what ships and what
> defers — does not mention them at all.** Zero hits for espresso, milk, gear,
> tasting, future, roadmap-content, coming, or later. Its "v2 roadmap" line
> names only Atlas and Duel as "two finished headline features waiting."
>
> So these four were never a recorded scope *decision*. They are four UI strings
> that shipped into a user-facing surface. **That gap is the finding** — not
> something this doc failed to collect.

This is a **product commitment visible to users**, not internal backlog. Treat it
as content: anything that would move one of these four into v1, or drop it, is a
change to something users have already been shown — and there is no design
record to check the change against.

**What would have to be decided before any of them is buildable:** how many
lessons each holds, in what order, which existing dictionary terms they claim
(the Espresso category already carries 7 terms, three of which now point at
`m5l7`), which collectibles and brew challenges they add, and whether "Coffee
Tasting" absorbs the parked Taste module wholesale or re-authors it. None of
that exists yet.

**Two variants, only one wired up.**

- `compact` — a dashed sage node, the smallcaps line "More coming soon", and the four titles joined by `·`. This is the **only variant rendered** (`screens.jsx:1454`).
- Full — a dotted trail continuing the path spine, an `ON THE HORIZON` eyebrow, the heading "More coffee adventures coming soon", the lead "New modules on espresso, milk drinks, brewing gear, and tasting skills are planned", and a 2×2 grid of dashed cards, each with its category glyph and a "Coming soon" chip. **Defined but never called** — still dead code, and still a design worth reviewing before it is either built or deleted.

**Relationship to the §5.5 gating rule.** These four are *not* locked `MODULES`
entries. `syncModuleProgress` locks a module when the previous one is incomplete
**or its content is unauthored** (`window.LESSONS[m.lessons[0].id]` missing) —
that rule governs the five modules that exist in data. `ComingSoonPath` is
separate: a hardcoded teaser for modules with no `MODULES` entry at all. The
gating rule keeps *unauthored* modules locked; this component advertises
*unbuilt* ones.

> **v1 scope.** All four are v2. **Coffee Tasting** is where the mobile app's
> existing Taste module is parked intact. **Two lessons have been pulled forward
> into v1:**
> - "Choosing your first grinder" (`m4l7`) out of **Brewing Gear**, into Grind. Espresso grinders stay with Espresso Basics.
> - "Espresso, in one small cup" (`m5l7`) out of **Espresso Basics**, into Brew. It is a single orientation lesson — 6 cards, no brew challenge, because a challenge would ask for a machine the learner does not own.
>
> Both are deliberate one-lesson previews of a v2 module. A third would stop
> reading as a preview and start reading as a broken promise about what
> "Espresso Basics" still contains.

### Full route list (103 deep-link states)

**Boot / intro** — `loading`, `welcome`, `meet`
**Onboarding questions (v2)** — `expectation`, `goal`, `brewer`, `commitment`, `experience`, `motivations`, `reminders`, `onboarding-done`
**Tabs** — `learn`, `path`, `cards`, `profile`
**Lesson** — `lesson`, `lesson-grind`, `lesson-ratio`, `lesson-taste`, `lesson-layers`
**Lesson cards (open a lesson at a given card kind)** — `card-predict`, `card-concept`, `card-mcq`, `card-multi`, `card-match`, `card-slider`, `card-sequence`, `card-decision`, `card-recall`, `card-visual`, `card-anatomy`, `card-bagpick`, `card-tastefix`, `card-practical`, `card-training`
**Mini-games** — `game-intro`, `game-flavor`, `game-quiz`, `game-bagpick`, `game-tastefix`, `game-calibrate`, `game-sequence`
**Rewards** — `lesson-complete`, `lesson-complete-weak`, `lesson-complete-perfect`, `module-complete`, `module-card`, `module-challenge`
**Brew Challenge** — `today-challenge`, `today-challenge-done`, `today-nochallenge`, `today-challenge-log`, `path-challenge`, `path-challenge-open`, `card-stamp`, `card-stamp-locked`
**Progress** — `streak`, `tree`
**Cards** — `cardsheet`
**Settings** — `settings`, `about`, `help`, `account`, `subscription`
**Plus** — `paywall`, `plus-welcome`, `studio`, `tree-chooser`, `roasty-studio`, `mood-player` (v2), `saved`
**Trials (v2)** — `rewarded-ad`, `roasty-gift`
**Dictionary** — `dictionary`, `term`, `term-locked`, `term-reference`, `term-of-day`, `flashcards`, `vocab-game`
**Atlas (v2)** — `atlas`, `atlas-loading`, `origin`, `origin-tabbed`, `atlas-region`, `atlas-activity`, `passport`, `passport-empty`, `atlas-stamp`, `atlas-stamp-lesson`
**Duel (v2)** — `duel`, `duel-empty`, `duel-pick`, `duel-play`, `duel-result`, `duel-invite`, `duel-sent`, `duel-received`, `duel-comparison`, `duel-loss`, `duel-rematch`, `duel-expired`, `duel-error`

> ⚠️ **Three route counts are in circulation.** This doc says **103** (keys in
> `SCREEN_ROUTES`). `QA Findings.html` says 96 in its hero and "all 97 routes"
> in its closed-defects note — both predate the routes added for `m1l7`,
> `m5l7`, the new mini-games and `term-reference`. 103 is the number to trust;
> the others are historical.

---

## 5. Core logic and mechanics

This is the part most likely to be missing or wrong in an implementation. Every rule below is enforced in code.

### 5.1 Points

The currency is **points** throughout — code, copy and mascot state. "XP" no
longer appears in the source; treat it as a legacy name.

- **+10 points, flat, for a first lesson completion.** The value is per-lesson data (`MODULES[].lessons[].points`, currently 10 for all 32) with a `|| 10` fallback in `app.jsx:760` — so it is tunable per lesson without touching code.
- **Replays pay 0.** A completed lesson opens through a review-confirm sheet; review mode grants no points and skips the reward screens entirely.
- **Perfect earns no bonus** — "mastery is the reward there."
- **+5 points for the first completion of a Brew Challenge** (`app.jsx:605`). Replays pay 0.
- Points are **effort/habit only**. They do not drive the tree, unlocks, or mastery.
- Mid-lesson correct answers show **no points toast** — feedback is purely qualitative (Roasty reacts). Points appear only on the result screen.

### 5.2 Mastery (separate from points)

Derived from the **best-ever** `{correct, total}` per lesson, as a **percentage** (lessons differ in length). `MASTERY_PASS = 0.8`.

| State | Condition | Label shown? |
|---|---|---|
| `needs-practice` | < 80% | Yes — "Needs Practice", amber chip. The only labelled state. |
| `mastered` | 80–99% | No label; the bean node shows fill level |
| `perfect` | 100% | No label; celebrated once, and triggers the (v2) gift |

Best-ever **never downgrades** on a worse replay. A replay *can* improve mastery even though it grants no points.

**Graded card kinds** (`lesson.jsx:146`): `mcq`, `multi`, `match`, `slider`, `sequence`, `tastefix`, **`bagpick`**, `decision`, `recall`.
**Ungraded:** `predict`, `concept`, `practical`, `visual` (+ the unexercised `intro`, `takeaway`).

### 5.3 The Coffee Tree (`data.jsx`)

- Grows **only** from first-time completion of **core** lessons. Replays, challenges, duels and mini-games never grow it.
- `stage = clamp(1..10, round(1 + (coreDone / coreTotal) * 9))` — **10 stages over 32 core lessons.**
- ⚠️ **The denominator changed.** `CORE_LESSON_IDS = MODULES.flatMap(m => m.lessons.map(l => l.id))`, so **every lesson is now core** and `CORE_TOTAL = 32`. The old model (15 core lessons out of 30, with the rest off-path) no longer exists — there is no non-core lesson in the build. Any implementation carrying the 15 is wrong, and will advance the tree more than twice as fast as the prototype.
- Stage names: `SEED · SPROUT · SAPLING · BUDDING · FLOWERING · GREEN CHERRY · TURNING · RIPENING · NEAR HARVEST · HARVEST` (`window.STAGE_NAMES`, `flavor-wheel.jsx`).
- A weak first completion still grows the tree.
- Never shrinks except on Reset Progress.
- Art: 10 PNGs in `assets/trees/1.png`…`10.png` (`CoffeePersona`), with `AnimatedTree` cross-fading from → to stage on reward screens. The Studio's variety/light choice composes over the same art as a CSS transform + filter (§6.7).
- ✅ **Closed:** the second, 7-item stage-name list that used to live in `app.jsx` for the reset-confirmation copy is gone. `STAGE_NAMES` is now the only list.

### 5.4 Streak and streak freeze

The freeze is a **mechanic, not a setting** — there is deliberately no toggle.

- Earn: **1 freeze per 7 consecutive days**, cap **2 held**.
- `freezesHeld = clamp(0..2, floor(streak / 7) - freezesSpent)` — derived, so it can never drift.
- Spent **automatically** when a day is missed. The streak survives; the day renders as covered in the week strip.
- Two deliberately-separate facts:
  - `frozenDays` — which days of *this week* a freeze covered. Presentational, clears on week rollover.
  - `freezesSpent` — lifetime count. Drives held count, clears only on Reset Progress.
  (Conflating them was a shipped bug: spent freezes silently refunded themselves weekly.)
- The **save notice** shows once on the Learn tab after a freeze covers a miss, then is dismissible. Framing is reassurance first, cost second — "someone returning after a miss is the most fragile user in the app."
- Week strip filled days **derive from the streak**, clipped to week start (fixed defect: they used to be hardcoded Mon–Fri and could lie).
- Streak is **free forever** — paid streak protection was explicitly dropped.
- `StreakScreen` + `ShareStreakSheet` (share targets) exist.

### 5.5 Progression gating (`data.jsx`)

`syncModuleProgress(completedSet)` recomputes on every render:
- Finished lesson → `complete`; first unfinished in an unlocked module → `current`; rest → `locked`.
- A module unlocks when the **previous module is fully complete AND its own first lesson is authored** in `LESSONS`. Unauthored future modules stay locked.
- This rule covers modules that **have a `MODULES` entry**. The four future modules users are shown below the path have no entry at all — they come from `ComingSoonPath` (§4), a separate hardcoded teaser. Do not conflate the two.
- Module 1 is authored open.
- Resetting progress re-locks everything correctly.
- `syncMastery(bestResults)` runs alongside it, stamping each lesson with its mastery state so Path / Learn / module cards can show it.

### 5.6 Collectible cards (`data.jsx`)

`syncCollection(completedSet)`:
- A **lesson card** unlocks when its lesson completes.
- A **module Field Guide card** unlocks when every lesson in the module is done.
- **Training cards** have no `unlock` and are earned from the start.
- Locked cards render a `LockedSilhouette`.
- A card can carry a **Brew Challenge stamp** — a permanent "I tried this for real" mark pressed onto the card once the linked challenge is logged.

### 5.7 Saved shelf / favorites

- Persisted to `localStorage['cq-favorites']` as a `Set` of prefixed keys: `l:` lesson, `t:` term, `g:` guide, `c:` collectible card.
- **Only `l:` / `t:` / `g:` count as "Saved"** and appear on the Saved screen or in the header badge. Card favourites do not.
- **Free cap: 10** (`SAVED_FREE_MAX`). Adding past the cap raises the Plus gate sheet. **Removing is always allowed**, so a capped free user can still curate.
- Plus lifts the cap. This is the paywall's primary concrete hook.
- Seed favourites: `l:m1l1`, `c:c1`, `t:arabica`, `t:bloom`, `t:crema`.

### 5.8 Brew Challenges (`brew-challenge.jsx`)

Small, optional **real-life** tasks. They never block learning, streaks, points, cards or progress.

- **12 challenges**: one capstone per module (5) + lesson challenges on the most hands-on lessons (7). *(§5.8 previously said 9 while §6.6 listed 12 — the list was right.)*
- Shape: `{ id, type: 'module'|'lesson', moduleId, lessonId?, cardId, title, instruction, effort, reactions[3] }`.
- State: one `activeId` + `startedAt`, a `completed` Set, a `saved` (parked-for-later) Set. Persisted to `localStorage['cq-brew']`.
- **48-hour active window** (`BREW_WINDOW_MS = 48 * 60 * 60 * 1000`). Past it, the challenge silently drops off Today — no penalty, no archive.
- Starting a different challenge parks the previous uncompleted one back into `saved` rather than dropping it.
- A challenge can only be saved once its source lesson/module is actually reached (`brewReached`).
- **Log Result sheet**: pick one of three reactions → completes. First completion pays **+5 pts** and presses a permanent stamp onto the linked collectible card and fills its Path node. Replays are unlimited and pay nothing.
- A completed challenge only returns to Today if the user explicitly replays it from the recap sheet.
- Surfaces: Today card, saved list, lesson-complete suggestion, full Module Challenge screen, Path node, card stamp section, Profile stat.

### 5.9 Plus, gating and trials (`gating.jsx`)

**Gated feature catalog** (`PLUS_FEATURES`): `dictionary`, `atlas`, `duel`, `saved`, `studio`.

**In v1, `featureUnlocked()` hardcodes `dictionary` and `saved` to always-open** (`app.jsx:388`) — everything that teaches is free, and Saved is a free tier with a soft cap. So the only true v1 gate is **Studio**.

- Single funnel: `requestFeature(key)` → open it, or raise `PlusGateSheet`.
- `FeatureLock` full-screen teaser, 3 styles: `blur` (default), `hard`, `curtain`.
- **Trials** (v2): `tempUnlocks` maps feature → expiry ms. `RewardedAdScreen` grants 15 min; the perfect-module `RoastyGiftScreen` grants 24 h. A live `TrialBadge` counts down. A 1s interval tick re-renders countdowns.
- Trial state is separate from Plus: `TRIAL_DAYS = 7`; `trialDaysLeft > 0` means the StoreKit trial is running. Access is identical (`isPlus`); only billing language changes.

**Pricing:** Yearly **$29.99/yr** (`$2.50/mo`, "SAVE 50%", default selection) · Monthly **$4.99/mo**. CTA: "Start 7-day free trial", subtitle "Free for 7 days, then … · cancel anytime". Paywall carries **Restore purchases / Terms / Privacy** links (store-review requirement). The same two plans are duplicated as `PLAN_OPTS` in `settings.jsx:384` for the change-plan sheet — **two sources for one price list**, worth unifying on the way in.

**Plus benefits as sold on the paywall:**
1. Unlimited Saved — keep every lesson, term and guide past the free shelf of 10
2. Dress up Roasty — hats, glasses, scarves, roast level
3. Choose your plant — species + light (§6.7)
4. *(v2)* Mood player

### 5.10 Persistence (localStorage keys)

| Key | Contents |
|---|---|
| `cq-theme` | `light` / `dark` / `system` |
| `cq-favorites` | array of favourite keys |
| `cq-custom` | `{ plus, trialDaysLeft, subPlan, variety, light, roasty }` |
| `cq-temp` | `{ featureKey: expiryMs }` temporary unlocks |
| `cq-brew` | `{ activeId, startedAt, completed[], saved[] }` |
| `cq-recent-terms` | recently opened dictionary terms (tracked but **not surfaced in v1**) |
| `cq-atlas` | `{ states, favs, tastedFrom }` (v2) |
| `cq-duel-progress` | in-flight duel run (v2) |

> **`cq-custom` changed shape.** The single `tree` skin id became two axes,
> `variety` + `light`. `window.migrateGrove(saved)` handles the upgrade: legacy
> `heirloom|blossom|verdant` → `daylight`, `goldenhour`/`moonlit` keep their
> light, and an earlier draft's cultivar ids (`typica`, `bourbon`, `geisha`)
> collapse into `arabica`. **A real app needs the same migration** for anyone
> who saved under the old shape.

**Not persisted** (prototype-only, in-memory): `progression` (streak, points, completed, bestResults), `frozenDays`, `freezesSpent`, `perfectLessons`, `giftedModules`. **These are the state a real app must persist and sync.**

### 5.11 Frozen prototype values to replace

- "Today" is hardcoded **Friday 8 May 2026** (`screens.jsx:715` and `:761`).
- The dictionary uses a **different** frozen date — **18 June 2026** (`dictionary-data.jsx:530`, `dictionary-extras.jsx:15`) — which drives term-of-day. Two frozen "todays" in one build.
- Trial charge date derives from the May 8 date (`app.jsx:1099`).
- Starting streak is **7 days**, starting points **10**, `m1l1` pre-completed with a 2/3 result.
- Account email `maya@hey.com`, profile name "Taster" (`USER.name`, which the Profile header interpolates), "Joined May 2026".
- App version string `BrewPath · v0.1 · A field guide` (`screens.jsx:567`).

---

## 6. Content inventory

### 6.1 Course — 5 modules, 32 lessons, 258 cards

Lessons are listed in **display order**, which is array position in
`MODULES[].lessons` — *not* id order. Existing ids never moved when the course
was restructured, so Roasting opens on `m3l4` and Grind runs `l1 · l2 · l5 · l3
· l6 · l7`. Four things point at lesson ids (`COLLECTION[].unlock.lesson`, brew
challenge pointers, dictionary `lesson` fields, mini-game `lessonId`), which is
why renumbering was ruled out.

| # | Module | Label | Lessons (display order) |
|---|---|---|---|
| 1 | Beans | BEANS | What coffee actually is · Arabica vs Robusta · What origin means · Why altitude matters · What the shelf promises · Why two Ethiopias taste different · **Inside the cherry, layer by layer** |
| 2 | Processing | PROCESSING | Washed, natural, honey · Why processing matters · Reading a bag label · Drying coffee · What happens in the tank · Decaf, honestly |
| 3 | Roasting | ROASTING | What roasting does · Light, medium, dark · First and second crack · Reading a roast date · Light vs dark, side by side · How much caffeine are you actually drinking? |
| 4 | Grind | GRIND | Particle size, in plain English · Burr vs blade · Which grind for which brewer · Dialing in by taste · Why pre-ground never tastes as good · Choosing your first grinder |
| 5 | Brew | BREW | The brew ratio · Water, the variable · Extraction explained · Choosing a filter · Tasting your cup · **Espresso, in one small cup** · Your first good cup |

**Two lessons are new since the 30-lesson restructure:**

- **`m1l7` — "Inside the cherry, layer by layer"** (Beans, 11 cards, the longest lesson in the course). Introduces the interactive cherry cross-section and the blind-bag card. Card run: `predict · visual · concept ×3 · sequence · match · mcq · practical · bagpick · recall`.
- **`m5l7` — "Espresso, in one small cup"** (Brew, 6 cards, the shortest). An orientation lesson pulled forward from the v2 Espresso Basics module: `predict · concept ×2 · mcq · decision · recall`.

Every lesson carries `points: 10` and `time: 3–6 min`; card counts run 6–11.

**Cards per lesson** (display order): m1l1 8 · m1l2 10 · m1l3 9 · m1l4 8 · m1l5 9 · m1l6 7 · m1l7 11 · m2l1 8 · m2l2 8 · m2l3 8 · m2l4 8 · m2l5 8 · m2l6 8 · m3l4 8 · m3l1 8 · m3l2 7 · m3l3 7 · m3l5 8 · m3l6 8 · m4l1 7 · m4l2 9 · m4l5 8 · m4l3 7 · m4l6 8 · m4l7 7 · m5l1 7 · m5l2 8 · m5l4 9 · m5l5 8 · m5l3 8 · m5l7 6 · m5l6 10 = **258**

**144 graded cards.** All strings carry typographic quotes and dashes.

> ✅ **The writing pass has landed.** **Zero lessons** now carry `draft: true`;
> the flag was removed from all 15 that had it. Prose is no longer provisional.

*(A recursive string count over `MODULES`, `LESSONS`, `COLLECTION` and
`MODULE_REWARDS` is the only defensible size measure; the old "1,445 strings"
figure predates two restructures and should not be quoted.)*

### 6.2 Card kinds (13 authored, 15 with renderers)

| Kind | Count | Graded | What it is |
|---|---|---|---|
| `concept` | 66 | no | Teaching card. **Fill-in-the-blank sentence** (tap a word from two choices per blank — the sentence always resolves correctly, so the user always leaves with the right idea) + paragraphs + a meta key/value pair |
| `predict` | 32 | no | Opening card. A framing body + one binary guess, held at lesson scope |
| `recall` | 32 | **yes** | "Before you go" — closing check that resolves the opening prediction, plus a one-line takeaway |
| `decision` | 28 | **yes** | Scenario card ("AT THE SHELF" / "IN THE KITCHEN" / "AT THE BREWER") — a real situation, two options, separate right/wrong explanations, plus a takeaway note |
| `mcq` | 27 | **yes** | 4-choice multiple choice + explanation |
| `match` | 17 | **yes** | Drag or tap-tap pairing, several traits can share an answer, animated connector lines |
| `sequence` | 12 | **yes** | Tap items in order, submit, reveal which spots were right |
| `visual` | 11 | no | Full-bleed visual guide, savable to Saved under a `g:` key. **8 variants, all with art** (§6.3) |
| `multi` | 10 | **yes** | Select-all-that-apply, graded as a whole set |
| `slider` | 9 | **yes** | Calibrate — drag to a value, check against a target range (incl. a grinder-dial variant) |
| `tastefix` | 8 | **yes** | A cup came out wrong — pick the one change that fixes it, watch the cup react |
| `practical` | 5 | no | Hands-on instruction card. Four in `m5l6` (*Your first good cup*), one in `m1l7` |
| **`bagpick`** | **1** | **yes** | **New.** Draw a sample from an unlabelled bag, inspect colour / centre cut / mottling / chaff on the rendered green beans, and call the process from the look alone. Renderer + content in `bean-anatomy.jsx`; the only authored instance is in `m1l7`, but it also backs a full mini-game (§6.5) |
| `intro` | 0 | no | Plain framing card. **Renderer exists, no authored card anywhere** — superseded by `predict` |
| `takeaway` | 0 | no | Closing statement card. **Renderer exists, no authored card anywhere** — superseded by `recall` |

`active-cards.jsx` records the supersession explicitly: `predict` was `intro`,
`decision` was `practical`, `recall` was `takeaway` — the three read-only beats
became active ones. `intro` and `takeaway` are the leftovers of that change and
are candidates for deletion rather than authoring.

**Help drawer.** `CARD_KIND_HELP` (`lesson.jsx:9`) holds title + blurb + 3
numbered steps, surfaced from a "?" button in the lesson top bar. It has **10
entries and does not cover every kind**: `mcq` · `multi` · `match` · `slider` ·
`sequence` · `tastefix` · `bagpick` · `fill` (the concept fill-in-the-blank) ·
plus `quiz` and `flavor` for the mini-games. The "?" button simply does not
render for a kind with no entry — so `decision`, `recall`, `predict`, `visual`
and `practical` have no help. Whether that is deliberate (they are
self-explanatory) or an omission is an open question, not a documented decision.

> ⚠️ Earlier versions of this doc called this `GAME_HELP` and claimed every
> interactive kind had an entry. **No `GAME_HELP` exists in the source**; both
> the name and the coverage claim were wrong.

**Lesson player chrome:** close button, `RoastBean` progress (fills as a roasting bean) + `NN / NN` counter, save-lesson bookmark. Glossary terms inside body copy are auto-linkified and open a `TermPeekSheet` without leaving the lesson.

### 6.3 Collectible cards — 42 total

| Group | Count | Unlock |
|---|---|---|
| Training / visual guides | 5 | Earned from the start (no `unlock`) |
| Lesson cards | 32 | One per lesson, no gaps |
| Module Field Guides | 5 | Beans · Processing · Roasting · Grind · Brew |

**The 5 training cards:** `tr-roast` Roast Levels · `tr-grind` Grind Size · `tr-extraction` Extraction · `tr-ratio` Coffee-to-Water Ratio · **`tr-anatomy` The Cherry in Section** (new).

Each card: title, summary, a `fact`, and a `meta` key/value table, plus bespoke inline-SVG art and a colour tint. `MODULE_REWARDS` carries an additional badge string per module (`BEANS · COMPLETE` … `BREW · COMPLETE`).

**Art coverage is now complete**, and the arithmetic is worth stating exactly
because three different counts are defensible:

- `COLLECTION` uses **38 distinct `kind` values**.
- `CARD_ART` has **38 keys** — 37 of those kinds, plus `guide`.
- `CARD_TINT` has **39 keys** — all 38 kinds, plus `guide`.

The one kind absent from `CARD_ART` is **`training`**, which routes to
`TrainingThumb` by design. `guide` belongs to the library list rather than the
collection grid. Every `kind` used in `COLLECTION` therefore resolves to art and
a tint; nothing falls through.

> ✅ **Closed since the last pass:** `scales`, `hourglass` and `burrs` now have
> components; so do the `variety`, `caffeine` and `distribution` visual guides
> (all eight `TRAINING` variants — `roast`, `grind`, `extraction`, `ratio`,
> `anatomy`, `variety`, `caffeine`, `distribution` — have both full art and a
> thumbnail). **23 designs are no longer outstanding; the art workstream is
> done.**

> ⚠️ **Three collectibles share a title with another collectible:**
> **Extraction** (`tr-extraction` training card and the `m5l4` lesson card),
> **Fermentation** (`c-m2l2` on *Why processing matters*, `c-m2l5` on *What
> happens in the tank*), and **The Cherry in Section** (`tr-anatomy` training
> card and the `m1l7` lesson card — new with `m1l7`). All three pairs appear in
> the same Cards grid. Renaming is prose work; it was left open by the writing
> pass and is now three collisions rather than two.

### 6.4 Coffee Dictionary — 72 terms, 8 categories

Categories and their counts: Beans and Botany (16) · Processing (12) · Equipment (9) · Roasting (8) · Brewing (7) · Espresso (7) · Coffee Trade (7) · Sensory Vocabulary (6).

Term shape: `{ id, term, pron?, cat, aliases?, short, deep?, example?, related[], lesson?, sources[], check{q, choices, explain} }`.

| Measure | Count |
|---|---|
| Terms | **72** (was 42) |
| "Full" terms carrying deep text | **46** (was 18) |
| Stubs with `short` only | 26 |
| With a self-check question | 29 |
| With a pronunciation respelling | 23 |
| **Reference-only** (no lesson teaches them) | **9** |

Sources cited across the full terms: Hoffmann's *World Atlas of Coffee*, SCA, World Coffee Research, Perfect Daily Grind.

#### The third term state: Reference

Previously a term was either **Learned** or **To learn**. A third state now
exists for terms **no lesson teaches**, so they can never become Learned:

| State | Glyph | Chip | When |
|---|---|---|---|
| Learned | filled `--sage` dot | `LEARNED` | The term's source lesson is complete |
| **Reference** | **hairline ring + a 7×1.5 `--ink-mute` dash** | **`REFERENCE`** | **`!term.lesson` — nothing on the path teaches it** |
| To learn | hollow dot, dashed `--rule` ring | `TO LEARN` | Readable, not yet taught |

The design note in `ds-content.js` is the rule to carry over: *dashed means "not
yet"; the dash means "not on the path at all". Never show a to-learn ring for a
term no lesson teaches* — a dashed ring there would be a promise the course
can't keep.

Behavioural consequences, all in `dictionary.jsx`:
- The **To-learn filter excludes reference terms** (`isToLearn = !learned && !!t.lesson`), and the filter counts follow. They appear under **All** only.
- `TermDetail` swaps the "WHERE YOU'LL LEARN IT" lesson card for a **`REFERENCE ONLY`** block reading *"No lesson covers this one — it's here for when you meet it on a bag or a menu."* Stated plainly rather than dropped, because a silent gap reads as a bug and a false link reads as a lie.
- Route `term-reference` deep-links the state (seeded with `masl`).

**The 9 reference-only terms:** `masl` · `washing-station` · `wet-hulled` · `tds` · `cold-brew` · `cupping` · `gooseneck` · `sca` · `origin-boards`.

**Learned state**: a term is "learned" once its source lesson is complete; plus a 6-term demo seed. `dictLessonAudit()` returns `[]` — every non-reference term's `lesson` pointer resolves to a lesson that actually teaches it.

**Dictionary surfaces:**
- `DictionaryHome` — search bar (matches aliases), category filter with live counts, Term-of-Day banner, quick chips (Flashcards, Vocab game), recent strip *(built but not surfaced in v1)*
- `TermDetail` — pronunciation + text-to-speech button, deep text, example, self-check, related-term chips, a link into the source lesson **or the Reference-only block**, sources list
- `TermPeekSheet` — compact non-interrupting peek used inside lessons
- `TermOfDayScreen` — deterministic term-of-day by date (frozen to 18 Jun 2026, §5.11)
- `FlashcardsScreen` — drill over saved terms
- `VocabGameScreen` — generated multi-round vocab drill

The two Practice screens share the app's standard drill chrome — a lesson top bar with the roasting-bean counter, the same pattern `MiniGamePlayer` uses, and a Roasty results screen at the end.

### 6.5 Mini-games — 7 (standalone, replayable)

Separate system from lesson cards: own intro → play → results flow, **never** touch lesson points or progression.

| id | Title | Kind | Subject | Length |
|---|---|---|---|---|
| `g-match` | Match the facts | match | ARABICA VS ROBUSTA | ~2 min |
| `g-flavor` | Name the flavor notes | flavor | TASTING NOTES | ~2 min |
| `g-quiz` | True or false | quiz | COFFEE BASICS | ~1 min |
| **`g-bagpick`** | **Read the green bean** | bagpick | WASHED, HONEY OR NATURAL | ~2 min |
| `g-tastefix` | Fix the cup | tastefix | DIAGNOSE AND DIAL IN | ~2 min |
| **`g-calibrate`** | **Dial it in** | slider | GRIND, RATIO, WATER, TIME | ~2 min |
| **`g-sequence`** | **Put it in order** | sequence | BEAN TO CUP | ~2 min |

Three are new (`g-bagpick`, `g-calibrate`, `g-sequence`), and the catalogue now
covers every drillable card kind rather than a sample of them. `g-bagpick` runs
five unlabelled bags from `BAGPICK_ROUNDS`.

Each has a blurb + 3 how-to-play steps + its own content bank (`MINI_GAME_CONTENT`). Surfaced under Learn → "Practice again → Mini-games", where the row leads with the *lesson* name and the game name becomes the eyebrow.

### 6.6 Brew Challenges — 12

| id | Type | Title | Effort |
|---|---|---|---|
| `bc-m1` | module | Two cups, two ratios | Next brews · 5 min |
| `bc-m2` | module | Blind process test | Next brews · 5 min |
| `bc-m3` | module | Light vs dark, same origin | Next bags · 5 min |
| `bc-m4` | module | One-step grind test | Next brews · 3 min |
| `bc-m5` | module | Fix one bad cup | Next brew · 3 min |
| `bc-m1l1` | lesson | Name the origin | Next bag · 1 min |
| `bc-m3l1` | lesson | Compare two roasts | Next bags · 5 min |
| `bc-m4l3` | lesson | Move one grind step | Next brew · 3 min |
| `bc-m5l1` | lesson | Dial your ratio | Next brew · 3 min |
| `bc-m2l6` | lesson | Blind decaf test | Next brews · 5 min |
| `bc-m4l6` | lesson | Fresh vs pre-ground | Next brews · 5 min |
| `bc-m5l6` | lesson | Brew it by the numbers | Next brew · 5 min |

`BREW_TOTAL` derives from `BREW_CHALLENGES.length` (**12**), which is what the
Profile stat counts against. Seven of the 32 lessons carry one. Challenges exist
only where a beginner can honestly run the experiment with beans and a brewer
they already own — which is why 25 lessons have none, `m5l7` (espresso)
deliberately among them.
Each has three reaction options for the log sheet (e.g. "Tasted the difference / Hard to tell / Only brewed one").

### 6.7 Personalization content (Studio)

**The tree chooser is now two axes, not one skin list.** `Tree Variety Proposal
v2.html` is the design record; `customize.jsx` is the implementation.

**Axis 1 — species** (`TREE_VARIETIES`). What is planted. Each carries real
botanical data used as the chooser's copy: latin name, world share, typical use,
origin, growing conditions, cup character, and a `tell` sentence.

| id | Name | Share | Use | Silhouette | Ships |
|---|---|---|---|---|---|
| `arabica` | Arabica (*Coffea arabica*) | ~60% | Filter & pour-over | unmodified | launch |
| `robusta` | Robusta (*Coffea canephora*) | ~35% | Espresso & instant | `scale(1.2, 0.9)` — broader, bushier | launch |
| `liberica` | Liberica (*Coffea liberica*) | <1% | Local brews in SE Asia | `scale(1.1, 1.12)` — taller, bigger leaves | **`drop: 'later'`** |

**Axis 2 — light** (`GROVE_LIGHT`). What it stands in — mood only, four treatments including the unfiltered default: **Daylight** (no filter) · **Golden Hour** (late sun) · **Moonlit** (cool night) · **First Frost** (cold morning).

Species and light compose into one CSS filter (`groveFilter`) plus a separate transform (`groveShape`), over the same 10 stage PNGs. *(A real ship would want bespoke art per species — the silhouette transform is a stand-in, and `drop` is the rollout note for that art.)*

**Roasty options:** 4 roast levels (Light · Medium · Dark · Espresso, each with a swatch) · 4 hats (None · Beanie · Field hat · Cap) · 5 gear (None · Glasses · Shades · Scarf · Headphones) · 4 sprouts (Leaves · Blossom · Cherry · Bare).
**5 backdrops** (mood player, v2): Studio · Cream · Sage · Berry · Night.

Default Roasty: `{ roast: 'medium', hat: 'none', gear: 'none', sprout: 'leaf' }`. Default grove: `arabica` + `daylight`.

### 6.8 Settings content

**Appearance** — theme row (Light / Dark / System)
**Practice** — Notifications toggle · Daily reminder (`REMINDER_TIMES`, 8 presets: 6:30, 7:00, 7:30, 8:00, 8:30 AM · 12:30 PM · 6:00, 8:30 PM; default 8:00 AM) · Sound effects toggle · Haptics toggle
**Account** — Account and sync · Subscription (Free / Trial / Plus) · *Download my data (v2 only)*
**Support** — Help and support · About
**Destructive** — Reset progress · Delete account

Both destructive actions use a `ConfirmSheet` with an itemised summary of what will be lost. Delete-account copy promises a **30-day restore window**.

**Help FAQ — 4 entries** (`FAQ_ITEMS`, `settings.jsx:619`). The answers are load-bearing spec, not filler:
1. *How does my streak work?* — restates the 7-day earn, 2-freeze cap, automatic spend, and "nothing to switch on".
2. *How does my tree grow?* — "tracks the core course only … ten stages from bare seed to full harvest", points don't grow it, never shrinks except on reset.
3. *What do I get with Plus?* — unlimited Saved (free keeps 10) and the Studio; **learning content is always free, and so is your streak**.
4. *Can I learn offline?* — "modules you've opened are kept on your phone. Progress syncs the next time you're online." **This is an offline requirement, not just copy.**

**Subscription screen**: plan display, renewal date, trial countdown + charge date, change plan sheet (`PLAN_OPTS`), cancel.
**Account and sync screen**: email, Plus/trial status, Manage plan, Sign out.

---

## 7. Flows

### 7.1 First run (v1)
`loading` (Roasty splash, auto-advances) → `welcome` → `meet` (Meet Roasty) → **straight to Today**.
The 4–7 question personalization flow exists in full (`onboarding.jsx`) but `isV1` skips it. When re-enabled it locks to the **Standard** 4-question depth: goal → brewer → commitment → experience. Two flow *directions* are built and tweakable: `guided` (Roasty speaks on every question) and `fieldguide` (quiet, editorial; Roasty only bookends).

### 7.2 The daily loop
Open → Today shows the current lesson → Begin lesson → play 6–11 cards → **+10 pts** → streak ticks → tree may advance a stage → collectible card unlocks → optional Brew Challenge offered → next lesson or back to Path.

### 7.3 Lesson → reward routing (`app.jsx`)
1. Record best-ever result (never downgrade). Runs for replays too.
2. If review mode → return to origin, no points, no reward screen. **Stop.**
3. If perfect → remember for the (v2) perfect-module gift.
4. Award the lesson's `points` (10), mark complete.
5. If last lesson in module → `module-complete` → `module-card` (collectible) → module Brew Challenge offer (if any) → *(v2: perfect-module gift)* → next module's first lesson **if authored**, else Path.
6. Otherwise → `lesson-complete` → Continue → next lesson **if authored**, else Path.

`lesson-complete` shows: Roasty celebration, score, mastery state, animated tree from→to stage, points payout, streak-freeze-earned row (suppressed at the cap), collectible-card link, brew-challenge suggestion, Practice again, Continue.

### 7.4 Replay / review
Tapping a completed lesson raises a `ConfirmSheet` stating explicitly: *Points and streak → No change*, length, last completed. Confirm → review mode.

### 7.5 Brew Challenge lifecycle
Offered at lesson/module complete → Start (active, 48h) **or** Save for later → sits on Today → Log Result (pick a reaction) → **+5 pts first time** → stamp pressed onto the collectible card, Path node fills → recap sheet available afterwards → optional unlimited replay.

### 7.6 Dictionary
Reachable from the header on any tab, from Learn's Term-of-Day, and from a term link inside a lesson (peek sheet, non-interrupting). Term detail cross-links to related terms and back into the source lesson — or, for the 9 reference-only terms, says plainly that no lesson covers it. Free and ungated in v1.

### 7.7 Paywall
Trigger points: Saved cap reached (peak intent), Studio card on Profile, Settings → Subscription. → `paywall` → select plan → `plus-welcome` → `studio`.

---

## 8. Deferred features — detail (for v2 tickets)

### Coffee Atlas (`atlas*.jsx`, ~1,600 lines, 10 screens)
- **15 origins**: Ethiopia, Kenya, Rwanda, Yemen · Colombia, Brazil, Peru, Guatemala, Costa Rica, Honduras, Mexico, Panama · Indonesia, India, Vietnam
- Rich per-origin data: tag, intro, growing regions, altitude, climate, species, varieties, processing, harvest window, history, flavour note + tags, sources, review date, and one activity
- **4 exploration ranks**: `not-explored → discovered → lesson → tasted`. Tasting is a reversible toggle that remembers the prior rank.
- **4 activity types**: Identify the origin · Match them up · Locate on the map · Compare two origins
- Custom SVG world map (1000×560) with tropic/equator lines, 2 style modes (`geo` / stylised), origin markers, peek sheet
- Region screens (Africa / Americas / Asia), Passport with animated stamp-press overlay, filter sheet, empty state

### Coffee Duel (`duel*.jsx`, ~1,300 lines, 13 screens)
- **5 duel types** × 5 questions each = 25 questions: Coffee basics · Origin detective · Brew order · Taste match · Processing
- Async head-to-head: hub (with incoming/sent sections), picker (grid/list variants), play, result (tally/instant reveal variants), invite + share, sent, received, comparison (win/loss), rematch, expired, error
- Persists an in-flight run so a duel can be resumed
- **Needs:** share sheet, deep-link resolution, server for invites and result sync

### Rewarded ads + timed trials
`RewardedAdScreen` (simulated video → 15-min unlock), `RoastyGiftScreen` (perfect-module → 24-h Studio unlock), `TrialBadge` countdown. Needs an ad SDK.

### Onboarding question flow
6 question screens + expectation + closing. Fully built; nothing consumes the answers yet.

### Mood player
Roasty centred, tap an emotion to see the reaction, 5 backdrops.

### Liberica tree art
`TREE_VARIETIES.liberica` carries `drop: 'later'` — the species is authored and selectable in code but is waiting on its own silhouette art (§6.7).

---

## 9. Assets

| Location | Count | Contents |
|---|---|---|
| `assets/trees/1–10.png` | 10 | The coffee-tree growth-stage illustrations (~1.7 MB). **These are the only production raster assets.** |
| `uploads/` | 67 | Reference images: onboarding screen refs, tree concepts, Duolingo iOS reference screenshots, streak refs, `Flowerpot_seed_to.mp4` |
| `explorations/` | 12 | **New.** Design-exploration captures whose filenames record the decision: `compact-1-bordered` / `-2-noborder` / `-3-noglyph` / `-4-tight-chosen`, `ds-icons-1..3-chosen`, `ds-lessonrow-1..2-chosen`, `hover-unified-1` / `-2-chosen` / `hover-whole-row`. The `-chosen` suffix marks the variant that shipped — treat these as the visual record for the coming-soon node, the icon weight, the lesson row and the hover treatment. |
| `scraps/` | 21 | Working/review captures — not production assets |

`screenshots/` and `scratch/` (previously 70 and 98 captures) were removed in `aa065bb` and were never tracked in git.

Everything else — Roasty, all icons, all card art, the cherry cross-section, the world map, all glyphs — is **inline SVG in code**. No icon font, no image sprites.

**Web fonts** loaded from Google Fonts: Fraunces (variable), IBM Plex Sans (400/500/600), IBM Plex Mono (400/500). A native build must bundle these.

---

## 10. Known open items

### Re-verified Aug 2026 (`QA Findings.html`)

The structural pass was re-run against the grown build. Every mechanical check is clean:

| Check | Result |
|---|---|
| Dictionary lesson links resolve to a lesson that teaches the term | 72 terms, `dictLessonAudit()` returns `[]`; 9 reference-only terms claim no lesson |
| Every lesson has a collectible card; every card unlocks from a real lesson | 32 / 32, no orphans either direction |
| Every card `kind` has bespoke art and a tint | All resolve (see §6.3 for the 38/39 arithmetic) |
| Path order matches defined lessons | 32 entries, 32 definitions, no drift |
| `m5l7` run through the Modules 2–5 review plan | Two fixes: two off-topic distractors replaced; one decision whose sub-labels graded the options rather than describing them |
| Brew challenges | 7 of 32 lessons, by design |

### Still open — accepted or v2-only
| Item | Where | Disposition |
|---|---|---|
| Tap targets under 44px | `customize.jsx:464` (28px backdrop swatches), `gating.jsx:182` (30px ad close) | Both behind `isV1` — fix when those surfaces return |
| Rewarded ad hardcodes the dark accent `#E07A4F` | `gating.jsx:176` | Wrong orange in cupping. v2 surface |
| Atlas smallcaps carry a lowercase "and" | `atlas.jsx:191,199,231` | v2 surface |
| `--accent` at 4.23:1 in cupping | token | Held — passes on `--surface` where most of it lives; moving the brand colour costs more than it buys |
| `--berry` at 3.86:1 in dark roast | token | Held — reads as the cross mark, not as text |
| Hairlines below 3:1 in both moods | `--rule` | Decoration, not a violation, but worth one look on a real phone at low brightness |

### Closed since the last pass
- ✅ **All 23 outstanding card-art designs are drawn.** `scales`, `hourglass`, `burrs` have components; `variety`, `caffeine`, `distribution` have both guide art and thumbnails.
- ✅ **The `draft: true` writing pass is complete** — 15 lessons cleared, 0 remain.
- ✅ **The duplicate 7-item tree stage-name list is gone** from `app.jsx`; `STAGE_NAMES` is the only list.

### Opened or still open
| Item | Where | Disposition |
|---|---|---|
| **Three duplicate collectible titles** — Extraction, Fermentation, and now **The Cherry in Section** (`tr-anatomy` vs the `m1l7` card) | `data.jsx` `COLLECTION` | Prose work, still unassigned. The third arrived with `m1l7` |
| `intro` and `takeaway` have **zero authored cards** across all 258 | `lesson.jsx` | `active-cards.jsx` documents them as superseded by `predict` / `recall`. **Decide: delete the renderers, or author cards.** Leaving them is the status quo by default, not by choice |
| **Two frozen "today" dates** — 8 May 2026 for the app, 18 Jun 2026 for the dictionary | `screens.jsx`, `dictionary-data.jsx`, `dictionary-extras.jsx` | Harmless in a prototype; a real clock must not inherit the split |
| **Price list duplicated** across the paywall and the change-plan sheet | `customize.jsx:184`, `settings.jsx:384` | Two places to edit one price. Unify on the way in |
| `QA Findings.html` **pacing note is internally stale** — still says "116 cards across 15 lessons" | `QA Findings.html` | The hero was updated to 32/258; the judgement section below it was not. Real figure: 258 cards / 32 lessons ≈ 8.1 per lesson |
| Three route counts in circulation (103 / 96 / 97) | §4 | 103 is the source of truth |
| **Help drawer covers 10 kinds, not all 13** — `decision`, `recall`, `predict`, `visual`, `practical` have no "?" | `lesson.jsx:9` | Never recorded as a decision. Confirm it is deliberate, or author the missing five |
| **A "merged nav model" is referenced but never specified** — the Learn tab becomes `LEARN` "only in the merged nav model, where Path folds into it" | `ds-content.js` icon notes | No route, no component, no decision record. Either an abandoned IA option or an unwritten one; it should not sit in the icon rationale unresolved |
| **Four future modules are promised to users with no design record of any kind** — Espresso Basics · Milk Drinks · Brewing Gear · Coffee Tasting | `screens.jsx:1147–1152` is their only appearance in the repo; `v1 Readiness Audit.html` never mentions them | **The largest open item in the product.** Four names ship to every user on the Path tab, backed by nothing: no lesson list, no scope, no rationale, no entry in the scope decision record. Either write the scope, or stop showing them |
| **The radius scale in earlier versions of this doc was wrong** (4/12/14/16/20 vs the real 2 / 14 / 999) | this doc, §3 | Corrected. Flagged because anything built from the old line has the wrong corner on every card and button |

**Explicitly not verified by machine — needs a human pass:** whether each question is worth asking, whether explanations teach *why wrong answers are wrong*, pacing (avg ~8.1 cards/lesson), and real-device feel (safe areas, thumb reach, hairline visibility, whether drill timers feel generous or stressful). This is the more valuable pass and no amount of structural checking substitutes for it.

**Remaining engineering work named by the audit:**
1. Wire StoreKit — receipt validation, restore, and a real trial counter (the prototype's is frozen).
2. Gate the dev **Tweaks panel** out of the production build (`tweaks-panel.jsx`, 569 lines, a build-time `dev` conditional).

### Omission sweep — method and standing result

The `ComingSoonPath` omission prompted a standing sweep for **user-visible
content declared in code rather than in `data.jsx`**. Method: every top-level
`const NAME = [...]`/`{...}` across the app `.jsx` files, plus every
component-local array rendered through `.map()`, checked against this document.

**Found and now documented:** `ComingSoonPath`'s four future modules (§4) ·
`APP_HEADER_TITLES` including "Beginner Foundations" (§4) · the dead full
`ComingSoonPath` variant (§4) · `TREE_VARIETIES` + `GROVE_LIGHT` (§6.7) ·
`FAQ_ITEMS` answers as spec (§6.8) · `REMINDER_TIMES` (§6.8) · `PLAN_OPTS` as a
second price list (§5.9) · `BAGPICK_ROUNDS` (§6.5) · `TRAINING`'s eight guides
(§6.3).

**Checked and already documented:** `MINI_GAMES` + `MINI_GAME_CONTENT` (§6.5) ·
`CARD_KIND_HELP` (§6.2) · `PLUS_FEATURES` (§5.9) · `ONB_QUESTIONS` (§8, v2) ·
`ROASTY_ANIM_META` (§3) · `SCREEN_ROUTES` (§4) · `CARD_ART` / `CARD_TINT` (§6.3)
· `ROAST_OPTS` / `HAT_OPTS` / `GEAR_OPTS` / `SPROUT_OPTS` / `BACKDROPS` (§6.7).

`ComingSoonPath`'s `cards` remains the only component-local array of
user-visible titles. The pattern that hid it has not recurred.

---

## 11. Gap-analysis checklist

Use this as the ticket-generation spine. Each line is independently verifiable against the mobile app.

### Foundation
- [ ] Two-mood colour token system + theme preference (light/dark/system, follows OS live, no flash on launch)
- [ ] Illustration palette as a **separate** set from theme tokens — 8 bean/roast + 6 cherry tokens
- [ ] 9-step type ladder, 3 font families bundled
- [ ] Icon set (all inline SVG, ~20 marks) with one shared stroke-weight token
- [ ] Roasty component: parametric (roast/hat/gear/sprout) + 9 animation states (note: `points`, not `xp`)
- [ ] 10 tree-stage assets + `CoffeePersona` + `AnimatedTree` cross-fade
- [ ] iOS large-title collapsing header
- [ ] Bottom sheets: confirm, time picker, plan picker, term peek, card sheet, log result, recap, gate, share
- [ ] 44px minimum tap targets on edge controls
- [ ] **Two radius languages** (2px editorial / 14px chrome / 999px pill) — not a single scale
- [ ] Hairline-first separation; shadows only on sheets and floating buttons; selection as a double stroke, never a fill
- [ ] **Port the 19 component state sets + 38 pattern rules from `Design System.html`** (§3) — this doc does not carry them, and they are the actual UI spec
- [ ] **Empty states** — specified in the design system, absent from this doc

### Data model & persistence
- [ ] Persist + sync `progression` (streak, points, completed set, bestResults) — **not persisted in the prototype**
- [ ] Persist `frozenDays` / `freezesSpent` separately
- [ ] Favourites with prefixed keys and the `l|t|g` Saved filter
- [ ] Brew state (active + startedAt + completed + saved)
- [ ] Plus / trial / subscription state
- [ ] Grove state as **two axes** (`variety` + `light`) + the `migrateGrove` legacy upgrade
- [ ] Offline: keep opened modules on device, sync when online (promised in the FAQ)
- [ ] Replace all frozen prototype dates/values — **including the second, dictionary-only frozen date**

### Core loop
- [ ] Lesson player with 13 authored card kinds + the help drawer (10 entries, not one per kind — see §6.2)
- [ ] `bagpick` card: green-bean rendering from process cues, sample draw, cue inspection
- [ ] Cherry cross-section (`CherrySection`) as both a lesson visual and a training card
- [ ] `RoastBean` progress + counter + save-lesson
- [ ] Term auto-linkification → peek sheet
- [ ] Points rules: +10 first completion only (per-lesson value), +5 first brew-challenge completion, 0 for replays, no perfect bonus, no mid-lesson toast
- [ ] Mastery: best-ever percentage, `MASTERY_PASS = 0.8`, three states, never downgrades
- [ ] Review-confirm sheet + no-points review mode
- [ ] Reward routing incl. "next lesson only if authored" fallback
- [ ] Tree growth: **all 32 lessons core**, 10 stages, `CORE_TOTAL` derived from `MODULES` rather than hardcoded
- [ ] Module/lesson gating recomputation
- [ ] Collectible unlock sync + locked silhouettes
- [ ] Decide the fate of the unexercised `intro` / `takeaway` renderers

### Streak
- [ ] Earn 1 per 7 days, cap 2, spend automatically
- [ ] Derived held count (never drifts)
- [ ] Week strip derived from real streak
- [ ] One-time dismissible save notice
- [ ] Streak screen + share sheet

### Content
- [ ] 5 modules / 32 lessons / 258 cards ported with typographic punctuation intact
- [ ] 72 dictionary terms (46 full) + 8 categories + cross-links + sources
- [ ] **Dictionary third state (Reference)**: glyph, chip, To-learn filter exclusion, `REFERENCE ONLY` block, 9 terms
- [ ] 42 collectible cards with bespoke art (**art complete — port, don't draw**)
- [ ] 7 mini-games with content banks
- [ ] 12 brew challenges
- [ ] Studio: 3 species × 4 light treatments, 8 training guides, Roasty option tables
- [ ] Resolve the three duplicate collectible titles

### Monetization
- [ ] Paywall with 2 plans, 7-day trial CTA, Restore/Terms/Privacy
- [ ] StoreKit: purchase, receipt validation, restore, real trial counter
- [ ] Saved free cap of 10 → gate sheet at the cap, removal always allowed
- [ ] Studio as the only true v1 gate
- [ ] Subscription + Account screens, change plan, cancel
- [ ] Plus welcome screen
- [ ] **One** price list, not two

### Settings & compliance
- [ ] All 5 settings sections
- [ ] Reset progress + Delete account with itemised confirm sheets, 30-day restore
- [ ] Help FAQ (4 entries — the answers are spec), About
- [ ] Local notifications for the daily reminder (8 preset times)

### Release hygiene
- [ ] Tweaks panel excluded from the store binary
- [ ] Verify `isV1`-gated code paths are either removed or correctly dark

---

## 12. Suggested epics

1. **Design foundation** — tokens (theme + illustration), typography, theming, iconography, sheet primitives
2. **Roasty** — component, 9 animation states, personalization props
3. **Content pipeline** — port 258 cards / 72 terms / 42 collectibles out of `.jsx` into a real content format
4. **Lesson player** — 13 card kinds + help drawer + term linking
5. **Bean & cherry visuals** — `CherrySection`, `GreenBean`, `BagPickCard` (their own epic: bespoke rendering, own palette, own mini-game)
6. **Progression engine** — points, mastery, gating, collectible sync, persistence
7. **Coffee Tree** — 10 stages, growth rules, animated transitions
8. **Streak & freeze** — earn/spend/derive, week strip, share
9. **Learn / Path / Cards / Profile tabs**
10. **Coffee Dictionary** — incl. the three-state model and the reference-only path
11. **Brew Challenges**
12. **Mini-games** (7)
13. **Plus, paywall & StoreKit**
14. **Studio & personalization** — two-axis grove, migration, Roasty options
15. **Settings, account & compliance**
16. **Onboarding (v1 intro only)**
17. *(v2)* **Coffee Atlas** · **Coffee Duel** · **Rewarded ads & trials** · **Onboarding questions** · **Mood player** · **Liberica art**
