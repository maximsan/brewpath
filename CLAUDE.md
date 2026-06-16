# Coffee Quest — CLAUDE.md

## Project Layout

```
brewpath/               ← git root, CLAUDE.md lives here
├── coffee_quest/       ← Flutter app; run ALL flutter/dart commands from here
├── docs/               ← Architecture and task-plan docs
└── .claude/            ← Claude Code project settings
```

## Learning track

A hands-on, learn-by-doing Flutter course for this app lives in
[`learning/`](learning/). When the user asks to "continue the lesson" /
"continue the Flutter onboarding", read
[`learning/README.md`](learning/README.md) (teaching contract) and
[`learning/curriculum.md`](learning/curriculum.md) (current step, marked 👉)
first, then resume.

## Architecture

| Concern           | Package                                   | Notes                                                                                                                                                                              |
| ----------------- | ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| State             | flutter_riverpod 3.x + riverpod_generator | `@riverpod` annotation; ref type is `Ref`                                                                                                                                          |
| Navigation        | go_router 17.x                            | `StatefulShellRoute` with 4 branches: `/learn`, `/path`, `/cards`, `/profile`                                                                                                      |
| Persistence       | Drift (SQLite) 2.33.x                     | Offline-first; tables + `AppDatabase` in `shared/storage/app_database.dart`. Repos map Drift rows ↔ mutable DTOs in `shared/storage/*_record.dart`. (Replaced abandoned Isar 3.x.) |
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
- **At release time:** run `node coffee_quest/tool/release.js` — it stamps the
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
- **Lints:** `very_good_analysis` baseline + `riverpod_lint` and `dart_code_linter` active via the `plugins:` block in `analysis_options.yaml` (native analysis_server_plugins — not `custom_lint`)

## Code Quality Rules

Magic numbers and per-function size/complexity are now **lint-enforced** by
`dart_code_linter` (config + exclusions in `analysis_options.yaml`).
**Identifier length** and **per-file size** have no rule, so they stay
conventions — follow every rule below on each new or modified file:

- **No magic numbers** (lint-enforced). Extract meaningful or repeated literals
  to named `static const` or theme tokens (`AppSpacing`, `AppColors`,
  `AppTypography`); only `0`/`1`/`2` inline, with intent names (`_stageSize`),
  never bare numbers in the widget tree.
- **Descriptive names.** No single-letter identifiers except trivial loop
  indices (`i`). Animation/controller values are `progress`, not `t`; phase
  fractions get real names (`normalizedPhase`, not `p`).
- **Small files & classes.** Per-file size stays a convention (soft cap ≈ 250
  lines/file — no rule); per-function size/complexity is lint-enforced. Split a
  file that grows multiple `State`/widget classes or mixes UI with logic; keep
  `build()` declarative — push math and derivations into named helpers.
- **Extract pure helpers.** Animation math, mapping, and derivations live in a
  sibling pure-Dart file (e.g. `*_animation.dart`) as named top-level functions,
  so they are unit-testable without pumping widgets.
- **Navigation policy lives in the router.** Screens don't duplicate
  gate→destination decisions; the `appRouter` redirect owns them. Navigate by
  route `name` (`context.goNamed('welcome')`), never by hardcoded path strings.
- **Debug toggles via `bool.fromEnvironment`,** never a hand-flipped `const`, so
  release builds are safe by construction. Catalogue each in the README
  _Run-time flags_ table.
- **Loading/empty/error states** get `Semantics` labels and respect
  `MediaQuery.disableAnimations` (reduced motion).
