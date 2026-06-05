# Coffee Quest — CLAUDE.md

## Project Layout

```
brewpath/               ← git root, CLAUDE.md lives here
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
| Payments          | `NoOpPaymentsService` stub                | Real `in_app_purchase` wired in Phase 9                                                                                                                                            |
| Ads               | `NoOpAdsService` stub                     | Real AdMob wired in Phase 9                                                                                                                                                        |
| Analytics / Crash | `NoOpAnalyticsService` stub               | Firebase wired in Phase 8                                                                                                                                                          |

## Critical Rules

- **Firebase is Phase 8+.** Phase 8 added the `firebase_*` deps and service code, but it stays **inactive** behind `kUseFirebase` in `lib/core/config/firebase_flags.dart` (currently `false`). All Firebase access is behind the `AnalyticsService` / `CrashReportingService` / `RemoteConfigService` abstractions — never call `Firebase*.instance` from feature code. Activation (real project, `flutterfire configure`, plist, flip the flag + three provider one-liners) is a manual user step.
- **Package imports within `lib/`.** Use `package:coffee_quest/…` instead of `../…` for all imports inside the `lib/` directory.
- **Regenerate after model changes.** Run `dart run build_runner build` whenever a Freezed model, Riverpod provider, or Drift table is added or modified. (build_runner 2.15 auto-resolves conflicts; the old `--delete-conflicting-outputs` flag was removed.)

## Change History

Major app changes and the completed build milestones (Phases 0–11) live in
[`docs/CHANGELOG.md`](docs/CHANGELOG.md). The workflow is documented at the top
of that file:

- **After meaningful work:** run the `/changelog` skill — it drafts Unreleased
  entries from the actual code diffs for review.
- **At release time:** run `coffee_quest/tool/release.sh` — it stamps the
  version + date, bumps `pubspec.yaml`, and tags the release.

## Common Commands (run from `coffee_quest/`)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter test test/unit/<file>
flutter test test/widget/<file>
flutter run -d "iPhone 17"
flutter build ios --release --no-codesign
```

### DB tests

Drift tests use an in-memory database (`AppDatabase(NativeDatabase.memory())`),
so no native binary copy is needed (the old `libisar.dylib` step is gone).

### iOS native build

The iOS project uses **Swift Package Manager**, not CocoaPods — there is no
`ios/Podfile` and no `pod install` step. Plugins resolve as Swift Packages
during `flutter build ios`. The iOS deployment target is **16.0** (required by
the Firebase SPM packages). CI builds the app on a macOS runner via the
`iOS build` job in `.github/workflows/ci.yml`.

## Code Conventions

- **Imports:** always `package:coffee_quest/…` within `lib/`; never relative `../` imports
- **Comments:** TSDoc only for complex logic or third-party integrations; skip self-evident code
- **Models:** Freezed for all content DTOs; Drift `Table` classes for persisted records
- **Providers:** function-style `@riverpod` only; class-based `@riverpod` only when state is mutable
- **Tests:** unit tests in `test/unit/`; widget tests in `test/widget/`; integration tests in `integration_test/`
- **No print statements** — use `debugPrint` only in development guards; never in production paths

## Code Quality Rules

These are not all lint-enforceable (the stock Dart linter has no rule for magic
numbers, identifier length, or file/class size, and `custom_lint`-based tooling
is blocked here — see the `pubspec.yaml` lint TODO). Follow them on every new or
modified file:

- **No magic numbers.** Extract meaningful or repeated literals to named
  `static const` or theme tokens (`AppSpacing`, `AppColors`, `AppTypography`).
  Only `0`/`1` may appear inline. Animation/layout constants get intent names
  (`_stageSize`, `_captionGap`), not bare numbers in the widget tree.
- **Descriptive names.** No single-letter identifiers except trivial loop
  indices (`i`). Animation/controller values are `progress`, not `t`; phase
  fractions get real names (`normalizedPhase`, not `p`).
- **Small files & classes.** Soft cap ≈ 250 lines/file. When a file grows
  multiple `State`/widget classes or mixes UI with logic, split it. Keep
  `build()` declarative — push math and derivations into named helpers.
- **Extract pure helpers.** Animation math, mapping, and derivations live in a
  sibling pure-Dart file (e.g. `*_animation.dart`) as named top-level functions,
  so they are unit-testable without pumping widgets.
- **Navigation policy lives in the router.** Screens don't duplicate
  gate→destination decisions; the `appRouter` redirect owns them. Navigate by
  route `name` (`context.goNamed('welcome')`), never by hardcoded path strings.
- **Debug toggles via `bool.fromEnvironment`,** never a hand-flipped `const`, so
  release builds are safe by construction.
- **Loading/empty/error states** get `Semantics` labels and respect
  `MediaQuery.disableAnimations` (reduced motion).
