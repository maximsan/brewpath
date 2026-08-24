# The screen-by-screen divergence register

Research for [issue #344](https://github.com/maximsan/brewpath/issues/344), child of the
design-parity map [#337](https://github.com/maximsan/brewpath/issues/337).

**Scope.** Every app screen against its prototype counterpart: the four tabs, the pushed
dictionary/module/lesson/settings screens, and the shell chrome they share. Layout,
palette (named as **tokens**, never hexes), typography, naming, and off-ruling artifacts.
This document **records** divergences and ranks them; it does not fix them and does not
open fix tickets — graduating fixes is the map's later work with the owner.

**Method.** Every prototype claim is cited to a file and line in `prototype/` read at
`96192cf`; every app claim to a file and line in `lib/`. Framework-default claims (what a
stock Material widget resolves to) were read from the installed Flutter SDK at
`/opt/homebrew/share/flutter`, not from recollection — those are the ones most easily
asserted wrongly. Ruling citations point at the issue or `CONTEXT.md` line that owns them.

**Severity.**

| | Meaning |
| --- | --- |
| **breaks-a-ruling** | Contradicts a closed decision, a `CONTEXT.md` term, or a `CLAUDE.md` rule. Not a taste question. |
| **structural** | A section, screen or control the design does not have, or does have and the app lacks; wrong hierarchy. |
| **cosmetic** | Right structure, wrong token / face / size / case. |

**Counts: 34 divergences — 4 breaks-a-ruling, 18 structural, 12 cosmetic.**

---

## 0. What already matches (so the register is not read as "all of it")

The premise going in was that "the overall palette diverges." **It does not.** The token
layer is a faithful transcription and should not be touched:

- `MoodColors` (`lib/shared/theme/mood_colors.dart:40-71`) carries all 13 colour tokens
  for both moods at exactly the prototype's values (`prototype/index.html:26-71`).
- `ArtColors` (`lib/shared/theme/art_colors.dart:28-93`) carries the full `--art-*` +
  `--cream` block (`prototype/index.html:208-216`) and even ships a drift guard keyed by
  token name (`art_colors.dart:122-137`).
- The type ladder `_Rung` (`lib/shared/theme/app_text.dart:48-57`) matches the nine
  `--t-*` steps 56/30/26/19/17/15/13/11/9.5 (`prototype/index.html:219-220`) exactly.
- The shared tab header — eyebrow + title per tab — is a correct port:
  `header_tier.dart:129-149` reproduces `APP_HEADER_TITLES`
  (`prototype/screens.jsx:661-669`) string for string, **TODAY included**.
- `SmallcapsLabel` (`lib/core/widgets/smallcaps_label.dart:22-27`) is a correct
  `.smallcaps` (`prototype/index.html:225-232`): Plex Sans 500, label step, 0.14em,
  uppercase.

**So the palette is not the problem — its *reach* is.** The divergences below are screens
that never route through the tokens the app already has, not tokens holding wrong values.
That changes the fix shape entirely: this is call-site work, not a palette migration.

---

## 1. Off-ruling artifacts

### 1.1 The Profile "Go Premium" card — breaks three rulings at once

`lib/features/profile/presentation/widgets/premium_card.dart`, mounted at
`profile_screen.dart:58`.

| # | Severity | Divergence | Ruling |
| --- | --- | --- | --- |
| 1 | **breaks-a-ruling** | Copy says *"…keep your streak safe with a BrewPath Plus **subscription**"* (`premium_card.dart:49-50`). Plus is a **one-time non-consumable**; subscriptions were dropped for v1. | [#55](https://github.com/maximsan/brewpath/issues/55) §3 *"One-time purchase, not a subscription"* — *"The product type changes from auto-renewable subscription to non-consumable."* |
| 2 | **breaks-a-ruling** | The word **"Premium"** appears three times — the card title `'Go Premium'` (`:41`), the dialog title `'Premium is brewing'` (`:83`), and the class name `PremiumCard`. | `CONTEXT.md:142-145` — **BrewPath Plus**, *"_Avoid_: Premium"*. Ruled in [#30](https://github.com/maximsan/brewpath/issues/30). |
| 3 | **breaks-a-ruling** | Copy sells *"**remove ads**"* (`premium_card.dart:49`). There is **no ads copy anywhere in the design** — a full-text sweep of `prototype/*.jsx` returns zero UI strings about ads. Ads ship disabled (`kAdsEnabled = false`, `docs/11-ads.md`), and the rewarded-ad surface is v2 per #55. | `docs/11-ads.md` *"Current Status: Disabled for MVP"*; #55 treats `RewardedAdScreen` as travelling with the ad SDK, already v2. |
| 4 | **structural** | **The prototype's Profile has no paywall card at all.** `ProfileTab` (`prototype/screens.jsx:2546-2808`) goes greeting → tree hero → streak → progress line → mastery → challenges → Studio → Duel → Saved → *Joined*. Nothing sells anything; locked entries wear a `PlusPill` on the card they gate (`:2710`, `:2735`, `:2760`). The app's accent-filled hero CTA in slot 2 is an invention. | — |

⚠️ **The card is not salvageable by editing its copy.** Three of its four faults are the
copy; the fourth is that the slot does not exist in the design. Rewriting the sentence
would leave a hero paywall where the prototype puts a tree.

⚠️ **Adjacent, and out of this ticket's scope but worth naming:** the *"Premium"* naming
sweep #55 already flagged as owed (`decisions-1.md` §11) is still owed, and this widget is
now a second instance of the same drift.

---

## 2. Shell chrome — the tab bar

The app renders a stock Material `NavigationBar` (`lib/app/app_shell.dart:105-130`) with
no `NavigationBarTheme`, against the prototype's hand-built `.tabbar`
(`prototype/screens.jsx:2857-2880`, CSS at `prototype/index.html:332-363`).

Because no theme is declared, M3 defaults resolve through `ColorScheme` — and the app's
`ColorScheme` (`lib/app/app_theme.dart:57-76`) leaves the relevant slots unset, so they
fall through a second time. Both fallback chains were read from the SDK:

- `NavigationBar.indicatorColor → _colors.secondaryContainer`
  (`navigation_bar.dart:1463`), and `secondaryContainer → _secondaryContainer ?? secondary`
  (`color_scheme.dart:1099`) = **`mood.sage`**.
- selected icon `→ onSecondaryContainer` (`navigation_bar.dart:1456`)
  `→ _onSecondaryContainer ?? onSecondary` (`color_scheme.dart:1109`) = **`mood.bg`**.
- label style `→ _textTheme.labelMedium!` (`navigation_bar.dart:1471`) — a slot
  `AppText.textTheme` never defines (see §7) = **Roboto 12**.

| # | Severity | Divergence | Prototype |
| --- | --- | --- | --- |
| 5 | **breaks-a-ruling** | The active tab wears a **sage** pill. `sage` is documented as *"Success = 'learned' … **Never an action** — that is `accent`"* (`mood_colors.dart:105-107`). The active tab is an action state. | `.tab.active { color: var(--accent) }` (`index.html:356`) — and **no pill at all**. |
| 6 | **cosmetic** | Selected **icon** resolves to `mood.bg` — the page background, painted on a sage pill. Wrong token twice over; should be `accent`. | `index.html:356` |
| 7 | **cosmetic** | Selected **label** resolves to `onSurface` = `mood.ink`, not `accent`. | `index.html:356` |
| 8 | **structural** | No top hairline. The prototype's bar is separated from the page by `border-top: 1px solid var(--rule)`. | `index.html:339` |
| 9 | **structural** | Material icons (`Icons.school`, `Icons.route`, `Icons.style`, `Icons.person` — `app_shell.dart:110-127`) replace the design's own 24×24 stroke-1.6 family (Cup / Route / Cards / Leaf), which the prototype declares a single source of truth for at `screens.jsx:2896-2909`. `school` and `person` are not marks the design owns at all. | `screens.jsx:2859-2863` |
| 10 | **naming / cosmetic** | Labels are **`Learn` / `Path` / `Cards` / `Profile`** title-case (`lib/core/constants/app_labels.dart:7-10`); the design's are **`TODAY` / `PATH` / `CARDS` / `PROFILE`**, uppercase at the micro step with 0.18em tracking. Note the app already says **TODAY** in the header eyebrow (`header_tier.dart:129`) — so the app currently calls one tab two different names on one screen. | `screens.jsx:2859-2863`; `index.html:357-362` |

---

## 3. Learn tab vs. prototype **TODAY**

App: `learn_screen.dart` → `learn_list_view.dart:68-145`.
Prototype: `LearnTab`, `prototype/screens.jsx:719-1352`.

| # | Severity | Divergence | Prototype |
| --- | --- | --- | --- |
| 11 | **structural** | **The Modules list does not belong on this tab.** The app ends Learn with `SectionHeader('Modules')` + a `ModuleCardWidget` per module (`learn_list_view.dart:135-140`). The prototype's TODAY has no module list — modules live on PATH, and are reached there. The app therefore lists every module on **two** tabs. | `screens.jsx:719-1352` has no module list; `PathTab` owns them (`:1408+`) |
| 12 | **structural** | **PRACTICE is one section, not two.** The app raises two sibling headers — `'Practice a finished lesson'` and `'Mini-games'` (`learn_list_view.dart:108`, `:114`). The design has one `PRACTICE` header over two **collapsible** `PracticeGroup`s ("Lessons", "Games"), each with a count, both closed by default. | `screens.jsx:962-970` |
| 13 | **structural** | Inside the Games group the design heads each **kind** with its glyph + kind name and indents that kind's games under it (`padding-left: 30`). The app's `MiniGamesCatalogWidget` is a flat catalog. | `screens.jsx:974-989` |
| 14 | **structural** | No `CONTINUE LEARNING` / `ALL CAUGHT UP` eyebrow over the lead card. The design's lead card is always introduced by one, and the string is what tells a finished learner they are done. | `screens.jsx:822` |
| 15 | **naming** | `'Practice a finished lesson'` (sentence case) for what the design calls **`PRACTICE`**; `'Mini-games'` for what the design calls **`Games`**. | `screens.jsx:962`, `:970` |

---

## 4. Path tab

App: `path_screen.dart:24-87`. Prototype: `PathTab`, `prototype/screens.jsx:1353-1611`.

| # | Severity | Divergence | Prototype |
| --- | --- | --- | --- |
| 16 | **naming** | Header reads **`'Your journey'`** (`path_screen.dart:64`). The design's Path h1 is the **course name — `Beginner Foundations`** — which is also what the shared header eyebrow already says (`header_tier.dart:135`). Same double-naming fault as the tab bar. | `screens.jsx:1391` |
| 17 | **structural** | The app counts **modules** (`'$done of $total modules complete'`, `path_screen.dart:71`); the design counts **lessons** (`{done} of {unlocked} lessons complete`) — and counts against *unlocked*, not total, so a locked course does not advertise a denominator the learner cannot reach. | `screens.jsx:1393-1398` |
| 18 | **structural** | The app adds a `LinearProgressIndicator` under the header (`path_screen.dart:77-83`). The design's Path header has **no progress bar** — the trail itself is the progress display. | `screens.jsx:1388-1400` |
| 19 | **structural** | No density treatment. The design collapses locked/upcoming modules to a `CompactModuleRow` and completed ones to a tappable accordion, expanding only the active module (`expandedMods`, session-scoped). The app renders every module node at full height. | `screens.jsx:1414-1436` |
| 20 | **cosmetic** | Module titles carry a `CatGlyph` cropped to cap height and tinted `accent` (or `ink-mute` when locked), set beside a Fraunces `--t-title` h2. | `screens.jsx:1445-1456` |

---

## 5. Cards tab

App: `cards_screen.dart:30-124`. Prototype: `CardsTab`, `prototype/screens.jsx:1612-1673`.

| # | Severity | Divergence | Prototype |
| --- | --- | --- | --- |
| 21 | **structural** | **The whole locked collection is on display.** The app grids every card (`cards_screen.dart:70-73`). The design shows earned cards plus **exactly one** locked teaser — the next one — and drops the rest. | `screens.jsx:1645-1652` |
| 22 | **structural** | Missing the dashed "*N more to collect / Finish lessons to reveal new cards.*" panel that stands in for the hidden remainder. | `screens.jsx:1654-1668` |
| 23 | **structural** | The app groups the grid by `moduleTag` with a `SectionHeader` per category (`cards_screen.dart:56-60`). The design has **one flat `cards-grid`** with no category sections. | `screens.jsx:1642-1653` |
| 24 | **structural** | The app adds a `LinearProgressIndicator` (`cards_screen.dart:114-120`); the design's Collection header has none. | `screens.jsx:1629-1640` |
| 25 | **cosmetic** | Sub-line is `'$collected of $total cards collected'` in `bodySmall`; the design prints bare `{earned} of {total}` in mono at the label step, 0.08em, uppercase. | `screens.jsx:1633-1638` |

---

## 6. Profile tab (beyond §1.1)

App: `profile_screen.dart:38-97`. Prototype: `ProfileTab`, `prototype/screens.jsx:2546-2808`.

Section order, side by side:

| Prototype | App |
| --- | --- |
| `Hello, {name}.` h1 | *(in shared header only)* |
| Tree hero **card** → tree screen | bare centred `CoffeeTree`, not tappable |
| — | **`PremiumCard`** ← §1.1 |
| Streak card + `WeekStrip` → streak screen | *(folded into a stat tile)* |
| `N lessons · M points` mono line | — |
| Mastery rollup → Path | — |
| `BrewChallengeStat` | `ChallengeStatRow` ✅ |
| Studio card — *Dress up Roasty* | — |
| Coffee Duel card | — |
| Saved card — *Your favorites* | — |
| — | `'Your progress'` 2×2 stat grid |
| — | `'Customize'` 2×2 preferences grid |
| `Joined May 2026` mono line | `ReplayTourRow` |

| # | Severity | Divergence | Prototype |
| --- | --- | --- | --- |
| 26 | **structural** | The tree is a bare centred illustration (`profile_screen.dart:45-56`), not the design's tappable hero card carrying the `YOUR COFFEE TREE` accent kicker, `Stage N · Name`, a progress bar and `N / M core lessons`. It is the tab's lead "I'm growing" signal and currently signals nothing. | `screens.jsx:2574-2601` |
| 27 | **structural** | **The mastery rollup is absent.** The design's segmented `sage`/`accent` bar with *"N solid / M need practice"*, deep-linking to Path to practise weak lessons, has no app counterpart. | `screens.jsx:2643-2683` |
| 28 | **structural** | The Studio, Duel and Saved entry cards are all absent; Saved is reachable only from the shared header. The design gives each a 64px art well, an accent kicker, a Fraunces heading and a chevron. | `screens.jsx:2693-2767` |
| 29 | **structural** | The streak card is demoted to one tile in a 2×2 stat grid (`profile_screen.dart:156-162`). The design gives it a full-width card with the `SteamMark`, a mono `N days`, `CURRENT STREAK`, and an inline `WeekStrip`. | `screens.jsx:2604-2632` |
| 30 | **structural** | The `'Customize'` preferences grid (Sound / Haptics / Daily reminder / Theme — `profile_screen.dart:198-225`) puts settings on the Profile tab. In the design these live in **Settings**, and the Profile's "Customize" is the **Studio** card — a different thing that happens to share a word. Two of the four tiles are dead (`trailingText: 'Soon'`). | `screens.jsx:2693-2717`; settings at `screens.jsx:503-565` |
| 31 | **cosmetic** | Missing the closing `Joined {Month Year}` mono micro line. | `screens.jsx:2797-2804` |

---

## 7. Typography — one systemic fault behind many screens

`AppText.textTheme` (`lib/shared/theme/app_text.dart:145-154`) populates **eight**
`TextTheme` slots: `displayLarge/Medium/Small`, `headlineSmall`, `bodyLarge`, `bodyMedium`,
`labelLarge`, `labelSmall`.

`ThemeData` merges a supplied `TextTheme` onto the default typography, so **every slot left
unset keeps Flutter's Roboto default** — and `app_theme.dart:22-51` sets no `fontFamily`
to soften that. Screen code reads six unset slots:

| Slot | Resolves to | Read at (sample) |
| --- | --- | --- |
| `titleLarge` | Roboto 22 | `premium_card.dart:42`, `profile_screen.dart:121`, `today_card_widget.dart:88`, `lesson_progress_header.dart:51`, `reference_section.dart:154` |
| `titleMedium` | Roboto 16 | `path_screen.dart:65`, `cards_screen.dart:102`, `module_card_widget.dart:62`, `preference_tile.dart:104`, +5 |
| `titleSmall` | Roboto 14 | `section_header.dart:19`, `module_lesson_card_widget.dart:62`, `card_grid_item_widget.dart:52`, +4 |
| `headlineMedium` | Roboto 28 | `course_completion_screen.dart:127`, `streak_screen.dart:159` |
| `labelMedium` | Roboto 12 | `today_card_widget.dart:78`, `keep_sharp_card_body.dart:61`, +3 — **and the tab bar** (§2) |
| `bodySmall` | Roboto 12 | `path_screen.dart:72`, `cards_screen.dart:109`, `module_card_widget.dart:107`, +8 |

| # | Severity | Divergence |
| --- | --- | --- |
| 32 | **breaks-a-ruling** | A large share of app text renders in **Roboto at Material sizes** — off the nine-step ladder and outside the design's three faces entirely. `AppText`'s own doc-comment claims it resolves Material's slots *"so stock widgets — and the ~70 screen call sites still reading `Theme.of(context).textTheme` — are set in the app's type rather than Roboto"* (`app_text.dart:135-144`); for six slots it does not, so the class does not do what it says. This also silently defeats the "no `fontSize` parameter / cannot go off-ladder" guarantee at `app_text.dart:74-78`. |
| 33 | **cosmetic** | Weights `w700` / `w800` appear at `profile_screen.dart:122`, `premium_card.dart:44`, `path_screen.dart:66`, `cards_screen.dart:103`, `settings_screen.dart:104`. The design has exactly two weights — Plex Sans **400 body / 500 controls**, Fraunces 400 (`app_text.dart:11-24`, from `index.html:222-246`). Nothing in the design is bolder than 500. |

### 7.1 Three hand-rolled smallcaps where the design has one rule

The app already ships the correct one — `SmallcapsLabel` (§0). Three call sites
reimplement it and each lands somewhere different:

| Where | What it does | Fault |
| --- | --- | --- |
| `section_header.dart:19` | `titleSmall` + `inkMute` | Roboto 14; **not uppercased at all**, no tracking |
| `term_entry_body.dart:_Block` (`:228-232`) | `labelSmall` + `letterSpacing: 1` | mono face where `.smallcaps` is Sans; a literal `1` overrides the ladder's 1.54 |
| `settings_screen.dart:_SectionLabel` (`:101-105`) | `labelSmall` + `letterSpacing: 1.2` + `w700` | mono, off-ladder tracking, and a weight the design does not have |

| # | Severity | Divergence |
| --- | --- | --- |
| 34 | **structural** | `SectionHeader` is the single widest lever in this register: it sets the section headers on **Learn, Cards, module detail and dictionary home**, and it is neither uppercase nor on the ladder. One correct implementation exists and is unused by all three. |

---

## 8. Token gap: `--accent-text` has no app counterpart

The prototype defines a **fourteenth** mood token the app does not carry:

```css
/* Accent used as TEXT: raw --accent lands at ~4.3:1 on paper, so small
   text takes a darkened mix instead. */
--accent-text: color-mix(in oklab, var(--accent) 62%, var(--ink));
```
`prototype/index.html:34-36` (and `:63` for Dark Roast)

`MoodColors` has no `accentText` (`mood_colors.dart:23-37`), and no `OffTokens` entry
records the omission. Meanwhile **53** call sites paint text or glyphs with raw
`mood.accent`. Any of those that are small text are under-contrast in Cupping mood by the
prototype's own stated measurement — this is an accessibility gap, not a hue preference.

Counted under §7's systemic entries rather than separately, since the fix is one token
plus a call-site sweep.

---

## 9. Pushed screens

### 9.1 Dictionary home

App: `dictionary_home_screen.dart`. Prototype: `DictionaryHome`,
`prototype/dictionary.jsx:297-462`.

The design's landing is a **discovery surface**; the app's is a flat term dump.

| Severity | Divergence | Prototype |
| --- | --- | --- |
| **structural** | **Term of the Day banner absent.** ADR-0002 rules it ships on Dictionary Home *only* (`CONTEXT.md:164-166`) — so the one surface it is allowed to appear on does not render it. | `dictionary.jsx:248-270`, mounted `:402` |
| **structural** | Quick chips (Flashcards / Guess the term) absent. | `dictionary.jsx:272-295`, mounted `:405` |
| **structural** | **The category index is absent.** The design lands on `ALL CATEGORIES` — a rule-separated list of glyph + label + one-line summary + count, each row drilling into that category. The app instead lists every term immediately, grouped under `SectionHeader`s. | `dictionary.jsx:414-433` |
| **structural** | The `REFERENCE · N TERMS` accent kicker over a Fraunces display h1 is replaced by a stock `AppBar` title (`dictionary_home_screen.dart:31`). | `dictionary.jsx:451-452` |
| **structural** | Filter is three loose Material `FilterChip`s (`dictionary_filter_chips.dart:50`) against the design's **segmented pill**: one `rule`-bordered `surface` container, radius 999, active segment filled `accent` with `accent-ink` text, Plex Sans 500 label step 0.1em uppercase. With no `ChipTheme` declared, the selected chip inherits `secondaryContainer` = **`mood.sage`** — the §5 fault again. | `dictionary.jsx:199-219` |
| **cosmetic** | Search is a stock `TextField` + `OutlineInputBorder` + `Icons.search`, hint `'Search terms'`; the design's `DictSearchBar` hints `'Search terms, e.g. crema, bloom…'`. | `dictionary.jsx:174-197` |
| **cosmetic** | Every category falls back to one generic `Icons.local_cafe_outlined` (`dictionary_home_screen.dart:199-203`, acknowledged in its own doc-comment); the design has a real per-category `CatGlyph`. | `dictionary.jsx:52-80` |
| **naming** | Screen title is `'Dictionary'`; the design's default name is **`Coffee Dictionary`**. | `dictionary.jsx:297` |

### 9.2 Term detail

App: `term_detail_screen.dart` + `term_entry_body.dart`. Prototype: `TermDetail`,
`prototype/dictionary.jsx:583-678`.

| Severity | Divergence | Prototype |
| --- | --- | --- |
| **structural** | The term is an `AppBar` **title** (`term_detail_screen.dart:68`). The design makes it a page `h1` in Fraunces at the display step, `line-height 1.02`, `letter-spacing -0.03em` — the tightest setting in the whole design, specific to this screen. | `dictionary.jsx:664` |
| **structural** | Status is a bare `labelSmall` string in the app-bar actions (`term_detail_screen.dart:73-77`); the design pairs an accent `CatGlyph` + category kicker on the left with a `StatusChipMini` on the right, above the title. | `dictionary.jsx:657-663` |
| **structural** | No pronunciation control. The design renders a `SpeakButton` (TTS via `speakTerm`) under the title when `term.pron` exists; the app prints the pronunciation as muted `bodySmall` text (`term_entry_body.dart:54-58`). | `dictionary.jsx:9-50`, mounted `:665` |
| **cosmetic** | The short explanation is set in `bodyLarge` (Plex Sans 15). The design sets it in **Fraunces at the heading step (19)** — it is the entry's deck, not body copy. | `dictionary.jsx:666` |
| **cosmetic** | Deep explanation has **no label**; the design heads it `IN DEPTH`. | `dictionary.jsx:608` |
| **naming** | Block labels diverge across the board: `In use` → **`IN PRACTICE`**; `Check yourself` → **`KNOWLEDGE CHECK`**; `Related` → **`RELATED TERMS`**. (`Sources` matches.) | `dictionary.jsx:614`, `:476`, `:627`, `:549` |

### 9.3 Module screens

| Severity | Divergence | Prototype |
| --- | --- | --- |
| **structural** | **The design has no module-detail screen.** `prototype/app.jsx:202-205` registers only module *completion* moments (`module-complete`, `module-card`, `module-challenge`); a module's lessons are read **inline on Path**, expanded under its heading, and `module.html` is a walkthrough harness that iframes exactly that ("One module, opened to closed", `module.html:84`). The app adds a pushed `ModuleDetailScreen` route. | `app.jsx:202-205`; `screens.jsx:1436-1470` |
| **naming** | Its `AppBar` title is the literal string **`'Module'`** (`module_detail_screen.dart:29`) rather than the module's name. | — |

### 9.4 Lesson player

App: `lesson_screen.dart:94-171` + `lesson_progress_header.dart`.
Prototype: `prototype/lesson.jsx:187-226`.

| Severity | Divergence | Prototype |
| --- | --- | --- |
| **structural** | **The design's player is immersive; the app's is not.** The design has a bespoke `.lesson-topbar` — close (X) left, progress centred, save right — and prints **no lesson title and no module eyebrow** during play. The app shows a stock `AppBar` plus a `LessonProgressHeader` carrying both (`lesson_progress_header.dart:45-51`), so the card competes with chrome the design deliberately removed. | `lesson.jsx:188-202` |
| **structural** | **No close button.** The design's X is the way out of a lesson; the app relies on the `AppBar`'s implicit back. | `lesson.jsx:190-192` |
| **cosmetic** | Progress is a `LinearProgressIndicator` + `'Step N of M'` (`lesson_progress_header.dart:73-96`). The design uses the `RoastBean` six-wedge mark plus a zero-padded mono counter (`01 / 12`) at the label step, 0.12em. | `lesson.jsx:183`, `:196-200` |

### 9.5 Settings

App: `settings_screen.dart:23-84`. Prototype: `SettingsScreen`,
`prototype/screens.jsx:503-565`.

| Prototype sections | App sections |
| --- | --- |
| `APPEARANCE`, `PRACTICE`, `ACCOUNT`, `SUPPORT`, *(unlabelled destructive)*, version footer | `Preferences`, `Appearance`, `Onboarding`, `Danger zone`, `About` |

| Severity | Divergence | Prototype |
| --- | --- | --- |
| **naming** | **`PRACTICE`** is the design's name for the notification/sound/haptics group; the app calls it `Preferences`. `Danger zone` and `Onboarding` are app inventions — the design leaves destructive rows unlabelled. | `screens.jsx:528`, `:557-560` |
| **structural** | Order is inverted: the design leads with `APPEARANCE`, the app leads with `Preferences`. | `screens.jsx:526-535` |
| **structural** | No `ACCOUNT` or `SUPPORT` sections — so Account and sync, Purchases, Help and support, and About have no route, though all four exist as designed screens (`settings.jsx:345`, `:408`, `:576`, `:297`). | `screens.jsx:538-551` |
| **structural** | Missing `Notifications` and `Daily reminder` rows (the latter with its `TimeSheet`). | `screens.jsx:529-530` |
| **structural** | Rows are Material `SwitchListTile` / `ListTile` with leading icons; the design's `NavRow` is a label-left / value-right row on a `rule` bottom hairline, minimum 44px, **no leading icon**. | `settings.jsx:149-189` |
| **cosmetic** | Version is a `ListTile` with `Icons.info_outline` + trailing number. The design closes with one centred mono micro line: `BrewPath · v0.1 · A field guide`. | `screens.jsx:559-563` |

✅ **Not a divergence — checked and cleared:** the app paints Reset Progress in
`mood.berry` (`settings_screen.dart:118-126`). The prototype's `accent` prop on that row is
a misleading *name* — `NavRow` resolves it to `var(--berry)` (`settings.jsx:170`). The app
is correct.

---

## 10. Recommended fix order

Ordered by ruling-risk first, then by breadth per unit of work.

1. **Delete the Profile paywall card** (§1.1). Three rulings, one widget, no dependencies —
   and deletion, not rewriting, because the slot itself is not in the design. Locked
   entries carry a `PlusPill` on the card they gate.
2. **Theme the tab bar** (§2). One `NavigationBarTheme` plus the four labels and the icon
   family kills the sage-pill ruling breach and the app's TODAY/Learn self-contradiction.
   Highest visibility in the app — it is on screen always.
3. **Finish `AppText.textTheme`** (§7). Six added slot mappings move a large share of app
   text off Roboto and onto the ladder in one file. Do this **before** the screen work, or
   every screen fixed after it gets re-touched.
4. **Fix `SectionHeader` to delegate to `SmallcapsLabel`** (§7.1), then fold `_Block` and
   `_SectionLabel` into it. Four screens' section headers, one widget.
5. **Add the `accentText` token** (§8) and sweep the small-text `mood.accent` call sites.
   Accessibility, and it gets cheaper the earlier it lands.
6. **Profile tab restructure** (§6) — greeting, tree hero card, streak card, mastery
   rollup, the three entry cards; move the preferences grid into Settings.
7. **Learn/Path module split** (§11, §16-19) — the largest single structural correction:
   take modules off Learn, reshape Path's header and density.
8. **Dictionary home** (§9.1) — Term of the Day, quick chips, the category index. Note
   ADR-0002 makes the missing Term of the Day a ruling matter, not only a layout one.
9. **Lesson player immersion** (§9.4) and **Settings sections** (§9.5).
10. **Cards tab locked-card policy** (§21-22) — behavioural as much as visual; confirm with
    the owner that hiding the unearned remainder is still wanted before building it.

---

## 11. Open questions for the owner

These are the places where the prototype and a closed ruling could be read as disagreeing;
none was resolved here, because the register records rather than decides.

- **Coffee Duel** appears on both Profile and TODAY in the prototype behind a `showDuel`
  flag. The app has no Duel anywhere. Is Duel v1 or v2? The register counts its absence as
  a Profile structural gap on the assumption it is v1; if it is v2 that entry drops.
- **The Courses card** is `showStore`-gated off for v1 by the prototype's own comment
  (`screens.jsx:2769-2771`), so its absence from the app is **correct** and is not counted
  as a divergence.
- **Module detail** (§9.3): the app has a screen the design does not. Deleting the route is
  the parity-true answer, but it is load-bearing for navigation today — worth a decision
  rather than a silent removal.
- **`ReplayTourRow`** on Profile has no prototype counterpart, but the guide layer is
  explicitly out of this map's scope (#337, *Out of scope*), so it is not counted.
