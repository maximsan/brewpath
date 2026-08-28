# BrewPath — CLAUDE.md

## Project Layout

The Flutter app is **at the git root** — there is no nested app directory.

```
brewpath/               ← git root, CLAUDE.md lives here
├── lib/                ← Flutter app source (package: brew_path)
├── test/               ← unit + widget tests
├── integration_test/   ← integration tests
├── assets/             ← bundled content, fonts, images
├── ios/                ← iOS runner (SPM-only; no Podfile)
├── tool/               ← release + maintenance scripts
├── prototype/          ← design source (React prototype, not built)
├── docs/               ← architecture, design reference and task-plan docs
├── learning/           ← hands-on Flutter course for this app
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
| Payments          | `NoOpPaymentsService` stub                | Real `in_app_purchase` deferred                                                                                                                                                    |
| Ads               | `NoOpAdsService` stub                     | Real AdMob deferred                                                                                                                                                                |
| Analytics / Crash | Firebase behind abstractions (gated off)  | Inactive until `kUseFirebase` is flipped                                                                                                                                           |

## Critical Rules

- **Doc map and source precedence: [`docs/README.md`](docs/README.md).** Read
  it before resolving any documentation conflict. Any doc change must leave
  every link, path, name and `§`-reference that touches it still resolving —
  verified in the same PR.
- **Firebase is gated off.** The `firebase_*` deps and service code exist, but
  stay **inactive** behind `kUseFirebase` in `lib/core/config/firebase_flags.dart`
  (currently `false`). All Firebase access is behind the `AnalyticsService` /
  `CrashReportingService` / `RemoteConfigService` abstractions — never call
  `Firebase*.instance` from feature code. Activation (real project,
  `flutterfire configure`, plist, flip the flag + three provider one-liners) is a
  manual user step.
- **Package imports within `lib/`.** Use `package:brew_path/…` instead of
  `../…` for all imports inside the `lib/` directory.
- **Regenerate after model changes.** Run `dart run build_runner build` whenever
  a Freezed model, Riverpod provider, or Drift table is added or modified
  (flags and behaviour: README _Development commands_).
- **Scope:** [`prototype/v1 Readiness Audit.html`](prototype/v1%20Readiness%20Audit.html)
  rules what ships in v1 and what defers to v2 — read it before calling anything
  missing, because a v2 screen absent from the app is correct. The prototype's
  other `.html` files carry design rulings the `.jsx` does not.

- **`prototype/` is read-only to agents.** It is the design source the app is
  built *against*, so an edit there moves the thing we are measuring ourselves
  by. Findings about the prototype — "this is wrong", "do not port this" — go in
  the issue that owns them or in [`docs/design/`](docs/design/README.md), never
  as an annotation in the source. An agent edits `prototype/` only when an issue
  rules it may (see [#196](https://github.com/maximsan/brewpath/issues/196) for
  the shape of such a ruling).

  **The owner authors course content here** — it is the authoring environment,
  and the extractor reads it. So the rules for that authoring live where it
  happens, in [`prototype/CLAUDE.md`](prototype/CLAUDE.md), which loads
  automatically in that directory.

## Change History

Major app changes and the completed build milestones (Phases 0–11) live in
[`docs/CHANGELOG.md`](docs/CHANGELOG.md). The workflow is documented at the top
of that file:

- **After meaningful work:** run the `/changelog` skill — it drafts Unreleased
  entries from the actual code diffs for review.
- **At release time:** run `node tool/release.js` — it stamps the
  version + date, bumps `pubspec.yaml`, and tags the release.

## Development commands

Run all flutter/dart commands from the repo root. The full command list with
explanations — plus test and iOS/SPM build notes — lives in
[`README.md`](README.md).

## Code Conventions

- **Imports:** always `package:brew_path/…` within `lib/`; never relative `../` imports
- **Colours:** read the mood tokens via `context.mood` (`MoodColors`, a `ThemeExtension` with a Cupping and a Dark Roast instance); never `Theme.of(context).colorScheme` — it is populated for stock Material widgets only. Everything that must **not** flip with the mood is `static const` on an `abstract final class` with no `of(context)` accessor — `ArtColors` (illustration palette), `OverlayColors` (scrim, scrim ink, modal dim), `AppSpacing`, `AppRadii` — so mood-dependence is unrepresentable, and painters can read them with no `BuildContext`. A value that is deliberately off-token goes in the `OffTokens` register with its reason, never as a bare literal.
- **Comments:** TSDoc only for complex logic or third-party integrations; skip self-evident code
- **Models:** Freezed for all content DTOs; Drift `Table` classes for persisted records
- **Providers:** function-style `@riverpod` only; class-based `@riverpod` only when state is mutable
- **Tests:** unit tests in `test/unit/`; widget tests in `test/widget/`; integration tests in `integration_test/`
- **No print statements** — use `debugPrint` only in development guards; never in production paths
- **Lints:** see `analysis_options.yaml` (the config is the truth) and the README _Toolchain_ paragraph
- **Screens:** read [`docs/design/03-design-system.md`](docs/design/03-design-system.md)
  before building one — it indexes all 57 components and patterns. Many are rules,
  not widgets, so no ticket will ever carry them.

## Code Quality Rules

Magic numbers and per-function size/complexity are now **lint-enforced** by
`dart_code_linter` (config + exclusions in `analysis_options.yaml`).
**Identifier length** and **per-file size** have no rule, so they stay
conventions — follow every rule below on each new or modified file:

- **No magic numbers** (lint-enforced). Extract meaningful or repeated literals
  to named `static const` or theme tokens (`AppSpacing`, `AppRadii`,
  `MoodColors`, `ArtColors`, `OverlayColors`, `AppTypography`); only
  `0`/`1`/`2` inline, with intent names (`_stageSize`),
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

## Agent skills

### Issue tracker

GitHub Issues on `maximsan/brewpath`, via the `gh` CLI. See
[`docs/agents/issue-tracker.md`](docs/agents/issue-tracker.md).

### Triage labels

The five canonical triage roles use their default label strings. See
[`docs/agents/triage-labels.md`](docs/agents/triage-labels.md).

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See
[`docs/agents/domain.md`](docs/agents/domain.md).
