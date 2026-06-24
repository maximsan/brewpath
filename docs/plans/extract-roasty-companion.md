# Plan: Extract Roasty into a reusable Companion subsystem

> **Executor instructions**: This is a multi-phase plan. Phases are ordered and
> mostly sequential — finish and verify a phase before starting the next, and
> tick its checkboxes. The plan is resumable: the "Progress log" near the top is
> the source of truth for where work stands. If anything under a phase's **STOP
> conditions** occurs, stop and report — do not improvise.
>
> **Drift check (run first)**:
> `git diff --stat 1864d94..HEAD -- lib/features/onboarding/presentation/widgets lib/features/lessons`
> If the Roasty widget files or the lesson-completion flow changed since this plan
> was written, re-confirm the "Current state" sections against the live files
> before editing; on a material mismatch, treat it as a STOP condition.

## Status

- **Priority**: P2 (engagement feature; no current bug)
- **Effort**: L (split across 5 phases; each phase is S–M)
- **Risk**: MEDIUM (Phase 1 touches a working onboarding flow; later phases add screens)
- **Depends on**: none
- **Category**: feature / refactor
- **Planned at**: commit `1864d94`, 2026-06-17

## Progress log (update as you go — this is the resume point)

- [x] Phase 1 — Extract + behavior-neutral migration to `lib/features/companion/`
- [x] Phase 2 — Companion subsystem API (mood provider, handle, bubble, `animate` flag, lines JSON)
- [x] Phase 3 — Wire the lesson-completion screen to the companion
- [x] Phase 4 — Plain per-step XP toast (not the companion)
- [x] Phase 5 — Module-summary screen + `moduleComplete` moment + cards-by-module aggregation

> 2026-06-23 — Phases 1 & 2 done. Full suite green (168 tests), analyze clean,
> metrics 0. Pre-existing blockers fixed along the way: stubbed
> `CardDetailScreen` (favorite-cards WIP) and ran a clean `build_runner` regen
> after the riverpod 3.3.2 bump. `analysis_options.yaml` magic-number/metrics
> excludes were re-pointed to the new `companion/presentation/` paths.
>
> 2026-06-23 — ALL PHASES COMPLETE. Full suite green (174 tests), analyze clean,
> metrics 0, `dart format` clean. Notes:
> - Phase 3: the "last lesson of module" predicate already exists as
>   `LessonCompletionResult.moduleCompleted` (STOP condition resolved). The
>   completion-screen companion loops idle after its one-shot, so the three
>   first-completion widget tests run under forced reduced motion (a local
>   `_app` wrapper) — this also exercises the reduced-motion path.
> - Phase 4: XP is banked at completion, not per step (the anticipated STOP
>   condition). The toast shows `XpValues.perStep` (+10) on each correct
>   non-final answer as anticipatory feedback; the total still banks at the end.
> - Phase 5: added `moduleSummaryProvider(moduleId)` (cards-by-module +
>   module XP) and `ModuleSummaryScreen` on a new `/learn/module-summary/:id`
>   route; the completion screen's Continue routes there when
>   `moduleCompleted`, else to `/learn`. The inline "+25 XP · Module complete!"
>   text was kept on the completion screen (XP reconciliation) in addition to
>   the new recap screen.
>
> Remaining (was always out of scope / deferred): the near-end mid-lesson
> encouragement interstitial; per-question correct/wrong reactions; cardEarned
> mascot; a dedicated "happy" RoastyState pose (mood.happy currently → idle).

> When pausing mid-phase, append a dated note here describing the exact stopping
> point (which step, what's verified, what's pending) so the next session resumes
> cleanly.

## Why this matters

Roasty is the app mascot and the primary engagement device — for congratulation,
encouragement, and support. Today it is buried in `onboarding/` and used in only
two places. We want to reuse it across flows: as an **animated companion** at
milestone moments (Duolingo-style) and as a **static/talking** character in
smaller contexts. This plan extracts Roasty into a `Companion` subsystem with a
clean two-tier API and wires the first real engagement moments (lesson and module
completion), without regressing the existing onboarding behavior.

