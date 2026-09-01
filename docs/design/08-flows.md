# Flows

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `prototype/`.


## 7.1 First run (v1)
`loading` (Roasty splash, auto-advances) → `welcome` → `meet` (Meet Roasty) → **straight to Today**.
The 4–7 question personalization flow exists in full (`onboarding.jsx`) but `isV1` skips it. When re-enabled it locks to the **Standard** 4-question depth: goal → brewer → commitment → experience. Two flow *directions* are built and tweakable: `guided` (Roasty speaks on every question) and `fieldguide` (quiet, editorial; Roasty only bookends).

## 7.2 The daily loop
Open → Today shows the current lesson → Begin lesson → play 6–11 cards → **+10 pts** → streak ticks → tree may advance a stage → collectible card unlocks → optional Coffee Challenge offered → next lesson or back to Path.

## 7.3 Lesson → reward routing (`app.jsx`)
1. Record best-ever result (never downgrade). Runs for replays too.
2. If review mode → return to origin, no points, no reward screen. **Stop.**
3. If perfect → remember for the (v2) perfect-module gift.
4. Award the lesson's `points` (10), mark complete.
5. If last lesson in module → `module-complete` — the lesson recap does **not** play; the module screen replaces it — → *Turn it over* flips the screen to the collectible → Continue → module Coffee Challenge offer (`module-challenge`, if any; *Not now* saves it) → *(v2: perfect-module gift)* → next module's first lesson **if authored**, else Path.
   ⚠️ **Dropped from this step: `module-card`.** Earlier revisions chained it after `module-complete`. It is unreachable in the running prototype — `continueFromModuleComplete` (`app.jsx:984`) is the only navigation to it and nothing calls it — and the collectible is the back of the flip instead. See [#230](https://github.com/maximsan/brewpath/issues/230) and ADR-0012.
6. Otherwise → `lesson-complete` → Continue → next lesson **if authored**, else Path.

### Every reward screen is two phases, not one

`LessonCompleteScreen` and `ModuleCompleteScreen` both
open on `phase: 'roasty'` — a full-screen `RoastyMoment` — and switch to
`phase: 'content'` only when it fires `onDone`. Route names like
`lesson-complete` land you on **phase two**; the celebration is a distinct state
in front of it.

| Screen | Roasty state | Eyebrow | Auto-advance |
|---|---|---|---|
| Lesson complete | `lesson` | `LESSON COMPLETE` | default |
| Module complete | `module` | `MODULE COMPLETE` — "Look how far you've come." | `autoMs={2200}` |

`ModuleRewardCardScreen` (`card` · `REWARD UNLOCKED`) also exists in `rewards.jsx` and is two-phase, but **no flow reaches it** — it is served only by the `?screen=module-card` review harness, and its content duplicates the flip's back face. Do not count it as a reward beat.

**Phase two of `lesson-complete` shows:** score, mastery state, animated tree
from→to stage, points payout, streak-freeze-earned row (suppressed at the cap),
the collectible-card link, coffee-challenge suggestion, Practice again, Continue.

**And three interactions the old linear description omitted:**

- **Card preview** — tapping the earned collectible opens a full-screen overlay (`setPreview(true)`); tapping the scrim dismisses it, while taps on the card itself `stopPropagation`.
- **Duel link** (`onDuel`) — a third Duel entry point alongside the Profile and Learn cards. All three are `showDuel` / `!isV1` gated.
- **Challenge suggestion** — `onStart` / `onNotNow`, with the `realState` guard described in [§7](07-components.md) 7.4.

`ModuleCompleteScreen` adds a **card flip** (`flipTo`) on the reward card.

### The course-exhausted state

When no lesson has `status: 'current'` — every unlocked lesson done — Today
swaps its `CONTINUE LEARNING` eyebrow for **`ALL CAUGHT UP`** and the line
*"You've finished every lesson available."* It does not offer a replay in that
slot.

This is reached after **32 lessons**, so roughly five weeks at one a day, and it
is where the daily loop stops having a next step. See [PRODUCT.md](PRODUCT.md)
§15.

## 7.4 Replay / review
Tapping a completed lesson raises a `ConfirmSheet` stating explicitly: *Points and streak → No change*, length, last completed. Confirm → review mode.

## 7.5 Coffee Challenge lifecycle
Offered at lesson/module complete → Start (active, 48h) **or** Save for later → sits on Today → Log Result (pick a reaction) → **+5 pts first time** → stamp pressed onto the collectible card, Path node fills → recap sheet available afterwards → optional unlimited replay.

## 7.6 Dictionary
Reachable from the header on any tab, from Today's Term-of-Day, and from a term link inside a lesson (peek sheet, non-interrupting). Term detail cross-links to related terms and back into the source lesson — or, for the 8 reference-only terms, says plainly that no lesson covers it. Free and ungated in v1.

## 7.7 Paywall
Trigger points: Saved cap reached (peak intent), Studio card on Profile, Settings → Subscription. → `paywall` → select plan → `plus-welcome` → `studio`.

## 7.8 Navigating the Path

Not a flow so much as a behaviour that changes what the Path looks like over
time, and which had no entry anywhere before this pass.

**A module collapses the moment its last lesson is completed, and defaults to
collapsed.** `canCollapse = allDone && !mod.locked`. In-progress and locked
modules cannot be collapsed at all — their headers are `disabled`. So the Path
self-prunes: finished work folds to a header, the current module stays open, and
locked modules sit below it.

Expanded state lives in `window.__pathExpandedMods` — a global, not persisted.
It survives tab switches within a session and resets on reload. See
[§7](07-components.md) 7.8.

## 7.9 Entry points that appear more than once

Worth listing because each has to be re-lit independently:

| Destination | Reached from |
|---|---|
| **Dictionary** | `AppHeader` on every tab · Learn's Term-of-Day · a term link inside a lesson (peek sheet) |
| **Saved** | `AppHeader` on every tab · the Profile card |
| **Duel** *(v2)* | Profile card · Learn card · the lesson-complete screen |
| **Studio / paywall** | Profile Studio card · Settings → Subscription · the Saved cap gate |
| **Privacy / Terms** | About screen · the paywall — both must resolve to the same URLs ([§7](07-components.md) 7.3) |
| **Path practice** | Profile's mastery rollup (`onPractice`) · Learn's "Practice again" rows |

---

← [Component & state inventory](07-components.md) · [Contents](README.md) · [Deferred features — v2 detail](09-deferred-v2.md) →
