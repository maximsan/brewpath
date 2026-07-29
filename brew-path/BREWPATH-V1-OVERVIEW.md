# BrewPath — v1 Design Reference

**Source:** the Claude Design prototype in this directory (`index.html` + ~30 `.jsx` files, React 18 UMD + Babel-standalone, no build step).
**Purpose of this doc:** a single, complete inventory of what the prototype contains — screens, logic, content, assets, decisions — so it can be diffed against the mobile app and turned into implementation tickets.

Everything below is read out of the prototype source, not invented. Where the prototype and the design docs disagree, the source wins and the discrepancy is flagged.

---

## 0. How to read the prototype

| Thing | Where |
|---|---|
| App shell, phone frame, design tokens, CSS | `index.html` (1,297 lines) |
| Top-level state + routing + all flow wiring | `app.jsx` (1,347 lines) |
| Course content (modules, lessons, cards, collectibles) | `data.jsx` (1,616 lines) |
| Tab screens, streak, tree, settings shell, mini-game catalog | `screens.jsx` (2,399 lines) |
| Lesson player + all card renderers + mini-game player | `lesson.jsx` (1,316 lines) |
| Design-system documentation site | `Design System.html` + `ds-content.js` |
| Scope decision record | `v1 Readiness Audit.html` |
| QA record | `QA Findings.html` |
| Screen gallery (live iframes) | `screens-overview.html` |
| Flow walkthroughs | `onboarding.html`, `lesson.html`, `module.html`, `challenge.html`, `dictionary.html`, `atlas.html`, `duel.html`, `customize.html`, `games.html`, `Coffee Tree.html`, `Mascot - Roasty.html`, `mascot-animations.html`, `Concept Card Interactivity.html` |

**Deep links:** `index.html?screen=<slug>` routes straight to any of **90 states** (`SCREEN_ROUTES` in `app.jsx:31`). `?screen=anim-<state>` renders a looping mascot animation. This is the fastest way to see any screen.

`support.js` is **not app code** — it is the generated Claude Design authoring runtime (`dc-runtime`). Ignore it for implementation.

**The `isV1` flag** (`app.jsx:165`, hardcoded `true`) is the master scope switch. Everything gated by `!isV1` is deferred-to-v2 code that still exists in the prototype.

---

## 1. Product in one paragraph

BrewPath is a Duolingo-shaped coffee-education app. A short daily lesson made of swipeable cards teaches one coffee idea; finishing it pays points, ticks a streak, unlocks a collectible card, and grows a coffee tree that is the single visual metaphor for overall progress. A companion mascot (Roasty, an anthropomorphic coffee bean) reacts to every beat. A Coffee Dictionary sits one tap away and cross-links into lessons. Optional real-world "Brew Challenges" push the learning off-screen. Monetization is a generous free tier plus a **BrewPath Plus** subscription whose two levers are an unlimited Saved shelf and a personalization Studio.

---

## 2. Scope: what ships in v1

Locked in `v1 Readiness Audit.html` (June 2026, reconciled July 2026) and enforced by `isV1` in code.

### In v1
| Area | Screens | Notes |
|---|---|---|
| App intro | 2 | Welcome + Meet Roasty. Content only, no questions. |
| Learn + Path + Lesson player | 10 | The core loop. |
| Rewards + collectible cards | (incl. above) | Lesson complete, module complete, collectible card, streak. |
| Profile + progress + Settings | 7 | Profile, tree, streak, settings, about, account, subscription. |
| Coffee Dictionary | 6 | Home, term, term-of-day, flashcards, vocab game, peek sheet. |
| Plus + Studio + Saved | 4 | Paywall, Plus welcome, Studio hub, tree chooser, Roasty studio, Saved shelf. |
| Active Brew Challenge | ~6 states | Today card, log sheet, recap sheet, module challenge screen, path nodes, card stamps. |

≈38 screens in the v1 cut, of ~64 built.

### Deferred to v2 (built, but switched off)
| Feature | Screens | Why deferred |
|---|---|---|
| **Coffee Atlas** | 10 | Second content vertical: 15 origins, activities, regions, passport, stamps. Needs as much writing/art as the course. |
| **Coffee Duel** | 13 | Async social. Needs share + server infra: invites, pending/expired/error, rematch, link resolution, result sync. |
| **Rewarded ads + timed trials** | 3 | Needs an ad SDK. Includes the perfect-module gift unlock. |
| **Onboarding question flow** | 6 | Nothing reads the answers in v1. Welcome + Meet Roasty stay. |
| **Mood player** | 1 | Delightful extra; ships with Studio depth in v2. |
| Cosmetic IAPs, weekly-goal setting, data export | — | Explicitly deferred. |
| Lifetime tier, paid streak protection | — | **Dropped, not deferred.** Reasons recorded in the audit. |