## Design decisions (the shared understanding behind this plan)

These were settled in a design interview; do not relitigate them mid-implementation.

1. **Subsystem, not just a moved widget.** New home: `lib/features/companion/`
   with `presentation/`, `application/`, `domain/`, `data/` subfolders.
2. **Two-tier architecture.**
   - **Low tier (skin):** `Roasty` — the raw `CustomPainter` renderer. Keeps the
     existing `RoastyState` enum (all 9 values incl. `sleep`/`awake`) and the
     `size` / `replayKey` / `sproutScale` props. Gains a new `animate` flag.
   - **High tier (role):** `Companion` widget + `CompanionController`, named
     abstractly so Roasty is a swappable skin.
3. **State model = two layers.**
   - `CompanionMood` — persistent, **reactive**, app-global. Driven **only by
     streak status** (`streakServiceProvider`). No event signals feed the mood.
   - `CompanionReaction` — transient, **imperative** one-shot; plays a
     non-looping animation, then reverts to the current mood.
   - The controller maps `mood` + active `reaction` → a concrete `RoastyState`.
   - **Reaction lifecycle:** a new reaction *interrupts* any in-flight one (no
     queue). On animation completion, revert to mood.
4. **Driving = hybrid, scoped.** Mood is one global provider; reactions are fired
   per-instance via a `CompanionHandle` the host holds, so a celebration only
   animates the companion that screen placed (no cross-firing).
5. **Static mode.** `Roasty(animate: false)` paints a single held frame, no
   `AnimationController`. **Reduced motion** (`MediaQuery.disableAnimations`)
   forces `animate: false` regardless of the prop.
6. **Talking mode.** `CompanionBubble` — a standalone composable wrapping *any*
   Roasty (static or animated) + bubble/tail. Usable without the controller.
7. **Speech content.** `assets/content/companion_lines.json`, keyed by event,
   each value a list of variants (random pick), loaded via the existing content
   pipeline; callers may pass an explicit `text` override.
8. **Naming.** Feature = `companion`. Engagement symbols are abstract
   (`Companion`, `CompanionController`, `CompanionMood`, `CompanionReaction`,
   `CompanionHandle`, `CompanionBubble`). The renderer stays `Roasty` /
   `RoastyState`.

### Wired vs unwired reactions (v1)

| Reaction         | v1 wiring                                                      |
|------------------|---------------------------------------------------------------|
| (mood) idle/happy| Global, streak-driven (Phase 2)                               |
| `lessonComplete` | Lesson-completion screen — mascot + final phrase + XP (Phase 3)|
| `moduleComplete` | New module-summary screen (Phase 5)                           |
| `correct`/`wrong`| **Unwired** — keep existing inline mini-game feedback         |
| `cardEarned`     | **Unwired** — card-reveal screen has no Roasty                |
| `xpGained`       | **Not the companion** — plain `XpGainToast` (Phase 4)         |

Unwired reaction values stay in the enum for future use.

## Current state (verified at planning time)

- Roasty lives in `lib/features/onboarding/presentation/widgets/`:
  `roasty.dart` (public widget + `_RoastyPainter`), `roasty_state.dart`
  (`enum RoastyState`), `roasty_body.dart`, `roasty_animation.dart`,
  `roasty_faces.dart`, `roasty_particles.dart`. ~900 lines total.
- The painters use **hardcoded colors — zero app-theme coupling.** Only the
  loading water-drop (`roasty_stage.dart`) references `AppColors`.
- Public API today: `Roasty({required state, size = 160, replayKey, sproutScale})`.
- **Only two consumers:**
  - `lib/features/onboarding/presentation/welcome/welcome_screen.dart:134` and
    `:153` — `Roasty(state: RoastyState.idle, ...)`.
  - `lib/features/onboarding/presentation/loading/widgets/roasty_stage.dart:93` —
    drives `state` + `sproutScale` from `WakePhase` for the wake-up cinematic.
