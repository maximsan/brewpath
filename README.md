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
for per-function size & complexity; the command, exactly as CI runs it, is in
[docs/git-and-github-workflow.md](docs/git-and-github-workflow.md) under
_Reproducing CI locally_.

Architecture and conventions live in [`CLAUDE.md`](CLAUDE.md); the doc map and
source-precedence rules are at [`docs/README.md`](docs/README.md), and deeper
design and milestone docs are in [`docs/`](docs/).

## Development commands

Run all Flutter/Dart commands from the repo root.

| Command                                     | What it does                                                                                                                                                                        |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `flutter pub get`                           | Fetch/refresh dependencies (after editing `pubspec.yaml`).                                                                                                                          |
| `dart run build_runner build`               | Regenerate code after changing a Freezed model, Riverpod provider, or Drift table. build_runner 2.15 auto-resolves conflicts — the old `--delete-conflicting-outputs` flag is gone. |
| `dart format lib test integration_test tool` | Format code. CI fails on unformatted files (`--set-exit-if-changed`).                                                                                                          |
| `flutter analyze`                           | Static analysis / lints — keep clean before pushing.                                                                                                                                |
| `flutter test`                              | Run the full test suite.                                                                                                                                                            |
| `flutter test test/unit/<file>`             | Run a single unit test.                                                                                                                                                             |
| `flutter test test/widget/<file>`           | Run a single widget test.                                                                                                                                                           |
| `flutter run -d "iPhone 17"`                | Launch on the iOS simulator.                                                                                                                                                        |
| `flutter build ios --release --no-codesign` | Release iOS build without signing (mirrors CI).                                                                                                                                     |
| `tool/install_hooks.sh`                     | Install the git hooks, once per clone (Claude Code does it at session start). What they run: [docs/quality-checks.md](docs/quality-checks.md).                                        |

### Tests

Drift tests use an in-memory database, so no native binary copy is needed.
What each suite covers, where a new test goes, and the rules the smoke walk
obeys are in [docs/testing.md](docs/testing.md).

### iOS build (Swift Package Manager)

The iOS project uses **Swift Package Manager**, not CocoaPods — there is no
`ios/Podfile` and no `pod install` step. Plugins resolve as Swift Packages during
`flutter build ios`. The deployment target is **16.0** (required by the Firebase
SPM packages). CI builds on a macOS runner via the `ios-build` workflow in
[`codemagic.yaml`](codemagic.yaml) — macOS runs on Codemagic rather than
GitHub Actions, for the billing reason in [`docs/ci-cd.md`](docs/ci-cd.md).

Troubleshooting:

- Target Integrity / "minimum platform version" build errors → run
  `tool/reset_ios_spm.sh` (see below).
- `flutter test` crashing with `PathExistsException` on
  `ios/Flutter/ephemeral/.../Packages` → `rm -rf ios/Flutter/ephemeral`, then retry.

## Quality checks

The repo's own rules run when Claude Code writes a Dart file, on `git commit`,
on `git push` and in CI. Install the hooks once per clone with
`tool/install_hooks.sh`; what runs at each moment, the escapes, and what to
do when a check fails are in [docs/quality-checks.md](docs/quality-checks.md).

## Run-time flags (`--dart-define`)

Debug toggles compiled in via `bool.fromEnvironment`. All default to off, so
release builds are unaffected.

| Flag            | Effect                                                             | Run with                                                      |
| --------------- | ------------------------------------------------------------------ | -------------------------------------------------------------- |
| `LOOP_LOADING`  | Loops the Roasty wake-up forever; disables auto-advance + tap-skip | `flutter run -d "iPhone 17" --dart-define=LOOP_LOADING=true`  |
| `GRANT_COURSE`  | Hands the learner the course entitlement, so the paid lessons open | `flutter run -d "iPhone 17" --dart-define=GRANT_COURSE=true`  |
| `MONETIZATION_MODEL` | Puts the development store on one experiment arm — `subscription` or `hybrid` — so its paywall can be driven; unpriced, since no store has those SKUs | `flutter run -d "iPhone 17" --dart-define=MONETIZATION_MODEL=hybrid` |
| `REVENUECAT_KEY` | The RevenueCat public SDK key. With one the app talks to the real store; without one it cannot take money at all | `flutter run -d "iPhone 17" --dart-define=REVENUECAT_KEY=appl_…` |
| `REPLAY_SWIPE_HINTS` | Replays every first-run swipe hint, whatever this device has already learned. Reads the used-flag rather than clearing it, so nothing is lost | `flutter run -d "iPhone 17" --dart-define=REPLAY_SWIPE_HINTS=true` |

