# Component & state inventory

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `prototype/`.

[§5](05-mechanics.md) gives the **rules**. [§6](06-content.md) gives the **content**. This section
gives the **surfaces** — every exported component, the states it can be in, and
the options that change what it renders.

**What this is for:** answering "what happens if…" questions. What does the
challenge card look like once it's logged? What does Restore Purchases do when
there's nothing to restore? Which component does the Profile row reuse?

**What it is not:** a visual specification. How a component *looks* — its
tokens, spacing, and per-state styling — lives in `Design System.html`
(indexed in [§3](03-design-system.md)). Where a component here implements a documented
design-system pattern, the mapping column names it; where the binding is a
judgement call rather than literal code reuse, it says so.

---

## 7.1 Shared primitives

These are reused across screens. Getting them right first removes most of the
per-screen work.

| Component | File | States / options | Design-system pattern |
|---|---|---|---|
| `NavRow` | `settings.jsx:142` | `label` · `sub` · `value` · `accent` (destructive) · `dim` (disabled-looking but live) · `external` · `toggle` + `toggleOn` · **`pending` + `pendingLabel`** (async, e.g. "Restoring…") | **Settings / nav row** |
| `SettingsRow` | `screens.jsx:2691` | Alias of `NavRow`, kept so screen code reads in its own vocabulary | same |
| `SettingsToggle` | `settings.jsx:11` | `on` / `off` | **Toggle** |
| `ConfirmSheet` | `settings.jsx:39` | `eyebrow` · `title` · `body` (⚠️ **single `<p>` — cannot render the approved multi-paragraph delete copy**, see [§5](05-mechanics.md) 5.12) · **`lines`** (itemised loss summary) · `danger` · custom `confirmLabel` / `cancelLabel` (default "Keep my progress") | **Bottom sheet** + **Result sheet** |
| `TimeSheet` | `settings.jsx:87` | 8 preset times; `value` / `onSave` | **Bottom sheet** |
| `PlanSheet` | `settings.jsx:388` | Yearly / Monthly from `PLAN_OPTS` | **Bottom sheet** |
| `SubScreenHeader` | `settings.jsx:254` | `scrolled` · `icon: 'back' \| 'close'` · `right` slot · `ringBack` · `solid` | **Screen top bar** + **Header buttons** |
| `StickyHeaderChrome` / `HeaderCompactTitle` | `settings.jsx:205,227` | `scrolled` — drives the iOS large-title collapse at `scrollTop > 72` | **Screen top bar** |
| `useScrollFlag(threshold=40, resetKey)` | `settings.jsx:193` | The hook every sub-screen uses for the above | — |
| `FormRow` | `screens.jsx` | — | **Form row** |
| `Bookmark` / `FavButton` / `TopBarFav` | `library.jsx` | saved / unsaved; `TopBarFav` is the in-player variant | **Save toggle** |

> **`dim` is not `disabled`.** A dimmed row still responds — "Daily reminder"
> renders dim with the value `Off` when notifications are toggled off, but
> remains tappable. An implementation that maps `dim` to a disabled control
> changes the behaviour.

---

## 7.2 Profile

`ProfileTab` (`screens.jsx:2418–2652`) is a single scrolling column. **Seven of
its eight blocks are tappable** — it is closer to a menu than a dashboard, which
is easy to miss when reading it as "the stats screen".

