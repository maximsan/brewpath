# Core logic and mechanics

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `brew-path/`.


This is the part most likely to be missing or wrong in an implementation. Every rule below is enforced in code.

## 5.1 Points

The currency is **points** throughout — code, copy and mascot state. "XP" no
longer appears in the source; treat it as a legacy name.

- **+10 points, flat, for a first lesson completion.** The value is per-lesson data (`MODULES[].lessons[].points`, currently 10 for all 32) with a `|| 10` fallback in `app.jsx:760` — so it is tunable per lesson without touching code.
- **Replays pay 0.** A completed lesson opens through a review-confirm sheet; review mode grants no points and skips the reward screens entirely.
- **Perfect earns no bonus.** ⚠️ Earlier versions of this reference justified this with the quote *"mastery is the reward there"*, attributed to the source. **That phrase exists in no file in the prototype** — it was inherited from an earlier draft of this document and repeated as if sourced. The rule is verified in code; the justification for it is not written down anywhere.
- **+5 points for the first completion of a Brew Challenge** (`app.jsx:605`). Replays pay 0.
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

**Graded card kinds** (`lesson.jsx:146`): `mcq`, `multi`, `match`, `slider`, `sequence`, `tastefix`, **`bagpick`**, `decision`, `recall`.
**Ungraded:** `predict`, `concept`, `practical`, `visual` (+ the unexercised `intro`, `takeaway`).

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

- Earn: **1 freeze per 7 consecutive days**, cap **2 held**.
- `freezesHeld = clamp(0..2, floor(streak / 7) - freezesSpent)` — derived, so it can never drift.
- Spent **automatically** when a day is missed. The streak survives; the day renders as covered in the week strip.
- Two deliberately-separate facts:
  - `frozenDays` — which days of *this week* a freeze covered. Presentational, clears on week rollover.
  - `freezesSpent` — lifetime count. Drives held count. **Intended to clear on Reset Progress; in the prototype it does not** — see 5.12.
  (Conflating them was a shipped bug: spent freezes silently refunded themselves weekly.)
- The **save notice** shows once on the Learn tab after a freeze covers a miss, then is dismissible. Framing is reassurance first, cost second — "someone returning after a miss is the most fragile user in the app."
- Week strip filled days **derive from the streak**, clipped to week start (fixed defect: they used to be hardcoded Mon–Fri and could lie).
- Streak is **free forever** — paid streak protection was explicitly dropped.
- `StreakScreen` + `ShareStreakSheet` (share targets) exist.

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
- ⚠️ **Training cards never appear in the Cards grid at all.** Both `CardsTab` and `ProfileTab`'s rollup filter `c.kind !== 'training'`, so the grid counts **37**, not 42. Training guides surface only inside lessons (`TrainingCard`) and on the Saved shelf under `g:` keys (`library.jsx:421`).
- A card can carry a **Brew Challenge stamp** — a permanent "I tried this for real" mark pressed onto the card once the linked challenge is logged.

## 5.7 Saved shelf / favorites

- Persisted to `localStorage['cq-favorites']` as a `Set` of prefixed keys: `l:` lesson, `t:` term, `g:` guide, `c:` collectible card.
- **Only `l:` / `t:` / `g:` count as "Saved"** and appear on the Saved screen or in the header badge. Card favourites do not.
- **Free cap: 10** (`SAVED_FREE_MAX`). Adding past the cap raises the Plus gate sheet. **Removing is always allowed**, so a capped free user can still curate.
- Plus lifts the cap. This is the paywall's primary concrete hook.
- Seed favourites: `l:m1l1`, `c:c1`, `t:arabica`, `t:bloom`, `t:crema`.

## 5.8 Brew Challenges (`brew-challenge.jsx`)

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

Two destructive actions, both behind a `ConfirmSheet`. Until now this reference
mentioned reset in five places and specified it in none — so what it actually
clears was never written down. It is written down here because checking it
turned up two defects.

### Reset Progress (`resetProgress`, `app.jsx:838`)

**Cleared:**

