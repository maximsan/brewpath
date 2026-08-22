# Core logic and mechanics

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `prototype/`.


This is the part most likely to be missing or wrong in an implementation. Every rule below is enforced in code.

## 5.1 Points

The currency is **points** throughout — code, copy and mascot state. "XP" no
longer appears in the source; treat it as a legacy name.

- **+10 points, flat, for a first lesson completion.** The value is per-lesson data (`MODULES[].lessons[].points`, currently 10 for all 32) with a `|| 10` fallback in `app.jsx:760` — so it is tunable per lesson without touching code.
- **Replays pay 0.** A completed lesson opens through a review-confirm sheet; review mode grants no points and skips the reward screens entirely.
- **Perfect earns no bonus.** ⚠️ Earlier versions of this reference justified this with the quote *"mastery is the reward there"*, attributed to the source. **That phrase exists in no file in the prototype** — it was inherited from an earlier draft of this document and repeated as if sourced. The rule is verified in code; the justification for it is not written down anywhere.
- **+5 points for the first completion of a Coffee Challenge** (`app.jsx:605`). Replays pay 0.
- Points are **effort/habit only**. They do not drive the tree, unlocks, or mastery.
- Mid-lesson correct answers show **no points toast** — feedback is purely qualitative (Roasty reacts). Points appear only on the result screen.

## 5.2 Mastery (separate from points)

Derived from the **best-ever** `{correct, total}` per lesson, as a **percentage** (lessons differ in length). `MASTERY_PASS = 0.8`.

| State | Condition | Label shown? |
|---|---|---|
| `needs-practice` | < 80% | Yes — "Needs Practice", amber chip. The only labelled state. |
| `mastered` | 80–99% | No label; the bean node shows fill level |
| `perfect` | 100% | No label; celebrated once, and triggers the (v2) gift |

Best-ever **never downgrades** on a worse replay. A replay *can* improve mastery even though it grants no points.

**Graded card kinds** (`lesson.jsx:165`): `mcq`, `multi`, `match`, `slider`, `sequence`, `tastefix`, `bagpick`, `decision`, `recall`.
**Ungraded:** `predict`, `concept`, `practical`, `visual` (+ the unexercised `intro`, `takeaway`).

> ⚠️ **`flavor` is in neither list, and that is the bug.** It increments the
> correct tally without being counted in the total, so mastery can exceed 100%
> and a perfect score is reachable with a wrong answer. See
> [§6](06-content.md) 6.2.

## 5.3 The Coffee Tree (`data.jsx`)

- Grows **only** from first-time completion of **core** lessons. Replays, challenges, duels and mini-games never grow it.
- `stage = clamp(1..10, round(1 + (coreDone / coreTotal) * 9))` — **10 stages over 32 core lessons.**
- ⚠️ **The denominator changed.** `CORE_LESSON_IDS = MODULES.flatMap(m => m.lessons.map(l => l.id))`, so **every lesson is now core** and `CORE_TOTAL = 32`. The old model (15 core lessons out of 30, with the rest off-path) no longer exists — there is no non-core lesson in the build. Any implementation carrying the 15 is wrong, and will advance the tree more than twice as fast as the prototype.
- Stage names: `SEED · SPROUT · SAPLING · BUDDING · FLOWERING · GREEN CHERRY · TURNING · RIPENING · NEAR HARVEST · HARVEST` (`window.STAGE_NAMES`, `flavor-wheel.jsx`).
- A weak first completion still grows the tree.
- Never shrinks except on Reset Progress.
- Art: 10 PNGs in `assets/trees/1.png`…`10.png` (`CoffeePersona`), with `AnimatedTree` cross-fading from → to stage on reward screens. The Studio's variety/light choice composes over the same art as a CSS transform + filter ([§6.7](06-content.md)).
- ✅ **Closed:** the second, 7-item stage-name list that used to live in `app.jsx` for the reset-confirmation copy is gone. `STAGE_NAMES` is now the only list.

