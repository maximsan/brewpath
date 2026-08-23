# BrewPath — Testing

> **Status:** The persistence layer uses **Drift 2.33.x** (migrated from Isar in
> Phase 3); test setups use `AppDatabase(NativeDatabase.memory())`.

---

## Testing Strategy

| Layer       | Tool                     | What is tested                                                                           |
| ----------- | ------------------------ | ---------------------------------------------------------------------------------------- |
| Unit        | `flutter_test`           | Business logic, points rules, streak logic, card unlock, module unlock, repository read/write |
| Widget      | `flutter_test`           | Mini-game widgets, lesson step runner, tab navigation, screen rendering                  |
| Integration | `integration_test` (SDK) | Smoke flow: launch → onboarding → relaunch → open authored content                       |

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
| `integration_test/` | The smoke flow — boots through onboarding (loading → welcome → goal → brewer → name) into Learn, proves it persisted across a relaunch by reading the name back off the Profile header, dismisses the Tour, and opens authored content |

Run: `flutter test` (everything), `flutter test test/unit/` etc. per directory,
`flutter test integration_test/smoke_test.dart -d <simulator>` for the smoke
test (a few seconds of testing; the Xcode build dominates, and is
several times slower on a cold CI runner than locally).

> **The smoke suite is the only thing that boots the real app**, and it is the
> reason to keep it. Everything under `flutter test` runs against in-memory
> Drift, a cleared `rootBundle` and an onboarding flag the harness seeds to
> `true` — so a migration that fails on a real on-disk database, an asset the
> pubspec does not bundle, and an unregistered plugin are invisible to all of
> it. `iOS build` proves the app links, never that it boots. Onboarding has no
> other coverage at all.
>
> **Never landmark on authored copy.** Lesson titles, card text and questions
> move with the content; open the Today card by its own `Start` control and
> prove content loaded with `Step 1 of N`, whose `N` is the lesson's real step
> count. Hardcoding a lesson title is what broke this walk twice.
>
> **Two launches, never three.** Each `app.main()` opens another `AppDatabase`
> over the same file, and drift is explicit that concurrent instances race. A
> third launch passes only when the simulator still holds an onboarded install
> from a previous run — green locally, red on every clean one.
>
> **Every step of the walk must assert.** It rotted for months because three
> did not: a skip guarded by an `if` that no-opped when its copy changed, a
> landmark two screens both render, and taps dispatched at a page still
> sliding in from off-screen. All three failed silently. A step that cannot
> fail is not a step — and `pumpAndSettle` is banned here, because Roasty
> idles forever and waiting on it is what disguised the breakage as a
> ten-minute job. CI runs it on **main only** ([13](13-ci-cd.md)).

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
