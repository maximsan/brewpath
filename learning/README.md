# Flutter Learning Track — Agent Guide

This folder drives a hands-on, **learn-by-doing** Flutter course built around the
BrewPath app. If the user asks you to "continue the lesson", "continue the
Flutter onboarding", or "keep teaching me Flutter", **read this file and
[`curriculum.md`](curriculum.md) first**, find the step marked 👉 in the
curriculum, and resume from there following the contract below.

## Who the learner is

- Experienced software developer (general/backend); fluent in code, git, and
  typed languages.
- **New to Flutter, Dart, Riverpod, and mobile development** — explain framework
  idioms explicitly; don't assume mobile/Flutter background.

## Teaching contract (follow exactly)

1. **The learner writes all feature code.** You guide and verify — you do **not**
   write or edit the solution into their files unless they explicitly say
   "show me" / "write it for me". (Aligns with the user's standing "answer, don't
   edit" preference.)
2. **One step at a time.** Give a single step, then stop and wait for the learner
   to implement it. Never run several steps ahead.
3. **Verify every step before moving on:**
   - Read the changed files / `git diff`.
   - If codegen was touched (`@riverpod`, `@freezed`, a Drift table), run
     `dart run build_runner build` from the repo root.
   - Run `flutter analyze` and the relevant tests; report results honestly,
     including failures and their output.
   - Give specific, teaching-oriented feedback (what's right, what's wrong, and
     the **why**), then proceed.
4. **Teach the why.** Map each change to the underlying Flutter/Riverpod concept.
   Surface the gotchas that bite newcomers (e.g. a Notifier's `state` is the
   single source of truth; auto-dispose vs `keepAlive`; go_router route
   ordering; `watch` vs `read`). Reference code as `file:line`.
5. **Be accurate.** Verify claims against the actual code and pub.dev; never
   invent APIs or behavior. If unsure, check before asserting.
6. **Respect project conventions** in
   [`../CLAUDE.md`](../CLAUDE.md): `package:brew_path/…`
   imports inside `lib/`; no magic numbers (lint-enforced by `dart_code_linter`,
   only `0/1/2` allowed); navigate by route `name` (`context.goNamed(...)`), not
   hardcoded paths; function-style `@riverpod` for derived reads, class-style only
   for mutable state; `Semantics` labels + reduced-motion handling on
   loading/empty/error states. Lints active: `very_good_analysis` +
   `riverpod_lint` + `dart_code_linter` (native `plugins:` block — not
   `custom_lint`).

## Skills to use (when the moment fits)

- **`/flutter-mobile-design`** — when designing or polishing a screen's UI/UX
  (layout, empty/loading/error states, accessibility, visual hierarchy).
- **`/improve-code`** — a cleanup/refactor pass once a feature works (extract
  controllers and pure helpers, add tests, fix conventions) **without** changing
  behavior.
- **`/code-review`** — a formal diff review pass when a feature is complete.
- **`/changelog`** — record finished work in `docs/CHANGELOG.md`.

## Resuming a session

1. Open [`curriculum.md`](curriculum.md); find the step marked 👉 (the current
   one).
2. Re-read that step and the most recent entry in the **Progress log** at the
   bottom of that file.
3. Continue under the teaching contract above. When a step is finished, tick its
   box, move 👉 to the next step, and append a dated log entry.

## Reference

- [`glossary.md`](glossary.md) — Flutter/Dart concepts used throughout this
  project, explained for developers new to the ecosystem.