| # | Block | Eyebrow / title | Action | Renders when |
|---|---|---|---|---|
| 1 | **Tree hero** | `YOUR COFFEE TREE` | **button** → `onOpenTree` (Tree screen) | always |
| 2 | Tree caption | — | — | `lessonsDone >= total` → **"Fully grown"**, else **"{n} / {total} core lessons"** |
| 3 | **Streak card** | `CURRENT STREAK` | **button** → `onOpenStreak` (Streak screen) | always. Embeds `WeekStrip size="sm"` with `frozen` + `streak`. The comment is explicit that the card is *a preview of that screen, so it cannot invent its own glyph* — it reuses the mark from the Streak screen's ring |
| 4 | Points line | — | **not tappable** | always. A quiet centred line: `PointsBean` + "{n} lesson/lessons · {n} points" |
| 5 | **Mastery rollup** | `LESSON PROGRESS` | **button** → `onPractice` — deep-links to the Path to practise weak lessons | **only when `playedLessons.length > 0`** — hidden for a brand-new user |
| 6 | **Coffee challenges** | — | `BrewChallengeStat` → `onOpenBrew` (7.4) | when the component exists |
| 7 | **Studio card** | "Dress up Roasty" / "Hats, outfits and your plant" | **button** → `onOpenCustomize` | always. `PlusPill` when `lock('studio')`. ⚠️ **The app says `GROVE · Choose your plant`** — the design's Studio is a hub of several doors and v1 ships only the grove chooser ([#140](https://github.com/maximsan/brewpath/issues/140)), so the card names what it opens. The mascot wardrobe returns with the hub in v2 |
| 8 | **Duel card** | "Challenge a friend" / "Quick head-to-head quizzes" | **button** → `onOpenDuel('hub')` | **`showDuel` only — v2.** `PlusPill` when `lock('duel')` |
| 9 | **Saved card** | "Your favorites" / "{n} saved to revisit" | **button** → `onOpenSaved` | always. ⚠️ **The `PlusPill` branch here is dead**: `featureUnlocked('saved')` returns true unconditionally (`app.jsx:519-522`), because the shelf is free and what Plus lifts is the cap on saving past five, gated at the bookmark. Do not port a pill onto this card |
| 10 | Joined date | — | — | always. "Joined May 2026", frozen ([§5](05-mechanics.md)) |

Settings is reached from the header gear (`onOpenSettings`), not from a row.

**The mastery rollup is the most detailed block and was previously described as
"points line + mastery rollup", which conflated it with #4.** It contains:

- `{doneN} / {allLessons.length} DONE` in mono, right-aligned
- A **two-segment bar** — `--sage` for solid, `--accent` for needs-practice, remainder empty
- A legend: "**{n}** solid" (sage dot) · "**{n}** need practice" (accent dot, dimmed to `--ink-mute` when the count is 0)
- A `Chevron`

`WeekStrip` (`screens.jsx`) renders 7 day cells in three states: **filled**
(streak-derived), **frozen** (covered by a spent freeze), **empty**.

> ⚠️ **`ProfileTab` accepts `theme` and `onTheme` and never uses them.** The
> theme control lives in `ThemeRow` (`screens.jsx:2652`), rendered by
> `SettingsScreen`. Dead props — drop them rather than porting them.

---

## 7.3 Settings, account & subscription

`SettingsScreen` (`screens.jsx:510`) is rows only; every destination is its own
component in `settings.jsx`.

| Screen | Component | States / options |
|---|---|---|
| Settings | `SettingsScreen` (`screens.jsx:510–611`) | 12 rows across 5 groups + the version line. `showDataExport` gates the v2 "Download my data" row; `progressSummary` feeds the reset `ConfirmSheet`'s itemised lines |
| About | `AboutScreen` (`settings.jsx:279`) | **Not static — 6 nav rows in 2 groups.** See below |
| Help | `HelpSupportScreen` (`settings.jsx:650`) | 4 `FaqRow` accordions under `COMMON QUESTIONS` **plus 2 contact rows** under `GET IN TOUCH`. See below |
| Account and sync | `AccountSyncScreen` (`settings.jsx:327`) | Status pill `BREWPATH PLUS · TRIAL` / `BREWPATH PLUS` · plan line ("Yearly" / "Monthly" / "Billed monthly") · **"Sync over cellular" toggle** · **"This iPhone" device row** · `Manage Plus` vs `Upgrade to Plus` → `onManagePlan` · `Sign out` → `onSignOut` |
| Subscription | `SubscriptionScreen` (`settings.jsx:437`) | The largest state surface in Settings — below |

### About — 6 rows, four of them external

Previously described here as "static; carries the version string". It is a
menu:

| Group | Row | `external` | Handler |
|---|---|---|---|
| `THE FINE PRINT` | **Privacy policy** | yes | `() => {}` |
| | **Terms of use** | yes | `() => {}` |
| | Acknowledgements | no | `() => {}` |
| | Open-source licenses | no | `() => {}` |
| `SAY SOMETHING` | **Rate BrewPath** | yes | `() => {}` |
| | **Say hello** — value `hi@brewpath.app` | yes | `() => {}` |

