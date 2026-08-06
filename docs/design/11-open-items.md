# Known open items

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `brew-path/`.


## Re-verified Aug 2026 (`QA Findings.html`)

The structural pass was re-run against the grown build. Every mechanical check is clean:

| Check | Result |
|---|---|
| Dictionary lesson links resolve to a lesson that teaches the term | 72 terms, `dictLessonAudit()` returns `[]`; 9 reference-only terms claim no lesson |
| Every lesson has a collectible card; every card unlocks from a real lesson | 32 / 32, no orphans either direction |
| Every card `kind` has bespoke art and a tint | All resolve (see [§6.3](06-content.md) for the 38/39 arithmetic) |
| Path order matches defined lessons | 32 entries, 32 definitions, no drift |
| `m5l7` run through the Modules 2–5 review plan | Two fixes: two off-topic distractors replaced; one decision whose sub-labels graded the options rather than describing them |
| Brew challenges | 7 of 32 lessons, by design |

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
- ✅ **All 23 outstanding card-art designs are drawn.** `scales`, `hourglass`, `burrs` have components; `variety`, `caffeine`, `distribution` have both guide art and thumbnails.
- ✅ **The `draft: true` writing pass is complete** — 15 lessons cleared, 0 remain.
- ✅ **The duplicate 7-item tree stage-name list is gone** from `app.jsx`; `STAGE_NAMES` is the only list.

