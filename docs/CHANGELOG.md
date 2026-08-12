# Changelog

All notable changes to BrewPath are recorded here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This is the single place to track **major app changes** over time — when you
finish a meaningful piece of work, add a line under **Unreleased** before you
commit. When you ship a build to TestFlight/App Store, move the Unreleased items
under a new dated version heading.

> **How to use this file (quick guide):**
>
> - Group each change under **Added**, **Changed**, **Fixed**, or **Removed**.
> - Write one short line per change, in plain language — describe the user- or
>   developer-visible effect, not the implementation detail.
> - You don't need to log every commit. Log things you'd want to _remember later_.
> - The **Build Milestones** table at the bottom is the frozen history of the
>   initial 0–11 build phases. Don't edit it; add new work above instead.

### Workflow — when and how to update this file

Two helpers keep this near-zero effort:

| When | Do this | What it does |
| --- | --- | --- |
| You finished something worth remembering | Run **`/changelog`** in Claude Code | Reads your recent code changes (not commit messages), proposes Added/Changed/Fixed bullets, and — once you approve — writes them into **[Unreleased]** below. |
| You're shipping a build to TestFlight / App Store | Run **`node tool/release.js`** | Renames **[Unreleased]** to a dated version heading, opens a fresh empty [Unreleased], bumps the version in `pubspec.yaml`, and (with `--commit`) tags the release. |

`release.js` usage (run from the repo root):

```bash
node tool/release.js                  # 1.0.0+1 → 1.0.0+2   (build number only)
node tool/release.js minor            # → 1.1.0+2
node tool/release.js 1.2.0            # → 1.2.0+2  (explicit version)
node tool/release.js minor --commit   # also commits + tags v1.1.0+2
node tool/release.js --dry-run        # preview only, writes nothing
```

You can always edit this file by hand instead — the helpers just save effort.

---

## [Unreleased]

### Added

- Two colour moods — **Cupping** (light) and **Dark Roast** (dark) — held as
  `MoodColors`, a single `ThemeExtension` carrying the design's own 13 token
  names plus the two background-derived veils. Screens read them through
  `context.mood`. `AppTheme.cupping` exists and is tested, but the app stays
  pinned to Dark Roast until the `light | dark | system` preference lands.
- Fonts are bundled as real Flutter font assets under `assets/fonts/`,
  replacing the `google_fonts` package and its runtime CDN fetch.
- Roasty became a **companion subsystem** rather than a loading-screen mascot:
  a mood + reaction API with a speech bubble and a static (non-animating) mode,
  speaking lines from the new `assets/content/companion_lines.json`. It now
  turns up on lesson completion.
- A floating **points-gain toast** that rises when points are awarded.
- A **module-summary screen** with a module-complete moment, reached when the
  last lesson in a module is finished.
- A **card detail screen**, and **favourite cards** — a card can be saved and
  read in full.
- **`learning/`** — a hands-on, learn-by-doing Flutter course for this app: a
  teaching contract in `README.md` and a `curriculum.md` that marks the current
  step.
- **The design source of truth now lives in the repo.** The React prototype is
  tracked under `brew-path/`, and `docs/design/` is the reference that indexes
  it — product, scope, design system, information architecture, mechanics,
  content, components and flows — so app work can be checked against the design
  without reading the prototype.

### Changed

- `AppTheme.lightTheme` is now `AppTheme.darkRoast` — the old name described a
  `Brightness.dark` theme.
- App code no longer reads `ColorScheme`; it stays populated purely so stock
  Material widgets are styled.
- Text styles take the ambient mood (`AppTypography.body(context.mood)`)
  instead of defaulting to hard-coded dark-roast ink.
- **The app is BrewPath.** The Dart package is `brew_path` (was
  `coffee_quest`), and the name is swept through code, tests, docs and the
  release tooling.
- **The Flutter app lives at the git root**, with no nested `coffee_quest/`
  directory; CI runs from the root. Paths in the released sections below are
  written against the old layout — they are left as they shipped.
- Lint stack moved from `flutter_lints` to **`very_good_analysis` +
  `dart_code_linter`**, with the DCL metrics (complexity, nesting, function
  size, magic numbers) calibrated to this codebase and CI failing on warnings.
  The existing code was remediated to satisfy them.
- `tool/release.sh` was rewritten as **`tool/release.js`**, run with `node`.
- The design prototype was restructured to the **30-lesson syllabus**, and the
  `docs/design/` reference regenerated to match it.
- Dependencies refreshed — `flutter_riverpod` 3.3.2, `riverpod_annotation`
  4.0.3, and `riverpod_generator` off its `-dev` release onto 4.0.4.

### Fixed

- The current node on the Path rail drew its play arrow in its own background
  colour, leaving the glyph invisible. It is an outlined node now, per the
  design.
- Correct-answer feedback in the mini-games used a raw Material green instead
  of the design's `sage`.
- The loading-screen water drop used two mis-transcribed hexes; both now match
  the design bundle.
- Hairlines that resolved to `outlineVariant` painted in full-strength ink
  rather than the `rule` token.