### Tab bar
**v1: four tabs — Learn · Path · Cards · Profile.** Atlas is removed from the tab bar (`app.jsx:560` force-redirects `tab === 'atlas'` back to `learn`). Dictionary and Saved stay as pinned top-right header entries.

---

## 3. Design system

### Color tokens (two moods, one system)
Documented in `ds-content.js`; defined in `index.html`.

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

**Illustration palette** — literal coffee, identical in both moods, never theme tokens:
`--art-raw #9FB088` · `--art-roast-light #C79A63` · `--art-roast-mid #A2703C` · `--art-roast-dark #54301C` · `--art-ripe #C8843A` · `--art-sour #B79A3C`

The separation is deliberate: keeping cherry/bean colours out of `--warn` is what lets `--warn` mean exactly one thing.

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
- Phone: 393 × 852 (iPhone 14/15 Pro), 56px corner radius, dynamic island, status bar, home indicator.
- Horizontal gutter: `.px-24` (24px). Radius scale: 4 / 12 / 14 / 16 / 20 / 999.
- iOS large-title pattern: large in-flow title scrolls away, compact blurred sticky header appears at `scrollTop > 72` (`app.jsx:565`).
- Header edge controls are 44×44 (fixed during QA).

### Theme handling
Preference is `light | dark | system`, stored in `localStorage['cq-theme']`, default `dark`. `system` follows `prefers-color-scheme` live. A pre-paint inline script in `index.html` applies it before first render to avoid flash. Cross-iframe sync via the `storage` event.
DOM contract: `data-mood="dark-roast" | "cupping"` on `<html>`, plus a legacy `data-theme="dark"` alias.

### Mascot — Roasty (`roasty.jsx`, 874 lines)
A pure-SVG coffee bean character, fully parametric. **9 animation states** (`ROASTY_ANIM_META`):

| State | Animation | Beat |
|---|---|---|
| `idle` | breathes, leaf sways | loops |
| `correct` | hop + sparkles | 1750ms |
| `wrong` | soft wobble | 1350ms |
| `xp` | wink + points rise | 2150ms |
| `lesson` | jump + confetti | 1950ms |
| `module` | grow + rays | 1850ms |
| `card` | shimmer + glow | loops |
| `sleep` | slow breathe + Zzz | loops |
| `awake` | pop open | 1400ms |

Roasty accepts `roast`, `hat`, `gear`, `sprout` props, read from `window.ROASTY_CONFIG`, so every instance app-wide reflects the user's Studio look.
Also in the file: `RoastyLoadingScreen` (branded splash, auto-advances), `RoastyMoment` (full-screen celebration beat), `ReplayButton`, `RoastyAnimScreen`.

### Icon set (`flavor-wheel.jsx`, all inline SVG)
`IconCup` (Learn) · `IconRoute` (Path) · `IconCards` (Cards) · `IconLeaf` (Profile) · `IconGlobe` (Atlas, v2) · `LockMark` · `Chevron` · `BackMark` · `CloseMark` · `CheckMark` · `Bookmark` · `FreezeMark` · `SteamMark` · `ProfileBean` · `PointsBean` · `RoastBean` (lesson progress) · `FlavorWheel` · `FlavorStamp` · `BrewCup` · `BrewStamp` · `LockGlyph`.

---

## 4. Information architecture

### Tabs (v1)
| Tab | Screen | Content |
|---|---|---|
| **Learn** ("Today") | `LearnTab` | Date header, freeze-save notice, Continue Learning card, active Brew Challenge, saved challenges, Practice Again (collapsible: Lessons, Mini-games) |
| **Path** | `PathTab` | Vertical module path with lesson nodes, mastery bean fill, brew-challenge nodes, coming-soon modules |
| **Cards** | `CardsTab` | Collectible card grid; tap → `CardSheet` |
| **Profile** | `ProfileTab` | Tree hero, streak card + week strip, points line, mastery rollup, brew-challenge stat, Studio card, Saved card, joined date |

### Global header (`AppHeader`)
Pinned top-right: **Saved** (with count badge, lock badge if gated) and **Dictionary**. Profile variant swaps in a gear → Settings. Duel entry is present but `showDuel={!isV1}`.

### Full route list (90 deep-link states)

