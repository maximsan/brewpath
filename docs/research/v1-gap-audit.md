# BrewPath v1 — gap audit of the Flutter app

> **📸 Point-in-time snapshot (2026-07-29) — do not cite as current state.**
> This audit was consumed into the parity map
> ([#6](https://github.com/maximsan/brewpath/issues/6) /
> [#8](https://github.com/maximsan/brewpath/issues/8)) and the app has moved
> substantially since (mastery is a `{correct, total}` pair at schema v5, the
> progress snapshot landed at v6, streak rules are ruled in
> `../decisions.md`, …). For what is true *now*, read the issues and the code;
> this file records what the gap looked like when the issues were cut.

Issue [#8](https://github.com/maximsan/brewpath/issues/8) (child of map #6).
Design reference: `docs/design/` (at the time, the since-removed `BREWPATH-V1-OVERVIEW.md`), §12 checklist as the spine;
prototype `prototype/*.jsx` as tiebreaker. Read-only audit — no source was changed.

**Repo layout:** the Flutter app is at the repo root.
It does not. The app is at the **repo root** (`pubspec.yaml`, `lib/`, `assets/`, `test/`
are all top-level). All paths below are repo-root-relative.

---

## Headline — the four sharpest divergences

1. **The points engine is a different game.** The design pays a flat **+10 once**, nothing
   else, and shows **no mid-lesson toast**. The app pays **10 XP per step** (`XpValues.perStep`,
   `lib/core/constants/xp_values.dart:5`) — a 5-step lesson banks **50** — plus a **+25 module
   bonus** (`xp_values.dart:6`) and **+2/day practice XP** (`xp_values.dart:10`), and it floats
   an explicit **`+10 XP` toast after every correct step** (`lib/features/lessons/presentation/lesson_screen.dart:125-137`).
   Three of the four "silently wrong" points rules are actively wrong in code.

2. **Streak freeze does not exist, at all.** No `freezesHeld`, `freezesSpent`, `frozenDays`,
   cap, week strip, or save notice anywhere in `lib/`. `StreakService`
   (`lib/features/progress/domain/streak_service.dart:35-43`) hard-resets the streak to `1`
   on any gap > 1 day. There is no week strip and no streak screen. The whole §5.4 mechanic
   is greenfield.

3. **Mastery exists as a number but not as a model.** `bestScore` is persisted and never
   downgrades (`lib/features/lessons/domain/lesson_completion_service.dart:176`), but there
   is no `MASTERY_PASS`, no `needs-practice / mastered / perfect` state, no label, no bean
   fill — `grep -i mastery lib/` returns only comments. Worse, the percentage is **first-try
   accuracy over all steps with infinite retries** (`lesson_screen.dart:78-82, 95-97`), not
   the design's one-shot score over *graded card kinds only*.

4. **The content is a different course, and roughly a third the size.** 25 five-step lessons
   built from **4 interaction types** vs the design's 15 lessons of **116 cards across 14 card
   kinds**. Module titles, lesson titles and IDs do not correspond to the design's syllabus at
   all (`assets/content/modules.json`, `lessons.json`). Dictionary (42 terms), coffee challenges
   (9), standalone mini-games (4), the Coffee Tree (10 stages) and the paywall are **entirely
   absent** — not stubs, no files.

Runner-up: **13 routes** in `lib/app/app_router.dart` against the design's 90 deep-link
states, and **zero bottom sheets** in the whole app (`grep showModalBottomSheet lib/` → no hits)
against the design's nine sheet types.

---

## Content gap, counted

Counted from `assets/content/*.json` (script over the JSON, not eyeballed).

| Design asks for | App has | Verdict |
|---|---|---|
| 5 modules | **5** — `module_beans, module_processing, module_roast, module_brewing, module_taste` | count matches, **content does not**: design is Beans/Processing/Roasting/**Grind**/**Brew**; app has …/Brewing Basics/**Taste** |
| 15 lessons | **25** (5 per module) | different syllabus; none of the 15 designed lesson titles present |
| 116 cards, 14 kinds | **125 steps, 4 kinds** (`multiple_choice` 53, `drag_drop` 25, `tap_order` 25, `slider` 22) | 10 of 14 designed kinds have no representation |
| 1,445 strings | **972** strings in `lessons.json` (57 contain typographic marks, 39 contain straight quotes) | ~67% of volume; punctuation is mixed, not uniformly typographic |
| 24 collectibles (4 training + 15 lesson + 5 field guide) | **17**, all lesson-linked (`cards.json`) | no training cards, no module Field Guide cards, no `fact`/`meta`/art-kind fields (shape is `id, title, description, iconName, lessonId, moduleTag`) |
| 42 dictionary terms | **0** — no file, no model, no screen | missing |
| 4 mini-games with content banks | **0 standalone**; the 4 files under `lib/features/mini_games/` are the in-lesson step players (`lesson_step_runner.dart:27-36`) | naming collision, not the feature |
| 9 coffee challenges (`BREW_TOTAL`, verified `brew-challenge.jsx:20-61`) | **0** | missing. Note §11 line says "10 coffee challenges" — the source says 9; source wins |
| 5 tree skins + Studio tables | **0** | missing |
| 10 tree PNGs, ~20 SVG icon marks | `assets/images/` and `assets/icons/` contain **only `.gitkeep`** | missing; icons are Material glyphs (`lib/core/utils/module_icons.dart:8-23`) |

`assets/content/companion_lines.json` (5 reaction buckets) has no design counterpart —
it is app-invented and fine.

---

## §11 checklist, line by line

### Foundation

| Line | Verdict | Evidence |
|---|---|---|
| Two-mood colour tokens + theme preference (light/dark/system, live OS follow, no flash) | **missing** | Only the dark-roast mood exists (`lib/shared/theme/app_colors.dart:24-68`); the Cupping light palette is absent. `AppTheme.lightTheme` is misnamed — it is `Brightness.dark` (`lib/app/app_theme.dart:8-11`) and is the *only* theme; `MaterialApp.router` passes no `darkTheme`/`themeMode` (`lib/app/app.dart:16-19`). Theme row on Profile is a "Soon" stub (`lib/features/profile/presentation/profile_screen.dart:190-196`). Illustration palette (`--art-*`) absent entirely. |
| 9-step type ladder, 3 families bundled | **partially present** | Right 3 families, bundled offline via `google_fonts/` asset dir (`pubspec.yaml:50, 87`). Ladder is **8 ad-hoc steps at wrong sizes** (36/32/30/22/16/15/14/12/11 — `lib/shared/theme/app_typography.dart:14-98`) against the design's 56/30/26/19/17/15/13/11/9.5. No `--t-hero`, no tabular-nums. |
| Icon set (~20 inline SVG marks) | **missing** | Material icons only (`lib/core/utils/module_icons.dart`, `lib/app/app_shell.dart:33-52`). No `RoastBean`, `FreezeMark`, `PointsBean`, `BrewStamp`, `LockGlyph`. |
| Roasty: parametric + 9 animation states | **partially present** | All **9 states** exist and are hand-painted on Canvas (`lib/features/companion/domain/roasty_state.dart:7-17`, `lib/features/companion/presentation/roasty_animation.dart:11-31`) — the strongest-built subsystem in the app. **Not parametric**: no `roast`/`hat`/`gear` props, only `sproutScale` (`lib/features/companion/presentation/roasty.dart:19-46`). Beats diverge from `ROASTY_ANIM_META` (e.g. `correct` 900 ms vs 1750; `wrong` 500 vs 1350). `CompanionMood` has 2 values and `happy` collapses to `idle` (`lib/features/companion/domain/companion_state_mapping.dart:37-43`); 4 of 6 `CompanionReaction`s are unwired (`companion_reaction.dart:8-24`). |
| 10 tree assets + `CoffeePersona` + `AnimatedTree` | **missing** | No tree feature, no stage names, no assets. `grep -ri tree lib/` hits only the onboarding welcome video. |
| iOS large-title collapsing header | **partially present** | Implemented once, on Profile only (`lib/features/profile/presentation/widgets/profile_header.dart:10-60`, 136→64 px). Learn/Path/Cards use a plain `AppBar` (`learn_screen.dart:28`, `path_screen.dart:20`, `cards_screen.dart:21`). No global `AppHeader` with Saved/Dictionary entries. |
| Bottom sheets (confirm, time, plan, term peek, card, log, recap, gate, share) | **missing** | Zero `showModalBottomSheet` calls in `lib/`. Confirmations use `AlertDialog` (`lib/features/profile/presentation/settings_screen.dart:127-150`). |
| 44 px minimum tap targets on edge controls | **unverified** | Nothing sets or asserts a minimum; Material `IconButton` defaults to 48×48 so it is probably satisfied by accident. Would need a widget test measuring the Profile header's X/gear hit boxes (`profile_header.dart`) to confirm. |

### Data model & persistence

| Line | Verdict | Evidence |
|---|---|---|
| Persist `progression` (streak, xp, completed set, bestResults) | **implemented differently** | All four persist in Drift and survive restart — `ProgressRecords` (lessonId/xpEarned/bestScore/completedAt) and `UserSettings` (totalXp/streakDays/lastActivityDate) at `lib/shared/storage/app_database.dart:14-31, 53-75`. **But** it is a normalised relational schema with **no `updatedAt` and no versioned snapshot** (`grep updatedAt lib/` → nothing), which is exactly what map #6 says CloudKit sync needs. `bestResults` is a single `bestScore` int, not `{correct, total}`. |
| Persist `frozenDays` / `freezesSpent` separately | **missing** | Neither column, field nor concept exists. |
| Favourites with prefixed keys and the `l\|t\|g` Saved filter | **missing** | `FavoriteCards` is an **in-memory** `Set<String>` of bare card ids, lost on restart, no prefixes, no cap, no gate (`lib/features/cards/domain/favorite_cards_provider.dart:8-22`). Only `c:`-equivalent (cards) is favouritable — i.e. the *one* prefix the design says must **not** count as Saved. No Saved screen, no header badge. |
| Brew state (active/startedAt/completed/saved) | **missing** | — |
| Plus / trial / subscription state | **missing** | `NoOpPaymentsService.hasActiveEntitlement()` returns a constant `false` and nothing is persisted (`lib/services/payments/noop_payments_service.dart:10`). No trial counter. |
| Offline: opened modules on device | **implemented differently** | Stronger than asked and simpler: **all** content ships in the bundle (`pubspec.yaml:80`, loaded by `lib/shared/repositories/content_repository.dart`), so the app is fully offline. There is no sync layer at all, so the "syncs when online" half is missing. |
| Replace frozen prototype dates/values | **implemented as designed** | Nothing was ported from the prototype, so no hardcoded 8 May 2026, no `maya@hey.com`, no seeded 7-day streak. Version string is real (`package_info_plus`, `lib/features/profile/domain/settings_providers.dart:39-43`). |

### Core loop

| Line | Verdict | Evidence |
|---|---|---|
| Lesson player with 14 card kinds + per-kind help drawer | **partially present** | A working player exists (`lib/features/lessons/presentation/lesson_screen.dart`) with a sealed 4-variant step union (`lib/shared/models/lesson_step_model.dart`, dispatched at `lesson_step_runner.dart:27-36`). **4 of 14 kinds**, and none maps cleanly: `drag_drop`/`tap_order` are near-`match`/`sequence`, `slider` is near-`slider`, `multiple_choice` is near-`mcq`. The ten teaching/ungraded kinds (`concept`, `predict`, `intro`, `visual`, `practical`, `takeaway`, `recall`, `decision`, `multi`, `tastefix`) are absent. **No `GAME_HELP` drawer** anywhere. |
| `RoastBean` progress + counter + save-lesson | **partially present** | Counter exists ("Step X of Y" + percent, `lesson_screen.dart:182-232`) but as a `LinearProgressIndicator`, not a filling bean. **No save-lesson bookmark** in the player. |
| Term auto-linkification → peek sheet | **missing** | No glossary, no linkifier, no sheet. |
| Points: +10 first only, +5 first coffee challenge, 0 replays, no perfect bonus, no mid-lesson toast | **implemented differently — the sharpest divergence** | ① Lesson pays `stepCount × 10` = **50 XP**, not 10 (`lib/core/constants/xp_values.dart:5,12` → `lesson_completion_service.dart:114`). ② An undesigned **+25 module bonus** is paid (`xp_values.dart:6`, `lesson_completion_service.dart:225`). ③ Replays: **correct for first-completion re-entry** (`lesson_completion_service.dart:104-112` returns early, awards nothing) and correct for pure practice (`lesson_completion_screen.dart:72-76`), **but** the `review` path pays **+2 XP/day** (`lesson_completion_service.dart:178-188`) — the design says 0. ④ No perfect bonus — **as designed**, though also no perfect *state*. ⑤ **Mid-lesson toast is present and shows `+10 XP` per correct step** (`lesson_screen.dart:91-93, 125-137` with `XpValues.perStep`) — flatly contrary to §5.1, and doubly misleading since that toast is not what gets banked. ⑥ Coffee-challenge +5: n/a, feature missing. |
| Mastery: best-ever %, `MASTERY_PASS = 0.8`, three states, never downgrades | **partially present** | Never-downgrades is correct (`lesson_completion_service.dart:176`, `if (score > record.bestScore)`), persisted as int % on first completion too (`app_database.dart:27`). **Missing**: the 0.8 threshold constant, the three states, the "Needs Practice" chip, any surfacing beyond a raw `Best score: N%` line (`lib/features/lessons/presentation/lesson_completion_body.dart:169`). **Also computed differently**: the app's % is first-try accuracy across *all* steps with unlimited retries on a wrong answer (`lesson_screen.dart:78`, `95-97`), whereas the design scores a single pass over graded kinds only. The two numbers are not interchangeable. |
| Review-confirm sheet + no-XP review mode | **partially present** | Review mode exists and is routed (`?review=true` from `lib/features/learn/presentation/module_lesson_card_widget.dart:31-33`; consumed at `lib/app/app_router.dart:112`). **No confirm sheet** — tapping a completed lesson drops straight into it. And review is **not** XP-free (see above). Note the app has *three* modes (complete / review / practice) where the design has two. |
| Reward routing incl. "next lesson only if authored" fallback | **partially present** | Module-complete routes to a `moduleSummary` recap (`lesson_completion_body.dart:64-71`, `app_router.dart:136-143`); otherwise Continue goes to `/learn`. **No** "next lesson if authored, else Path" chaining, no `module-card` step, no perfect branch, no coffee-challenge offer. |
| Tree growth from core lessons only, 10 stages | **missing** | — |
| Module/lesson gating recomputation | **implemented as designed** | Recomputed on every read from the completed set (`lib/features/learn/domain/learn_providers.dart:44-65`): a module unlocks when its `unlockRequirement` module is fully complete; module 1 is open (`unlockRequirement: null`, `assets/content/modules.json`). Matches `syncModuleProgress`. **Not covered**: the design's second condition — "*and* its own first lesson is authored" / coming-soon state — is moot here since all 25 lessons are authored. Reset re-locks correctly (`lib/features/profile/domain/settings_providers.dart:50-64`). |
| Collectible unlock sync + locked silhouettes | **partially present** | Lesson-card unlock on completion works (`lesson_completion_service.dart:126-133`) and locked tiles render an inert `???` silhouette (`lib/features/cards/presentation/card_grid_item_widget.dart:29, 46-60`). **Missing**: module Field Guide unlock (all-lessons-done), always-unlocked training cards, coffee-challenge stamps. |

### Streak

| Line | Verdict | Evidence |
|---|---|---|
| Earn 1 per 7 days, cap 2, spend automatically | **missing** | No freeze concept. `StreakService.onLessonCompleted` returns `1` on any gap ≥ 2 (`lib/features/progress/domain/streak_service.dart:41-43`). |
| Derived held count (never drifts) | **missing** | Nothing to derive. (Prototype rule confirmed at `prototype/app.jsx:432-433`.) |
| Week strip derived from real streak | **missing** | No week strip; the streak surfaces only as a number tile (`lib/features/profile/presentation/profile_screen.dart:129-133`). |
| One-time dismissible save notice | **missing** | — |
| Streak screen + share sheet | **missing** | No `/streak` route (`lib/app/app_router.dart` has 13 routes total). |

### Content

| Line | Verdict | Evidence |
|---|---|---|
| 5 modules / 15 lessons / 116 cards / 1,445 strings | **implemented differently** | 5 / 25 / 125 steps / 972 strings, and a **different syllabus** — see the counted table above. |
| 42 dictionary terms + 8 categories + cross-links + sources | **missing** | `grep -ri dictionary lib/` → no hits. |
| 24 collectible cards with bespoke art | **partially present** | 17 cards, Material-icon badges, no bespoke art, no `fact`/`meta` fields (`assets/content/cards.json`). |
| 4 mini-games with content banks | **missing** | The `mini_games` folder is the in-lesson step players; there is no standalone intro→play→results flow and no `MINI_GAME_CONTENT`. |
| 9 coffee challenges (§11 says 10; source says 9) | **missing** | — |
| Studio option tables + 5 tree skins | **missing** | — |

### Monetization

| Line | Verdict | Evidence |
|---|---|---|
| Paywall: 2 plans, 7-day trial CTA, Restore/Terms/Privacy | **missing** | The only surface is a `PremiumCard` opening a "Premium is brewing" `AlertDialog` (`lib/features/profile/presentation/widgets/premium_card.dart:26-27, 80-100`). Its copy also **contradicts the design** — it sells "unlock every module, remove ads, keep your streak safe", where the design makes learning free, ads v2-only, and the streak free forever. |
| StoreKit: purchase, receipt validation, restore, real trial counter | **missing** | `in_app_purchase: ^3.2.3` is in `pubspec.yaml:36` and `lib/services/payments/in_app_purchase_service.dart` exists, but the wired implementation is `NoOpPaymentsService` (all methods constant/no-op, `noop_payments_service.dart:10-27`). |
| Saved free cap 5 → gate sheet, removal always allowed | **missing** | No cap, no gate, no Saved screen (see Favourites above). |
| Studio as the only true v1 gate | **missing** | No `featureUnlocked`/`requestFeature` funnel, no `FeatureLock`, no Studio. |
| Subscription + Account screens, change plan, cancel | **missing** | — |
| Plus welcome screen | **missing** | — |

### Settings & compliance

| Line | Verdict | Evidence |
|---|---|---|
| All 5 settings sections | **partially present** | Of Appearance / Practice / Account / Support / Destructive, the app has **Practice (partial)** — Haptics + Sound toggles (`lib/features/profile/presentation/settings_screen.dart:42-59`) — and **Destructive (partial)** — Reset progress only (`settings_screen.dart:106-124`). Appearance, Account and Support are absent; "Daily reminder" and "Theme" appear on Profile as `Soon` stubs (`profile_screen.dart:183-196`). An extra non-design "Restart onboarding" section exists (`settings_screen.dart:179-222`). |
| Reset progress + Delete account with itemised confirm sheets, 30-day restore | **partially present** | Reset progress works end-to-end and is itemised in the copy (`settings_screen.dart:131-135`; wipes progress, module ledger, cards, XP/streak via `settings_providers.dart:50-64`) — but via `AlertDialog`, not a `ConfirmSheet`. **Delete account is missing entirely** (nothing to delete — no accounts), so the 30-day-restore copy question flagged in map #6 is still open. Note `resetProgress` does **not** clear favourites (they are in-memory anyway). |
| Help FAQ (4 entries), About | **partially present** | "About" is a single Version row (`settings_screen.dart:70-75`). No FAQ, no About screen. |
| Local notifications for the daily reminder | **missing** | No notifications plugin in `pubspec.yaml`; the reminder tile is a "Coming soon" snackbar (`profile_screen.dart:183-189`, `76-85`). |

### Release hygiene

| Line | Verdict | Evidence |
|---|---|---|
| Tweaks panel excluded from the store binary | **implemented as designed (vacuously)** | No tweaks panel was ported. The one debug toggle follows the repo rule — `bool.fromEnvironment('LOOP_LOADING')` (`lib/features/onboarding/presentation/loading/loading_screen.dart:31`), so release builds are safe by construction. |
| Verify `isV1`-gated paths removed or dark | **implemented as designed (vacuously)** | No `isV1` equivalent exists in `lib/`; no Atlas/Duel/mood-player code was ported, so there is nothing to keep dark. `kUseFirebase` (`lib/core/config/firebase_flags.dart`) and `kAdsEnabled` (`lib/features/monetization/monetization_config.dart:11`) are both `false` and correctly abstraction-gated. |

---

## Cross-cutting observations

- **Test coverage is real but aimed at the current design, not the target one.**
  53 test files, including `test/unit/streak_service_test.dart`, `xp_service_test.dart`,
  `lesson_completion_service_test.dart` and Drift migration tests
  (`test/unit/shared/storage/app_database_migration_test.dart`, schemas v1–v3). Every
  points/streak change above will break tests that currently encode the *wrong* rules —
  budget for rewriting them, not just extending.
- **Reduced motion is honoured** in the three places that animate (`roasty.dart`,
  `xp_gain_toast.dart`, `loading_screen.dart`), but `Semantics` labels appear only in the
  onboarding loading screen — loading/empty/error states elsewhere are unlabelled
  (`lib/core/widgets/loading_indicator.dart`, `error_view.dart`).
- **The companion subsystem is the one place where the app is ahead of the checklist** —
  9 Canvas-painted states, pure animation helpers with unit tests, mood/reaction separation.
  It needs parametric props and correct beats, not a rewrite.
- **Nothing in `lib/` references the prototype's own vocabulary** (`brew`, `dictionary`,
  `freeze`, `mastery`, `stage`, `trial`, `paywall` all return zero or comment-only hits).
  The two codebases share a subject, not a domain model. Ticketing should assume *build*,
  not *port*, everywhere except gating and card-unlock sync.

## Explicitly unverified

- 44 px tap targets — needs a widget test measuring hit boxes.
- Whether `google_fonts/` actually contains all three families at the weights the ladder
  needs (only that the directory is bundled and `google_fonts` resolves offline).
- Runtime behaviour of the Drift v1→v3 migration on a real device (tests cover it in memory).
