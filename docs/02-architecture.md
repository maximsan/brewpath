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
- `Provider` for pure computed values (e.g., total XP derived from progress records)
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

### Shell Route Structure

```
/ (AppShell — bottom nav)
├── /learn              (LearnScreen)
│   └── /learn/module/:moduleId        (ModuleDetailScreen)
│       └── /learn/lesson/:lessonId    (LessonScreen)
├── /path               (PathScreen)
├── /cards              (CardsScreen)
│   └── /cards/:cardId                 (CardDetailScreen)
└── /profile            (ProfileScreen)
```

`AppShell` is a `StatefulShellRoute` — it preserves tab scroll position and state when switching tabs.

### Route Definition Location

```
lib/app/app_router.dart
```

All named route constants live in `lib/core/constants/route_names.dart`.

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

// Concrete implementation
class FirebaseAnalyticsService implements AnalyticsService { ... }

// Provider
@riverpod
AnalyticsService analyticsService(Ref ref) => FirebaseAnalyticsService();
```

This means:
- Tests can inject a `NoOpAnalyticsService` without touching Firebase
- Swapping providers (e.g., to Amplitude) requires changing one file

---

## Local Persistence Strategy — Drift 2.30.x

**Why Drift (SQLite) over Isar:** Isar 3.x development stalled and Isar 4 dropped its generator before reaching parity. Drift is actively maintained by the Flutter community, runs on SQLite (mature, ubiquitous, supported on iOS/Android/macOS/web), generates type-safe queries from `Table` definitions, and runs in-memory in tests via `NativeDatabase.memory()`. Tables: `ProgressRecords`, `CardRecords`, `UserSettings`.

**Drift is not exposed directly to features.** All access goes through repository classes in `shared/repositories/`.

```
AppDatabaseService (shared/storage/app_database.dart)
  └── exposes the singleton AppDatabase via .instance
  └── repositories read it lazily — no constructor wiring

ProgressRepository (shared/repositories/progress_repository.dart)
  └── reads/writes ProgressRecord (mutable DTO ↔ Drift row)

CardRepository (shared/repositories/card_repository.dart)
  └── reads/writes CardRecord

SettingsRepository (shared/repositories/settings_repository.dart)
  └── reads/writes UserSettingsRecord (singleton row id=1)
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

## Definition of Done

- [x] Architecture diagram is understood by the developer
- [x] Riverpod provider pattern is established and documented
- [x] go_router shell route structure is finalized
- [x] Drift repository pattern is established (no raw Drift access in feature code)
- [x] All services (analytics, crash, remote config, ads, payments) have abstract interfaces
- [ ] Offline-first behavior is confirmed on Simulator with Airplane Mode
- [x] Analytics events are never in widget `build` methods