**Boot / intro** — `loading`, `welcome`, `meet`
**Onboarding questions (v2)** — `expectation`, `goal`, `brewer`, `commitment`, `experience`, `motivations`, `reminders`, `onboarding-done`
**Tabs** — `learn`, `path`, `cards`, `profile`
**Lesson** — `lesson`, `lesson-grind`, `lesson-ratio`, `lesson-taste`
**Lesson cards (open a lesson at a given card kind)** — `card-intro`, `card-predict`, `card-concept`, `card-mcq`, `card-multi`, `card-match`, `card-slider`, `card-sequence`, `card-decision`, `card-recall`, `card-takeaway`, `card-practical`, `card-visual`, `card-tastefix`, `card-training`
**Mini-games** — `game-intro`, `game-flavor`, `game-quiz`
**Rewards** — `lesson-complete`, `lesson-complete-weak`, `lesson-complete-perfect`, `module-complete`, `module-card`, `module-challenge`
**Brew Challenge** — `today-challenge`, `today-challenge-done`, `today-nochallenge`, `today-challenge-log`, `path-challenge`, `path-challenge-open`, `card-stamp`, `card-stamp-locked`
**Progress** — `streak`, `tree`
**Settings** — `settings`, `about`, `help`, `account`, `subscription`
**Plus** — `paywall`, `plus-welcome`, `studio`, `tree-chooser`, `roasty-studio`, `mood-player` (v2), `saved`
**Trials (v2)** — `rewarded-ad`, `roasty-gift`
**Dictionary** — `dictionary`, `term`, `term-locked`, `term-of-day`, `flashcards`, `vocab-game`
**Atlas (v2)** — `atlas`, `atlas-loading`, `origin`, `origin-tabbed`, `atlas-region`, `atlas-activity`, `passport`, `passport-empty`, `atlas-stamp`, `atlas-stamp-lesson`
**Duel (v2)** — `duel`, `duel-empty`, `duel-pick`, `duel-play`, `duel-result`, `duel-invite`, `duel-sent`, `duel-received`, `duel-comparison`, `duel-loss`, `duel-rematch`, `duel-expired`, `duel-error`

---

## 5. Core logic and mechanics

This is the part most likely to be missing or wrong in an implementation. Every rule below is enforced in code.

### 5.1 Points (XP)

- **+10 points, flat, for a first lesson completion.** Nothing else in the lesson pays points (`app.jsx:680`).
- **Replays pay 0.** A completed lesson opens through a review-confirm sheet; review mode grants no XP and skips the reward screens entirely (`app.jsx:659`).
- **Perfect earns no bonus** — "mastery is the reward there."
- **+5 points for the first completion of a Brew Challenge.** Replays pay 0 (`app.jsx:539`).
- Points are **effort/habit only**. They do not drive the tree, unlocks, or mastery.
- Mid-lesson correct answers show **no points toast** — feedback is purely qualitative (Roasty reacts). Points appear only on the result screen (`lesson.jsx:157`).

### 5.2 Mastery (separate from points)

Derived from the **best-ever** `{correct, total}` per lesson, as a **percentage** (lessons differ in length). `MASTERY_PASS = 0.8`.

| State | Condition | Label shown? |
|---|---|---|
| `needs-practice` | < 80% | Yes — "Needs Practice", amber chip. The only labelled state. |
| `mastered` | 80–99% | No label; the bean node shows fill level |
| `perfect` | 100% | No label; celebrated once |

Best-ever **never downgrades** on a worse replay (`app.jsx:648`). A replay *can* improve mastery even though it grants no points.
Graded card kinds that count toward the score: `mcq`, `multi`, `match`, `slider`, `sequence`, `tastefix`, `decision`, `recall` (`lesson.jsx:139`). Ungraded: `intro`, `predict`, `concept`, `practical`, `visual`, `takeaway`.

### 5.3 The Coffee Tree (`data.jsx:1488`)

- Grows **only** from first-time completion of **core** (main-path) lessons. Replays, challenges, duels and mini-games never grow it.
- `stage = clamp(1..10, round(1 + (coreDone / coreTotal) * 9))` — 10 stages over 15 core lessons.
- Stage names: `SEED · SPROUT · SAPLING · BUDDING · FLOWERING · GREEN CHERRY · TURNING · RIPENING · NEAR HARVEST · HARVEST`
- A weak first completion still grows the tree.
- Never shrinks except on Reset Progress.
- Art: 10 PNGs in `assets/trees/1.png`…`10.png` (`CoffeePersona`), with `AnimatedTree` cross-fading from → to stage on reward screens.
- ⚠️ **Discrepancy:** `app.jsx:986` has a *second*, 7-item stage-name list used only for the reset-confirmation copy. The canonical list is the 10-item `window.STAGE_NAMES` in `flavor-wheel.jsx:173`.

### 5.4 Streak and streak freeze (`app.jsx:415`)

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

### 5.5 Progression gating (`data.jsx:1571`)

