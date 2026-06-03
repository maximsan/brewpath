# coffee_quest

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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
