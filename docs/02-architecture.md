# BrewPath — Architecture

## Layer Overview

```
┌─────────────────────────────────────────────────┐
│                  Presentation                   │
│  Widgets · Screens · Navigation (go_router)     │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│               State (Riverpod)                  │
│  Providers · Notifiers · AsyncNotifiers         │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│                   Domain                        │
│  Use-case logic · Business rules · Models       │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│                    Data                         │
│  Repositories · Content loading · Mappers       │
└──────────┬──────────────────────────┬───────────┘
           │                          │
┌──────────▼──────────┐   ┌───────────▼───────────┐
│  Local Persistence  │   │   Bundled Assets       │
│      (Drift)        │   │  assets/content/*.json │
└─────────────────────┘   └───────────────────────┘
```

Services (analytics, crash reporting, remote config, ads, payments) are injected via Riverpod providers and called from domain/presentation — never from widgets directly.

---

## State Management — Riverpod 3.x

**Why Riverpod:** Type-safe, compile-verified provider graph, first-class async support with `AsyncNotifier`, no `BuildContext` dependency for business logic, and Flutter Favorite status with active maintenance. It scales from simple computed values to complex async state without rewriting.

**Pattern used:**
- `@riverpod` annotation (riverpod_generator) for code generation
- `Notifier` for synchronous state (e.g., current tab, UI toggles)
- `AsyncNotifier` for async state (e.g., loading lessons from Drift, loading content from assets)
- `Provider` for pure computed values (e.g., total points derived from progress records)
- Providers scoped per feature — no global god-provider

**No ChangeNotifier, no BLoC, no setState in business logic screens.**

### Provider Naming Convention

```
// Feature providers live in their feature's domain/ folder
// lib/features/learn/domain/learn_providers.dart
// lib/features/progress/domain/progress_providers.dart
// lib/services/analytics/analytics_provider.dart
```

---

## Navigation — go_router 17.x

**Why go_router:** Flutter team–maintained, declarative, URL-based routing. Required for future web portability. Deep link support with minimal extra work.

### Route Structure

Top-level (outside the shell): `/loading`, `/welcome`, `/meet-roasty`,
`/onboarding/name`, `/course-complete`. The router's `redirect` owns the
onboarding gate — screens never duplicate gate→destination decisions (a
CLAUDE.md rule).

```
/ (AppShell — StatefulShellRoute, bottom nav)
├── /learn                                  (LearnScreen)
│   ├── module/:moduleId                    (ModuleDetailScreen)
│   ├── lesson/:lessonId                    (LessonScreen — root navigator, covers the shell)
│   │   └── complete                        (LessonCompletionScreen)
│   ├── module-summary/:moduleId            (ModuleSummaryScreen)
│   └── mini-game/:gameId                   (MiniGameIntroScreen)
│       └── play                            (MiniGamePlayerScreen)
├── /path                                   (PathScreen)
├── /cards                                  (CardsScreen)
│   └── :cardId                             (CardDetailScreen)
└── /profile                                (ProfileScreen)
    └── settings                            (SettingsScreen)
```

The catalog of every route (name + path) is
`lib/core/constants/app_routes.dart` — **regenerate this diagram from it, don't
edit the diagram alone**; the router itself is `lib/app/app_router.dart`.

---

## Feature-First Folder Structure

Each feature owns its own data, domain, and presentation layers. Shared code goes in `shared/` or `core/`.

**Rule:** If only one feature uses it, it lives inside that feature. If two or more features use it, it moves to `shared/` or `core/`.

---

## The type ladder — `AppText`

`lib/shared/theme/app_text.dart` is the only place a font size exists. Ten
steps — `hero · display · title · subtitle · heading · lead · body · support ·
label · micro` at 56 / 30 / 26 / 22 / 19 / 17 / 15 / 13 / 11 / 9.5 —
transcribed from the `--t-*` block of the design bundle.

**There is no `fontSize` parameter.** A size that is not a step cannot be asked
for: going off-ladder means editing the private rung table, which is visible in
a diff, rather than passing a number at a call site where nobody will see it.