| State | Reset to |
|---|---|
| `progression.streak` | `0` |
| `progression.points` / `prevPoints` | `0` |
| `progression.completed` | empty Set — every lesson re-locks, every collectible re-locks, the tree returns to `SEED` |
| `progression.bestResults` | `{}` — all mastery erased |
| `brew.activeId` / `startedAt` | `null` |
| `brew.completed` | empty Set — challenge stamps vanish from cards, Path nodes empty, the Profile stat returns to `0 / 12` |
| `frozenDays` | `[]` |

Then it navigates to **Profile**, `view: 'app'`.

**Deliberately kept** (these are not progress):

- Plus / trial state, `subPlan`
- Studio choices — grove variety + light, Roasty config
- Theme preference
- The Saved shelf (`cq-favorites`)
- `cq-recent-terms`

**Not cleared, and arguably should be** — see the two defects below: `freezesSpent`, `freezeNoticeSeen`, `perfectLessons`, `giftedModules`.

**Confirm sheet copy.** Eyebrow `RESET PROGRESS`, title *"Start again from seed?"*,
body *"Your tree returns to a bare seed and every lesson locks back to the start.
There's no undo."*, confirm *"Reset everything"*. Itemised `lines` come from
`progressSummary` (`app.jsx:1077`) and list exactly four things: **Daily streak ·
Points earned · Lessons completed · Your coffee tree → Back to SEED.**

> ⚠️ **The itemised summary under-states the loss.** It never mentions brew
> challenges (all completions cleared, stamps removed), collectible cards
> (all re-lock), or mastery (`bestResults` wiped). [§6](06-content.md) describes
> these sheets as carrying "an itemised summary of what will be lost" — it is a
> partial one. Either extend the lines or soften the claim.

### ⚠️ Defect 1 — `brew.saved` is dropped, not emptied

`resetProgress` sets `brew` to `{ activeId, startedAt, completed }` with **no
`saved` key**, so `brew.saved` becomes `undefined` rather than an empty Set.
Two consequences, both live:

1. **The persistence effect (`app.jsx:520`) throws.** It runs `[...brew.saved]` on every `brew` change; the spread of `undefined` raises a TypeError. It is inside a `try/catch`, so there is no crash — but `cq-brew` is **never written**, and the pre-reset saved queue is still sitting in localStorage. **On the next launch the parked challenges come back.** A silent reset failure.
2. **`app.jsx:946` calls `brew.saved.has(ch.id)` unguarded.** After a reset, completing any lesson that has a brew challenge hits this and throws for real.

`SavedBrewList` guards it (`saved ? [...saved] : []`), which is why the Today
list looks correct and hides the problem.

**Fix:** `setBrew({ activeId: null, startedAt: null, completed: new Set(), saved: new Set() })`.

### ⚠️ Defect 2 — `freezesSpent` survives reset

5.4 states that `freezesSpent` "clears only on Reset Progress". **It does not
clear there at all** — only `deleteAccount` calls `setFreezesSpent(0)`.

This is invisible immediately (streak is `0`, so
`clamp(0..2, floor(0/7) − freezesSpent)` is `0` either way) and appears later:
once the user rebuilds a 7-day streak, held freezes are `1 − freezesSpent`. A
user who had spent two freezes before resetting **cannot earn a freeze again
until day 21**, with nothing in the UI explaining why.

The doc and the code disagreed in exactly the direction that hid it.

### Delete Account (`deleteAccount`, `app.jsx:846`)

Clears everything reset does **plus** `freezesSpent`, `freezeNoticeSeen`,
`isPlus`, `trialDaysLeft`, then lands on `onboarding-1` as a signed-out user.

**Does not touch** `brew` state at all, the Saved shelf, or Studio config.

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

**Also worth confirming against the decision:** `deleteAccount` does **not**
touch `brew` state, the Saved shelf, or Studio config. "Permanently deleted"
should mean all of it. The current implementation leaves three stores behind.

### Carried into the app

Reset and delete are the two places where every other rule in this section has to
agree at once. When implementing:

- Decide per state whether it is **progress** (clear), **preference** (keep), or **entitlement** (never touch — it is not yours to clear).
- The Saved shelf survives reset by design, which means a free user can hold 10 saved `l:` lessons that just re-locked. Confirm that opening one from Saved after a reset does something sensible.
- Both sheets are the only `danger` `ConfirmSheet` instances; they are the reference for that variant.

---

← [Information architecture](04-information-architecture.md) · [Contents](README.md) · [Content inventory](06-content.md) →
