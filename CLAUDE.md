# Coffee Quest — CLAUDE.md

## Project Layout

```
brewpath/               ← git root, CLAUDE.md lives here
├── coffee_quest/       ← Flutter app; run ALL flutter/dart commands from here
├── docs/               ← Architecture and task-plan docs
└── .claude/            ← Claude Code project settings
```

## Architecture

| Concern | Package | Notes |
|---|---|---|
| State | flutter_riverpod 2.x + riverpod_generator | `@riverpod` annotation; ref type is `{ProviderName}Ref` |
| Navigation | go_router 17.x | `StatefulShellRoute` with 4 branches: `/learn`, `/path`, `/cards`, `/profile` |
| Persistence | Drift (SQLite) 2.31.x | Offline-first; tables + `AppDatabase` in `shared/storage/app_database.dart`. Repos map Drift rows ↔ mutable DTOs in `shared/storage/*_record.dart`. (Replaced abandoned Isar 3.x.) |
| Content models | Freezed + json_serializable | Loaded from `assets/content/*.json` at startup |
| Payments | `NoOpPaymentsService` stub | Real `in_app_purchase` wired in Phase 9 |
| Ads | `NoOpAdsService` stub | Real AdMob wired in Phase 9 |
| Analytics / Crash | `NoOpAnalyticsService` stub | Firebase wired in Phase 8 |

## Critical Rules

- **Firebase is Phase 8+.** Phase 8 added the `firebase_*` deps and service code, but it stays **inactive** behind `kUseFirebase` in `lib/core/config/firebase_flags.dart` (currently `false`). All Firebase access is behind the `AnalyticsService` / `CrashReportingService` / `RemoteConfigService` abstractions — never call `Firebase*.instance` from feature code. Activation (real project, `flutterfire configure`, plist, flip the flag + three provider one-liners) is a manual user step.
- **Package imports within `lib/`.** Use `package:coffee_quest/…` instead of `../…` for all imports inside the `lib/` directory.
- **Regenerate after model changes.** Run `dart run build_runner build` whenever a Freezed model, Riverpod provider, or Drift table is added or modified. (build_runner 2.15 auto-resolves conflicts; the old `--delete-conflicting-outputs` flag was removed.)
- **No Firebase before Phase 8.** This rule is listed twice intentionally. (Phase 8 is now reached; Firebase code exists but is gated off by `kUseFirebase`.)

## Phase Status (updated 2026-05-19)

| Phase | Status | Description |
|---|---|---|
| 0 | ✅ Done | Prerequisites verified |
| 1 | ✅ Done | Project scaffold, routing stub, theme |
| 2 | ✅ Done | Content models, JSON assets, ContentRepository |
| 3 | ✅ Done | Drift persistence, repositories, providers |
| 4 | ✅ Done | Domain logic: XP/streak/completion services, providers |
| 5 | ✅ Done | Navigation: StatefulShellRoute app shell, 4 tabs, analytics observer |
| 6 | ✅ Done | Feature screens: Learn/Path/Cards/Profile + lock/settings/version providers |
| 7 | ✅ Done | Lesson runner, 4 mini-games, completion screen, immersive lesson route |
| 8 | 🚧 Code complete | Firebase services (Analytics/Crashlytics/Remote Config) behind abstractions; **activation pending user setup** (`kUseFirebase`) |
| 9–11 | ⏳ Pending | See `docs/16-claude-code-task-plan.md` |

## Common Commands (run from `coffee_quest/`)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter test test/unit/<file>
flutter test test/widget/<file>
flutter run -d "iPhone 16 Pro"
flutter build ios --release --no-codesign
```

### DB tests

Drift tests use an in-memory database (`AppDatabase(NativeDatabase.memory())`),
so no native binary copy is needed (the old `libisar.dylib` step is gone).

## Code Conventions

- **Imports:** always `package:coffee_quest/…` within `lib/`; never relative `../` imports
- **Comments:** TSDoc only for complex logic or third-party integrations; skip self-evident code
- **Models:** Freezed for all content DTOs; Drift `Table` classes for persisted records
- **Providers:** function-style `@riverpod` only; class-based `@riverpod` only when state is mutable
- **Tests:** unit tests in `test/unit/`; widget tests in `test/widget/`; integration tests in `integration_test/`
- **No print statements** — use `debugPrint` only in development guards; never in production paths
