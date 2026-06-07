# Coffee Quest

A Duolingo-style mobile app for learning coffee — short lessons and mini-games
that grow your knowledge (and Roasty, your coffee-bean companion) one cup at a
time. Flutter, offline-first.

**Stack:** Flutter · Riverpod (state) · go_router (navigation) · Drift/SQLite
(offline persistence) · Freezed + json_serializable (content models).

Architecture and conventions live in [`../CLAUDE.md`](../CLAUDE.md); deeper
design and milestone docs are in [`../docs/`](../docs/).

## Development commands

Run all Flutter/Dart commands from `coffee_quest/`.

| Command | What it does |
| --- | --- |
| `flutter pub get` | Fetch/refresh dependencies (after editing `pubspec.yaml`). |
| `dart run build_runner build` | Regenerate code after changing a Freezed model, Riverpod provider, or Drift table. build_runner 2.15 auto-resolves conflicts — the old `--delete-conflicting-outputs` flag is gone. |
| `dart format lib test integration_test` | Format code. CI fails on unformatted files (`--set-exit-if-changed`). |
| `flutter analyze` | Static analysis / lints — keep clean before pushing. |
| `flutter test` | Run the full test suite. |
| `flutter test test/unit/<file>` | Run a single unit test. |
| `flutter test test/widget/<file>` | Run a single widget test. |
| `flutter run -d "iPhone 17"` | Launch on the iOS simulator. |
| `flutter build ios --release --no-codesign` | Release iOS build without signing (mirrors CI). |

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

| Flag           | Effect                                                              | Run with                                                    |
| -------------- | ------------------------------------------------------------------ | ----------------------------------------------------------- |
| `LOOP_LOADING` | Loops the Roasty wake-up forever; disables auto-advance + tap-skip | `flutter run -d "iPhone 17" --dart-define=LOOP_LOADING=true` |

> With **Reduce Motion** enabled, `LOOP_LOADING` holds a static "brewing" frame
> instead of animating the loop.

## Tooling scripts (`tool/`)

Helper scripts are **not** wired into CI or any build step — run them by hand
only when the situation below applies.

### `tool/reset_ios_spm.sh` — fix iOS SPM build errors

Run when `flutter build ios` fails with a Target Integrity / "minimum platform
version" error. Wipes the stale Swift Package Manager caches so they re-resolve.
Break-glass only — forces a full re-download (minutes).

```bash
cd coffee_quest
./tool/reset_ios_spm.sh           # clean caches only
./tool/reset_ios_spm.sh --build   # clean, then flutter build ios
```

### `tool/release.sh` — cut a release

Run when shipping a build to TestFlight / the App Store. Bumps the version in
`pubspec.yaml`, stamps `../docs/CHANGELOG.md` with the version + date, and (with
`--commit`) tags the release. Draft the changelog first with the `/changelog`
skill.

```bash
cd coffee_quest
./tool/release.sh                  # build number only: 1.0.0+1 → 1.0.0+2
./tool/release.sh minor            # → 1.1.0+2
./tool/release.sh minor --commit   # also commits + tags
./tool/release.sh --dry-run        # preview, writes nothing
```

## Database schema migrations

Drift schema snapshots (`drift_schemas/`) and generated test helpers
(`test/generated/`) are committed. When you change the schema:

1. Bump `schemaVersion` in `lib/shared/storage/app_database.dart` and add the
   migration in `MigrationStrategy.onUpgrade`.
2. `dart run drift_dev schema dump lib/shared/storage/app_database.dart drift_schemas/`
3. `dart run drift_dev schema generate drift_schemas/ test/generated/`
4. Add a previous→new migration test (see `test/database/schema_smoke_test.dart`
   for the `SchemaVerifier` pattern), then `flutter test`.
5. Commit the new snapshot + regenerated helpers with the schema change.