Header copy: `A FIELD GUIDE TO COFFEE`.

> ⚠️ **Privacy policy and Terms of use appear in two places** — here, and on the
> paywall ([§5](05-mechanics.md) 5.9) where they are a store-review requirement.
> Both must resolve to the same real URLs. [§5](05-mechanics.md) previously named
> only the paywall pair.

### Help and support — 2 contact rows beyond the FAQ

| Group | Row | `external` |
|---|---|---|
| `COMMON QUESTIONS` | 4 × `FaqRow` accordion ([§6](06-content.md)) | — |
| `GET IN TOUCH` | **Email support** — value `hi@brewpath.app` | yes |
| | **Report a problem** | yes |

> ⚠️ **All 8 About/Help rows are `onClick={() => {}}` — dead stubs.** They render
> as fully interactive rows with an external-link affordance and do nothing.
> Every one needs a real destination before ship: two legal URLs, an App Store
> review deep link, two mail composers, a licenses screen and an
> acknowledgements screen. That is **8 pieces of work behind rows the prototype
> makes look finished**, and none of them appeared in [§12](12-checklist.md)
> before this pass.

> **"Sync over cellular" and "This iPhone" are the UI for the offline promise.**
> [§6](06-content.md)'s FAQ commits to keeping opened modules on device and syncing when
> online. These two controls are where that surfaces, and both were missing from
> every earlier version of this reference.

### Restore Purchases — a three-outcome state machine

`SubscriptionScreen` (`settings.jsx:437`). The source comment states the reason
plainly: *"iOS owns the Apple ID auth sheet, StoreKit hands back a result, and it
shows the user NOTHING. So the three outcomes below are ours to state plainly —
otherwise the row looks broken on the two paths that don't end in a
subscription."*

| Outcome | Eyebrow | Title | Body |
|---|---|---|---|
| `plus` | `PLUS RESTORED` | "Your Plus is back." | "We found your subscription on this Apple ID and reactivated it. Saved is unlimited again, and Roasty and your plant are yours to dress." |
| `none` | `NOTHING TO RESTORE` | "No purchase on this Apple ID." | "If you bought Plus with a different Apple ID, sign in with that one and try again." |
| `error` | `RESTORE FAILED` | "We couldn't reach the store." | "Check your connection and try again." |

Plus the transitions around them:

- **Pending:** the row renders through `NavRow`'s `pending` state with the label **"Restoring…"**; re-entry is blocked while in flight.
- **Simulated latency:** 1500 ms in the prototype — a real StoreKit call replaces it.
- **Error retry:** confirming the `error` sheet re-runs the restore. Confirming the other two just closes.
- **Success side-effect:** `plus` fires `onRestored`, flipping app-level Plus state.

**This is a store-review surface.** A build that only implements the happy path
fails the first reviewer who taps Restore on a fresh account.

### Cancel — two copy variants, four labels

| Case | Title | Body | Confirm | Cancel |
|---|---|---|---|---|
| In trial | "Cancel your free trial?" | "You won't be billed. Plus stays open until …" | **Cancel trial** | **Keep trialling** |
| Paying | "Cancel your subscription?" | "Plus stays open until …" | **Cancel subscription** | **Keep Plus** |

Both run through the `danger` `ConfirmSheet`. The restore-error sheet uses a
third confirm label, **"Try again"**.

### The rest of the Subscription screen

| Element | States |
|---|---|
| Status | **Trialling** / **Active** |
| Date row | **First charge** (in trial) · **Next charge** / **Renews {date}** (paying) |
| Benefits list | "Unlimited Saved" · "Dress up Roasty" · "Choose your plant" — the source notes this *"matches the paywall's pitch exactly — the two levers, not the old cosmetics list"* |
| Change plan | → `PlanSheet` (Yearly / Monthly from `PLAN_OPTS`) |
| Restore purchases | The three-outcome machine above |
| Cancel | The two variants above |

---

## 7.4 Coffee Challenges

