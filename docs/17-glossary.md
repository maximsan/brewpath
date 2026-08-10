# BrewPath — Glossary

A reference for Flutter/Dart concepts used throughout this project, written for developers new to the ecosystem.

---

## Flutter & Dart

### `async` / `await`

Dart's syntax for asynchronous code. `async` marks a function as asynchronous; `await` pauses execution until a `Future` resolves — similar to JavaScript `async/await` or Swift `async/await`.

### `BuildContext`

An object Flutter passes to widget `build()` methods. It represents a widget's position in the widget tree and is needed to navigate, show dialogs, or read inherited data. Riverpod reduces how often you need `BuildContext` in business logic.

### `ConsumerWidget` / `ConsumerStatefulWidget`

Riverpod-aware Flutter widgets. Replace the standard `StatelessWidget` / `StatefulWidget` when the widget needs to read a Riverpod provider. The `build()` method receives a `WidgetRef ref` argument instead of just `BuildContext`.

### `Future<T>`

A Dart type representing a value that will be available later (asynchronous result). Like a `Promise<T>` in JavaScript or `Task<T>` in C#.

### `sealed class`

A Dart class modifier (Dart 3+) that restricts which classes can extend or implement it. Used with Freezed's union types so the compiler can exhaustively check all variants in a `switch` statement.

### `StatefulShellRoute` (go_router)

A go_router route type that preserves the state (scroll position, navigation stack) of each tab independently when the user switches between bottom navigation tabs.

### Widget

The fundamental building block of Flutter UIs. Everything visible on screen is a widget — text, buttons, layout containers. Widgets are immutable; Flutter rebuilds them when state changes.

---

## Riverpod

### `@riverpod` annotation

A code-generation annotation from `riverpod_annotation`. Applied to a Dart function or class, it generates a type-safe provider. Requires running `build_runner` to produce the `.g.dart` file.

### Provider

A Riverpod object that holds a piece of state or a service. Widgets and other providers can `watch` or `read` a provider to access its value. Providers are lazy by default — they compute their value only when first accessed.

### `Ref`

The first argument to every Riverpod provider function. Used to access other providers (`ref.watch`, `ref.read`) and to register lifecycle callbacks (`ref.onDispose`).

### `WidgetRef`

The `ref` object available inside a `ConsumerWidget.build()`. Behaves like `Ref` but is tied to the widget's lifecycle.

---

## Freezed

### Freezed

A Dart code-generation library that produces immutable data classes. Generates `==`, `hashCode`, `copyWith`, and — when combined with `json_annotation` — `fromJson`/`toJson`. Reduces boilerplate for model classes.

### `@freezed` annotation

Marks a class for Freezed code generation. The class must be abstract; Freezed generates a concrete implementation in the `.freezed.dart` file.

### Union type (Freezed)

A single Dart type with multiple distinct variants, similar to an enum with associated data. Used for `LessonStepModel` which has four variants: `MultipleChoiceStep`, `DragDropStep`, `SliderStep`, `TapOrderStep`. Pattern-matched exhaustively with `switch`.

### `part"../../docs"` directive

A Dart language feature that splits a library across multiple files. `part '../../docs/x.freezed.dart'` tells Dart that the generated file is part of the same library. Required for Freezed and json_serializable generated code.

---

## Isar

### Isar

A fast, embedded NoSQL database for Flutter/Dart. Stores Dart objects natively without SQL. Supports reactive queries (automatically updates UI when data changes). Used in this project for user progress, settings, and card collection.

### `@collection`

An Isar annotation that marks a Dart class as a database table (called a "collection" in Isar). Isar's code generator produces the schema and query API for it.

### Schema

In Isar, a schema is the metadata description of a collection (its fields and types). Schemas must be passed to `Isar.open()` at startup. Generated from `@collection` classes by `isar_generator`.

### `IsarService`

A singleton in this project (`lib/shared/storage/isar_service.dart`) that holds the open `Isar` instance and the list of registered schemas. Phase 3 adds `@collection` classes here.

---

## build_runner

### `build_runner`

A Dart tool that runs code generators (Freezed, json_serializable, Riverpod generator, Isar generator). Must be run manually after adding or modifying annotated classes.

```bash
dart run build_runner build --delete-conflicting-outputs
```

The `--delete-conflicting-outputs` flag removes stale generated files before regenerating.

### Generated files (`.g.dart`, `.freezed.dart`)

Files produced by `build_runner`. Never edit these manually — they are overwritten on the next build. They are committed to version control in this project.

---

## go_router

### go_router

Flutter's team-maintained navigation package. Uses URL-style paths (`/learn/lesson/:lessonId`) and supports nested routes, redirects, and deep linking. Replaces the lower-level `Navigator` API.

### `GoRoute`

Defines a single navigable path in go_router. Has a `path` and a `builder` that returns the widget for that screen.

### `StatefulShellBranch`

Each tab in a `StatefulShellRoute` gets a branch. Branches maintain their own navigation stack and scroll position independently.

---

## Coffee Terms

### Bean Belt

The tropical region between the Tropics of Cancer and Capricorn where coffee plants grow. Encompasses Central/South America, Africa, and Southeast Asia.

### Arabica / Robusta

The two main commercial coffee species. Arabica (60–70% of world production) is grown at higher altitudes and has a softer, more complex flavor. Robusta grows in lowland tropics, has more caffeine and a stronger, more bitter taste.

### Green coffee

Unroasted coffee beans. Exported in this form before being roasted at or near their destination.

### Processing (coffee)

How the coffee cherry (the fruit surrounding the seed/bean) is removed after harvesting.

- **Washed (wet):** the fruit is removed before drying — produces clean, bright flavors.
- **Natural (dry):** the whole cherry is dried in the sun before hulling — produces fruity, heavier flavors.
- **Honey:** a middle ground; some fruit is left on while drying.

### Roast level

How long and at what temperature green beans are roasted. Light roast → more acidity and origin flavor. Medium roast → balanced. Dark roast → less acidity, more bitterness and body.

### Extraction

The process of dissolving flavor compounds from coffee grounds into water. Under-extracted = sour/weak. Over-extracted = bitter/harsh. Correct extraction = balanced.

### Brew ratio

The ratio of coffee to water, usually expressed as grams of coffee per gram of water (e.g., 1:15). Controls strength.

### Acidity / Body / Sweetness

Three primary sensory axes in coffee tasting:

- **Acidity:** brightness or tartness (like citrus or wine)
- **Body:** the perceived weight and texture in the mouth (light, medium, full)
- **Sweetness:** natural sugars that balance acidity; more pronounced in lighter roasts
