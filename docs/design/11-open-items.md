# Known open items

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `brew-path/`.


## Verified Aug 2026 (`QA Findings.html`)

`QA Findings.html` was rewritten as **"the state of the build, not its history"**
— it now reports what holds rather than what was fixed. Its header reads
*"Nothing is broken in the build"* and it agrees with this reference on 103
routes (the 104th, `card-flavor`, arrived after).

| Check | Result it reports |
|---|---|
| Dictionary lesson links resolve to a lesson that teaches the term | 72 terms, 64 pointers, `dictLessonAudit()` returns `[]` — verified. The audit scans **learner-visible copy only** (`lessonVisibleText()`), not the raw record |
| Every lesson has a collectible card; every card unlocks from a real lesson | 32 / 32, no orphans either direction |
| Every card `kind` has bespoke art and a tint | 37 collectibles, 37 distinct kinds, one per card, all covered |
| **A card's words match wherever it appears** | 42 card entries, one source each — `syncCardText()` for the 37 collectibles, `syncTrainingText()` for the 5 guides |
| **No two collectible cards share a name** | Distinct across both registries; the invariant no longer depends on which lists render together |
| Path order matches defined lessons | 32 entries, 32 definitions, no drift |
| Coffee challenges | 7 of 32 lessons, by design |

## Still open — accepted or v2-only
| Item | Where | Disposition |
|---|---|---|
| Tap targets under 44px | `customize.jsx:464` (28px backdrop swatches), `gating.jsx:182` (30px ad close) | Both behind `isV1` — fix when those surfaces return |
| Rewarded ad hardcodes the dark accent `#E07A4F` | `gating.jsx:176` | Wrong orange in cupping. v2 surface |
| Atlas smallcaps carry a lowercase "and" | `atlas.jsx:191,199,231` | v2 surface |
| `--accent` at 4.23:1 in cupping | token | Held — passes on `--surface` where most of it lives; moving the brand colour costs more than it buys |
| `--berry` at 3.86:1 in dark roast | token | Held — reads as the cross mark, not as text |
| Hairlines below 3:1 in both moods | `--rule` | Decoration, not a violation, but worth one look on a real phone at low brightness |

## Closed since the last pass
- ✅ **`flavor` cards are graded.** They briefly incremented the score without being counted in the total, so mastery could exceed 100% and a perfect score was reachable with a wrong answer. `flavor` is now in the graded list; the total is 144.
- ✅ **The `terroir` audit failure is fixed — and the check was tightened, not relaxed.** Two changes: the word now appears in *What origin means* ("Coffee borrowed wine's word for why that matters: terroir — soil, altitude and climate leaving a signature no other place can copy"), **and** `dictLessonAudit()` stopped scanning `JSON.stringify(lesson)` in favour of a new `lessonVisibleText()` that reads only fields a learner actually sees. The reasoning, from the source: *"a data field no card renders would otherwise pass a check whose whole point is that the word appears on screen."* The audit is now strictly harder to satisfy than when it was passing vacuously.
- ✅ **The three duplicate collectible titles are resolved** — Extraction, Fermentation and The Cherry in Section. Fixed structurally: training guides moved out of `COLLECTION` into their own `TRAINING_CARDS` array, because sharing one array *"made a plain 'no two cards share a title' check report false collisions."* QA now carries the check as a standing invariant.
- ✅ **Card copy can no longer drift between the reward screen and the collection sheet** — `syncCardText()` / `syncTrainingText()` copy the words from one authored source at load. See [§6](06-content.md) 6.3.
- ✅ **The competing route counts are gone.** Every document now says **104**, the count of `SCREEN_ROUTES` keys as re-derived by `tools/extract-facts.js`. QA had lagged at 103 — it was written before `card-flavor` — and has been corrected; 96 and 97 are older still. The count is derived rather than authored, so it cannot drift again without the extractor drifting.
- ✅ **The QA pacing note was stale ("116 cards across 15 lessons") and has been rewritten** along with the rest of that document.
- ✅ **What makes a good question is now written down** — `brew-path/CLAUDE.md`, seven content rules. See [§6](06-content.md) 6.9. *(Whether the cards meet them is still an open human pass.)*
- ✅ **All 23 outstanding card-art designs are drawn.** `scales`, `hourglass`, `burrs` have components; `variety`, `caffeine`, `distribution` have both guide art and thumbnails.
- ✅ **The `draft: true` writing pass is complete** — 15 lessons cleared, 0 remain.
- ✅ **The duplicate 7-item tree stage-name list is gone** from `app.jsx`; `STAGE_NAMES` is the only list.