- No other file imports `widgets/roasty.dart` or `widgets/roasty_state.dart`.
- Content pipeline: `lib/shared/repositories/content_repository.dart` loads
  `assets/content/{cards,lessons,modules}.json`; models are Freezed +
  json_serializable in `lib/shared/models/`. `pubspec.yaml` already bundles the
  whole `assets/content/` dir (line ~80).
- Lesson completion: `lib/features/lessons/presentation/lesson_completion_screen.dart`
  + `lesson_completion_body.dart` render `LessonCompletionReward`
  (`reviewResult` / `completion` / practice). Completion data is produced by
  `lib/features/lessons/domain/lesson_completion_service.dart`.
- Mini-games expose `onResult(MiniGameResult)` (`MiniGameIncorrect`/correct) —
  the right/wrong signal, intentionally left unwired to the companion.
- Module completion already exists as a concept: `XpService.moduleCompletionBonus`
  and `ModuleProgressRepository.isModuleXpAwarded` / `markModuleXpAwarded`.
- **No module-level "cards earned" aggregation exists** — Phase 5 must add one.
- No localization (`intl` / `flutter_localizations` absent) — plain strings.

## Conventions to honor (project rules — non-negotiable)

- Imports inside `lib/` use `package:coffee_quest/…`, never relative `../`.
- After adding/modifying any Freezed model, Riverpod provider, or Drift table:
  `dart run build_runner build` (no `--delete-conflicting-outputs`).
- Function-style `@riverpod` by default; class-based only when state is mutable
  (the `CompanionController` is mutable → class-based).
- No magic numbers (lint-enforced) — extract to `static const` / theme tokens.
- Pure animation/mapping math lives in sibling pure-Dart files (e.g.
  `companion_state_mapping.dart`), unit-testable without pumping widgets.
- Loading/empty/error and animated states get `Semantics` labels and respect
  `MediaQuery.disableAnimations`.
- Tests: unit in `test/unit/`, widget in `test/widget/`.
- `debugPrint` only behind dev guards; never `print`.

## Target structure

```
lib/features/companion/
  domain/
    roasty_state.dart            // enum RoastyState (moved; unchanged)
    companion_mood.dart          // enum CompanionMood { idle, happy }
    companion_reaction.dart      // enum CompanionReaction { correct, wrong,
                                 //   lessonComplete, moduleComplete, xpGained, cardEarned }
    companion_state_mapping.dart // pure: (mood, reaction?) -> RoastyState + helpers
    companion_line.dart          // Freezed model for companion_lines.json
  data/
    companion_lines_repository.dart  // loads/parses companion_lines.json, random pick
  application/
    companion_providers.dart     // companionMoodProvider (streak-driven),
                                 //   companionLinesProvider
  presentation/
    roasty.dart                  // raw renderer (moved) + new `animate` flag
    roasty_body.dart             // moved
    roasty_animation.dart        // moved
    roasty_faces.dart            // moved
    roasty_particles.dart        // moved
    companion.dart               // high-tier widget: watches mood, takes CompanionHandle
    companion_handle.dart        // per-instance reaction trigger
    companion_bubble.dart        // standalone speech-bubble composable

assets/content/companion_lines.json   // new content asset

lib/features/onboarding/presentation/loading/widgets/roasty_stage.dart
  // stays in onboarding; imports the moved raw Roasty, keeps driving it directly
```

---

## Phase 1 — Extract + behavior-neutral migration

**Goal:** move the 6 Roasty files to `lib/features/companion/` with **no
behavior change** and re-point the two existing consumers. Nothing new yet.

### Steps

1. Create `lib/features/companion/{domain,presentation}/` and move:
   - `roasty_state.dart` → `domain/roasty_state.dart`
   - `roasty.dart`, `roasty_body.dart`, `roasty_animation.dart`,
     `roasty_faces.dart`, `roasty_particles.dart` → `presentation/`
   Use `git mv` so history is preserved.
