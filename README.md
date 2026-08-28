# BrewPath

A Duolingo-style mobile app for learning coffee — short lessons and mini-games
that grow your knowledge (and Roasty, your coffee-bean companion) one cup at a
time. Flutter, offline-first.

**Stack:** Flutter · Riverpod 3 (state) · go_router 17 (navigation) · Drift 2.33 /
SQLite (offline persistence) · Freezed 3 + json_serializable (content models).

**Toolchain:** analyzer 12 · `very_good_analysis` (strict lint baseline) ·
`riverpod_lint` + `dart_code_linter` enabled via the `plugins:` block in
`analysis_options.yaml` (native analysis_server_plugins — not dependencies, no
`custom_lint`). `dart_code_linter` adds `no-magic-number` plus a CI metrics gate
(`dart run dart_code_linter:metrics analyze lib`) for per-function size &
complexity.

Architecture and conventions live in [`CLAUDE.md`](CLAUDE.md); the doc map and
source-precedence rules are at [`docs/README.md`](docs/README.md), and deeper
design and milestone docs are in [`docs/`](docs/).

## Development commands

Run all Flutter/Dart commands from the repo root.

| Command                                     | What it does                                                                                                                                                                        |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `flutter pub get`                           | Fetch/refresh dependencies (after editing `pubspec.yaml`).                                                                                                                          |
| `dart run build_runner build`               | Regenerate code after changing a Freezed model, Riverpod provider, or Drift table. build_runner 2.15 auto-resolves conflicts — the old `--delete-conflicting-outputs` flag is gone. |
| `dart format lib test integration_test`     | Format code. CI fails on unformatted files (`--set-exit-if-changed`).                                                                                                               |
| `flutter analyze`                           | Static analysis / lints — keep clean before pushing.                                                                                                                                |
| `flutter test`                              | Run the full test suite.                                                                                                                                                            |
| `flutter test test/unit/<file>`             | Run a single unit test.                                                                                                                                                             |
| `flutter test test/widget/<file>`           | Run a single widget test.                                                                                                                                                           |
| `flutter run -d "iPhone 17"`                | Launch on the iOS simulator.                                                                                                                                                        |
| `flutter build ios --release --no-codesign` | Release iOS build without signing (mirrors CI).                                                                                                                                     |

### Tests

Drift tests use an in-memory database (`AppDatabase(NativeDatabase.memory())`),
so no native binary copy is needed. Unit tests live in `test/unit/`, widget tests
in `test/widget/`, integration tests in `integration_test/`.

### iOS build (Swift Package Manager)

The iOS project uses **Swift Package Manager**, not CocoaPods — there is no
`ios/Podfile` and no `pod install` step. Plugins resolve as Swift Packages during
`flutter build ios`. The deployment target is **16.0** (required by the Firebase
SPM packages). CI builds on a macOS runner via the `iOS build` job in
`.github/workflows/ci.yml`.

Troubleshooting:

- Target Integrity / "minimum platform version" build errors → run
  `tool/reset_ios_spm.sh` (see below).
- `flutter test` crashing with `PathExistsException` on
  `ios/Flutter/ephemeral/.../Packages` → `rm -rf ios/Flutter/ephemeral`, then retry.

## Run-time flags (`--dart-define`)

Debug toggles compiled in via `bool.fromEnvironment`. All default to off, so
release builds are unaffected.

| Flag           | Effect                                                             | Run with                                                     |
| -------------- | ------------------------------------------------------------------ | ------------------------------------------------------------ |
| `LOOP_LOADING` | Loops the Roasty wake-up forever; disables auto-advance + tap-skip | `flutter run -d "iPhone 17" --dart-define=LOOP_LOADING=true` |

> With **Reduce Motion** enabled, `LOOP_LOADING` holds a static "brewing" frame
> instead of animating the loop.

## Versioning

`pubspec.yaml` uses Flutter's `version: X.Y.Z+B` format — two independent
counters joined by `+`:

