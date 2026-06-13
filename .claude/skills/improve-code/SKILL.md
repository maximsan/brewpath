---
name: improve-code
description: Use when refactoring or improving a Coffee Quest screen, widget, or feature for testability, structure, and convention-consistency — extracting controllers and pure helpers out of widgets, removing magic numbers, adding unit tests, organizing per-screen folders, wiring debug toggles, or fixing accessibility — all without changing user-visible behavior. Invoke as `/improve-code <path-or-feature>`; defaults to the open file / current selection when no target is given.
---

# Improve Code Skill

Apply Coffee Quest's refactoring + testability playbook to a screen, widget, or
feature. Goal: clearer, more testable, convention-consistent code with **no change
to user-visible behavior**.

**Target:** the path/feature passed as the argument; otherwise the open file or
current selection.

## Operating rules

- Run all commands from `coffee_quest/`. After each step run `flutter analyze`
  (expect "No issues found!") and `flutter test` (expect green). Do not continue on
  red.
- Work in small, individually-verifiable steps. For large or structural changes,
  propose a short plan first; track progress with a todo list.
- Refactors must be behavior-preserving. When extracting numeric constants keep the
  **exact literal values** — do NOT derive them (`1 - 0.85 != 0.15` in IEEE-754).
  Let tests prove parity.
- Reuse existing helpers/widgets/providers before writing new code.
- Report honestly: if a test fails or a step is skipped, say so with the output.
- If a Flutter tooling crash hits a stale SwiftPM symlink (`PathExistsException` on
  `ios/Flutter/ephemeral/`), `rm -rf ios/Flutter/ephemeral` and retry. Note: the
  Bash working directory can flap — prefer absolute paths.

## Review lens — look for

1. **Magic numbers** — bare literals in `build()` / math. Only `0`/`1` may be inline.
2. **Logic trapped in the widget** — timers, state machines, sequencing, or async
   orchestration living inside a `State`.
3. **Side-effects that can't be unit-tested** — persistence/navigation called inline
   instead of injected.
4. **Oversized files** — soft cap ~250 lines; multiple `State`/widget classes, or UI
   mixed with logic, in one file.
5. **Accessibility gaps** — loading/empty/error states without `Semantics` labels, or
   animations that ignore reduced motion.
6. **Unsafe debug toggles** — hand-flipped `const` flags instead of compile-time off.
7. **Weak names** — single-letter identifiers (except loop `i`), `t`/`p` for
   animation values instead of intent names.
8. **Hardcoded navigation** — path strings or gate→destination logic duplicated in
   screens instead of the router.
9. **Organization** — single-use widgets not collocated with their screen; widgets
   shared by 2+ screens buried in one screen's folder.
10. **Docs drift** — how-to instructions duplicated across code comments and docs.

## Refactor playbook

- **Pure helpers:** move animation math / mappings / derivations into a sibling
  pure-Dart file (e.g. `*_animation.dart`) as named top-level functions; unit-test
  them directly, no widget pumping.
- **Controller:** pull orchestration/state/timers into a plain `ChangeNotifier` named
  `*Controller`, with dependencies injected as callbacks (e.g. `onSubmit`,
  `onFinished`, `isGateResolved`). Test with `fake_async` + fake callbacks. Reserve
  the name **Notifier** for Riverpod `@riverpod` classes; a widget-local
  `ChangeNotifier` is a **Controller** (mirrors Flutter's `TextEditingController` /
  `AnimationController`).
- **Thin the widget:** the screen becomes a view that creates the controller in
  `initState` / `didChangeDependencies`, listens, rebuilds, and disposes it.
- **Test views without a DB:** wrap in
  `ProviderScope(overrides: [repoProvider.overrideWithValue(fake)])`; test notifiers
  via `ProviderContainer`. Do **not** introduce a BLoC-style Page/View split — this
  is a Riverpod app, so provider overrides are the isolation seam.
- **Folders:** per-screen subfolder; collocate single-use widgets in
  `<screen>/widgets/`, keep widgets shared by 2+ screens in the feature's
  `presentation/widgets/`. Verify usage by grep, not assumption. Move files with
  `git mv` so history is preserved.
- **Debug toggles:** `static const X = bool.fromEnvironment('X')` (default off, safe
  by construction); add it to the README "Run-time flags" table and point to it from
  the code comment.
- **Accessibility:** loading/empty/error states get `Semantics` labels and respect
  `MediaQuery.disableAnimations` (reduced motion).

## Conventions

- `package:coffee_quest/…` imports inside `lib/` (never relative `../`).
- TSDoc only for complex logic / third-party integrations; skip self-evident code.
- Single source of truth for how-to docs (README); code comments point to it.
- Navigate by route `name` (`context.goNamed(...)`), never hardcoded paths;
  gate→destination policy lives in the router.
- Regenerate after model/provider/table changes: `dart run build_runner build`.
- Keep `CLAUDE.md` and `AGENTS.md` in sync when editing either.

## Deliverable

Report **findings → changes made → verification** (analyze result + test counts,
before/after). Call out anything intentionally left, risky, or out of scope.