`syncModuleProgress(completedSet)` recomputes on every render:
- Finished lesson → `complete`; first unfinished in an unlocked module → `current`; rest → `locked`.
- A module unlocks when the **previous module is fully complete AND its own first lesson is authored** in `LESSONS`. Unauthored future modules stay locked ("coming soon").
- Module 1 is authored open.
- Resetting progress re-locks everything correctly.

### 5.6 Collectible cards (`data.jsx:1601`)

`syncCollection(completedSet)`:
- A **lesson card** unlocks when its lesson completes.
- A **module Field Guide card** unlocks when every lesson in the module is done.
- **Training/visual-guide cards** have no `unlock` and are earned from the start.
- Locked cards render a `LockedSilhouette`.
- A card can carry a **Brew Challenge stamp** — a permanent "I tried this for real" mark pressed onto the card once the linked challenge is logged.

### 5.7 Saved shelf / favorites (`app.jsx:235`)

- Persisted to `localStorage['cq-favorites']` as a `Set` of prefixed keys: `l:` lesson, `t:` term, `g:` guide, `c:` collectible card.
- **Only `l:` / `t:` / `g:` count as "Saved"** and appear on the Saved screen or in the header badge. Card favourites do not.
- **Free cap: 10** (`SAVED_FREE_MAX`). Adding past the cap raises the Plus gate sheet. **Removing is always allowed**, so a capped free user can still curate.
- Plus lifts the cap. This is the paywall's primary concrete hook.
- Seed favourites: `l:m1l1`, `c:c1`, `t:arabica`, `t:bloom`, `t:crema`.

### 5.8 Brew Challenges (`brew-challenge.jsx`)

Small, optional **real-life** tasks. They never block learning, streaks, XP, cards or progress.

- **9 challenges**: one capstone per module (5) + lesson challenges on the most hands-on lessons (4).
- Shape: `{ id, type: 'module'|'lesson', moduleId, lessonId?, cardId, title, instruction, effort, reactions[3] }`.
- State: one `activeId` + `startedAt`, a `completed` Set, a `saved` (parked-for-later) Set. Persisted to `localStorage['cq-brew']`.
- **48-hour active window** (`BREW_WINDOW_MS`). Past it, the challenge silently drops off Today — no penalty, no archive.
- Starting a different challenge parks the previous uncompleted one back into `saved` rather than dropping it.
- A challenge can only be saved once its source lesson/module is actually reached (`brewReached`).
- **Log Result sheet**: pick one of three reactions → completes. First completion pays **+5 pts** and presses a permanent stamp onto the linked collectible card and fills its Path node. Replays are unlimited and pay nothing.
- A completed challenge only returns to Today if the user explicitly replays it from the recap sheet.
- Surfaces: Today card, saved list, lesson-complete suggestion, full Module Challenge screen, Path node, card stamp section, Profile stat.

### 5.9 Plus, gating and trials (`gating.jsx`)

**Gated feature catalog** (`PLUS_FEATURES`): `dictionary`, `atlas`, `duel`, `saved`, `studio`.

**In v1, `featureUnlocked()` hardcodes `dictionary` and `saved` to always-open** (`app.jsx:377`) — everything that teaches is free, and Saved is a free tier with a soft cap. So the only true v1 gate is **Studio**.

- Single funnel: `requestFeature(key)` → open it, or raise `PlusGateSheet`.
- `FeatureLock` full-screen teaser, 3 styles: `blur` (default), `hard`, `curtain`.
- **Trials** (v2): `tempUnlocks` maps feature → expiry ms. `RewardedAdScreen` grants 15 min; the perfect-module `RoastyGiftScreen` grants 24 h. A live `TrialBadge` counts down. A 1s interval tick re-renders countdowns.
- Trial state is separate from Plus: `trialDaysLeft > 0` means the 7-day StoreKit trial is running. Access is identical; only billing language changes.

**Pricing:** Yearly **$29.99/yr** (`$2.50/mo`, "SAVE 50%", default selection) · Monthly **$4.99/mo**. CTA: "Start 7-day free trial". Paywall carries **Restore purchases / Terms / Privacy** links (store-review requirement).

**Plus benefits as sold on the paywall:**
1. Unlimited Saved — keep every lesson, term and guide past the free shelf of 10
2. Dress up Roasty — hats, glasses, scarves, roast level
3. Choose your plant — 5 botanical skins
4. *(v2)* Mood player

### 5.10 Persistence (localStorage keys)