Size, face (`AppFace`) and tracking are separate axes, because the design
uses one step with more than one of each. Each step defaults to the face the
design most often sets it in and accepts any other. Tracking is documented in
[the design system's Typography section](design/03-design-system.md#tracking--a-separate-axis-from-size).

Colour resolves in one order: an explicit `color`, then the step's role colour
from `mood`, then nothing — in which case the surrounding `DefaultTextStyle`
supplies it. Pass `mood` from `context.mood`; a painter with no context passes
`color` instead.

### Material's slots, resolved onto the ladder

`AppText.textTheme` maps **all fifteen** of Material's text slots, so stock
widgets and the ~70 call sites still reading `Theme.of(context).textTheme` are
set in the app's type rather than Roboto. None may be left out: `ThemeData`
merges a supplied `TextTheme` onto the default typography, so a null slot keeps
Roboto at Material's own size — off the ladder and outside the design's three
faces. Seven slots did exactly that, which is how a class whose whole point is
that going off-ladder must be a visible act let a large share of the app's text
off it invisibly.

**Role first, then the nearest size.** The role picks which rungs are eligible:
a `label*` slot may only land on a tracked rung (`label`, `micro`), because
0.14em is smallcaps spacing and would set body copy adrift; a `body*` slot may
only land on an untracked one. Within those, the slot takes the rung nearest
the Roboto size it used to resolve to — 57/45/36 · 32/28/24 · 22/16/14 ·
16/14/12 · 14/12/11 — so mapping a slot does not restyle screens nobody
touched. A tie goes downwards: `bodyLarge` 16 → `body`, `bodyMedium` and
`labelLarge` 14 → `support`, `headlineMedium` 28 → `title`, `labelMedium` 12 →
`label`.

Role is why the two 12px slots part company — `bodySmall` takes `support` (13,
untracked) and `labelMedium` takes `label` (11, tracked), where size alone
would have tied them. It is also why the three `display*` slots ignore the
nearest rung: 57 and 45 are nearest `hero`, but a screen title is a role and
`hero` is reserved for celebration numerals.

Two things the nearest size cannot decide:

- **Face.** A slot Material sets at weight 500 is a control, so it takes
  `AppFace.control` where its rung defaults to the 400 body face —
  `titleMedium`, `titleSmall`, `labelLarge`. `labelSmall` keeps mono: it is the
  numeral smallcaps.
- **Colour.** `support` and `label` are muted by role, which is right under a
  heading and wrong for a title, so `titleSmall` lands on the `support` rung in
  full-strength ink.

Fifteen slots over ten rungs means slots Material distinguishes share one —
`bodySmall` and `bodyMedium` both land on `support`. That is the ladder being
shorter than Material's scale, which is the point of it.

What this cannot fix is a call site reading the wrong slot: three read
`labelMedium` for sentence-case text ("3 of 5 saved") and so inherit the
smallcaps tracking the label rung owes its uppercase siblings. Those belong to
the per-screen work.

---

## Service Abstraction Pattern

Every external service (analytics, crash reporting, remote config, ads, payments) is accessed **only through an abstract interface**. Concrete implementations are injected via Riverpod providers.

```dart
// Abstract interface
abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> logScreen(String screenName);
}

// Concrete implementations
class FirebaseAnalyticsService implements AnalyticsService { ... }
class NoOpAnalyticsService implements AnalyticsService { ... }

// Provider — wired to the No-Op while kUseFirebase == false; activation
// swaps this one line (see lib/services/analytics/analytics_provider.dart)
@riverpod
AnalyticsService analyticsService(Ref ref) => const NoOpAnalyticsService();
```

This means:
- Tests can inject a `NoOpAnalyticsService` without touching Firebase
- Swapping providers (e.g., to Amplitude) requires changing one file

---

## Local Persistence Strategy — Drift 2.33.x

**Why Drift (SQLite) over Isar:** Isar 3.x development stalled and Isar 4 dropped its generator before reaching parity. Drift is actively maintained by the Flutter community, runs on SQLite (mature, ubiquitous, supported on iOS/Android/macOS/web), generates type-safe queries from `Table` definitions, and runs in-memory in tests via `NativeDatabase.memory()`. Tables: `UserSettings`, `ProgressSnapshots`, `AppInstalls`.

**Progress is one row, not a schema.** The three normalised tables the app opened with — per-lesson completions, a module-XP ledger and collected cards — were replaced by the progress snapshot in v6 and dropped in v13 ([#116](https://github.com/maximsan/brewpath/issues/116)). What is left on `user_settings` is device-local state only: appearance, haptics, sound, the onboarding and Tour bits, the learner's name and the reminder.

**Drift is not exposed directly to features.** All access goes through repository classes in `shared/repositories/` — `SettingsRepository`, `SnapshotRepository`, `InstallRepository`, each mapping Drift rows ↔ mutable DTOs in `shared/storage/`, plus `ContentRepository` for the bundled asset banks.

```
AppDatabaseService (shared/storage/app_database.dart)
  └── exposes the singleton AppDatabase via .instance
  └── repositories read it lazily — no constructor wiring
```

### Schema migrations

Each schema version is dumped to `drift_schemas/` and the generated harness
replays the whole chain in `test/database/` ([12](12-testing.md)).

**A step may only name things the current Dart definition still has.**
`addColumn`, `createTable` and `alterTable` all take a live `TableInfo`, so a
step written against a table that is later removed stops compiling — which is
why v13 deleted the v1 → v2 and v4 → v5 steps outright rather than rewriting
them. Dropping is the exception: `deleteTable` takes a table *name* and issues
`DROP TABLE IF EXISTS`, so a step can drop a table a given database never
created, and `dropColumn` names its column rather than reading it off a class.

That rules out the rebuild hazard the old chain carried
([#273](https://github.com/maximsan/brewpath/issues/273)):
`alterTable(TableMigration(...))` builds the new table from the **current**
definition and copies every column it does not list in `newColumns` out of the
old one, so a column added later fails every chained upgrade in a step that
predates it. No rebuild is left — every drop in the chain is by name.

---

## Offline-First Strategy

All MVP content is bundled as JSON files in `assets/content/`. No network call is required to load lessons.

User progress is stored entirely in Drift (SQLite) on-device. No sync in MVP.

The app must:
- Launch and function with Airplane Mode enabled
- Load all lesson content from bundled assets
- Read and write all progress from Drift

---

## Analytics Call Discipline

Analytics events are **never called directly in widget `build` methods**. They are called in:
- Provider notifiers (on state transitions)
- `initState` / `didChangeDependencies` via `ref.listen`
- Explicit user action handlers

This keeps widgets pure and tests clean.

---

## Still open (manual — user)

- [ ] Offline-first behavior confirmed on Simulator with Airplane Mode
