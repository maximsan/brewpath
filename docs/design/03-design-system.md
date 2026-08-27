# Design system

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `prototype/`.


## Color tokens (two moods, one system)
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
The cherry-anatomy work ([§6.1](06-content.md), `m1l7`) added eight tokens to what was a six-token set:

| Group | Tokens |
|---|---|
| Bean / roast | `--art-raw #9FB088` · `--art-roast-light #C79A63` · `--art-roast-mid #A2703C` · `--art-roast-deep #7A4526` · `--art-roast-dark #54301C` · `--art-ripe #C8843A` · `--art-sour #B79A3C` · `--art-seed-crease #5C6B52` |
| Cherry cross-section | `--art-cherry-skin #A93227` · `--art-cherry-pulp #C9563A` · `--art-cherry-gel #D9A94C` · `--art-cherry-parchment #E3D2AE` · `--art-cherry-silverskin #F1E8D6` · `--art-cherry-seed #8FA184` |

The separation from theme tokens is deliberate: keeping cherry/bean colours out of `--warn` is what lets `--warn` mean exactly one thing.

## Typography — 3 families, one 9-step ladder, nothing off-ladder
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

## Frame & layout
- Phone: 393 × 852 (iPhone 15), 56px corner radius, dynamic island, status bar, home indicator.
- Horizontal gutter: `.px-24` (24px); tight layouts drop narrower.
- iOS large-title pattern: large in-flow title scrolls away, compact blurred sticky header appears at `scrollTop > 72`.
- Header edge controls are 44×44 (fixed during QA).

## Radius — two languages, deliberately

There is **one radius token** (`--r: 14px`). Everything else is a rule, not a scale:

| Radius | Language | Where |
|---|---|---|
| **2px** | Editorial | Cards, buttons and inputs. The sharp, print-like default. |
| **14px** (`--r`) | Soft chrome | Media frames, bottom sheets, icon wells, avatars, mini-game tiles. 14px is the token; 12–20 is the range other chrome may sit in. |
| **999px** | Pill / dot | Status dots, fav toggle, switch toggles, badges, home indicator. |

> **"Mixing them on one element is the tell of an off-system component."**
> Two radius languages run in parallel on purpose; they are not points on one scale.

> ⚠️ **MCQ and match tiles are 14px, not 2px.** The two prototype sources
> disagree: `Design System.html` sets `.mcq-choice` and `.match-item` to `2px`,
> while `index.html` — the running prototype — sets both to `var(--r)`. Per
> [ADR-0009](../adr/0009-the-running-prototype-wins-over-the-design-system-catalogue.md)
> the running prototype wins, so they are **14px** and this table no longer
> lists them under editorial. The dropped value is named here so it is not
> "corrected" back. `.pick-tile` is 14px in both.

> ⚠️ **Correction.** Earlier versions of this doc listed a "radius scale of
> 4 / 12 / 14 / 16 / 20 / 999". No such scale exists in the source — `--r` is
> the only radius token, and the editorial default is **2px, not 4px**. An
> implementation built from the old line would round every card and button
> wrong.

## Borders & elevation
- **Hairlines do the work.** 1px `--rule` separates almost everything; shadows are reserved for sheets and floating buttons only.
- **Selection = double stroke.** A selected card keeps its border and adds `inset 0 0 0 1px var(--accent)` — a crisper edge, never a fill.

## Theme handling
Preference is `light | dark | system`, stored in `localStorage['cq-theme']`, default `dark`. `system` follows `prefers-color-scheme` live. A pre-paint inline script in `index.html` applies it before first render to avoid flash. Cross-iframe sync via the `storage` event.
DOM contract: `data-mood="dark-roast" | "cupping"` on `<html>`, plus a legacy `data-theme="dark"` alias.

## Mascot — Roasty (`roasty.jsx`, 868 lines)
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

## Icon set (`flavor-wheel.jsx`, all inline SVG)
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

## The design system is specified far beyond this section

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
| Progress & reward | Mastery rollup · Points mark · Points chip · Sequence row · Coffee challenge card |
| Layout & chrome | Card or section · **Empty state** · Screen top bar · Header buttons · Sticky action bar · Scrims and dims · Media frame · Media overlay button |
| Sheets | Bottom sheet · Result sheet |
| Plus & gating | Lock affordances · Plus gate sheet · Rewarded ad |
| Games | Card cue · Round length |
| Brand & boot | Roasty, the companion · Intro screen skeleton · Tap to continue · Brand mark · Loading sequence |

**Empty states are specified there and nowhere in this doc** — worth knowing before anyone writes an empty-state ticket from [§11](12-checklist.md).

**The `FLAGS` register.** The design-system site carries its own audit register
(severity `high` → "NEEDS DECISION", `med` → "SHOULD FIX", `low` → "POLISH",
plus resolved entries with an `APPLIED` note). **It is currently empty —
`FLAGS = []`, rendering "No open flags".** The site's convention is that fixes
are folded into the rule they changed rather than logged, so the register only
ever holds live drift. An empty register means no known design drift, not that
nobody looked.

---

← [Scope: what ships in v1](02-scope.md) · [Contents](README.md) · [Information architecture](04-information-architecture.md) →