2. Update the `package:coffee_quest/features/onboarding/presentation/widgets/roasty_*`
   imports inside the moved files to the new
   `package:coffee_quest/features/companion/...` paths.
3. Re-point the two consumers:
   - `welcome_screen.dart` import → `companion/presentation/roasty.dart` (+ the
     `RoastyState` import → `companion/domain/roasty_state.dart`).
   - `roasty_stage.dart` import → same. It keeps driving `Roasty` **directly**
     (state + `sproutScale`); do not route it through the controller.
4. Delete the now-empty `onboarding/presentation/widgets/` dir if nothing else
   lives there (verify with `ls`).
5. Move any existing Roasty tests under `test/` to mirror the new path (search
   `grep -rl Roasty test`).

### Verify (Phase 1)

- [x] `grep -rn "onboarding/presentation/widgets/roasty" lib test` → no matches.
- [x] `flutter analyze` → "No issues found!"
- [x] `dart run dart_code_linter:metrics analyze lib --set-exit-on-violation-level=warning` → exit 0.
- [x] `flutter test` → all pass.
- [ ] App runs; welcome screen and the onboarding loading wake-up animation look
      and behave **identically** (manual check — see Test Plan). ⟵ MANUAL, not run
- [x] `git diff` shows pure moves + import path edits, no logic changes.

### STOP conditions (Phase 1)

- A third consumer of Roasty exists that the "Current state" survey missed —
  re-survey before moving.
- The wake-up animation visibly changes — revert and investigate before
  proceeding; this phase must be behavior-neutral.

---

## Phase 2 — Companion subsystem API

**Goal:** build the high-tier surface. No new call sites wired yet (welcome and
wake-up keep using the raw widget).

### Steps

1. **`animate` flag (raw widget).** Add `this.animate = true` to `Roasty`. When
   `false`, do **not** create/run the `AnimationController`; paint a single held
   frame (a representative `t` per state — for looping states use a calm pose).
   In `build`/`initState`, treat `animate && !MediaQuery.disableAnimations` as
   the effective flag so **reduced motion forces static**. Keep the existing
   animated path otherwise. Extract the chosen frozen-frame `t` selection into a
   pure helper in `roasty_animation.dart`.
2. **Enums.** `CompanionMood { idle, happy }`,
   `CompanionReaction { correct, wrong, lessonComplete, moduleComplete, xpGained, cardEarned }`.
3. **Pure mapping.** `companion_state_mapping.dart`:
   `RoastyState roastyStateFor({required CompanionMood mood, CompanionReaction? reaction})`
   — reaction (if present) wins and maps to the matching `RoastyState`; otherwise
   mood maps (`idle`→`idle`, `happy`→a content idle/happy pose). Pure, unit-tested.
4. **Mood provider.** `companionMoodProvider` (`@riverpod`, function-style):
   watches `streakServiceProvider`; active streak → `CompanionMood.happy`, else
   `idle`. Keep the streak→mood threshold a named `static const`.
5. **Content model + repository.**
   - `companion_line.dart` — Freezed model (e.g. a map of event-key → `List<String>`
     wrapper). Run build_runner.
   - `companion_lines.json` in `assets/content/` — keys for the wired events
     (`lessonComplete`, `moduleComplete`) at minimum; add the rest as desired.
   - `companion_lines_repository.dart` + `companionLinesProvider` — load/parse
     and expose `lineFor(CompanionReaction)` returning a random variant. Reuse
     the loading approach in `content_repository.dart`.
6. **CompanionHandle.** A small `ChangeNotifier`/`Listenable` (or a controller
   object) the host constructs and passes to `Companion`; `handle.react(reaction)`
   sets the active reaction. Disposed by the host.
7. **Companion widget.** `Companion({required handle, size, ...})`: watches
   `companionMoodProvider`, listens to the handle, computes the effective
   `RoastyState` via the pure mapping, renders `Roasty`. On a one-shot reaction
   animation completing, clears the reaction → reverts to mood. New reaction
   interrupts an in-flight one.