- **`X.Y.Z`** — the semantic version: the user-facing "marketing" version shown
  in the App Store / Play Store (iOS `CFBundleShortVersionString`, Android
  `versionName`). Bump per [semver](https://semver.org) — patch for fixes, minor
  for features, major for breaking changes.
- **`+B`** — the **build number** (iOS `CFBundleVersion`, Android `versionCode`).
  The stores reject any upload whose build number isn't higher than the last, so
  it must increase on **every** binary — independent of `X.Y.Z`.

Unlike an npm package (one semver string), a mobile app carries two numbers: one
for humans, one for the store.

`tool/release.js` (below, run with `node`) **always increments `+B`**, and changes
`X.Y.Z` only when you pass an argument:

| Command            | From `1.0.0+3` → | What changed                           |
| ------------------ | ---------------- | -------------------------------------- |
| `release.js`       | `1.0.0+4`        | build number only                      |
| `release.js patch` | `1.0.1+4`        | patch + build                          |
| `release.js minor` | `1.1.0+4`        | minor (patch reset to 0) + build       |
| `release.js major` | `2.0.0+4`        | major (minor/patch reset to 0) + build |
| `release.js 2.3.1` | `2.3.1+4`        | explicit version + build               |

Pre-launch it's normal to stay on `1.0.0` and bump only the build number across
TestFlight builds; start moving `X.Y.Z` once you ship user-facing updates.

## Tooling scripts (`tool/`)

Helper scripts are **not** wired into CI or any build step — run them by hand
only when the situation below applies.

### `tool/reset_ios_spm.sh` — fix iOS SPM build errors

Run when `flutter build ios` fails with a Target Integrity / "minimum platform
version" error. Wipes the stale Swift Package Manager caches so they re-resolve.
Break-glass only — forces a full re-download (minutes).

```bash
./tool/reset_ios_spm.sh           # clean caches only
./tool/reset_ios_spm.sh --build   # clean, then flutter build ios
```

### `tool/extract_content.js` — regenerate bundled content

Node script (no dependencies). Run after the design prototype's (`prototype/`)
authored content changes. Writes ten banks — modules, lessons, collectibles,
dictionary terms, Coffee Challenges, mini games, card-kind help, mini-game
content, grove varieties and grove lights — validating the whole
cross-reference graph first, and only then writing `assets/content/generated/`.

Validating and refusing to write is the point: on any violation it names the
offending card and the broken reference, writes **nothing**, and exits non-zero,
so a run can never leave a stale mixture of old and new files behind. Its output
is generated — regenerate it, never hand-edit it. `prototype/` is opened for
reading only.

Every bank carries a `schemaVersion`, and the app refuses one it was not built
to read. Before changing what the extractor emits, read _Bumping the schema
version_ in the script's header — a rename or a change of meaning is breaking
even when the shape is unchanged, and the number has to move on both the
JavaScript and the Dart side. Why the prototype authors content at all, and what
would end that, is [ADR-0006](docs/adr/0006-the-prototype-authors-v1-and-the-extracted-json-is-the-contract.md).

```bash
node tool/extract_content.js                          # the usual run
node tool/extract_content.js --source DIR --out DIR   # used by the tests
```

### `tool/extract_icons.js` — regenerate the icon family

Node script (no dependencies). Run after the design prototype's icon family
changes. Writes the design's 39 marks as SVG into `assets/icons/`, plus the
`index.json` that describes the family, and gives five of them a second file
for the state the design draws them in when active.

The marks carry arcs, transforms, per-element opacity and nine stroke widths
across four element types, which is why they are rendered rather than
transcribed into painters. Colour is not baked in: a mark paints in
`currentColor`, which `IconMark` resolves to a mood token, or in a sentinel
magenta standing in for a CSS variable, which it maps back to a token.

Like the content extractor, it validates and refuses to write — an unmappable
colour, two sets drawing one name differently, or a state transcription the
catalogue no longer matches all fail the run and write **nothing**. Its output
is generated: regenerate it, never hand-edit it. `prototype/` is opened for
reading only.

Two sources, per [ADR-0009](docs/adr/0009-the-running-prototype-wins-over-the-design-system-catalogue.md):
geometry comes from the catalogue (`prototype/ds-content.js`), and the paint of
each active state from the running components (`prototype/flavor-wheel.jsx`),
which the catalogue does not draw.

```bash
node tool/extract_icons.js                          # the usual run
node tool/extract_icons.js --source DIR --out DIR   # used by the tests
```

### `tool/release.js` — cut a release

Node script (no dependencies). Run when shipping a build to TestFlight / the App
Store. Bumps the version in `pubspec.yaml`, stamps `docs/CHANGELOG.md` with the
version + date, and (with `--commit`) tags the release. Draft the changelog first
with the `/changelog` skill. Refuses to run when `[Unreleased]` is empty — pass
`--allow-empty` for a build-only rebuild.

```bash
node tool/release.js                  # build number only: 1.0.0+1 → 1.0.0+2
node tool/release.js minor            # → 1.1.0+2
node tool/release.js minor --commit   # also commits + tags
node tool/release.js --dry-run        # preview, writes nothing
```

## Database schema migrations

Drift schema snapshots (`drift_schemas/`) and generated test helpers
(`test/generated/`) are committed. When you change the schema:

1. Bump `schemaVersion` in `lib/shared/storage/app_database.dart` and add the
   migration in `MigrationStrategy.onUpgrade`.

   ⚠️ **Guard each step by the version it landed in, never by
   `schemaVersion`.** A step written as `if (from < schemaVersion)` is correct
   only until the next bump, after which it re-runs on a database that already
   has those columns and fails on the duplicate. The failure is invisible until
   someone else changes the schema, so it is found by the person who did not
   cause it. Name a constant per step — `_onboardingColumnsVersion`,
   `_themeModeVersion` — and let `schemaVersion` be the latest of them.
2. `dart run drift_dev schema dump lib/shared/storage/app_database.dart drift_schemas/`
3. `dart run drift_dev schema generate drift_schemas/ test/generated/`

   This rewrites **every** file in `test/generated/`, not just the new one.
   Expect no diff on the existing versions: they are generated by the pinned
   `drift_dev`, so output matches. If they do change, the generator version
   moved — regenerate them deliberately on their own branch rather than letting
   the churn ride along with a schema change.
4. Add a previous→new migration test (see `test/database/schema_smoke_test.dart`
   for the `SchemaVerifier` pattern), then `flutter test`.

   Target `db.schemaVersion`, not a literal version number. `migrateAndValidate`
   then checks the migrated database against the committed snapshot for whatever
   the current version is, and the test stops going stale on every bump.

   ⚠️ **`testWithDataIntegrity` cannot do that, so retarget its `newVersion`
   and `createNew` to the version you just added.** It takes the target as a
   literal and a snapshot class, while `openTestedDatabase` is the real
   `AppDatabase` — which always migrates as far as it goes. A test left pointing
   at the previous version fails with "Schema does not match" the moment a new
   one exists, naming the columns you changed, and it reads like your migration
   is broken when it is the assertion that is stale. The existing ones are
   deliberately aimed at the current version for this reason.

   Prefer removing a column by recreating the table (`TableMigration` with the
   column omitted from the current definition), and cover it with a
   data-integrity test that seeds the **other** columns and asserts they
   survive — a recreate that copies the wrong set silently resets whatever it
   missed.
5. Commit the new snapshot + regenerated helpers with the schema change.
