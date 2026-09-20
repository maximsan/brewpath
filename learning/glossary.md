# BrewPath — Glossary

The terms of art this project's code and docs use, for someone meeting them
for the first time. Each entry says what the term means here and where it is
used, so the term can be read in place. The rule: a term appears here before a
doc leans on it. Product vocabulary — lessons, cards, mastery, the streak — is
[`CONTEXT.md`](../CONTEXT.md), the domain glossary; this file is the
engineering side.

---

## Flutter & Dart

### `async` / `await`

Dart's syntax for asynchronous code. `async` marks a function as asynchronous; `await` pauses execution until a `Future` resolves — similar to JavaScript `async/await` or Swift `async/await`.

### `BuildContext`

An object Flutter passes to widget `build()` methods. It represents a widget's position in the widget tree and is needed to navigate, show dialogs, or read inherited data. Riverpod reduces how often you need `BuildContext` in business logic.

### `Future<T>`

A Dart type representing a value that will be available later (asynchronous result). Like a `Promise<T>` in JavaScript or `Task<T>` in C#.

### `sealed class`

A Dart class modifier (Dart 3+) that restricts which classes can extend or implement it. Used with Freezed's union types so the compiler can check that a `switch` covers every variant — `ContentCard` is the one you will meet first (see _Union type_).

### Widget

The fundamental building block of Flutter UIs. Everything visible on screen is a widget — text, buttons, layout containers. Widgets are immutable; Flutter rebuilds them when state changes.

### `part` directive

A Dart language feature that splits a library across files. `part 'content_card.freezed.dart';` tells Dart that the generated file belongs to the same library. Required for Freezed and json_serializable output.

### Generated files (`.g.dart`, `.freezed.dart`)

Files produced by `build_runner`. Never edit them by hand — they are overwritten on the next build. They are committed in this project, so CI runs no generation step.

---

## State — Riverpod

### `@riverpod` annotation

A code-generation annotation from `riverpod_annotation`. Applied to a Dart function or class, it generates a type-safe provider. Requires running `build_runner` to produce the `.g.dart` file.

### Provider

A Riverpod object that holds a piece of state or a service. Widgets and other providers can `watch` or `read` a provider to access its value. Providers are lazy by default — they compute their value only when first accessed.

### `Ref`

The first argument to every Riverpod provider function. Used to access other providers (`ref.watch`, `ref.read`) and to register lifecycle callbacks (`ref.onDispose`).

### `WidgetRef`

The `ref` object available inside a `ConsumerWidget.build()`. Behaves like `Ref` but is tied to the widget's lifecycle.

### `ConsumerWidget` / `ConsumerStatefulWidget`

Riverpod-aware Flutter widgets. Replace the standard `StatelessWidget` / `StatefulWidget` when the widget needs to read a Riverpod provider. The `build()` method receives a `WidgetRef ref` argument as well as `BuildContext`.

---

## Navigation — go_router

### go_router

Flutter's team-maintained navigation package. Uses URL-style paths (`/learn/lesson/:lessonId`) and supports nested routes, redirects, and deep linking. Replaces the lower-level `Navigator` API.

### `GoRoute`

Defines a single navigable path in go_router. Has a `path` and a `builder` that returns the widget for that screen.

### `StatefulShellRoute`

A go_router route type that preserves the state (scroll position, navigation stack) of each tab independently when the user switches between bottom navigation tabs. The app's four tabs are one.

### `StatefulShellBranch`

Each tab in a `StatefulShellRoute` gets a branch. Branches maintain their own navigation stack and scroll position independently.

---

## Data models and code generation

### Freezed

A Dart code-generation library that produces immutable data classes. Generates `==`, `hashCode`, `copyWith`, and — when combined with `json_annotation` — `fromJson`/`toJson`. Reduces boilerplate for model classes.

### `@freezed` annotation

Marks a class for Freezed code generation. Freezed generates the concrete implementation in the `.freezed.dart` file.

### Union type (Freezed)

A single Dart type with several distinct variants, like an enum whose values carry data. `ContentCard` (`lib/shared/models/content/content_card.dart`) is one: fifteen variants — `mcq`, `match`, `slider`, `sequence`, `predict` and so on — told apart by the `kind` field in the JSON (`@Freezed(unionKey: 'kind')`), and matched exhaustively with `switch`.

### `build_runner`

The Dart tool that runs the code generators (Freezed, json_serializable, the Riverpod generator, Drift). Run it after adding or changing an annotated class:

```bash
dart run build_runner build
```

It resolves conflicting outputs on its own; the old `--delete-conflicting-outputs` flag is gone.

---

## Persistence — Drift

### Drift

The database layer: a type-safe wrapper over SQLite that generates queries from Dart `Table` classes. It replaced Isar, whose development stalled. Runs in memory in tests (`NativeDatabase.memory()`), so no test needs a file on disk. Why, and how features reach it only through repositories: [`docs/architecture.md`](../docs/architecture.md), _Local Persistence Strategy_.

### Table

A Dart class extending Drift's `Table`, one per SQLite table. The app has three, in `lib/shared/storage/app_database.dart`: `UserSettings` (device-local state), `ProgressSnapshots` (the learner's progress as one row) and `AppInstalls`.

### `AppDatabase` / `AppDatabaseService`

`AppDatabase` is the generated database class; `AppDatabaseService.instance` holds the one open copy, and repositories read it lazily, so nothing is wired through constructors. Tests set the instance to an in-memory database in `setUp`.

### Schema version and migration