## 5.4 Streak and streak freeze

The freeze is a **mechanic, not a setting** — there is deliberately no toggle.

> **What is and is not implemented.** The **visible** freeze surfaces now match
> the ruled §10 set — the one-off authorized edit
> ([#196](https://github.com/maximsan/brewpath/issues/196)): `FREEZE_CAP = 1`,
> the `FreezeTokens` pips deleted (the status line and the week strip's
> `FreezeMark` carry the state), a single-branch save notice, and the streak
> screen's Roasty beat playing once per session instead of on every open. The
> lifecycle has still **never executed**: `setFreezesSpent` is called only in
> reset paths, so no freeze has ever been earned or spent here. Read this block
> as "what the code contains", not "what has been observed to work".
>
> The freeze system is real code, not a
> sketch: `FREEZE_EARN_DAYS = 7`, `FREEZE_CAP = 1`, the derived held count, the
> `nextFreezeIn` countdown, the `frozenDays` / `freezesSpent` split, the
> save-notice trigger, and the week strip's streak-derived fill all execute.
>
> The **only** missing piece is the clock: nothing advances the streak, because
> the prototype's date is frozen. The source says so itself and specifies the
> real implementation — *"the earn beat can't be derived here: the prototype's
> streak is fixed, so no lesson completion crosses a 7-day boundary. Driven from
> the dev panel"*, and *"with real streak progression the check belongs on the
> **pre-earn** held count (`heldBefore < FREEZE_CAP`); the derived value stands
> in for it here."*
>
> Treat that second quote as a spec line, not a caveat — it names the exact bug
> a naive port would introduce.

- ⚠️ **Do not port the prototype's freeze *derivation*.** `docs/decisions.md` §10 ships whole — settled at [Streak freeze: §10 now rules nine behaviours](https://github.com/maximsan/brewpath/issues/58), which corrects [Streak and freeze](https://github.com/maximsan/brewpath/issues/17). The visible surfaces match it since [#196](https://github.com/maximsan/brewpath/issues/196), but the underlying math is still #17's, unported on purpose (it never executes — the clock is frozen):
  - `freezesHeld = clamp(0..1, floor(streak / 7) − spent)` re-grants from the streak total; §10 requires **no accrual while holding** and **7 fresh days after each use**.
  - `nextFreezeIn = 7 − streak % 7` counts from the streak modulo, not from the post-spend run.
  - Ruled behaviour, unchanged: spent **automatically** when a day is missed. The streak survives; the day renders as covered in the week strip.
- Two deliberately-separate facts:
  - `frozenDays` — which days of *this week* a freeze covered. Presentational, clears on week rollover.
  - `freezesSpent` — lifetime count. Drives held count. Clears on Reset Progress via the keyless registry row — see 5.12.
  (Conflating them was a shipped bug: spent freezes silently refunded themselves weekly.)
- The **save notice** shows once on the Learn tab after a freeze covers a miss, then is dismissible. Framing is reassurance first, cost second — "someone returning after a miss is the most fragile user in the app." Under cap 1 its copy has one branch — *"You'll earn another in 7 days"* (the *"N still held"* branch was dead code, deleted in #196).
- Week strip filled days **derive from the streak**, clipped to week start (fixed defect: they used to be hardcoded Mon–Fri and could lie).
- Streak is **free forever** — paid streak protection was explicitly dropped.
- `StreakScreen` + `ShareStreakSheet` (share targets) exist.
- **A qualifying day is one completed lesson *or* one completed practice activity.** ✅ **Settled by product-owner ruling** (`docs/decisions.md`, Aug 2026) and recorded at [The streak's qualifying-activity rule](https://github.com/maximsan/brewpath/issues/33). **A completed lesson replay counts**, once it reaches the final card — which is what lets a streak survive past lesson 32. Also qualifying: **two *different* standalone mini-games in the same local calendar day** (one run is not enough, and the same game twice counts once — the anti-farm rule from [Mini-games](https://github.com/maximsan/brewpath/issues/22), upheld at [Mini-game streak unit](https://github.com/maximsan/brewpath/issues/59)), the Vocab game, Flashcards after reviewing every card in the selected set, and the Keep Sharp recommendation — which inherits its underlying activity's completion rule rather than defining one. **Not qualifying:** Coffee Challenges (their completion can be passed by skipping or picking arbitrarily), Term of the Day, reading dictionary entries, browsing Saved or Coffee Cards, Roasty/Tree customization, and anything started but not finished. The streak advances **at most once per local calendar day** — the first qualifying completion protects it and further activity that day adds nothing. No minimum score, and subscription status never decides whether a completed accessible activity qualifies. ⚠️ The Help FAQ string still says *"finish at least one lesson a day"* and now understates the rule — see 6.8.
- **Dev-panel simulation:** two toggles stand in for the states the frozen clock can't produce — *Freeze covered Thursday* and *Freeze earned this lesson*.

## 5.5 Progression gating (`data.jsx`)

`syncModuleProgress(completedSet)` recomputes on every render:
- Finished lesson → `complete`; first unfinished in an unlocked module → `current`; rest → `locked`.
- A module unlocks when the **previous module is fully complete AND its own first lesson is authored** in `LESSONS`. Unauthored future modules stay locked.
- This rule covers modules that **have a `MODULES` entry**. The four future modules users are shown below the path have no entry at all — they come from `ComingSoonPath` ([§4](04-information-architecture.md)), a separate hardcoded teaser. Do not conflate the two.
- Module 1 is authored open.
- Resetting progress re-locks everything correctly.
- `syncMastery(bestResults)` runs alongside it, stamping each lesson with its mastery state so Path / Learn / module cards can show it.

## 5.6 Collectible cards (`data.jsx`)

`syncCollection(completedSet)`:
- A **lesson card** unlocks when its lesson completes.
- A **module Field Guide card** unlocks when every lesson in the module is done.
- **Training cards** have no `unlock` and are earned from the start.
- ⚠️ **Only the *first* locked card is rendered in the Cards grid.** `CardsTab` (`screens.jsx:1471`) draws every earned card, then the single card at `firstLockedIdx` as a teaser, and `return null`s the rest. The grid is not "earned cards plus silhouettes" — it is earned cards plus exactly one. A "{n} more to collect" footer stands in for the remainder.
- **Training guides are a separate registry now.** They were moved out of `COLLECTION` into `TRAINING_CARDS`, so the collectible count *is* 37 — the old filter-at-render workaround is gone. Guides surface inside lessons (`TrainingCard`) and on the Saved shelf under `g:` keys.
- **Card copy is not stored on the collectible.** `syncCardText()` copies title/summary/fact/meta from the lesson's own `reward` (or `MODULE_REWARDS`) at load; `syncTrainingText()` does the same for guides. One card, one text — see [§6](06-content.md) 6.3.
- A card can carry a **Coffee Challenge stamp** — a permanent "I tried this for real" mark pressed onto the card once the linked challenge is logged.

## 5.7 Saved shelf / favorites

- Persisted to `localStorage['cq-favorites']` as a `Set` of prefixed keys: `l:` lesson, `t:` term, `g:` guide, `c:` collectible card.
- **Only `l:` / `t:` / `g:` count as "Saved"** and appear on the Saved screen or in the header badge. Card favourites do not.
- **Free cap: 5** (`SAVED_FREE_MAX`). Adding past the cap raises the Plus gate sheet. **Removing is always allowed**, so a capped free user can still curate.
- BrewPath Plus lifts the cap. This is the paywall's primary concrete hook.
- Seed favourites: `l:m1l1`, `c:c1`, `t:arabica`, `t:bloom`, `t:crema`.

## 5.8 Coffee Challenges (`brew-challenge.jsx`)

Small, optional **real-life** tasks. They never block learning, streaks, points, cards or progress.

- **12 challenges**: one capstone per module (5) + lesson challenges on the most hands-on lessons (7). *(§5.8 previously said 9 while [§6.6](06-content.md) listed 12 — the list was right.)*
- Shape: `{ id, type: 'module'|'lesson', moduleId, lessonId?, cardId, title, instruction, effort, reactions[3] }`.
- State: one `activeId` + `startedAt`, a `completed` Set, a `saved` (parked-for-later) Set. Persisted to `localStorage['cq-brew']`.
- **48-hour active window** (`BREW_WINDOW_MS = 48 * 60 * 60 * 1000`). Past it, the challenge silently drops off Today — no penalty, no archive.
- Starting a different challenge parks the previous uncompleted one back into `saved` rather than dropping it.
- A challenge can only be saved once its source lesson/module is actually reached (`brewReached`).
- **Log Result sheet**: pick one of three reactions → completes. First completion pays **+5 pts** and presses a permanent stamp onto the linked collectible card and fills its Path node. Replays are unlimited and pay nothing.
- A completed challenge only returns to Today if the user explicitly replays it from the recap sheet.
- Surfaces: Today card, saved list, lesson-complete suggestion, full Module Challenge screen, Path node, card stamp section, Profile stat.

## 5.9 Plus, gating and trials (`gating.jsx`)

> ⚠️ **This whole section describes a superseded model.** The prototype gates
> **features**; the shipping model gates **content** — the first three lessons
> ([ADR-0007](../adr/0007-free-tier-is-the-first-three-lessons.md)) are free
> permanently, the other twenty-nine are paid, with a cap of two learning/practice
> activities a day ([PRODUCT.md](PRODUCT.md) §11, `docs/decisions.md` §7–§8,
> §11–§12). An intermediate *pacing* ruling (2 new lessons/day) was also proposed
> and **withdrawn**; do not build to it either. Everything below is an accurate
> account of `gating.jsx` and a **poor guide to what to build**: lesson gating
> exists in neither codebase, so there is nothing to port.
>
> Settled on [Monetization shape](https://github.com/maximsan/brewpath/issues/29)
> and [Free-tier practice content](https://github.com/maximsan/brewpath/issues/57).

**Gated feature catalog** (`PLUS_FEATURES`): `dictionary`, `atlas`, `duel`, `saved`, `studio`.

**In v1, `featureUnlocked()` hardcodes `dictionary` and `saved` to always-open** (`app.jsx:388`), and Saved is a free tier with a soft cap (now **5**, not 10). So **Studio is the only surviving _feature_ gate** — but it is no longer the only gate: **lessons** are now gated by tier, which is the first content gate either codebase has had, and the dictionary is tiered by *depth* rather than by term (free gets the short explanation; Plus adds the full one, and the 8 reference terms are Plus-only).

- Single funnel: `requestFeature(key)` → open it, or raise `PlusGateSheet`.
- `FeatureLock` full-screen teaser, 3 styles: `blur` (default), `hard`, `curtain`.
- **Trials** (v2): `tempUnlocks` maps feature → expiry ms. `RewardedAdScreen` grants 15 min; the perfect-module `RoastyGiftScreen` grants 24 h. A live `TrialBadge` counts down. A 1s interval tick re-renders countdowns.
- Trial state is separate from Plus: `TRIAL_DAYS = 7`; `trialDaysLeft > 0` means the StoreKit trial is running. Access is identical (`isPlus`); only billing language changes.

**Pricing:** ⚠️ **Superseded shipped copy — do not port.** [Offers, plans and the paywall pitch #55](https://github.com/maximsan/brewpath/issues/55) ruled **no trial and no subscriptions**: v1 sells a single one-time purchase ([ADR-0003](../adr/0003-one-time-purchase-no-trial.md)), and the owner is reworking the prototype paywall now. What `gating.jsx` ships: Yearly **$29.99/yr** (`$2.50/mo`, "SAVE 50%", default selection) · Monthly **$4.99/mo** · CTA "Start 7-day free trial", subtitle "Free for 7 days, then … · cancel anytime" · the same two plans duplicated as `PLAN_OPTS` in `settings.jsx:384`. Only the **Restore purchases / Terms / Privacy** links survive (store-review requirement).

**Plus benefits as sold on the paywall:**
1. Unlimited Saved — keep every lesson, term and guide past the free shelf of 10 ⚠️ *(shipped copy still says 10 — `prototype/customize.jsx:134`, `settings.jsx:631` — while the constant and the ruling say **5**; the copy fix is owed on port)*
2. Dress up Roasty — hats, glasses, scarves, roast level
3. Choose your plant — species + light ([§6.7](06-content.md))
4. *(v2)* Mood player

## 5.10 Persistence (localStorage keys)

| Key | Contents |
|---|---|
| `cq-theme` | `light` / `dark` / `system` |
| `cq-favorites` | array of favourite keys |
| `cq-custom` | `{ plus, trialDaysLeft, subPlan, variety, light, roasty }` |
| `cq-temp` | `{ featureKey: expiryMs }` temporary unlocks |
| `cq-brew` | `{ activeId, startedAt, completed[], saved[] }` |
| `cq-recent-terms` | recently opened dictionary terms. ⚠️ **Written and persisted, then consumed by nothing** — passed to `DictionaryHome` as `recent` and never read; no recent-strip component exists. Build the UI or drop the key |
| `cq-atlas` | `{ states, favs, tastedFrom }` (v2) |
| `cq-duel-progress` | in-flight duel run (v2) |

> **`cq-custom` changed shape.** The single `tree` skin id became two axes,
> `variety` + `light`. `window.migrateGrove(saved)` handles the upgrade: legacy
> `heirloom|blossom|verdant` → `daylight`, `goldenhour`/`moonlit` keep their
> light, and an earlier draft's cultivar ids (`typica`, `bourbon`, `geisha`)
> collapse into `arabica`. **A real app needs the same migration** for anyone
> who saved under the old shape.

**Not persisted** (prototype-only, in-memory): `progression` (streak, points, completed, bestResults), `frozenDays`, `freezesSpent`, `perfectLessons`, `giftedModules`. **These are the state a real app must persist and sync.**

## 5.11 Frozen prototype values to replace

- "Today" is hardcoded **Friday 8 May 2026** (`screens.jsx:715` and `:761`).
- The dictionary uses a **different** frozen date — **18 June 2026** (`dictionary-data.jsx:530`, `dictionary-extras.jsx:15`) — which drives term-of-day. Two frozen "todays" in one build.
- Trial charge date derives from the May 8 date (`app.jsx:1099`).
- Starting streak is **7 days**, starting points **10**, `m1l1` pre-completed with a 2/3 result.
- Account email `maya@hey.com`, profile name "Taster" (`USER.name`, which the Profile header interpolates), "Joined May 2026".
- App version string `BrewPath · v0.1 · A field guide` (`screens.jsx:567`).

## 5.12 Reset Progress and Delete Account

Two destructive actions, both behind a `ConfirmSheet`, and both driven by the
`ACCOUNT_STORES` registry (`app.jsx:958`) rather than by hand. Every store is
listed there once, with a scope and a reset callback:

- **`progress`** — cleared by *Reset progress **and** Delete account*
- **`account`** — cleared by *Delete account only* (a purchase or a preference)

`cq-theme` is deliberately absent from the table and survives both wipes:
appearance is a device preference, not account data.

> ⚠️ **This section was written against the hand-written wipes that preceded the
> registry.** The registry sweep (`wipeStores`, `app.jsx:980`) has since fixed
> both defects recorded below *and* closed the deletion gap. Corrections are
> marked inline; the audit is kept because it is what motivated the registry.

### Reset Progress (`resetProgress`, `app.jsx:1008`)

`wipeProgress()` sweeps every `progress`-scoped store.

**Cleared:**

| State | Reset to |
|---|---|
| `progression.streak` | `0` |
| `progression.points` / `prevPoints` | `0` |
| `progression.completed` | empty Set — every lesson re-locks, every collectible re-locks, the tree returns to `SEED` |
| `progression.bestResults` | `{}` — all mastery erased |
| `brew` | `EMPTY_BREW()` — `activeId`, `startedAt`, `completed` **and `saved`** |
| `frozenDays` / `freezesSpent` / `freezeNoticeSeen` | `[]` / `0` / `false` (the keyless registry row) |
| `cq-favorites` | empty Set — **the Saved shelf goes with the progress it recorded** |
| `cq-recent-terms` | `[]` |
| `cq-atlas`, `cq-duel-progress` | v2 stores, swept by the same rule |

Then it navigates to **Profile**, `view: 'app'`.

**Deliberately kept** (these are not progress):

- Plus / trial state, `subPlan`
- Studio choices — grove variety + light, Roasty config
- Theme preference

> ⚠️ **Correction.** This list previously also carried *the Saved shelf
> (`cq-favorites`)* and *`cq-recent-terms`*. Both are wrong: the registry scopes
> them `progress`, so both are cleared. The registry's own comment carries the
> reasoning — *"a favorited lesson that has re-locked … is a record of work that
> was just undone"* — and the confirm button says **"Reset everything"**, which a
> surviving bookmark list breaks. Ratified by
> [#14](https://github.com/maximsan/brewpath/issues/14); `PRODUCT.md` carried the
> same error and is corrected too.

**Still not cleared:** `perfectLessons` and `giftedModules`. Both are in-memory
only — no key, so the dev guard cannot see them — and both feed the Roasty module
gift, which is `!isV1`-gated, so the leak is within-session and v2-only. They
belong in the keyless registry row alongside the freeze state.

**Confirm sheet copy.** Eyebrow `RESET PROGRESS`, title *"Start again from seed?"*,
body *"Your tree returns to a bare seed and every lesson locks back to the start.
There's no undo."*, confirm *"Reset everything"*. Itemised `lines` come from
`progressSummary` (`app.jsx:1077`) and list exactly four things: **Daily streak ·
Points earned · Lessons completed · Your coffee tree → Back to SEED.**

> ⚠️ **The itemised summary under-states the loss.** It never mentions brew
> challenges (all completions cleared, stamps removed), collectible cards
> (all re-lock), mastery (`bestResults` wiped), or — since the correction above —
> the Saved shelf. [§6](06-content.md) describes these sheets as carrying "an
> itemised summary of what will be lost"; it is a partial one. Either extend the
> lines or soften the claim. The fix direction is *say more*, not *clear less*.

### ✅ Defect 1 — `brew.saved` was dropped, not emptied — **FIXED**

`resetProgress` used to set `brew` to `{ activeId, startedAt, completed }` with
**no `saved` key**, so `brew.saved` became `undefined` rather than an empty Set.
Two consequences, both live at the time:

1. **The persistence effect threw.** It runs `[...brew.saved]` on every `brew` change; the spread of `undefined` raises a TypeError. Inside a `try/catch`, so no crash — but `cq-brew` was **never written**, and the pre-reset saved queue stayed in localStorage. **On the next launch the parked challenges came back.** A silent reset failure.
2. **`brew.saved.has(ch.id)` was called unguarded.** After a reset, completing any lesson with a coffee challenge threw for real.

`SavedBrewList` guards it (`saved ? [...saved] : []`), which is why the Today
list looked correct and hid the problem.

**Fixed by the registry:** `cq-brew` resets via `EMPTY_BREW()` (`app.jsx:241`),
which carries `saved: new Set()`. Reset can no longer construct a partial `brew`.

### ✅ Defect 2 — `freezesSpent` survived reset — **FIXED**

5.4 states that `freezesSpent` "clears only on Reset Progress". It did not clear
there at all — only `deleteAccount` called `setFreezesSpent(0)`.

Invisible immediately (streak is `0`, so `clamp(0..2, floor(0/7) − freezesSpent)`
is `0` either way) and surfacing later: once the user rebuilt a 7-day streak, held
freezes were `1 − freezesSpent`, so a user who had spent two freezes before
resetting **could not earn one again until day 21**, with nothing explaining why.

> **Historical arithmetic — cap 2.** This worked example predates the cap moving
> to **1**, where holding two spent freezes is unreachable. It is left as written
> because it documents a *fixed* defect and its reasoning; the shipping rules are
> in 5.4.

**Fixed by the registry:** the keyless `progress` row clears `frozenDays`,
`freezesSpent` and `freezeNoticeSeen` together, so the doc and the code now agree.

⚠️ **The Flutter side removes the whole class.**
[#17](https://github.com/maximsan/brewpath/issues/17) makes `freezesSpent`
*derived* from the active-day set, which reset clears — so it cannot survive a
wipe by construction rather than by remembering to clear it.

### Delete Account (`deleteAccount`, `app.jsx:1016`)

`wipeStores(['progress', 'account'])` — every store in the registry, both scopes —
then lands on `onboarding-1` as a signed-out user.

> ⚠️ **Correction.** This previously read *"Does not touch `brew` state at all,
> the Saved shelf, or Studio config."* That was true of the hand-written wipe and
> is false of the registry: `cq-brew` and `cq-favorites` are `progress`-scoped and
> `cq-custom` (Plus, trial, grove, Roasty) is `account`-scoped, so the two-scope
> sweep clears all three. "Permanently deleted" now means all of it.

#### ✅ DECIDED (Aug 2026): deletion is permanent — no recovery period

**The flow to build:**

1. User confirms account deletion.
2. Account and associated data are **permanently deleted**.
3. **No 30-day recovery period.**
4. The confirm sheet must **clearly warn that deletion cannot be undone**.

This closes the open item that flagged the 30-day promise as unimplemented. It
was resolved by **removing the promise**, not by building the window — which
also means the prototype's immediate wipe is now the *correct* behaviour rather
than an unfinished one.

> ⚠️ **The prototype's copy is now wrong and must be rewritten.** It currently
> reads: *"This permanently erases your account and everything in it after 30
> days. Sign back in before then and it's all restored."* Under the decision
> above, the second sentence is a false promise and the "after 30 days" delay is
> incorrect. Eyebrow `DELETE ACCOUNT`, title *"Delete your account?"*, confirm
> *"Delete my account"* and cancel *"Keep my account"* all stand; **only the body
> changes**, to state immediacy and irreversibility plainly.
>
> Treat the existing string as a **decoy**: it looks finished, and porting it
> verbatim would ship a recovery promise the product does not honour.

#### ✅ DECIDED (Aug 2026): the subscription survives, the account does not

A paid subscription lives with the **Apple Account, not the app account**, so it
is unaffected by deletion. The resolution:

> If the user creates a new account and restores purchases using the **same Apple
> Account** that bought the subscription, **the active subscription is applied to
> the new account. Previously deleted account data and progress are not
> restored.**

**The two axes are independent, and the copy has to make that legible:**

| | Deleted account | New account after restore |
|---|---|---|
| Progress — lessons, streak, mastery, tree, collectibles, challenges | **Gone permanently** | Starts from zero |
| Saved shelf, Studio config | **Gone permanently** | Defaults |
| Plus entitlement | Unaffected — still billing | **Re-applied via Restore Purchases** |

So a user is never stranded paying for nothing: the entitlement follows the Apple
Account and can always be recovered onto a fresh app account. What they cannot
recover is everything they learned.

**Implementation consequences:**

- **Entitlement must be read from StoreKit, never from local state.** `isPlus` is currently a local boolean cleared on delete; after deletion + reinstall it would be `false` while the user is still a paying subscriber. The source of truth is the receipt.
- **Restore Purchases is now load-bearing on the new-account path**, not just the "I changed device" path. Its three outcomes ([§7](07-components.md) 7.3) all apply here — including `none`, which is exactly what a user with a *different* Apple Account will hit, and whose copy already says the right thing.
- **Consider checking entitlement automatically at account creation** rather than relying on the user to find Restore Purchases. Nothing in the decision requires it, but a subscriber who does not think to tap Restore sees a paywall for something they are already paying for.

#### ✅ DECIDED (Aug 2026): the delete sheet warns, it does not gate

**Deleting with an active subscription does not require cancelling first.** The
sheet keeps **exactly two actions** — no third "cancel subscription" path, no
blocking state. The warning carries the responsibility instead.

**Approved copy:**

> Your account and all associated data will be permanently deleted. This action
> cannot be undone.
>
> Your App Store subscription will remain active and must be cancelled separately
> in your Apple subscription settings.

This supersedes the prototype's *"…after 30 days. Sign back in before then and
it's all restored."* entirely.

**Why gating was rejected:** forcing cancellation first turns a two-tap
destructive action into a multi-app errand, and a user who wants their data gone
should not be held hostage to a billing flow. The trade is that the warning has
to be unmissable — which is why it sits in the body rather than a footnote.

**Three implementation notes:**

1. ⚠️ **`ConfirmSheet` cannot render this today.** `body` is a single `<p>{body}</p>` (`settings.jsx:52`). The approved copy is **two paragraphs**, and the second must not be run together with the first — it is a different subject. The component needs `body` to accept an array or nodes before this copy can ship.
2. **The `lines` slot stays empty for delete.** Reset uses `lines` for its itemised loss summary; this copy covers the same ground in prose ("all associated data"), so delete does not need them. Do not add an itemised list here — it would compete with the subscription warning for attention.
3. **Paragraph two is presumably conditional on an active subscription.** The decision is scoped to "account deletion *with an active subscription*", and telling a free user their subscription will remain active would be nonsense. Assumed conditional on entitlement; **confirm before building.**

> ⚠️ **Button labels are unresolved.** The decision names the two actions as
> **Cancel** and **Delete account**; the prototype uses **"Keep my account"** and
> **"Delete my account"**. The two-action *constraint* is settled — the *labels*
> may or may not be. Left as-is pending confirmation, since "keep only the
> existing actions" reads as a constraint on how many, not a rename.

✅ **Resolved against the decision.** This previously flagged that `deleteAccount`
left `brew` state, the Saved shelf and Studio config behind, so "permanently
deleted" was not true of all of it. The `ACCOUNT_STORES` sweep over both scopes
now clears all three.

### Carried into the app

Reset and delete are the two places where every other rule in this section has to
agree at once. When implementing:

- Decide per state whether it is **progress** (clear), **preference** (keep), or **entitlement** (never touch — it is not yours to clear). Register it once; do not hand-list stores at the call site. The registry is what let three stores go unwiped.
- **Port the dev guard, as a test.** `app.jsx:983` warns when a `cq-` key is written but not registered — it is the check that makes the registry worth having. In Flutter it becomes a test that fails the build when a snapshot field escapes both clear-sets.
- **Name the two sets by what clears them.** `scope: 'account'` means *"cleared by Delete account **only**"* — it survives reset and dies with delete, and it reads as the exact opposite. [#14](https://github.com/maximsan/brewpath/issues/14) ports them as `clearedByReset` / `clearedByDeleteOnly`.
- Both sheets are the only `danger` `ConfirmSheet` instances; they are the reference for that variant.

---

← [Information architecture](04-information-architecture.md) · [Contents](README.md) · [Content inventory](06-content.md) →
