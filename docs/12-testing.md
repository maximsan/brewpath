# BrewPath — Testing

> **Status:** The persistence layer uses **Drift 2.33.x** (migrated from Isar in
> Phase 3); test setups use `AppDatabase(NativeDatabase.memory())`.

---

## Testing Strategy

| Layer       | Tool                     | What is tested                                                                           |
| ----------- | ------------------------ | ---------------------------------------------------------------------------------------- |
| Unit        | `flutter_test`           | Business logic, points rules, streak logic, card unlock, module unlock, repository read/write |
| Widget      | `flutter_test`           | Mini-game widgets, lesson step runner, tab navigation, screen rendering                  |
| Integration | `integration_test` (SDK) | Smoke flow: launch → onboarding → relaunch → play a lesson → relaunch → read back what it paid |

**Mocking strategy:** Use Riverpod `ProviderScope` overrides to inject test doubles. Avoid `mockito` for domain logic — prefer real implementations with `AppDatabase(NativeDatabase.memory())` (an in-memory Drift database).

---

## The suite, by directory

**The tests themselves are the spec** — this doc names the suites and the
conventions, and deliberately lists no per-test assertions (an earlier revision
did, and every listed snippet had drifted from the real APIs).

| Directory | What lives there |
|---|---|
| `test/unit/` (top level) | Domain logic: points, streak, lesson completion, module unlock, routes, monetization stubs, no-op services, the content repository. Also the content rules checked over the **committed** banks, which catch a hand-edit or a half-applied regeneration that a fresh extraction cannot see |
| `test/unit/features/` | Per-feature domain tests (onboarding, companion, learn, lessons, progress) |
| `test/unit/shared/theme/` | The token suite — mood colours, art colours, overlays, radii, text — including drift guards against the prototype's palette |
| `test/unit/shared/storage/` + `storage/snapshot/` | Drift records, the progress-snapshot merge laws, JSON round-trips, account wipe + tombstones |
| `test/unit/tool/` | The extractors, each shelling out to its script — content (`node tool/extract_content.js`) and collectible art (`node tool/extract_card_art.js`), including what each refuses to write |
| `test/unit/core/icons/` | The icon family — the catalogue against the written marks, and both against a fresh `node tool/extract_icons.js` |
| `test/database/` | Schema smoke + migration tests over the real Drift schema history (`drift_schemas/`) |
| `test/widget/` | Screens, games, shell navigation, shared widgets |
| `integration_test/` | The smoke flow — boots through onboarding into Learn, proves it persisted across a relaunch by reading the name back off the Profile header, dismisses the Tour, plays `m1l1` to completion, and after a second relaunch reads the completion, its points and its card back off Profile and Cards |

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
> move with the content; open the Today card by its own control, and prove
> content loaded off the `RoastMeter`'s own numbers rather than the string it
> draws. Hardcoding a lesson title is what broke this walk twice.
>
> **A relaunch tears the previous app down first.** Each `app.main()` opens
> another `AppDatabase` over the same file, and drift is explicit that
> concurrent instances race — which is why the walk once had a hard "two
> launches, never three" rule. `launch` now unmounts the tree and closes the
> open database before it starts the next one, so a relaunch is a restart
> rather than a second handle, and the count is no longer the limit.
>
> **Every step of the walk must assert.** It rotted for months because three
> did not: a skip guarded by an `if` that no-opped when its copy changed, a
> landmark two screens both render, and taps dispatched at a page still
> sliding in from off-screen. All three failed silently. A step that cannot
> fail is not a step — and `pumpAndSettle` is banned here, because Roasty
> idles forever and waiting on it is what disguised the breakage as a
> ten-minute job. CI runs it on **main only** ([13](13-ci-cd.md)).

### The smoke walk's helpers

Three rules are written into `pumpUntil`, `tapWhenReady` and `liveButton`, and
each of them was learned from a step that failed silently.

**Wait for hit-testable, never for merely present.** A page sliding in exists
in the tree well before it is on screen, so waiting on existence hands back a
widget whose centre is off the right-hand edge; every tap then misses it and
Flutter reports that as a warning, not a failure. A push transition also mounts
both pages at once, so the raw finder can match the outgoing copy as well and
`ensureVisible` fails on "too many elements" — a wait and an action disagreeing
about which widget they meant. The one exception is `tappable: false`, for a
widget the walk **reads** rather than taps — Profile's lessons-and-points line,
a Cards tile it only inspects. Hit-testability is not what makes those
assertions true, so requiring it can only add a way for them to fail.

**Find a button by its label anywhere beneath it.** `liveButton` matches an
*enabled* `FilledButton` that has the label somewhere under it. It read
`child is Text` until the button grew an optional trailing mark and wrapped its
label in a `Row`, after which every wait timed out against a button that was on
screen the whole time and the gate stayed red across five merges. What the walk
needs is an enabled button that says this; how the button lays its label out is
the button's business. A failure dumps every string on screen, because a walk
that says only what it wanted makes the reader guess what it got.

**Never `pumpAndSettle`, and budget each step generously.** Roasty idles on an
infinite animation, which `pumpAndSettle` waits on forever; real-time pumps
also let Drift's FFI and the asset bundle make progress, which a fake-async
pump does not. A cold CI runner is several times slower than a warm laptop — an
eight-second budget passed locally and failed on the first real run — and
nothing is lost by waiting, since a genuine hang still fails in seconds rather
than at the job's cap.

---

## Conventions

**In-memory Drift, no mocks for persistence** (the real setup, from
`test/unit/shared/storage/account_wipe_test.dart`):

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