The database carries a version number, and every change to a table walks a fixed procedure — bump, dump the snapshot, regenerate the test helpers, add a migration test. All of it is [`docs/schema-migrations.md`](../docs/schema-migrations.md).

---

## Content pipeline

### Bank

One generated JSON file holding one kind of content — `lessons.json`, `dictionary_terms.json`, `collectibles.json` — under `assets/content/generated/`. The app loads each at startup through `lib/shared/repositories/bank_loader.dart`. Seventeen today.

### Extractor

`tool/extract_content.js`: the script that reads the design prototype's authored content and writes the banks, refusing to write anything if a cross-reference is broken. Its output is generated — never hand-edited. Its two siblings extract the icons and the card art the same way; all three are [`docs/content-pipeline.md`](../docs/content-pipeline.md).

### Envelope

The fixed wrapper around every bank file: `schemaVersion` and `items`, with the records inside `items`. The app refuses a bank whose envelope is missing or stamped with a version this build does not read. `lib/shared/repositories/bank_envelope.dart`, and the `schemaVersion` paragraph of the extractor's section in the README.

### Overlay (a language "laid over" the master)

How a translated bank lands on the English one: entry by entry, matched by `id`, field by field — a translated field wins, an omitted one stays English. `lib/shared/repositories/language_overlay.dart`; the whole picture is [`docs/localization.md`](../docs/localization.md).

### Fingerprint

A short hash of a piece of English text, stored beside its translation as `translatedFrom`. When the English changes, the fingerprint stops matching and the translation is known to be stale. `tool/draft_language/fingerprint.js`; the marks are explained in [`docs/localization.md`](../docs/localization.md), _What the files carry_.

### Register

A named list of exceptions, each with its reason written beside it, so the exception cannot be silent. Two in the repo: the translation register (`tool/draft_language/fields.js`) says which bank strings are keys rather than words; the `OffTokens` register (`CLAUDE.md`, _Colours_) holds every design value that is deliberately off-token.

---

## The way we work

### No-Op implementation

Short for *no operation*: a class that satisfies an interface but does nothing when called — every method has an empty body and returns at once. The app uses one wherever a real service is gated off or absent: `NoOpAnalyticsService` accepts every `logEvent` and discards it while Firebase is off, and `NoOpPaymentsService` owns nothing and cancels every purchase in a build with no store key. The rest of the app is then written as if the service were live, tests need no service running, and activation swaps one line in a provider instead of touching every call site. [`docs/architecture.md`](../docs/architecture.md), _Service Abstraction Pattern_.

### Stub

A placeholder implementation that exists so the code compiles and the wiring can be built around it, with the real work still to come. `AdMobAdsService` (`lib/services/ads/admob_ads_service.dart`) is one — every method throws "implement when ads go live". Different from a No-Op, which is finished and deliberately does nothing. [`docs/ads.md`](../docs/ads.md).

### Guard test

A test that reads the source tree and fails when a rule is broken, rather than testing behaviour: no comment cites the prototype, nothing outside the payments layer imports the store, no `build()` reads the clock. They end in `_guard_test.dart` under `test/unit/` — seven today — and run on every push and in CI (README, _Quality checks_).

### Smoke walk

The one test that boots the real app and plays through it: onboarding, a relaunch, a full lesson, a second relaunch, then reading the progress back. `integration_test/smoke_test.dart`; its rules — every step asserts, never `pumpAndSettle`, never landmark on authored copy — are in [`docs/testing.md`](../docs/testing.md). CI runs it on `main` only.

### Worktree

A second checkout of the same repository in another folder (`git worktree add`), so a branch can be worked on without disturbing the main checkout. Agent sessions work in `.claude/worktrees/<branch>/`, each with its own `build/`; `tool/clean_build_caches.sh --worktrees` reclaims those. [`docs/git-and-github-workflow.md`](../docs/git-and-github-workflow.md).

### Squash

Merging a branch as one commit on `main` (`gh pr merge --squash`), so `main` reads as a list of shipped changes while the step-by-step stays in the PR. Two consequences that look alarming and are not — a branch's own commits never appear on `main`, and `git branch -d` warns — are explained in [`docs/git-and-github-workflow.md`](../docs/git-and-github-workflow.md), _Merging_.

---

## Coffee terms

### Bean Belt

The tropical region between the Tropics of Cancer and Capricorn where coffee plants grow. Encompasses Central/South America, Africa, and Southeast Asia.

### Arabica / Robusta

The two main commercial coffee species. Arabica (60–70% of world production) is grown at higher altitudes and has a softer, more complex flavor. Robusta grows in lowland tropics, has more caffeine and a stronger, more bitter taste.

### Processing (coffee)

How the coffee cherry (the fruit surrounding the seed/bean) is removed after harvesting.

- **Washed (wet):** the fruit is removed before drying — produces clean, bright flavors.
- **Natural (dry):** the whole cherry is dried in the sun before hulling — produces fruity, heavier flavors.
- **Honey:** a middle ground; some fruit is left on while drying.

### Roast level

How long and at what temperature green beans are roasted. Light roast → more acidity and origin flavor. Medium roast → balanced. Dark roast → less acidity, more bitterness and body.

### Extraction

The process of dissolving flavor compounds from coffee grounds into water. Under-extracted = sour/weak. Over-extracted = bitter/harsh. Correct extraction = balanced.

### Acidity / Body / Sweetness

Three primary sensory axes in coffee tasting:

- **Acidity:** brightness or tartness (like citrus or wine)
- **Body:** the perceived weight and texture in the mouth (light, medium, full)
- **Sweetness:** natural sugars that balance acidity; more pronounced in lighter roasts