## Opened or still open
| Item | Where | Disposition |
|---|---|---|
| `intro` and `takeaway` have **zero authored cards** across all 257 | `lesson.jsx` | `active-cards.jsx` documents them as superseded by `predict` / `recall`. **Decide: delete the renderers, or author cards.** Leaving them is the status quo by default, not by choice |
| **Two frozen "today" dates** — 8 May 2026 for the app, 18 Jun 2026 for the dictionary | `screens.jsx`, `dictionary-data.jsx`, `dictionary-extras.jsx` | Harmless in a prototype; a real clock must not inherit the split |
| **Price list duplicated** across the paywall and the change-plan sheet | `customize.jsx:184`, `settings.jsx:384` | Two places to edit one price. Unify on the way in |
| **Whether a replay ticks the streak is unspecified** | Help FAQ vs [§5](05-mechanics.md) 5.1 | The FAQ says "finish at least one lesson a day". Replays pay no points and no tree growth — but nothing says whether they count as the day's lesson. Irrelevant during the course, decisive after it: past lesson 32 there are no new lessons, so this rule alone determines whether a streak can continue. See [PRODUCT.md](PRODUCT.md) §15 |
| **Streak advancement is unwired, by design** | `app.jsx:554–579` | Not a defect — the freeze system is fully implemented and the missing clock is documented in-source, including the correct real-world form (`heldBefore < FREEZE_CAP` rather than the derived value). Listed so a porter knows to wire the day rollover and use the pre-earn count |
| **`cq-recent-terms` is persisted but consumed by nothing** | `app.jsx:336–340`, `dictionary.jsx:316` | The key is written on every term open and passed in as `recent`; `DictionaryHome` never reads it and no recent-strip component exists. Build the strip or stop writing the key |
| **Path expanded/collapsed state lives in a `window` global** — `window.__pathExpandedMods` | `screens.jsx:1280` | Mirrored out of React state; not persisted, lost on reload. Decide deliberately whether a collapsed module stays collapsed across launches |
| **Three components accept props they never use** — `ProfileTab` (`theme`, `onTheme`), `LearnTab` (`onStreak`, `onOpenModule`, `onOpenSaved`, `onOpenDictionary`, `onOpenTermOfDay`, `brewPathMode`) | `screens.jsx` | 8 dead props. Harmless in the prototype, misleading when porting — they imply entry points that do not exist on those screens |
| **Duel has three entry points, not one** — Profile card, Learn card, lesson-complete link | `screens.jsx`, `rewards.jsx` | All `showDuel` / `!isV1`. v2 work has to re-light all three; the tab is not the only surface |
| **All 8 About / Help rows are dead stubs** — Privacy policy · Terms of use · Acknowledgements · Open-source licenses · Rate BrewPath · Say hello · Email support · Report a problem | `settings.jsx:279`, `settings.jsx:650` | Every one is `onClick={() => {}}` behind a finished-looking row with an external-link affordance. **Privacy and Terms are store-review requirements.** 8 destinations to build; none was in the checklist before this pass |
| **Privacy + Terms exist in two places** — About and the paywall | `settings.jsx:279`, `customize.jsx` | Must resolve to the same URLs. Only the paywall pair was documented |
| **`brew.saved` is dropped on Reset Progress, not emptied** — becomes `undefined` | `app.jsx:958` | ✅ **Fixed by the `ACCOUNT_STORES` registry.** `cq-brew` resets via `EMPTY_BREW()` (`app.jsx:241`), which carries `saved: new Set()`, so a partial `brew` can no longer be constructed. Was: the persist effect threw on `[...undefined]`, swallowed by its `try/catch`, `cq-brew` never rewritten — parked challenges returned on next launch. See [§5](05-mechanics.md) 5.12 |
| **`freezesSpent` is not cleared by Reset Progress** although the streak rules say it is | `app.jsx:958` | ✅ **Fixed by the registry** — the keyless `progress` row clears `frozenDays`, `freezesSpent` and `freezeNoticeSeen` together. [#17](https://github.com/maximsan/brewpath/issues/17) removes the class on the Flutter side by deriving `freezesSpent` from the active-day set. See [§5](05-mechanics.md) 5.12 |
| **The reset confirm sheet's itemised loss list is incomplete** — 4 lines, omits coffee challenges, collectibles, mastery and the Saved shelf | `app.jsx:1077` | Copy claims an itemised summary of what will be lost; it lists streak, points, lessons and the tree only. Extend the lines or soften the claim — the fix direction is *say more*, not *clear less* |
| **Delete Account still ships copy promising a 30-day restore** | `screens.jsx` delete `ConfirmSheet` | ✅ **Resolved by decision (Aug 2026): deletion is permanent, no recovery period.** The open question is closed; the **copy is not** — the body must be rewritten to state immediacy and irreversibility. Porting the current string verbatim ships a promise the product does not honour |
| **Deletion does not clear `brew`, the Saved shelf, or Studio config** | `app.jsx:1016` | ✅ **Fixed by the registry.** `deleteAccount` runs `wipeStores(['progress', 'account'])` — `cq-brew` and `cq-favorites` are `progress`-scoped, `cq-custom` (Plus, trial, grove, Roasty) is `account`-scoped, so all three now go. "Everything in it" means everything |
| **`ConfirmSheet` cannot render the approved delete copy** | `settings.jsx:52` | `body` is a single `<p>{body}</p>`. The approved copy is **two paragraphs** on two different subjects and must not run together. Component change required before the copy can ship |
| **Delete button labels unresolved** — decision says *Cancel* / *Delete account*, prototype says *Keep my account* / *Delete my account* | `screens.jsx` delete `ConfirmSheet` | The two-action constraint is settled; whether the labels change is not. Prototype labels left in place pending confirmation |
| **Is the subscription warning conditional?** | — | Decision is scoped to deletion *with an active subscription*. Assumed conditional on entitlement — telling a free user their subscription stays active would be nonsense. Confirm before building |
| **`isPlus` is local state, but entitlement lives in the receipt** | `app.jsx:846` | After delete + reinstall, `isPlus` is `false` while the user is still a paying subscriber. Read entitlement from StoreKit, and consider checking it automatically at account creation rather than waiting for a manual Restore tap |
| **Help drawer covers 10 kinds, not all 13** — `decision`, `recall`, `predict`, `visual`, `practical` have no "?" | `lesson.jsx:9` | Never recorded as a decision. Confirm it is deliberate, or author the missing five |
| **A "merged nav model" is referenced but never specified** — the Learn tab becomes `LEARN` "only in the merged nav model, where Path folds into it" | `ds-content.js` icon notes | No route, no component, no decision record. Either an abandoned IA option or an unwritten one; it should not sit in the icon rationale unresolved |
| **Four future modules are promised to users with no design record of any kind** — Espresso Basics · Milk Drinks · Brewing Gear · Coffee Tasting | `screens.jsx:1147–1152` is their only appearance in the repo; `v1 Readiness Audit.html` never mentions them | **The largest open item in the product.** Four names ship to every user on the Path tab, backed by nothing: no lesson list, no scope, no rationale, no entry in the scope decision record. Either write the scope, or stop showing them |
| **The radius scale in earlier versions of this doc was wrong** (4/12/14/16/20 vs the real 2 / 14 / 999) | this doc, [§3](03-design-system.md) | Corrected. Flagged because anything built from the old line has the wrong corner on every card and button |

**Explicitly not verified by machine — needs a human pass:** whether each question is worth asking, whether explanations teach *why wrong answers are wrong*, pacing (avg ~8.0 cards/lesson — 257 across 32), and real-device feel (safe areas, thumb reach, hairline visibility, whether drill timers feel generous or stressful). This is the more valuable pass and no amount of structural checking substitutes for it.

**Remaining engineering work named by the audit:**
1. Wire StoreKit — receipt validation, restore, and a real trial counter (the prototype's is frozen).
2. Gate the dev **Tweaks panel** out of the production build (`tweaks-panel.jsx`, 569 lines, a build-time `dev` conditional).

## Divergences: where the Flutter app and this design disagree

Everything above describes the **prototype**. This section is the first entry
where the shipped app was checked against it — which is the stated purpose of
this whole reference, and had not actually been done until now.

> ⚠️ **This is not a systematic diff.** It came out of one question ("do we still
> use XP anywhere?"). One question found three mechanical disagreements, which
> suggests a real diff would find more. Treat the list below as a sample, not a
> total.

### The monetization model is not what either codebase implements

**[Product-owner ruling — settled]** Free gets **the first two lessons,
permanently**; the other thirty are paid. A cap of **two learning/practice
activities a day** applies to free users, the free Saved cap is **5**, and the
dictionary is tiered by **depth** rather than by term. Full rules in
`docs/decisions-1.md` §7–§8, §11–§12; resolved on
[Monetization shape](https://github.com/maximsan/brewpath/issues/29) and
[Free-tier practice content](https://github.com/maximsan/brewpath/issues/57).

⚠️ **An intermediate _pacing_ ruling — *2 new lessons per day free, Premium
removes the limit* — was also proposed and then withdrawn.** It is recorded
because this file stated it as current: on a finite course its value expires
when the course ends, so a free user who finished would hold the complete
product while a paying user's benefit evaporated in week three.

| | Prototype | Flutter app | Shipping model |
|---|---|---|---|
| Axis | Features (Studio, Atlas) behind a Plus tier | No gate at all — `kAdsEnabled = false`, paywall absent | **Content** — 2 lessons free of 32 |
| Saved shelf | Free cap of 10, Plus lifts it | absent | free cap **5**, Plus lifts it |
| Dictionary | fully free | absent | free = short explanation; premium adds the full one; 8 reference terms premium-only |
| Mini-games | all 7 free | absent | **2 free** (`g-match`, `g-quiz`), 5 premium but visible and lock-marked |
| Timed unlocks | Rewarded-ad 15-min trial, 24-hour perfect-module gift | absent | ads are v2; the gift is open at [Offers, plans and the paywall pitch](https://github.com/maximsan/brewpath/issues/55) |

**Lesson gating is greenfield in both places** — `featureUnlocked` only ever
took feature keys, and lesson locking is sequential progress — so there is no
prototype behaviour to port and no "the source wins" to appeal to.

What Premium buys is now settled; what remains open is the **offer** (trial,
plan structure, paywall copy), tracked separately. [§12](12-checklist.md)'s
Monetization block still describes the superseded feature axis and should not
be turned into issues as written.

### The progression model is materially different

The app is still built on **XP**; the design settled on **points**. That is a
naming difference on the surface and three genuine disagreements underneath.

| Rule | This design | The Flutter app | Where |
|---|---|---|---|
| Lesson reward | **Flat 10**, identical for every lesson | **10 × step count** — a long lesson pays several times a short one | `lib/core/constants/xp_values.dart` — `forLesson(stepCount) => stepCount * perStep` |
| Module completion | **No bonus at all** | **+25** | `XpValues.moduleCompletionBonus` |
| Replay / practice | **Zero, always** | **+2 per run**, capped once per lesson per day | `XpValues.practiceXp` |
| Coffee challenge | +5 on first completion | Not implemented | — |
| Mascot state name | `points` | `RoastyState.xp` | `lib/features/companion/domain/roasty_state.dart` |
| User-facing label | "points" | "+N XP", "Total XP" | `today_card_widget.dart`, `module_lesson_card_widget.dart` |

**The practice-XP conflict is the one that matters.** [§5](05-mechanics.md) 5.1
is explicit that replays pay nothing, and the reason is structural: points
measure showing up, mastery measures knowing it, and a replay is supposed to
improve the second without touching the first. Paying 2 XP per practice run
reintroduces exactly the grind incentive that separation exists to prevent.

The app also already carries the copy *"Practice runs do not change your XP,
streak, or progress"* (`game_type_practice_widgets.dart`) while granting practice
XP — so the app currently contradicts itself, independently of the design.

**Variable-vs-flat is the second.** Scaling by lesson length means a learner is
paid for volume rather than attendance. Whether that is wrong depends on what
points are *for*, which the design answers and the app does not.

> **Neither model is self-evidently right — this needs a decision, not a fix.**
> The design's position is argued; the app's may simply predate it. See
> [PRODUCT.md](PRODUCT.md) §14 for the product framing.

### Smaller

| Item | Detail |
|---|---|
| **`tools/extract-facts.js` reads a dead field** | Line 86 pulls `L[i].xp`, which is `null` for every lesson — per-lesson points live on the module entries. Harmless, but this reference's own tooling still carries the legacy name |
| ~~**`CLAUDE.md` points at the wrong app path**~~ **RESOLVED** | It documented the Flutter app as living in `coffee_quest/` while `lib/` and `test/` are at the repo root. Both halves are now fixed: the app was renamed to package `brew_path` ([#41](https://github.com/maximsan/brewpath/issues/41)) and the project instructions were corrected to the real root-relative layout ([#35](https://github.com/maximsan/brewpath/issues/35)). The note that project instructions sit outside this reference's remit still holds — recorded here only because this table raised it |

## Omission sweep — method and standing result

The `ComingSoonPath` omission prompted a standing sweep for **user-visible
content declared in code rather than in `data.jsx`**. Method: every top-level
`const NAME = [...]`/`{...}` across the app `.jsx` files, plus every
component-local array rendered through `.map()`, checked against this document.

**Found and now documented:** `ComingSoonPath`'s four future modules ([§4](04-information-architecture.md)) ·
`APP_HEADER_TITLES` including "Beginner Foundations" ([§4](04-information-architecture.md)) · the dead full
`ComingSoonPath` variant ([§4](04-information-architecture.md)) · `TREE_VARIETIES` + `GROVE_LIGHT` ([§6.7](06-content.md)) ·
`FAQ_ITEMS` answers as spec ([§6.8](06-content.md)) · `REMINDER_TIMES` ([§6.8](06-content.md)) · `PLAN_OPTS` as a
second price list ([§5.9](05-mechanics.md)) · `BAGPICK_ROUNDS` ([§6.5](06-content.md)) · `TRAINING`'s eight guides
([§6.3](06-content.md)).

**Checked and already documented:** `MINI_GAMES` + `MINI_GAME_CONTENT` ([§6.5](06-content.md)) ·
`CARD_KIND_HELP` ([§6.2](06-content.md)) · `PLUS_FEATURES` ([§5.9](05-mechanics.md)) · `ONB_QUESTIONS` ([§8](09-deferred-v2.md), v2) ·
`ROASTY_ANIM_META` ([§3](03-design-system.md)) · `SCREEN_ROUTES` ([§4](04-information-architecture.md)) · `CARD_ART` / `CARD_TINT` ([§6.3](06-content.md))
· `ROAST_OPTS` / `HAT_OPTS` / `GEAR_OPTS` / `SPROUT_OPTS` / `BACKDROPS` ([§6.7](06-content.md)).

`ComingSoonPath`'s `cards` remains the only component-local array of
user-visible titles. The pattern that hid it has not recurred.

---

← [Assets](10-assets.md) · [Contents](README.md) · [Gap-analysis checklist](12-checklist.md) →
