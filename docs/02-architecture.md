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

**Why Drift (SQLite) over Isar:** Isar 3.x development stalled and Isar 4 dropped its generator before reaching parity. Drift is actively maintained by the Flutter community, runs on SQLite (mature, ubiquitous, supported on iOS/Android/macOS/web), generates type-safe queries from `Table` definitions, and runs in-memory in tests via `NativeDatabase.memory()`. Tables: `ProgressRecords`, `ModuleProgressRecords`, `CardRecords`, `UserSettings`, `ProgressSnapshots`.

**Drift is not exposed directly to features.** All access goes through repository classes in `shared/repositories/` — one per table (`ProgressRepository`, `ModuleProgressRepository`, `CardRepository`, `SettingsRepository`, `SnapshotRepository`), each mapping Drift rows ↔ mutable DTOs in `shared/storage/*_record.dart`, plus `ContentRepository` for the bundled asset banks.

```
AppDatabaseService (shared/storage/app_database.dart)
  └── exposes the singleton AppDatabase via .instance
  └── repositories read it lazily — no constructor wiring
```

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