8. **CompanionBubble.** `CompanionBubble({required child, required text, ... })`
   — positions a bubble + tail around `child` (any `Roasty`). Bubble text gets a
   `Semantics` label. No controller dependency.

### Verify (Phase 2)

- [x] Unit tests: `roastyStateFor` mapping (mood-only, reaction-wins, each
      reaction), mood derivation from streak, `lineFor` returns a valid variant.
- [x] Widget test: `Roasty(animate: false)` mounts no running controller (e.g.
      `tester.pump` with no scheduled frames / golden of a static frame), and a
      `Companion` reverts to mood after a reaction completes.
- [x] Widget test: with `MediaQuery(disableAnimations: true)`, `Roasty(animate: true)`
      renders statically.
- [x] `flutter analyze`, metrics gate, `flutter test` all green.
- [x] build_runner output regenerated; no stale `.g.dart` / `.freezed.dart`.
      (Not yet git-committed — committing is a separate user step.)

### STOP conditions (Phase 2)

- `streakServiceProvider`'s shape differs from what the mood provider assumes —
  inspect and adapt; don't guess the streak value semantics.

---

## Phase 3 — Wire the lesson-completion screen

**Goal:** the lesson-completion screen shows the companion + a `lessonComplete`
line + the total XP (XP total already rendered by the screen; we add the mascot
and line). This is the first real engagement moment.

### Steps

1. In `lesson_completion_screen.dart` (the stateful host, not the pure body),
   create + own a `CompanionHandle`; fire `react(CompanionReaction.lessonComplete)`
   when the completion result is shown (and it is NOT the module's last lesson —
   that path is Phase 5).
2. Place a `Companion` in `lesson_completion_body.dart`'s completion layout as the
   hero, with a `CompanionBubble` carrying the line from `companionLinesProvider`.
   Keep `LessonCompletionBody` otherwise pure — pass the handle/line in via
   constructor params rather than reading providers inside the pure body.
3. Leave the `reviewResult` and practice branches unchanged unless trivially
   appropriate (out of scope — confirm with the operator before adding mascots
   there).

### Verify (Phase 3)

- [x] Widget test: completing a (non-final) lesson renders the `Companion` and a
      bubble line; the reaction reverts to mood after playing.
- [ ] Manual: finish a lesson → mascot animates `lessonComplete`, shows a line,
      XP total still correct; Continue still routes to `/learn`. ⟵ MANUAL, not run
- [x] `flutter analyze`, metrics, `flutter test` green.

### STOP conditions (Phase 3)

- The completion screen can't tell whether a lesson is the module's last from
  available data — resolve the "last lesson of module" predicate here (it's also
  needed by Phase 5) before wiring; do not hardcode.

---

## Phase 4 — Plain per-step XP toast (not the companion)

**Goal:** a transient "+N XP" bubble that pops up and fades on a scoring step.
**No Roasty** — keep it decoupled from the companion.

### Steps

1. Build `XpGainToast` (a small animated chip: amount + XP icon, rises and fades)
   in the lessons/mini-games presentation layer. Respect reduced motion (no
   movement, brief fade or instant) and add a `Semantics` live label ("+10 XP").
2. Trigger it on the step-scoring signal in the lesson/mini-game runner (where
   XP is awarded per step). Reuse `XpValues` constants; no magic numbers.

### Verify (Phase 4)

- [x] Widget test: toast appears on an XP-awarding step and disposes itself.
- [ ] Manual: answering a scoring step shows "+N XP" floating up and fading; no
      mascot appears for it. ⟵ MANUAL, not run
- [x] Analyze / metrics / tests green.

### STOP conditions (Phase 4)

- There is no clean per-step XP-award hook (XP only computed at lesson end) —
  report; the toast may need a different trigger point than assumed.

---

## Phase 5 — Module-summary screen + `moduleComplete`

**Goal:** after the **last lesson of a module** completes, show a dedicated
module-summary screen with a `moduleComplete` mascot moment, a recap (total
module XP incl. the completion bonus), and the cards earned in that module.