11 exported components in `brew-challenge.jsx`. [§5](05-mechanics.md) covers the rules; this is
the surface inventory.

| Component | Line | States / options |
|---|---|---|
| `ActiveBrewCard` | 201 | **`mode: 'active' \| 'completed'`**. `active` shows Log Result / Skip. `completed` is a **transient confirmation**: lingers, fades at 4800 ms, self-dismisses at 5600 ms (`autoHide`, defeatable). `showPoints` toggles the +5 display. ✕ always dismisses immediately |
| `LogResultSheet` | 320 | Three reaction buttons from the challenge's own `reactions[3]`, under its own `prompt` |
| `BrewRecapSheet` | 379 | Post-completion record; the **only** route back to an unlimited replay |
| `ChallengeSuggestion` | 421 | One reward-screen row — label, muted detail, one go button. Its own **`suggested` → `started`** morph, *and* a separate **`realState`**: `completed` or `active` renders nothing at all, because Today owns that status. **No dismissal** — leaving the screen is the not-now |
| `PathChallengeNode` | 497 | Header comment documents 4 states; the code handles **5**: `locked` · `available` · `active` · `completed` · **`saved`**. ⚠️ See below |
| `CardStampSection` | 459 | Inside the card sheet. Renders **only if the card is earned** — the locked teaser opens the same sheet and must not offer the challenge. `completed` + `active` combine into a distinct "Active again on Today" line |
| `SavedBrewList` | 550 | The parked queue. Excludes the active one and anything completed; filters again by `reached` so a challenge tied to a lesson still ahead is never advertised |
| `BrewChallengeStat` | 618 | Profile row, `done / total`. Progress fraction floors at `0.02` so an empty bar is still visible |
| `BrewStamp` | 132 | `done` · **`press`** (the stamp-press animation) |
| `TriedSeal` | 165 | The permanent "tried it for real" mark on a collectible |
| `BrewCup` | 110 | Icon; `steam` toggle |

> ⚠️ **`PathChallengeNode`'s comment is out of date.** It documents
> `'locked' \| 'available' \| 'active' \| 'completed'`, but the body also
> branches on `saved`. Five states, four documented — fix the comment or drop
> the branch.

### Challenge shape — two fields the content tables omit

