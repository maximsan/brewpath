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