### Steps

1. **Cards-by-module aggregation (new data).** Add a query/provider returning the
   cards earned within a module (the recap needs it; it does not exist today).
   Inspect `card_repository.dart` + `module_progress_repository.dart` and the
   card↔module relationship in the content models before designing the query.
2. **Module-XP total.** Reuse `XpService.moduleCompletionBonus` +
   per-lesson XP for the module to present a module total.
3. **Routing.** After the last lesson's completion screen, route to a new
   `ModuleSummaryScreen` (add a named route to `lib/app/app_router.dart`; navigate
   by `name`, never a hardcoded path). The Phase-3 completion screen should fire
   `lessonComplete`; the module-summary screen fires `moduleComplete`.
4. **Screen.** `ModuleSummaryScreen` renders a `Companion` (`moduleComplete`
   reaction + line), the XP recap, and the earned cards. Honor loading/empty/error
   + `Semantics` + reduced motion.

### Verify (Phase 5)

- [x] Unit test: cards-by-module aggregation returns the right set.
- [x] Widget test: finishing a module's last lesson navigates completion →
      module summary; the summary shows `moduleComplete` mascot, XP total, cards.
- [ ] Manual: complete a module end-to-end; sequence and content correct; back to
      `/learn` afterwards. ⟵ MANUAL, not run
- [x] Analyze / metrics / tests green.

### STOP conditions (Phase 5)

- The content model has no reliable card↔module mapping — report; the recap's
  "cards earned in module" can't be built without it.
- "Last lesson of module" predicate (shared with Phase 3) is ambiguous — resolve
  once and reuse.

---

## Git workflow

- Branch off `main`: e.g. `git checkout -b feat/companion-subsystem`.
- One commit per phase (or per logical sub-step), conventional-commit style:
  - Phase 1: `refactor: extract Roasty into companion feature (no behavior change)`
  - Phase 2: `feat: companion subsystem API (mood, reactions, bubble, static mode)`
  - Phase 3: `feat: show companion on lesson completion`
  - Phase 4: `feat: floating XP gain toast`
  - Phase 5: `feat: module-summary screen with module-complete moment`
- Do **not** push or open a PR unless the operator explicitly asks.
- Run `/changelog` after meaningful phases to draft Unreleased entries.

## Test Plan (overall)

- **Phase 1 is the riskiest for regressions** and is config/move-only at the
  behavior level: the gate is the **existing** suite passing plus a manual check
  that welcome + the onboarding wake-up cinematic are visually unchanged.
- New unit tests: pure mapping (`roastyStateFor`), mood-from-streak, line picking,
  cards-by-module aggregation.
- New widget tests: static render (incl. reduced motion), reaction→mood revert,
  lesson-completion mascot, module-summary navigation + content, XP toast.
- No new tests for unwired reactions (`correct`/`wrong`/`cardEarned`/companion-`xpGained`).

## Out of scope (do NOT build under this plan)

- Per-question `correct`/`wrong` mascot reactions (keep inline mini-game feedback).
- Roasty on the card-reveal screen (`cardEarned` stays unwired).
- A `companion`-based XP reaction (Phase 4's toast is plain, mascot-free).
- The near-end mid-lesson encouragement interstitial — **deferred to a follow-up**
  (adds lesson-runner branching + a "how close is close" rule).
- Time-of-day mood, multi-instance simultaneous reactions, localization of lines.

## Maintenance notes

- If the mascot art is ever replaced, only the `Roasty`/`RoastyState` skin and
  `companion_state_mapping.dart` should change — the `Companion*` engagement API
  stays. That separation is the point of the naming split.
- New engagement moments: add a `CompanionReaction` value + a `companion_lines.json`
  key, place a `Companion`/`CompanionBubble`, and fire `handle.react(...)`. Avoid
  feeding event signals into `companionMoodProvider` (keep mood ambient/slow).
- `companion_lines.json` is content-editable without a code change (already
  bundled via `assets/content/`). Keep variants short and on-brand.