Each entry in `BREW_CHALLENGES` carries a **`prompt`** (the log sheet's question)
and three **named reactions**, neither of which appears in [§6](06-content.md)'s title table:

| Challenge | Prompt | Reactions |
|---|---|---|
| `bc-m1` Two cups, two ratios | `WHICH CUP WON?` | Preferred 1:15 · Preferred 1:17 · About the same |
| `bc-m2` Blind process test | `HOW DID THE GUESS GO?` | Got it right · Got it backwards · Honestly a coin flip |
| `bc-m3` Light vs dark | `WHICH ONE WON?` | Prefer lighter · Prefer darker · About the same |
| `bc-m4` One-step grind test | `WHICH CUP WON?` | Finer cup won · Coarser cup won · About the same |
| `bc-m5` Fix one bad cup | `DID THE FIX WORK?` | — |
| `bc-m1l1` Name the origin | `DID YOU FIND IT?` | — |

`cardId` links a challenge to the collectible whose stamp it unlocks. The source
notes it is *"unused by the current module-only set"* in one comment and used in
another — worth a check when porting.

---

## 7.5 Lesson player

| Component | File | States / options | Design-system pattern |
|---|---|---|---|
| `LessonPlayer` | `lesson.jsx:125` | `startKind` opens at a given card kind (the `card-*` deep links). **`prediction` is held at lesson scope** and cleared on `lessonId` change, so the closing `recall` can resolve the opening `predict` ||
| `HelpDrawer` | `lesson.jsx:62` | Renders only when `CARD_KIND_HELP[kind]` exists — 10 of 15 kinds ([§6](06-content.md)) ||
| `MiniGamePlayer` | `lesson.jsx` | Own intro → play → results; never touches progression ||
| `FillSlot` | `lesson.jsx` | The concept card's tap-to-choose blank | **Fill-in-the-blank** |
| `TasteFixCard` | `practical.jsx` | | **Taste Fix card** |
| `VisualGuideCard` / `VisualGuideThumb` / `VisualLessonCard` | `practical.jsx` | 8 `VISUAL_GUIDE_CONTENT` variants; `inSheet` and `hideHeader` / `mergeHeader` layout options ||
| `PracticalCard` | `practical.jsx` | ||
| `CherrySection` / `GreenBean` / `BagPickCard` | `bean-anatomy.jsx` | `GreenBean` renders from process cues: `body` colour, `crease` colour, `mottle`, `chaff`. `BagPickCard` draws a sample, exposes cues, takes the call | **Card cue** |

Card renderers for `predict` / `decision` / `recall` live in `active-cards.jsx`
and export nothing to `window` — they are referenced directly by `lesson.jsx`.

---

## 7.6 Dictionary

| Component | File | States / options | Design-system pattern |
|---|---|---|---|
| `TermDetail` | `dictionary.jsx:584` | **`variant: 'entry' \| …`** · `learned` · the reference-only branch ([§6](06-content.md)) ||
| `StatusGlyph` | `dictionary.jsx:82` | **3 states**: learned (filled sage dot) · **reference** (hairline ring + 7×1.5 dash) · to-learn (hollow dot, dashed ring) | **Term row** |
| `StatusChipMini` | `dictionary.jsx:120` | `LEARNED` / **`REFERENCE`** / `TO LEARN` | **Term status chip** |
| `TermPeekSheet` | `dictionary.jsx` | Non-interrupting in-lesson peek | **Term peek sheet** |
| `TermCheck` | `dictionary.jsx` | Self-check question | **Knowledge check** |
| `RelatedChips` | `dictionary.jsx` | Learned-state aware | **Related chips** |
| `SpeakButton` / `speakTerm` | `dictionary.jsx` | Text-to-speech | **Pronunciation chip** |
| `CatGlyph` | `dictionary.jsx:79` | One per category (8) | |
| `linkifyTerms` | `dictionary.jsx` | Auto-links glossary terms in body copy | |

### Dictionary home (`dictionary.jsx:316–464`)

| Element | Action / state | Design-system pattern |
|---|---|---|
| **Search field** | `setQuery`; matches term text **and aliases**. Takes `initialQuery` and **`focusSearch`** — search is deep-linkable and can open focused | **Search field** |
| **Status filter** | `setFilter` — `all` / `learned` / to-learn, with live counts. Reference-only terms are excluded from to-learn ([§6](06-content.md)) | **Segmented control** |
| **Category tile** | `() => { setFilter('all'); setCat(c.id) }` — **picking a category silently resets the status filter to All.** Deliberate (a category + "learned" often yields nothing) but worth preserving knowingly ||
| **Term-of-Day banner** | `TermOfDayBanner` → `onTermOfDay`, `big` variant on home ||
| **Quick chips** | `DictQuickChips` → `onFlashcards` · `onVocabGame`, disabled/annotated by `savedTermCount` ||
| Category grid | `ALL CATEGORIES`, one `CatGlyph` each (8) ||
| Reference header | `REFERENCE · {n} TERMS` ||
| Term row | `DictTermRow` → `onOpenTerm`, plus `onToggleFav('t:' + id)` outside the open tap target ||

> ⚠️ **`recent` is a dead prop.** `app.jsx` tracks and persists `cq-recent-terms`
> and passes it in as `recent`, but `DictionaryHome` never reads it and **no
> recent-strip component exists**. Earlier text here called it "built but not
> surfaced" — it is *tracked but never built*. Either build the strip or drop the
> key; right now the app is persisting data nothing consumes.

### Term of the Day (`dictionary-extras.jsx:12–66`)

`onOpenFull(term.id)` → "Read the full entry" · `onToggleFav` · `onClose` /
"Back". Term selection is deterministic by date, frozen to 18 Jun 2026
([§5](05-mechanics.md)).

### Flashcards (`dictionary-extras.jsx:116–276`)

A real card-drill, not a list. Previously described here as "drill over saved terms".

| Action | Behaviour |
|---|---|
| **Tap card** | `setFlipped(f => !f)` — flip between term and definition |
| **`go(-1)` / `go(1)`** | Previous / next card |
| **`shuffle`** | Re-order the deck |
| **`onOpenTerm(term.id)`** | Jump from a card into the full entry |
| **`onBrowse`** | Empty state → "Browse the dictionary" |

### Vocab game (`dictionary-extras.jsx:299–485`)

A **three-phase machine** (`useStateX('setup')` → play → results), configurable
before it starts.

| Setup control | Options |
|---|---|
| **Deck picker** | `setDeck(d.id)` — Saved terms vs all ("Every term in this deck"). Defaults to `canSaved ? 'saved' : 'all'`; decks carry a `disabled` state when too small |
| **Round length** | `setLen(n)`, default **5**, guarded by `capped` so you cannot ask for more rounds than the deck holds |
| **Start** | `start` → "Start round" |

| Play / results | Behaviour |
|---|---|
| `pick(idx)` | Answer the round |
| `next` | Advance |
| `readMisses` | Missed terms are collected and shown at the end |
| `onOpenTerm(round.answer.id)` | Open any missed term from the results |

Both practice screens reuse the lesson top bar + roasting-bean counter and end on
a Roasty results screen.

---

## 7.7 Plus, gating & Studio

| Component | File | States / options | Design-system pattern |
|---|---|---|---|
| `FeatureLock` | `gating.jsx` | **3 styles**: `blur` (frosted peek at the real screen) · `hard` (opaque panel, no preview) · `curtain` (content visible up top, rising curtain + lock card) ||
| `LockCard` | `gating.jsx:306` | `glass` · `showAd` | **Plus gate sheet** |
| `PlusGateSheet` | `gating.jsx` | Raised by `requestFeature` on a denied key | **Plus gate sheet** |
| `LockBadge` · `PlusPill` · `LockGlyph` | `gating.jsx` | `PlusPill` takes a `tone` | **Lock affordances** |
| `TrialBadge` | `gating.jsx:59` | `until` · `floating`; re-renders on a 1 s interval | |
| `RewardedAdScreen` · `RoastyGiftScreen` | `gating.jsx` | v2. `TRIAL_AD_MIN` (15) / `TRIAL_GIFT_MIN` (24 h) | **Rewarded ad** |
| `PaywallScreen` · `PlusWelcomeScreen` · `StudioHub` | `customize.jsx` | | |
| `TreeChooserScreen` | `customize.jsx` | Two axes: variety (3) × light (4) ([§6](06-content.md)) | |
| `RoastyStudio` | `customize.jsx` | 4 `OptionRow`s + a randomise action | |
| `RoastyMoodScreen` | `customize.jsx` | v2; 5 backdrops | |

**`PLUS_FEATURES` blurbs are user-visible copy**, one per gated key — including
the Saved one, which is written for the cap-reached moment specifically: *"Your
free shelf is full. Plus keeps unlimited lessons, terms and guides together for
review."*

---

## 7.8 The three remaining tabs

### Learn (`screens.jsx:757–949`)

| Block | Action | Renders when |
|---|---|---|
| Freeze-save notice | **✕ button** → `onDismissFreeze` (`aria-label="Dismiss"`) | `freezeSaved`. Carries `freezesHeld` and `nextFreezeIn`. ⚠️ **Both changed shape** under [Streak freeze](https://github.com/maximsan/brewpath/issues/58): `freezesHeld` is now `0 \| 1`, and **`nextFreezeIn` has no value while a freeze is held**, because accrual stops until one is spent. The component needs that null state — the prototype's copy assumes a countdown always exists |
| Continue Learning | **primary button** → `onLesson(curLesson.id)` | a current lesson exists |
| Active coffee challenge | `ActiveBrewCard` → `onBrewLog` · `onBrewSkip` · `onBrewDismiss` · `onBrewCard` (7.4) | `brewChallenge` |
| Saved challenges | `SavedBrewList` → `onBrewAction(ch, 'available')` · `onBrewUnsave` | the queue is non-empty **and** each entry's source lesson is reached |
| **Duel card** | **button** → `onOpenDuel('hub')` | **`showDuel` only — v2** |
| **Practice** | per row: **`isGame ? onGame(it) : onLesson(it.id)`**; the drill rows → `onVocabGame` / `onFlashcards` | groups Lessons and Games. [ADR-0004](../adr/0004-learn-tab-practice-section-lists-all-four-practice-types.md) renames the section and puts the two dictionary drills at the head of **Games**, free and always visible, with no lock treatment. *Guess the term* shipped with [#98](https://github.com/maximsan/brewpath/issues/98); Flashcards joins the same row group with [#97](https://github.com/maximsan/brewpath/issues/97) |

> ⚠️ **`LearnTab` accepts six props it never uses:** `onStreak`, `onOpenModule`,
> `onOpenSaved`, `onOpenDictionary`, `onOpenTermOfDay`, `brewPathMode`. Saved and
> Dictionary are reached from `AppHeader`, not from the tab body. Dead props —
> the same pattern as `ProfileTab`'s `theme` / `onTheme` (7.2).

### Path (`screens.jsx:1266–1470`)

Only 6 props, but one undocumented behaviour that changes how the screen reads.

| Element | Action |
|---|---|
| Module header | **button** → `toggleMod(mod.id)`, but only when `canCollapse`; `disabled` when `mod.locked \|\| !canCollapse` |
| Lesson node | **button** → `onLesson(lesson.id)`, guarded by `!isLocked` — **except a purchase-locked one**, which stays live: `disabled={isLocked && !buyLocked}` (`screens.jsx:1487`) |
| Challenge node | `PathChallengeNode` → `onBrewAction` (7.4) |
| Compact module row | `CompactModuleRow` → **`onTap={onPurchaseTap}`** (`screens.jsx:1418`), and it is `interactive` **only** when `purchase` is true |
| Coming-soon teaser | none — `ComingSoonPath compact` is inert ([§4](04-information-architecture.md)) |

> **The purchase lock is a second lock, drawn differently.** `buyLocked =
> !isComplete && purchaseLocked(lesson.id)` (`screens.jsx:1477`); a module takes
> it from its **first** lesson (`:1417`). It draws the mark in **`--accent`**
> where progression draws `--ink-mute` (`:1509` against `:1513`), labels it
> `Part of Foundations`, and replaces the module sub-line's prereq hint with
> `Part of Foundations · {n} lessons` (`:1345`). The row stays tappable and
> raises the purchase sheet.
>
> The app follows this on all three locked surfaces, Reference included —
> [ADR-0016](../adr/0016-a-locked-row-names-what-unlocks-it-for-this-learner.md),
> which is where the rule and the owner's ruling behind it live.

> **Completed modules collapse, and default to collapsed.**
> `canCollapse = allDone && !mod.locked`; `open = !canCollapse || expandedMods[mod.id]`.
> So a module folds away the moment its last lesson is done, keeping the current
> module in view. In-progress and locked modules cannot be collapsed.
>
> ⚠️ **The expanded/collapsed state lives in `window.__pathExpandedMods`,** a
> global mirrored out of React state — not in `localStorage`, not in a provider.
> It survives tab switches within a session and is lost on reload. A real
> implementation needs to decide deliberately whether this persists.

### Cards (`screens.jsx:1470–1533`)

| Element | Action |
|---|---|
| Collectible | `CollectionCard` → `onOpen` → `CardSheet` |
| Header count | "{earned} of 37" — not 42, see below |
| Footer | "{n} more to collect" |

Two filtering rules, both previously mis-stated in this reference:

1. **`collectibles = COLLECTIBLES`** — the visual guides live in their own registry, so no filter is needed and the grid is **37 cards**. The old render-time filter is gone; `ProfileTab`'s rollup reads the same list.
2. **Only the first locked card renders.** Earned cards draw normally; the card at `firstLockedIdx` draws as a teaser; every later locked card `return null`s. There is no wall of silhouettes.

`stampedFor(c)` and `challengeOpen(c)` decorate earned cards with brew state — a
challenge is "on offer" when the card is earned, has a linked challenge, and is
not yet stamped.

---

## 7.8b Reward screens, shell & the rest

**Both reward screens are two-phase.** They open on `phase: 'roasty'`
rendering a full-screen `RoastyMoment`, and only switch to `phase: 'content'`
when it calls `onDone`. Flow diagrams that show `lesson-complete` as a single
screen are missing this.

| Screen | Roasty state | Eyebrow | Extra interactions |
|---|---|---|---|
| `LessonCompleteScreen` | `lesson` | `LESSON COMPLETE` | `onContinue` · `onBack` · **`setPreview(true/false)`** — a tap-to-enlarge overlay on the earned card, dismissed by tapping the scrim (`stopPropagation` on the card itself) · `onPractice` · **`onDuel`** · `ChallengeSuggestion` → `onStart` (the `onNotNowChallenge` prop is vestigial — nothing passes it on) |
| `ModuleCompleteScreen` | `module`, `autoMs={2200}` | `MODULE COMPLETE`, "Look how far you've come." | `onContinue` · `onBack` · **`flipTo(true/false)`** — the **whole screen** turns over to the `RewardCard`; the back face's close control flips it back · `ChallengeSuggestion` → `onStart`, above the exit CTA on that back face and only while the offer is live ([#464](https://github.com/maximsan/brewpath/issues/464)) |

`ModuleRewardCardScreen` is **gone** — the 3 Sep drop deleted it, and its one surviving trace is the `module-card` demo route, which now opens `ModuleCompleteScreen` with `startFlipped` so it lands straight on the flip's back face. That is the ruling [#230](https://github.com/maximsan/brewpath/issues/230) and ADR-0017 already reached: the card is the back of the module ending, not a screen after it.

**Duel has three entry points in the prototype** — Profile card (7.2), Learn
card, and the lesson-complete screen — all behind `showDuel` / `!isV1`. Any v2
work has to re-light all three, not just the tab.

| Component | File | Notes | Design-system pattern |
|---|---|---|---|
| `AppHeader` · `DictHeaderButton` | `screens.jsx` | Saved + Dictionary pinned right; gear on Profile; `showDuel={!isV1}` | **Header buttons** |
| `TabBar` | `screens.jsx` | 4 tabs in v1 | |
| `CardSheet` | `screens.jsx` | `brewCompleted` · `brewActive` · `guideSaved` · `onToggleGuideSave`; branches on `card.kind === 'training'` (`isGuide`) | **Collectible card** |
| `StreakScreen` · `TreeScreen` · `WeekStrip` · `FreezeMark` | `screens.jsx` | | |
| `ModuleScreen` | `library.jsx` | **Two layouts** | |
| `SavedScreen` | `library.jsx` | Title "Favorites" — ⚠️ **the app ships this as "Saved"** (`SavedScreen.title`): the prototype names this one screen twice, "Favorites" in the header and "0 OF 5 SAVED" in the counter beneath it, and *Favourites* was also the deleted card-hearting feature. Port the screen, not the second name. Three groups in fixed order — **Dictionary terms · Lessons · Visual guides** — each hidden when empty; `totalCount` sums all three. **"Study {n} terms as flashcards"** row appears whenever `terms.length > 0` (a second Flashcards entry point). `onUpgrade` → "Unlock Plus" when capped | |
| `GameIntroScreen` · `PickScreen` | `screens.jsx` | | **Pick card** / **Pick tile** |
| `OnboardingWelcome` · `OnboardingRoasty` | `screens.jsx` | The two v1 intro screens | **Intro screen skeleton** / **Tap to continue** |
| `Roasty` · `RoastyLoadingScreen` · `RoastyMoment` · `RoastyAnimScreen` · `ReplayButton` | `roasty.jsx` | `RoastyMoment` takes `autoMs` + `onDone` — the phase driver above | **Roasty, the companion** / **Loading sequence** |

---

## 7.9 What this section still does not cover

Stated so the gap isn't rediscovered:

- **Per-state visual specs.** Which token, what spacing, what the pressed state looks like — `Design System.html` owns all of it.
- **Empty states.** Documented as a design-system pattern; no inventory here of which screens have one or what each says.
- **Error and loading states** beyond the ones named above. The prototype has no network, so most do not exist yet and will be new work rather than a port.
- **Atlas and Duel components** (~2,900 lines across 7 files). v2; see [§8](09-deferred-v2.md).

---

← [Content inventory](06-content.md) · [Contents](README.md) · [Flows](08-flows.md) →
