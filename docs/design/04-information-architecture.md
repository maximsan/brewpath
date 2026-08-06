# Information architecture

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `brew-path/`.


## Tabs (v1)
| Tab | Screen | Content |
|---|---|---|
| **Learn** ("Today") | `LearnTab` | Date header, freeze-save notice, Continue Learning card, active Brew Challenge, saved challenges, Practice Again (collapsible: Lessons, Mini-games) |
| **Path** | `PathTab` | Vertical module path with lesson nodes, mastery bean fill, brew-challenge nodes, and the four named coming-soon modules (`ComingSoonPath`) |
| **Cards** | `CardsTab` | Collectible card grid; tap → `CardSheet` |
| **Profile** | `ProfileTab` | Tree hero, streak card + week strip, points line, mastery rollup, brew-challenge stat, Studio card, Saved card, joined date |

## Global header (`AppHeader`)
Pinned top-right: **Saved** (with count badge, lock badge if gated) and **Dictionary**. Profile variant swaps in a gear → Settings. Duel entry is present but `showDuel={!isV1}`.

Per-tab eyebrow + title (`APP_HEADER_TITLES`, `screens.jsx:713`) — user-visible copy, declared in code rather than content:

| Tab | Eyebrow | Title |
|---|---|---|
| Learn | `TODAY` | The date, e.g. "Friday, May 8" (**frozen** to `new Date(2026, 4, 8)` — see [§5.11](05-mechanics.md)) |
| Path | `YOUR PATH` | Beginner Foundations |
| Cards | `YOUR DECK` | Collection |
| Profile | `PROFILE` | `Hello, ` + `USER.name` + `.` — "Hello, Taster." with the seed user |

"Beginner Foundations" is the only name the five-module course is given anywhere in the product.

## The roadmap the Path tab shows users (`ComingSoonPath`, `screens.jsx:1146`)

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

**Relationship to the [§5.5](05-mechanics.md) gating rule.** These four are *not* locked `MODULES`
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

## Full route list (103 deep-link states)

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

← [Design system](03-design-system.md) · [Contents](README.md) · [Core logic and mechanics](05-mechanics.md) →