> With **Reduce Motion** enabled, `LOOP_LOADING` holds a static "brewing" frame
> instead of animating the loop.

> `GRANT_COURSE` is the way past the course wall in a build with no
> `REVENUECAT_KEY`: the payments stub reports no entitlement, so an ordinary
> build can open the first three lessons and nothing else. It swaps the stub
> for `GrantedPaymentsService`, which grants the entitlement and touches no
> store, and it wins over a key when both are passed.

## Versioning

`pubspec.yaml` carries two numbers, `X.Y.Z+B` — the store's marketing version
and the build number that must rise on every upload — and `tool/release.js`
moves them. What each means and how a release is cut is
[docs/releasing.md](docs/releasing.md).

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

### `tool/clean_build_caches.sh` — reclaim disk

Run when the machine is low on space. Reports what a build has accumulated —
Xcode's DerivedData and device symbols, and the `build/` each worktree grows —
and deletes nothing without `--apply`. All of it is rebuilt on demand; source,
Archives and package caches are refused by an allow-list.

```bash
./tool/clean_build_caches.sh                     # report only
./tool/clean_build_caches.sh --apply             # Xcode caches, dead simulators
./tool/clean_build_caches.sh --apply --worktrees # also every build/
```

`--worktrees` forces a full rebuild for anyone working in one; leave it off
while another session is mid-build.

### `tool/extract_content.js` — regenerate the content banks

Node script (no dependencies). Run after a prototype drop changes the authored
content. Validates the whole cross-reference graph and writes
`assets/content/generated/`, or refuses and writes nothing. The pipeline it
belongs to — the shared contract, the order after a drop, the schema version
rule — is [docs/content-pipeline.md](docs/content-pipeline.md).

```bash
node tool/extract_content.js                          # the usual run
node tool/extract_content.js --source DIR --out DIR   # used by the tests
```

### `tool/draft_language.js` — draft and check a language folder

Node script (no dependencies). How a language is made, from the first
`plan` to a reader picking it, is [docs/localization.md](docs/localization.md).

### `tool/extract_icons.js` — regenerate the icon family

Node script (no dependencies). Run after a drop changes the design's icons.
Writes the 43 marks as SVG into `assets/icons/`, or refuses and writes nothing
([docs/content-pipeline.md](docs/content-pipeline.md)).

```bash
node tool/extract_icons.js                          # the usual run
node tool/extract_icons.js --source DIR --out DIR   # used by the tests
```

### `tool/extract_card_art.js` — regenerate the collectible artwork

Node script (no dependencies). Run after a drop changes the card art. Writes
the 37 illustrations as SVG into `assets/card_art/`, or refuses and writes
nothing ([docs/content-pipeline.md](docs/content-pipeline.md)).

```bash
node tool/extract_card_art.js                          # the usual run
node tool/extract_card_art.js --source DIR --out DIR   # used by the tests
```


### `tool/release.js` — cut a release

Node script (no dependencies). Run when shipping a build to TestFlight / the App
Store: bumps `pubspec.yaml`, stamps `docs/CHANGELOG.md`, and with `--commit`
tags the release. Every argument and the whole release walk are in
[docs/releasing.md](docs/releasing.md).

```bash
node tool/release.js                  # build number only: 1.0.0+1 → 1.0.0+2
node tool/release.js minor            # → 1.1.0+2
node tool/release.js minor --commit   # also commits + tags
node tool/release.js --dry-run        # preview, writes nothing
```

## Database schema migrations

Every change to the Drift schema — the version bump, the snapshot dump, the
regenerated helpers and the migration test — is
[docs/schema-migrations.md](docs/schema-migrations.md).