## Opened or still open
| Item | Where | Disposition |
|---|---|---|
| **Three duplicate collectible titles** — Extraction, Fermentation, and now **The Cherry in Section** (`tr-anatomy` vs the `m1l7` card) | `data.jsx` `COLLECTION` | Prose work, still unassigned. The third arrived with `m1l7` |
| `intro` and `takeaway` have **zero authored cards** across all 257 | `lesson.jsx` | `active-cards.jsx` documents them as superseded by `predict` / `recall`. **Decide: delete the renderers, or author cards.** Leaving them is the status quo by default, not by choice |
| **Two frozen "today" dates** — 8 May 2026 for the app, 18 Jun 2026 for the dictionary | `screens.jsx`, `dictionary-data.jsx`, `dictionary-extras.jsx` | Harmless in a prototype; a real clock must not inherit the split |
| **Price list duplicated** across the paywall and the change-plan sheet | `customize.jsx:184`, `settings.jsx:384` | Two places to edit one price. Unify on the way in |
| `QA Findings.html` **pacing note is internally stale** — still says "116 cards across 15 lessons" | `QA Findings.html` | The hero was updated to 32/257; the judgement section below it was not. Real figure: 257 cards / 32 lessons ≈ 8.0 per lesson |
| Three route counts in circulation (103 / 96 / 97) | [§4](04-information-architecture.md) | 103 is the source of truth |
| **`cq-recent-terms` is persisted but consumed by nothing** | `app.jsx:336–340`, `dictionary.jsx:316` | The key is written on every term open and passed in as `recent`; `DictionaryHome` never reads it and no recent-strip component exists. Build the strip or stop writing the key |
| **Path expanded/collapsed state lives in a `window` global** — `window.__pathExpandedMods` | `screens.jsx:1280` | Mirrored out of React state; not persisted, lost on reload. Decide deliberately whether a collapsed module stays collapsed across launches |
| **Three components accept props they never use** — `ProfileTab` (`theme`, `onTheme`), `LearnTab` (`onStreak`, `onOpenModule`, `onOpenSaved`, `onOpenDictionary`, `onOpenTermOfDay`, `brewPathMode`) | `screens.jsx` | 8 dead props. Harmless in the prototype, misleading when porting — they imply entry points that do not exist on those screens |
| **Duel has three entry points, not one** — Profile card, Learn card, lesson-complete link | `screens.jsx`, `rewards.jsx` | All `showDuel` / `!isV1`. v2 work has to re-light all three; the tab is not the only surface |
| **All 8 About / Help rows are dead stubs** — Privacy policy · Terms of use · Acknowledgements · Open-source licenses · Rate BrewPath · Say hello · Email support · Report a problem | `settings.jsx:279`, `settings.jsx:650` | Every one is `onClick={() => {}}` behind a finished-looking row with an external-link affordance. **Privacy and Terms are store-review requirements.** 8 destinations to build; none was in the checklist before this pass |
| **Privacy + Terms exist in two places** — About and the paywall | `settings.jsx:279`, `customize.jsx` | Must resolve to the same URLs. Only the paywall pair was documented |
| **`brew.saved` is dropped on Reset Progress, not emptied** — becomes `undefined` | `app.jsx:838` | **Live defect.** The persist effect at `app.jsx:520` throws on `[...undefined]`, is swallowed by its `try/catch`, and `cq-brew` is never rewritten — so parked challenges **return on next launch**. `app.jsx:946` then calls `.has()` on it unguarded and throws for real. Fix: include `saved: new Set()`. See [§5](05-mechanics.md) 5.12 |
| **`freezesSpent` is not cleared by Reset Progress** although the streak rules say it is | `app.jsx:838` vs `app.jsx:846` | **Live defect.** Only `deleteAccount` zeroes it. Invisible at reset (streak is 0), then blocks freeze earning once the user rebuilds a 7-day streak: held = `1 − freezesSpent`. See [§5](05-mechanics.md) 5.12 |
| **The reset confirm sheet's itemised loss list is incomplete** — 4 lines, omits brew challenges, collectibles and mastery | `app.jsx:1077` | Copy claims an itemised summary of what will be lost; it lists streak, points, lessons and the tree only. Extend the lines or soften the claim |
| **Delete Account still ships copy promising a 30-day restore** | `screens.jsx` delete `ConfirmSheet` | ✅ **Resolved by decision (Aug 2026): deletion is permanent, no recovery period.** The open question is closed; the **copy is not** — the body must be rewritten to state immediacy and irreversibility. Porting the current string verbatim ships a promise the product does not honour |
| **Deletion does not clear `brew`, the Saved shelf, or Studio config** | `app.jsx:846` | Under a permanent-deletion policy, "everything in it" has to mean everything. Three stores survive today |
| **`ConfirmSheet` cannot render the approved delete copy** | `settings.jsx:52` | `body` is a single `<p>{body}</p>`. The approved copy is **two paragraphs** on two different subjects and must not run together. Component change required before the copy can ship |
| **Delete button labels unresolved** — decision says *Cancel* / *Delete account*, prototype says *Keep my account* / *Delete my account* | `screens.jsx` delete `ConfirmSheet` | The two-action constraint is settled; whether the labels change is not. Prototype labels left in place pending confirmation |
| **Is the subscription warning conditional?** | — | Decision is scoped to deletion *with an active subscription*. Assumed conditional on entitlement — telling a free user their subscription stays active would be nonsense. Confirm before building |
| **`isPlus` is local state, but entitlement lives in the receipt** | `app.jsx:846` | After delete + reinstall, `isPlus` is `false` while the user is still a paying subscriber. Read entitlement from StoreKit, and consider checking it automatically at account creation rather than waiting for a manual Restore tap |
| **Help drawer covers 10 kinds, not all 13** — `decision`, `recall`, `predict`, `visual`, `practical` have no "?" | `lesson.jsx:9` | Never recorded as a decision. Confirm it is deliberate, or author the missing five |
| **A "merged nav model" is referenced but never specified** — the Learn tab becomes `LEARN` "only in the merged nav model, where Path folds into it" | `ds-content.js` icon notes | No route, no component, no decision record. Either an abandoned IA option or an unwritten one; it should not sit in the icon rationale unresolved |
| **Four future modules are promised to users with no design record of any kind** — Espresso Basics · Milk Drinks · Brewing Gear · Coffee Tasting | `screens.jsx:1147–1152` is their only appearance in the repo; `v1 Readiness Audit.html` never mentions them | **The largest open item in the product.** Four names ship to every user on the Path tab, backed by nothing: no lesson list, no scope, no rationale, no entry in the scope decision record. Either write the scope, or stop showing them |
| **The radius scale in earlier versions of this doc was wrong** (4/12/14/16/20 vs the real 2 / 14 / 999) | this doc, [§3](03-design-system.md) | Corrected. Flagged because anything built from the old line has the wrong corner on every card and button |

**Explicitly not verified by machine — needs a human pass:** whether each question is worth asking, whether explanations teach *why wrong answers are wrong*, pacing (avg ~8.1 cards/lesson), and real-device feel (safe areas, thumb reach, hairline visibility, whether drill timers feel generous or stressful). This is the more valuable pass and no amount of structural checking substitutes for it.

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

### The progression model is materially different

The app is still built on **XP**; the design settled on **points**. That is a
naming difference on the surface and three genuine disagreements underneath.

| Rule | This design | The Flutter app | Where |
|---|---|---|---|
| Lesson reward | **Flat 10**, identical for every lesson | **10 × step count** — a long lesson pays several times a short one | `lib/core/constants/xp_values.dart` — `forLesson(stepCount) => stepCount * perStep` |
| Module completion | **No bonus at all** | **+25** | `XpValues.moduleCompletionBonus` |
| Replay / practice | **Zero, always** | **+2 per run**, capped once per lesson per day | `XpValues.practiceXp` |
| Brew challenge | +5 on first completion | Not implemented | — |
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
| **`CLAUDE.md` points at the wrong app path** | It documents the Flutter app as living in `coffee_quest/`, but `lib/` and `test/` are at the repo root. Package imports still use `package:coffee_quest/…`, so the package name is right and the directory is not. Not corrected here — project instructions are outside this reference's remit |

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
