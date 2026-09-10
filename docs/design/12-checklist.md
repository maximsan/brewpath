# Gap-analysis checklist — audited

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `prototype/`.

**Audited on 9–10 September 2026 against the app and the tracker.** Every line
below now says what became of it, with a file or an issue as the proof: a
ticked line is built (the path names the code) or superseded by a ruling
(struck through, the ruling named); an unticked line points at the open issue
that owns it. Nothing here is unowned. The seven lines that were unowned when
the audit ran are now #570–#576.

This file was the staging list that fed GitHub Issues once; the living
checklists are [#365](https://github.com/maximsan/brewpath/issues/365) and
[#368](https://github.com/maximsan/brewpath/issues/368). It is kept as the
record of that audit and nothing else.
---

## Foundation
- [x] Two-mood colour token system + theme preference (light/dark/system, follows OS live, no flash on launch) ([§3](03-design-system.md)) — **shipped:** `lib/shared/theme/mood_colors.dart`, `app_theme_mode.dart`, theme read in `app_bootstrap.dart` before `runApp`; #37, #40
- [x] Illustration palette as a **separate** set from theme tokens — 8 bean/roast + 6 cherry tokens — **shipped:** `lib/shared/theme/art_colors.dart`, un-themed by construction; #12
- [x] 10-step type ladder, 3 font families bundled — **shipped:** `lib/shared/theme/app_text.dart` (10 rungs), the three families in `pubspec.yaml`; #36
- [x] Icon set (all inline SVG, ~20 marks) with one shared stroke-weight token — **shipped:** `lib/core/icons/app_icon.dart` (49 marks), `icon_mark.dart`, `tool/extract_icons.js`; #378, #436
- [ ] Roasty component: parametric (roast/hat/gear/sprout) + 9 animation states (`points`, not `xp`) — **→** #367 owns the dress-up; the 9 states are `lib/features/companion/domain/roasty_state.dart`, `points` not `xp` (#160)
- [x] 10 tree-stage assets + `CoffeePersona` + `AnimatedTree` cross-fade — **shipped:** `assets/images/trees/1–10.png`, `lib/features/progress/presentation/coffee_tree.dart`, `growing_tree.dart`; #136, #446
- [x] iOS large-title collapsing header — **shipped:** `lib/app/app_header.dart`, `lib/core/widgets/page_large_title.dart`, `header_compact_title.dart`; #441, #513
- [ ] Bottom sheets: confirm, time picker, plan picker, term peek, card sheet, log result, recap, gate, share — **→** #570 — Reset confirms in an `AlertDialog`; every other sheet is built (time, term peek, card, log, recap, gate, share) or dropped (plan picker, ADR-0003)
- [ ] `ConfirmSheet.body` renders **multiple paragraphs** — a single `<p>` today, which blocks the approved delete copy ([§5](05-mechanics.md) 5.12) — **→** #570
- [x] 44px minimum tap targets on edge controls — **shipped:** `lib/core/widgets/float_topbar.dart` (`hitSize = 44`), `sub_header.dart`, `settings_nav_row.dart`; #513, #533
- [x] **Two radius languages** — 2px editorial / 14px chrome / 999px pill, not a single scale — **shipped:** `lib/shared/theme/app_radii.dart` (2 / 14 / 999); ADR-0009 for the button exception
- [ ] Hairline-first separation; shadows only on sheets and floating buttons; selection as a double stroke, never a fill — **→** #571 — `lib/core/widgets/pick_card.dart` still fills the indicator (#389 row 2)
- [ ] Port the **19 component state sets + 38 pattern rules** from `Design System.html` ([§3](03-design-system.md)) — the actual UI spec — **→** #365
- [ ] Empty states for every list, grid and drill — specified in the design system ([§3](03-design-system.md)) — **→** #572 — three empty states exist, none carries the ghost button (#389 row 38)

## Data model & persistence
- [x] Persist + sync `progression` (streak, points, completed set, bestResults) — **not persisted in the prototype** ([§5](05-mechanics.md) 5.10) — **shipped:** `lib/shared/storage/snapshot/progress_snapshot.dart`, `snapshot_scopes.dart`; #78, #115, #116 — the sync half is line 52
- [x] ~~Persist `frozenDays` / `freezesSpent` separately~~ — **superseded:** nothing is stored: freezes held, spent and covered days derive from the active-day set (`lib/features/progress/domain/streak_engine.dart`); #133, #137
- [x] The Saved shelf with prefixed keys and the `l|t|g` filter — **shipped:** `lib/features/saved/domain/saved_key.dart`, `saved_shelf.dart`; #288, #296
- [x] Brew state (active + startedAt + completed + saved) — **shipped:** `snapshot_scopes.dart` (`activeChallenge`, `challengesCompleted`, parked set), `lib/features/challenges/domain/challenge_lifecycle.dart`; #143, #145
- [ ] Plus / trial / subscription state, read from StoreKit rather than local flags — **→** #421; trial and subscription dropped by ADR-0003
- [x] Grove state as **two axes** (`variety` + `light`) + the `migrateGrove` legacy upgrade — **shipped:** `lib/shared/models/content/grove_variety.dart`, `grove_light.dart`, the snapshot's `grove`; `migrateGrove` not ported, nothing to migrate (#135)
- [ ] Offline: keep opened modules on device, sync when online (promised in the FAQ) — **→** #575 — no transport exists and no ruling drops it
- [x] Replace all frozen prototype dates/values — **including the second, dictionary-only frozen date** ([§5](05-mechanics.md) 5.11) — **shipped:** no frozen literal in `lib/`; today via `lib/app/current_day.dart`; #96, ADR-0013 (clock staleness is #202)

## Core loop
- [ ] Lesson player with 13 authored card kinds + the help drawer (10 entries, not one per kind — [§6](06-content.md) 6.2) — **→** #550 owns the help drawer; the renderers are `lib/features/lessons/presentation/cards/content_card_view.dart` (#418)
- [x] `bagpick` card: green-bean rendering from process cues, sample draw, cue inspection — **shipped:** `lib/features/lessons/presentation/cards/bagpick_card_view.dart`; #326
- [ ] Cherry cross-section (`CherrySection`) as both a lesson visual and a visual guide — **→** #323; the static rings are `lib/core/widgets/visual_guide_art.dart`
- [x] `RoastBean` progress + counter + save-lesson — **shipped:** `lib/core/widgets/roast_meter.dart`, `SavedBookmarkButton` in `lesson_screen.dart`; #381, #437, #290
- [ ] Term auto-linkification → peek sheet — **→** #99; the peek sheet is built (`term_peek_sheet.dart`), the matcher (`term_mentions.dart`) has no caller yet
- [x] Points rules: +10 first completion only (per-lesson value), +5 first coffee-challenge completion, 0 for replays, no perfect bonus, no mid-lesson toast ([§5](05-mechanics.md) 5.1) — [#160](https://github.com/maximsan/brewpath/issues/160)
- [x] ~~Mastery: best-ever percentage, `MASTERY_PASS = 0.8`, three states, never downgrades~~ — **superseded:** bands come from the wrong-answer count, never a 0.8 pass (#16); `lib/features/progress/domain/mastery.dart`
- [ ] Review-confirm sheet + no-points review mode — **→** #573 — the app goes straight into the lesson (`path_lesson_row.dart`); the no-points half is built (#160)
- [x] Reward routing incl. "next lesson only if authored" fallback — **shipped:** `lib/features/lessons/domain/lesson_completion_actions.dart`, `lib/features/learn/domain/course_order.dart`
- [x] Tree growth: **all 32 lessons core**, 10 stages, `CORE_TOTAL` derived from `MODULES` rather than hardcoded ([§5](05-mechanics.md) 5.3) — **shipped:** `lib/features/progress/domain/tree_growth.dart` (stages from the module bank), `tree_stage_names.dart`; #376
- [x] Module/lesson gating recomputation — **shipped:** `lib/features/learn/domain/learn_providers.dart`, `lib/features/path/domain/path_density.dart`; #215
- [x] Collectible unlock sync — grid shows **37** (training filtered out), earned cards plus exactly one locked teaser, then a "{n} more to collect" footer ([§5](05-mechanics.md) 5.6) — **shipped:** `lib/features/cards/domain/cards_grid.dart`, `cards_footer.dart`, 37 in `collectibles.json`; #396
- [x] Path: completed modules collapse and default to collapsed; in-progress and locked cannot collapse — **shipped:** `path_density.dart` (`canCollapse` only when complete), `path_screen.dart`
- [x] Reward screens are two-phase — `RoastyMoment` then content; module complete auto-advances at 2200 ms — **shipped:** `lesson_completion_screen.dart`, `module_complete_screen.dart` (2200 ms hold)
- [x] Lesson complete: card preview overlay, Practice again, challenge suggestion (and the Duel link in v2) — **shipped:** `lesson_completion_body.dart`, `lesson_completion_actions.dart`; #490 (the module-final gap is #504)
- [x] Module complete: reward-card flip — **shipped:** `module_complete_screen.dart`, `lib/core/widgets/reward_flip.dart`; ADR-0017, #384

## Streak
- [x] ~~Earn 1 per 7 days, cap 2, spend automatically~~ — **superseded:** the cap is 1 (`streak_status.dart`, #58); earn-at-7 and auto-spend in `streak_engine.dart`; #69
- [x] Derived held count (never drifts) — **shipped:** `streak_engine.dart`; #137, #159
- [x] Week strip derived from real streak — **shipped:** `lib/features/progress/domain/streak_week.dart`, `presentation/week_strip.dart`; #235
- [x] One-time dismissible save notice — **shipped:** `freeze_save_notice.dart`, `freeze_save_notice_card.dart`; #233
- [x] Streak screen + share sheet — **shipped:** `streak_screen.dart`, `streak_share_card.dart`, `lib/services/share/`; #232, #237

## Content
- [x] ~~5 modules / 32 lessons / 257 cards ported with typographic punctuation intact ([§6](06-content.md) 6.1)~~ — **superseded:** the extracted bank is the contract (ADR-0006) and holds 258 cards; `06-content.md` still says 257
- [x] 73 dictionary terms (all full) + 8 categories + cross-links + sources — **shipped:** `dictionary_terms.json` (73), `dictionary_categories.json` (8), rendered by `term_entry_body.dart`; #95
- [x] Dictionary third state (**Reference**): glyph, chip, To-learn filter exclusion, `REFERENCE ONLY` block, 8 terms — **shipped:** `dictionary_derivations.dart`, `term_entry_body.dart`, `status_chip.dart`; #217, #249
- [ ] Dictionary home: alias-matching search (deep-linkable + auto-focus), status filter with live counts, category grid, Term-of-Day banner, quick chips — **→** #574 — everything else on this line is built (#398); the deep-link and auto-focus are not
- [x] Flashcards: flip, prev/next, shuffle, jump-to-term, empty state — **shipped:** `flashcards_screen.dart`, `flashcards_empty_view.dart`; #97, #468
- [x] Vocab game: setup phase (three-deck picker + round length with a `capped` guard), play, results, and the Misses deck a wrong answer feeds — **shipped:** `vocab_setup.dart`, `vocab_miss_log.dart`; ADR-0022; #98, #298
- [x] Saved screen: three groups (terms · lessons · guides), each hidden when empty, plus the "study as flashcards" row — **shipped:** `saved_screen.dart`, `saved_group_section.dart`, `saved_study_row.dart`; #296
- [x] 37 collectible cards + 8 visual guides, all with bespoke art (**art complete — port, don't draw**) — **shipped:** `lib/features/cards/domain/card_art.dart` + `assets/card_art/` (37), `visual_guide_art.dart` + `guide_marks/` (8); #480, #276
- [x] 13 mini-games over 7 kinds with content banks (69 rounds; [ADR-0005](../adr/0005-mini-games-are-many-games-per-kind-gated-by-topic.md)) — **shipped:** `mini_games.json` (13), `mini_game_content.json` (69); #311 (match dragging is #566)
- [x] 12 coffee challenges — **shipped:** `brew_challenges.json` (12), `lib/features/challenges/`; #143
- [ ] Studio: 3 species × 4 light treatments, 8 visual guides, Roasty option tables — **→** #367 owns the Roasty tables; the grove is built (`studio_screen.dart`, #140) and the guides live on Path (`reference_section.dart`, #275)

## Monetization

> ⚠️ **Every line in this block was written against the superseded feature-gating
> model.** The shipping model is a **content gate**: the first three lessons free ([ADR-0007](../adr/0007-free-tier-is-the-first-three-lessons.md)),
> permanently, the other twenty-nine paid, plus a cap of two learning/practice
> activities a day, a free Saved cap of **5**, and a dictionary tiered by depth
> ([PRODUCT.md](PRODUCT.md) §11, `docs/decisions.md` §7–§8, §11–§12). What
> **BrewPath Plus** buys is now **settled** on
> [Monetization shape](https://github.com/maximsan/brewpath/issues/29); the
> *offer* — trial, plan shape, paywall copy — is open at
> [Offers, plans and the paywall pitch](https://github.com/maximsan/brewpath/issues/55).
>
> **The lines below still under-describe the work**, because lesson gating is
> greenfield in both codebases and nothing here covers it. Generate issues from
> the decisions, not from this block.

- [x] Paywall: single one-time purchase, no trial ([ADR-0003](../adr/0003-one-time-purchase-no-trial.md)), Restore/Terms/Privacy — **shipped:** `lib/features/monetization/presentation/plus_gate_sheet.dart`; the Terms/Privacy targets are #448
- [ ] StoreKit: purchase, receipt validation, restore, real trial counter — **→** #421; the trial counter is dropped by ADR-0003
- [ ] Restore Purchases with all **three** outcomes — restored / nothing to restore / failed — plus pending and error-retry ([§7](07-components.md) 7.3) — **→** #421
- [ ] Plus entitlement read from **StoreKit, not local state** — after delete + reinstall a paying subscriber must not see a paywall — **→** #421
- [ ] New account + Restore on the same Apple Account re-applies the subscription; deleted progress does not return — **→** #421; deleted progress not returning is built (`wipe_snapshot.dart`, #81)
- [x] Saved free cap of 5 → gate sheet at the cap, removal always allowed — **shipped:** `lib/features/saved/domain/saved_cap.dart`, `presentation/saved_gate.dart`; #286, #296
- [x] ~~Studio as the only true v1 gate~~ — **superseded:** the gate is on content (ADR-0007); the Studio is one of nine gate call sites
- [x] ~~Subscription + Account screens, change plan, cancel (four labels: Cancel trial / Keep trialling / Cancel subscription / Keep Plus)~~ — **superseded:** ADR-0003: no plans, no trial, no change-plan or cancel
- [ ] Plus welcome screen — **→** #576
- [x] ~~**One** price list, not two — `customize.jsx` and `settings.jsx` currently each hold one~~ — **superseded:** ADR-0003 drops the second list; the app writes no price, the store supplies it (`lib/services/payments/store_product.dart`)

## Settings & compliance
- [x] All 5 settings sections ([§6](06-content.md) 6.8) — **shipped:** `lib/features/profile/presentation/settings_screen.dart`; #395
- [x] Reset progress: clear progression + brew (**including `saved`**) + `frozenDays` + `freezesSpent` + **the Saved shelf** + `recentTerms`; keep entitlement, Studio, theme ([§5](05-mechanics.md) 5.12) — **shipped:** `wipe_snapshot.dart` (`resetTombstone`), `account_wipe.dart`, `wipe_snapshot_test.dart`; `recentTerms` has no store
- [ ] Reset confirm sheet: itemise **all** of what is lost — not just streak / points / lessons / tree, and now the Saved shelf too — **→** #570
- [x] ~~Account deletion is **permanent and immediate** — no recovery period ([§5](05-mechanics.md) 5.12)~~ — **superseded:** no separate Delete account in v1 (#395; #365, 3 Sep): the row is drawn inert; the mechanism exists unreached in `account_wipe.dart`
- [x] ~~Deletion clears **everything**, including `brew`, the Saved shelf and Studio config~~ — **superseded:** same ruling; `deleteTombstone` clears both scopes
- [x] Drive both wipes from **one registry**, never a hand-list at the call site, and port the prototype's dev guard as a build-failing test ([§5](05-mechanics.md) 5.12) — **shipped:** `snapshot_scopes.dart` (`ClearedByReset` is the registry); `wipe_snapshot_test.dart`, `account_wipe_test.dart`
- [x] ~~Delete sheet warns rather than gates — no forced cancellation, exactly two actions~~ — **superseded:** same ruling (#395, #365)
- [x] ~~Ship the approved delete body: permanent + irreversible, then the App Store subscription warning ([§5](05-mechanics.md) 5.12)~~ — **superseded:** same ruling; the subscription warning is moot under ADR-0003
- [ ] Help FAQ (4 entries — the answers are spec) — **→** #531
- [ ] **About screen: 6 rows** — Privacy policy · Terms of use · Acknowledgements · Open-source licenses · Rate BrewPath · Say hello — **→** #532; Privacy and Terms are #448
- [ ] **Help screen: 2 contact rows** — Email support · Report a problem — **→** #531
- [ ] Real destinations for all 8 of the above: two legal URLs, an App Store review link, two mail composers, a licenses screen, an acknowledgements screen — every one is a `() => {}` stub today — **→** #448, #531, #532
- [ ] Privacy + Terms resolve to the **same** URLs from both About and the paywall — **→** #448
- [ ] Account and sync: status pill, plan line, "Sync over cellular" toggle, "This iPhone" row, Manage/Upgrade, Sign out — **→** #575
- [x] Profile: 7 tappable blocks (tree, streak, mastery rollup → Path practice, brew stat, Studio, Saved, Duel in v2) — a menu, not a dashboard ([§7](07-components.md) 7.2) — **shipped:** `lib/features/profile/presentation/profile_screen.dart`; the Duel is v2 (`09-deferred-v2.md`)
- [x] Mastery rollup hides entirely until at least one lesson has been played — **shipped:** `profile_screen.dart` (`rollup.scored > 0`)
- [ ] Local notifications for the daily reminder (8 preset times) — **→** #443, rows hidden meanwhile by PR #559

## Release hygiene
- [x] ~~Tweaks panel excluded from the store binary~~ — **superseded:** prototype-only: no tweaks panel exists in `lib/`
- [x] ~~Verify `isV1`-gated code paths are either removed or correctly dark~~ — **superseded:** prototype-only: `isV1` does not exist in `lib/`; the gated surfaces were never ported
- [x] ~~Drop the 8 dead props before porting — `ProfileTab` (`theme`, `onTheme`), `LearnTab` (6) ([§11](11-open-items.md))~~ — **superseded:** prototype-only: none of those props exists in `lib/`

---

← [Known open items](11-open-items.md) · [Contents](README.md) · [Suggested epics](13-epics.md) →