| Key | Contents |
|---|---|
| `cq-theme` | `light` / `dark` / `system` |
| `cq-favorites` | array of favourite keys |
| `cq-custom` | `{ plus, trialDaysLeft, subPlan, tree, roasty }` |
| `cq-temp` | `{ featureKey: expiryMs }` temporary unlocks |
| `cq-brew` | `{ activeId, startedAt, completed[], saved[] }` |
| `cq-recent-terms` | recently opened dictionary terms (tracked but **not surfaced in v1**) |
| `cq-atlas` | `{ states, favs, tastedFrom }` (v2) |
| `cq-duel-progress` | in-flight duel run (v2) |

**Not persisted** (prototype-only, in-memory): `progression` (streak, xp, completed, bestResults), `frozenDays`, `freezesSpent`, `perfectLessons`, `giftedModules`. **These are the state a real app must persist and sync.**

### 5.11 Frozen prototype values to replace

- "Today" is hardcoded **Friday 8 May 2026** (`screens.jsx:794`).
- Starting streak is **7 days**, starting XP **10**, `m1l1` pre-completed with a 2/3 result.
- Renewal dates hardcoded (`18 Jul 2026` / `18 Jun 2027`).
- Account email `maya@hey.com`, profile name "Taster", "Joined May 2026".
- App version string `BrewPath · v0.1 · A field guide`.

---

## 6. Content inventory

### 6.1 Course — 5 modules, 15 lessons, 116 cards

| # | Module | Label | Lessons |
|---|---|---|---|
| 1 | Beans | BEANS | What coffee actually is · Arabica vs Robusta · What origin means |
| 2 | Processing | PROCESSING | Washed, natural, honey · Why processing matters · Reading a bag label |
| 3 | Roasting | ROASTING | Light, medium, dark · First and second crack · Reading a roast date |
| 4 | Grind | GRIND | Particle size, in plain English · Burr vs blade · Dialing in by taste |
| 5 | Brew | BREW | The brew ratio · Water, the variable · Tasting your cup |

Every lesson: `xp: 10`, `time: 3–5 min`, 7–10 cards.

**Cards per lesson:** m1l1 8 · m1l2 10 · m1l3 9 · m2l1 8 · m2l2 8 · m2l3 8 · m3l1 8 · m3l2 7 · m3l3 7 · m4l1 7 · m4l2 7 · m4l3 7 · m5l1 7 · m5l2 8 · m5l3 7 = **116**

Content stats from the QA record: **1,445 strings**, all with typographic quotes/dashes; 58 graded cards, all with exactly one correct answer.

### 6.2 Card kinds (14 in the lesson player)

| Kind | Count | Graded | What it is |
|---|---|---|---|
| `concept` | 25 | no | Teaching card. **Fill-in-the-blank sentence** (tap a word from two choices per blank — the sentence always resolves correctly, so the user always leaves with the right idea) + paragraphs + a meta key/value pair |
| `predict` | 15 | no | Opening card. A framing body + one binary guess, held at lesson scope |
| `recall` | 15 | **yes** | "Before you go" — closing check that resolves the opening prediction, plus a one-line takeaway |
| `mcq` | 15 | **yes** | 4-choice multiple choice + explanation |
| `decision` | 15 | **yes** | Scenario card ("AT THE SHELF" / "IN THE KITCHEN" / "AT THE BREWER") — a real situation, two options, separate right/wrong explanations, plus a takeaway note |
| `multi` | 7 | **yes** | Select-all-that-apply, graded as a whole set |
| `tastefix` | 6 | **yes** | A cup came out wrong — pick the one change that fixes it, watch the cup react |
| `match` | 6 | **yes** | Drag or tap-tap pairing, several traits can share an answer, animated connector lines |
| `visual` | 5 | no | Full-bleed visual guide (roast / grind / extraction / ratio spectrums), savable to Saved |
| `sequence` | 4 | **yes** | Tap items in order, submit, reveal which spots were right |
| `slider` | 3 | **yes** | Calibrate — drag to a value, check against a target range (incl. a grinder-dial variant) |
| `practical` | — | no | Hands-on instruction card |
| `intro` | — | no | Plain framing card |
| `takeaway` | — | no | Closing statement card |

Every interactive kind has a `GAME_HELP` entry (title, blurb, 3 numbered steps) surfaced from a "?" bottom-sheet in the lesson top bar.

**Lesson player chrome:** close button, `RoastBean` progress (fills as a roasting bean) + `NN / NN` counter, save-lesson bookmark. Glossary terms inside body copy are auto-linkified and open a `TermPeekSheet` without leaving the lesson.

### 6.3 Collectible cards — 24 total

- **4 training / visual-guide cards** (earned from the start): Roast Levels, Grind Size, Extraction, Coffee-to-Water Ratio
- **15 lesson cards** (one per lesson), art kinds: `botanical`, `map`, `specimen`, `dryingbed`, `ferment`, `label`, `roastscale`, `crack`, `calendar`, `gauge`, `droplet`, `spectrum`
- **5 module Field Guide cards**: Beans, Processing, Roasting, Grind, Brew