- The CI format job ran `dart format` before `flutter pub get`, so it read the
  wrong language version and failed on files that were correctly formatted. It
  had been red on `main` for over a week.

### Removed

- The 6 unused legacy colour tokens (`coffeeBrown`, `espresso`, `latte`,
  `cream`, `surface`, `locked`). `AppColors` now holds only mood-invariant
  literals.

---

## [1.0.0+3] — 2026-06-08

### Added

- `riverpod_lint` static analysis, enabled via the native analyzer `plugins:`
  block in `analysis_options.yaml` (analysis_server_plugin — no `custom_lint`).
  Previously deferred by the custom_lint/analyzer-9 gap.

### Changed

- Moved the code-gen toolchain onto analyzer 12: `riverpod_generator` + `freezed`
  to their analyzer-12 `-dev` releases, `drift`/`drift_dev` 2.30 → 2.33 (+
  `drift_flutter` 0.3, `sqlite3_flutter_libs` 0.6), `json_serializable` 6.13 →
  6.14 (`json_annotation` 4.12). Drops the pins that had held the project in the
  analyzer-9 window. CI Flutter 3.44.0 → 3.44.1.
- Loading wake-up animation now grows Roasty's sprout out of its head during the
  grow phase (new host-driven `sproutScale`).
- Onboarding screens reorganized into per-screen folders with their orchestration
  pulled into extracted controllers (`GoalController`, `BrewerController`,
  `WakeSequenceController`), each unit-tested.
- Stricter analyzer linting — added `require_trailing_commas`,
  `always_declare_return_types`, `prefer_const_constructors_in_immutables`,
  `avoid_redundant_argument_values`, and `unawaited_futures` (codebase reformatted
  to match).
- Developer docs reorganized — common dev commands and run-time flags (e.g.
  `LOOP_LOADING`) now live in `coffee_quest/README.md`; `CLAUDE.md`/`AGENTS.md`
  slimmed to point there.

### Fixed

- `flutter analyze` no longer reports errors from the vendored Firebase Swift
  Package sources under `ios/build/` (analyzer now excludes nested `build/`
  directories).

---

## [1.0.0+2] — 2026-06-03

### Added

- Loading screen with a cycled "coffee bean cracking in two" animation, shown
  until the app finishes loading.
- Welcome hero screen for first launch.
- `coffee_quest/tool/reset_ios_spm.sh` — helper to reset the iOS Swift Package
  Manager state when native builds get stuck.
- `coffee_quest/tool/release.sh` — release helper that bumps the version + build
  number in `pubspec.yaml`, stamps the Unreleased section with the new version
  and date, and (with `--commit`) commits and tags the release.
- Changelog tracking workflow — this `docs/CHANGELOG.md` plus a `/changelog`
  helper that drafts Unreleased entries from real code diffs rather than commit
  messages.

### Changed

- Redesigned the UI/UX of all four tabs — Learn, Path, Cards, Profile — plus the
  Settings screen.
- Reworked scrolling behavior across screens.
- Reworked XP: corrected total-XP accumulation, adjusted XP-per-lesson
  calculation, and fixed "today's lesson" selection logic.
- Consolidated the welcome flow down to a single welcome screen variant.
- Migrated the iOS native build from CocoaPods to Swift Package Manager
  (no more `Podfile` / `pod install`).

### Fixed

- Repaired a broken test after the XP logic changes.

---

## Build Milestones

The initial product was built in numbered phases (0–11). All are complete except
Phase 8, whose Firebase code is written but gated off behind `kUseFirebase`
(activation is a manual user step). This table is the historical record of that
build; see `docs/archive/16-claude-code-task-plan.md` for the original
phase-by-phase plan.

| Phase | Status           | Description                                                                                                       |
| ----- | ---------------- | ----------------------------------------------------------------------------------------------------------------- |
| 0     | ✅ Done          | Prerequisites verified                                                                                            |
| 1     | ✅ Done          | Project scaffold, routing stub, theme                                                                             |
| 2     | ✅ Done          | Content models, JSON assets, ContentRepository                                                                    |
| 3     | ✅ Done          | Drift persistence, repositories, providers (replaced abandoned Isar)                                              |
| 4     | ✅ Done          | Domain logic: XP / streak / completion services, providers                                                        |
| 5     | ✅ Done          | Navigation: StatefulShellRoute app shell, 4 tabs, analytics observer                                              |
| 6     | ✅ Done          | Feature screens: Learn / Path / Cards / Profile + lock / settings / version providers                             |
| 7     | ✅ Done          | Lesson runner, 4 mini-games, completion screen, immersive lesson route                                            |
| 8     | 🚧 Code complete | Firebase services (Analytics / Crashlytics / Remote Config) behind abstractions; activation pending (`kUseFirebase`) |
| 9     | ✅ Done          | Ads & Payments service stubs (NoOp active; in_app_purchase / AdMob impls deferred)                                |
| 10    | ✅ Done          | Test suite (52 tests) + `integration_test/smoke_test.dart`; on-Simulator smoke run pending user                  |
| 11    | ✅ Done          | CI: 3-job `ci.yml` (format / analyze+test / iOS build); CocoaPods → SPM migration                                |
