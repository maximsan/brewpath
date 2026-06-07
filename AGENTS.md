# Coffee Quest — AGENTS.md

## Project Layout

```
brewpath/               ← git root, AGENTS.md lives here
├── coffee_quest/       ← Flutter app; run ALL flutter/dart commands from here
├── docs/               ← Architecture and task-plan docs
└── .claude/            ← Claude Code project settings
```

## Architecture

| Concern           | Package                                   | Notes                                                                                                                                                                              |
| ----------------- | ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| State             | flutter_riverpod 2.x + riverpod_generator | `@riverpod` annotation; ref type is `{ProviderName}Ref`                                                                                                                            |
| Navigation        | go_router 17.x                            | `StatefulShellRoute` with 4 branches: `/learn`, `/path`, `/cards`, `/profile`                                                                                                      |
| Persistence       | Drift (SQLite) 2.31.x                     | Offline-first; tables + `AppDatabase` in `shared/storage/app_database.dart`. Repos map Drift rows ↔ mutable DTOs in `shared/storage/*_record.dart`. (Replaced abandoned Isar 3.x.) |
| Content models    | Freezed + json_serializable               | Loaded from `assets/content/*.json` at startup                                                                                                                                     |
| Payments          | `NoOpPaymentsService` stub                | Real `in_app_purchase` deferred                                                                                                                                                   |
| Ads               | `NoOpAdsService` stub                     | Real AdMob deferred                                                                                                                                                               |
| Analytics / Crash | Firebase behind abstractions (gated off)  | Inactive until `kUseFirebase` is flipped                                                                                                                                          |

## Critical Rules

- **Firebase is gated off.** The `firebase_*` deps and service code exist, but
  stay **inactive** behind `kUseFirebase` in `lib/core/config/firebase_flags.dart`
  (currently `false`). All Firebase access is behind the `AnalyticsService` /
  `CrashReportingService` / `RemoteConfigService` abstractions — never call
  `Firebase*.instance` from feature code. Activation (real project,
  `flutterfire configure`, plist, flip the flag + three provider one-liners) is a
  manual user step.
- **Package imports within `lib/`.** Use `package:coffee_quest/…` instead of
  `../…` for all imports inside the `lib/` directory.
- **Regenerate after model changes.** Run `dart run build_runner build` whenever
  a Freezed model, Riverpod provider, or Drift table is added or modified.
  (build_runner 2.15 auto-resolves conflicts; the old
  `--delete-conflicting-outputs` flag was removed.)

## Change History

Major app changes and the completed build milestones (Phases 0–11) live in
[`docs/CHANGELOG.md`](docs/CHANGELOG.md). The workflow is documented at the top
of that file:

- **After meaningful work:** run the `/changelog` skill — it drafts Unreleased
  entries from the actual code diffs for review.
- **At release time:** run `coffee_quest/tool/release.sh` — it stamps the
  version + date, bumps `pubspec.yaml`, and tags the release.

## Development commands

Run all flutter/dart commands from `coffee_quest/`. The full command list with
explanations — plus test and iOS/SPM build notes — lives in
[`coffee_quest/README.md`](coffee_quest/README.md).

## Code Conventions

- **Imports:** always `package:coffee_quest/…` within `lib/`; never relative `../` imports
- **Comments:** TSDoc only for complex logic or third-party integrations; skip self-evident code
- **Models:** Freezed for all content DTOs; Drift `Table` classes for persisted records
- **Providers:** function-style `@riverpod` only; class-based `@riverpod` only when state is mutable
- **Tests:** unit tests in `test/unit/`; widget tests in `test/widget/`; integration tests in `integration_test/`
- **No print statements** — use `debugPrint` only in development guards; never in production paths