Each card: title, summary, a `fact`, and a `meta` key/value table. Each has bespoke inline-SVG art plus a colour tint. Module rewards (`MODULE_REWARDS`) carry an additional badge string (e.g. `BEANS · COMPLETE`).

### 6.4 Coffee Dictionary — 42 terms, 8 categories

Categories: Beans and Botany · Processing · Roasting · Brewing · Espresso · Sensory Vocabulary · Equipment · Coffee Trade.

Term shape: `{ id, term, pron?, cat, aliases?, short, deep?, example?, related[], lesson?, sources[], check{q, choices, explain} }`.
**18 of 42 are "full" terms** carrying deep text + example + a self-check question + cited sources (Hoffmann's *World Atlas of Coffee*, SCA, World Coffee Research, Perfect Daily Grind). The other 24 are stubs with `short` only.

**Learned state**: a term is "learned" once its source lesson is complete; plus a 6-term demo seed. Learned terms show a sage status glyph.

**Dictionary surfaces:**
- `DictionaryHome` — search bar (matches aliases), category filter with live counts, Term-of-Day banner, quick chips (Flashcards, Vocab game), recent strip *(built but not surfaced in v1)*
- `TermDetail` — pronunciation + text-to-speech button, deep text, example, self-check, related-term chips, a link into the source lesson, sources list
- `TermPeekSheet` — compact non-interrupting peek used inside lessons
- `TermOfDayScreen` — deterministic term-of-day by date
- `FlashcardsScreen` — drill over saved terms
- `VocabGameScreen` — generated multi-round vocab drill

All 42 cross-links resolve (verified in QA).

### 6.5 Mini-games — 4 (standalone, replayable)

Separate system from lesson cards: own intro → play → results flow, **never** touch lesson XP or progression.

| id | Title | Kind | Source lesson | Length |
|---|---|---|---|---|
| `g-match` | Match the facts | match | m1l2 | ~2 min |
| `g-flavor` | Name the flavor notes | flavor | m1l1 | ~2 min |
| `g-quiz` | True or false | quiz | m1l1 | ~1 min |
| `g-tastefix` | Fix the cup | tastefix | m5l3 | ~2 min |

Each has a blurb + 3 how-to-play steps + its own content bank (`MINI_GAME_CONTENT`). Surfaced under Learn → "Practice again → Mini-games", where the row leads with the *lesson* name and the game name becomes the eyebrow.

### 6.6 Brew Challenges — 9

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

`BREW_TOTAL = 9`, which is what the Profile stat counts against.
Each has three reaction options for the log sheet (e.g. "Tasted the difference / Hard to tell / Only brewed one").

### 6.7 Personalization content (Studio)

- **5 tree skins**: Heirloom (free, the real art) · Golden Hour · Moonlit · Blossom · Verdant. Non-heirloom skins are CSS filters over the same 10-stage art. *(A real ship would want bespoke art per stage — noted in the source.)*
- **4 roast levels**: Light · Medium · Dark · Espresso
- **4 hats**: None · Beanie · Field hat · Cap
- **5 gear**: None · Glasses · Shades · Scarf · Headphones
- **4 sprouts**: Leaves · Blossom · Cherry · Bare
- **5 backdrops** (mood player, v2): Studio · Cream · Sage · Berry · Night

Default Roasty: `{ roast: 'medium', hat: 'none', gear: 'none', sprout: 'leaf' }`. Default tree: `heirloom`.

### 6.8 Settings content

**Appearance** — theme row (Light / Dark / System)
**Practice** — Notifications toggle · Daily reminder (time sheet, 8 preset times 6:30 AM–8:30 PM, default 8:00 AM) · Sound effects toggle · Haptics toggle
**Account** — Account and sync · Subscription (Free / Trial / Plus) · *Download my data (v2 only)*
**Support** — Help and support · About
**Destructive** — Reset progress · Delete account

Both destructive actions use a `ConfirmSheet` with an itemised summary of what will be lost. Delete-account copy promises a **30-day restore window**.

**Help FAQ — 4 entries:** How does my streak work · How does my tree grow · What do I get with Plus · Can I learn offline (answer: yes, opened modules are kept on device, progress syncs when online — **this is an offline requirement, not just copy**).

**Subscription screen**: plan display, renewal date, trial countdown + charge date, change plan sheet, cancel.
**Account and sync screen**: email, Plus/trial status, Manage plan, Sign out.

---

## 7. Flows

### 7.1 First run (v1)
`loading` (Roasty splash, auto-advances) → `welcome` → `meet` (Meet Roasty) → **straight to Today**.
The 4–7 question personalization flow exists in full (`onboarding.jsx`) but `isV1` skips it. When re-enabled it locks to the **Standard** 4-question depth: goal → brewer → commitment → experience. Two flow *directions* are built and tweakable: `guided` (Roasty speaks on every question) and `fieldguide` (quiet, editorial; Roasty only bookends).

### 7.2 The daily loop
Open → Today shows the current lesson → Begin lesson → play 7–10 cards → **+10 pts** → streak ticks → tree may advance a stage → collectible card unlocks → optional Brew Challenge offered → next lesson or back to Path.

### 7.3 Lesson → reward routing (`app.jsx:643`)
1. Record best-ever result (never downgrade). Runs for replays too.
2. If review mode → return to origin, no XP, no reward screen. **Stop.**
3. If perfect → remember for the (v2) perfect-module gift.
4. Award +10, mark complete.
5. If last lesson in module → `module-complete` → `module-card` (collectible) → module Brew Challenge offer (if any) → *(v2: perfect-module gift)* → next module's first lesson **if authored**, else Path.
6. Otherwise → `lesson-complete` → Continue → next lesson **if authored**, else Path.

`lesson-complete` shows: Roasty celebration, score, mastery state, animated tree from→to stage, points payout, streak-freeze-earned row (suppressed at the cap), collectible-card link, brew-challenge suggestion, Practice again, Continue.

### 7.4 Replay / review
Tapping a completed lesson raises a `ConfirmSheet` stating explicitly: *Points and streak → No change*, length, last completed. Confirm → review mode.

### 7.5 Brew Challenge lifecycle
Offered at lesson/module complete → Start (active, 48h) **or** Save for later → sits on Today → Log Result (pick a reaction) → **+5 pts first time** → stamp pressed onto the collectible card, Path node fills → recap sheet available afterwards → optional unlimited replay.

### 7.6 Dictionary
Reachable from the header on any tab, from Learn's Term-of-Day, and from a term link inside a lesson (peek sheet, non-interrupting). Term detail cross-links to related terms and back into the source lesson. Free and ungated in v1.

### 7.7 Paywall
Trigger points: Saved cap reached (peak intent), Studio card on Profile, Settings → Subscription. → `paywall` → select plan → `plus-welcome` → `studio`.

---

## 8. Deferred features — detail (for v2 tickets)

### Coffee Atlas (`atlas*.jsx`, ~1,300 lines, 10 screens)
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

---

## 9. Assets

| Location | Contents |
|---|---|
| `assets/trees/1–10.png` | The 10 coffee-tree growth-stage illustrations (1.7 MB total). **These are the only production raster assets.** |
| `uploads/` | 47 reference images: onboarding screen refs, 10 tree concepts, Duolingo iOS reference screenshots, streak refs, `Flowerpot_seed_to.mp4` |
| `screenshots/` (70), `scratch/` (98), `scraps/` (22) | Working/review captures — not production assets |

Everything else — Roasty, all icons, all card art, the world map, all glyphs — is **inline SVG in code**. No icon font, no image sprites.

**Web fonts** loaded from Google Fonts: Fraunces (variable), IBM Plex Sans (400/500/600), IBM Plex Mono (400/500). A native build must bundle these.

---

## 10. Known open items (from `QA Findings.html`)

**Closed:** 11 defects fixed; all 97 routes loaded without a crash; cupping contrast raised to AA (`--warn` → `#9A5F1C`, `--sage` → `#5F6E55`).

**Still open — accepted or v2-only:**
| Item | Where | Disposition |
|---|---|---|
| Tap targets under 44px | `customize.jsx:464` (28px backdrop swatches), `gating.jsx:182` (30px ad close) | Both behind `isV1` — fix when those surfaces return |
| Rewarded ad hardcodes the dark accent `#E07A4F` | `gating.jsx:176` | v2 surface |
| Atlas smallcaps carry a lowercase "and" | `atlas.jsx:191,199,231` | v2 surface |
| `--accent` at 4.23:1 in cupping | token | Held — passes on `--surface` where most of it lives; moving the brand colour costs more than it buys |
| `--berry` at 3.86:1 in dark roast | token | Held — reads as the cross mark, not as text |
| Hairlines below 3:1 in both moods | `--rule` | Decoration, not a violation, but worth one look on a real phone at low brightness |

**Explicitly not verified by machine — needs a human pass:** whether each question is worth asking, whether explanations teach *why wrong answers are wrong*, pacing (avg ~8 cards/lesson), and real-device feel (safe areas, thumb reach, hairline visibility, whether drill timers feel generous or stressful).

**Remaining engineering work named by the audit:**
1. Wire StoreKit — receipt validation, restore, and a real trial counter (the prototype's is frozen).
2. Gate the dev **Tweaks panel** out of the production build (`tweaks-panel.jsx`, a build-time `dev` conditional).

---

## 11. Gap-analysis checklist

Use this as the ticket-generation spine. Each line is independently verifiable against the mobile app.

### Foundation
- [ ] Two-mood colour token system + theme preference (light/dark/system, follows OS live, no flash on launch)
- [ ] 9-step type ladder, 3 font families bundled
- [ ] Icon set (all inline SVG, ~20 marks)
- [ ] Roasty component: parametric (roast/hat/gear/sprout) + 9 animation states
- [ ] 10 tree-stage assets + `CoffeePersona` + `AnimatedTree` cross-fade
- [ ] iOS large-title collapsing header
- [ ] Bottom sheets: confirm, time picker, plan picker, term peek, card sheet, log result, recap, gate, share
- [ ] 44px minimum tap targets on edge controls

### Data model & persistence
- [ ] Persist + sync `progression` (streak, xp, completed set, bestResults) — **not persisted in the prototype**
- [ ] Persist `frozenDays` / `freezesSpent` separately
- [ ] Favourites with prefixed keys and the `l|t|g` Saved filter
- [ ] Brew state (active + startedAt + completed + saved)
- [ ] Plus / trial / subscription state
- [ ] Offline: keep opened modules on device, sync when online (promised in the FAQ)
- [ ] Replace all frozen prototype dates/values

### Core loop
- [ ] Lesson player with 14 card kinds + per-kind help drawer
- [ ] `RoastBean` progress + counter + save-lesson
- [ ] Term auto-linkification → peek sheet
- [ ] Points rules: +10 first completion only, +5 first brew-challenge completion, 0 for replays, no perfect bonus, no mid-lesson toast
- [ ] Mastery: best-ever percentage, `MASTERY_PASS = 0.8`, three states, never downgrades
- [ ] Review-confirm sheet + no-XP review mode
- [ ] Reward routing incl. "next lesson only if authored" fallback
- [ ] Tree growth from core lessons only, 10 stages
- [ ] Module/lesson gating recomputation
- [ ] Collectible unlock sync + locked silhouettes

### Streak
- [ ] Earn 1 per 7 days, cap 2, spend automatically
- [ ] Derived held count (never drifts)
- [ ] Week strip derived from real streak
- [ ] One-time dismissible save notice
- [ ] Streak screen + share sheet

### Content
- [ ] 5 modules / 15 lessons / 116 cards / 1,445 strings ported with typographic punctuation intact
- [ ] 42 dictionary terms (18 full) + 8 categories + cross-links + sources
- [ ] 24 collectible cards with bespoke art
- [ ] 4 mini-games with content banks
- [ ] 10 brew challenges
- [ ] Studio option tables + 5 tree skins

### Monetization
- [ ] Paywall with 2 plans, 7-day trial CTA, Restore/Terms/Privacy
- [ ] StoreKit: purchase, receipt validation, restore, real trial counter
- [ ] Saved free cap of 10 → gate sheet at the cap, removal always allowed
- [ ] Studio as the only true v1 gate
- [ ] Subscription + Account screens, change plan, cancel
- [ ] Plus welcome screen

### Settings & compliance
- [ ] All 5 settings sections
- [ ] Reset progress + Delete account with itemised confirm sheets, 30-day restore
- [ ] Help FAQ (4 entries), About
- [ ] Local notifications for the daily reminder

### Release hygiene
- [ ] Tweaks panel excluded from the store binary
- [ ] Verify `isV1`-gated code paths are either removed or correctly dark

---

## 12. Suggested epics

1. **Design foundation** — tokens, typography, theming, iconography, sheet primitives
2. **Roasty** — component, 9 animation states, personalization props
3. **Content pipeline** — port 116 cards / 42 terms / 24 collectibles out of `.jsx` into a real content format
4. **Lesson player** — 14 card kinds + help drawer + term linking
5. **Progression engine** — points, mastery, gating, collectible sync, persistence
6. **Coffee Tree** — 10 stages, growth rules, animated transitions
7. **Streak & freeze** — earn/spend/derive, week strip, share
8. **Learn / Path / Cards / Profile tabs**
9. **Coffee Dictionary**
10. **Brew Challenges**
11. **Mini-games**
12. **Plus, paywall & StoreKit**
13. **Studio & personalization**
14. **Settings, account & compliance**
15. **Onboarding (v1 intro only)**
16. *(v2)* **Coffee Atlas** · **Coffee Duel** · **Rewarded ads & trials** · **Onboarding questions** · **Mood player**
