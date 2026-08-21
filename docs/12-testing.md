# BrewPath — Testing

> **Status:** The persistence layer uses **Drift 2.33.x** (migrated from Isar in
> Phase 3); test setups use `AppDatabase(NativeDatabase.memory())`.

---

## Testing Strategy

| Layer       | Tool                     | What is tested                                                                           |
| ----------- | ------------------------ | ---------------------------------------------------------------------------------------- |
| Unit        | `flutter_test`           | Business logic, points rules, streak logic, card unlock, module unlock, repository read/write |
| Widget      | `flutter_test`           | Mini-game widgets, lesson step runner, tab navigation, screen rendering                  |
| Integration | `integration_test` (SDK) | Full smoke flow: launch → start lesson → complete → see points                           |

**Mocking strategy:** Use Riverpod `ProviderScope` overrides to inject test doubles. Avoid `mockito` for domain logic — prefer real implementations with `AppDatabase(NativeDatabase.memory())` (an in-memory Drift database).

---

## The suite, by directory

**The tests themselves are the spec** — this doc names the suites and the
conventions, and deliberately lists no per-test assertions (an earlier revision
did, and every listed snippet had drifted from the real APIs).

| Directory | What lives there |
|---|---|
| `test/unit/` (top level) | Domain + repository logic: points, streak, lesson completion, module unlock, routes, monetization stubs, no-op services, content + progress + module-progress repositories |
| `test/unit/features/` | Per-feature domain tests (onboarding, companion, learn, lessons, progress) |
| `test/unit/shared/theme/` | The token suite — mood colours, art colours, overlays, radii, text — including drift guards against the prototype's palette |
| `test/unit/shared/storage/` + `storage/snapshot/` | Drift records, the progress-snapshot merge laws, JSON round-trips, account wipe + tombstones |
| `test/unit/tool/` | The content extractor (shells out to `node tool/extract_content.js`) |
| `test/database/` | Schema smoke + migration tests over the real Drift schema history (`drift_schemas/`) |
| `test/widget/` | Screens, games, shell navigation, shared widgets |
| `integration_test/` | The smoke flow — boots through onboarding (loading → welcome → goal → brewer) into Learn |

Run: `flutter test` (everything), `flutter test test/unit/` etc. per directory,
`flutter test integration_test/smoke_test.dart -d <simulator>` for the smoke
test.

---

## Conventions

**In-memory Drift, no mocks for persistence** (the real setup, from
`test/unit/progress_repository_test.dart`):

```dart
setUp(() {
  db = AppDatabase(NativeDatabase.memory());
  AppDatabaseService.instance = db;
});

tearDown(() async {
  await db.close();
});
```

**Service doubles:** while `kUseFirebase == false` the providers already
resolve to No-Op implementations, so tests need no Firebase overrides today.
Riverpod `ProviderScope` overrides become relevant only after Firebase
activation flips the providers.

---

## Android Testing Addendum (For Future)

Nothing here is done — there is no `android/` directory and no Android CI job.
The plan lives in [`15-future-android-web-plan.md`](15-future-android-web-plan.md);
unit/widget tests are platform-agnostic and need no changes when it lands.
