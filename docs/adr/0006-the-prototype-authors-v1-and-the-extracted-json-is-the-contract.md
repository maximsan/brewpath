# ADR-0006: The prototype authors v1, and the extracted JSON is the versioned contract

- **Status:** accepted
- **Date:** 2026-08-21

## Context

All course content is written in [`prototype/`](../../prototype/), a React
app that this repository treats as read-only. A script,
`tool/extract_content.js`, reads the prototype, checks that every
cross-reference resolves, and writes JSON files into
`assets/content/generated/`. Those JSON files ship inside the app. This
arrangement was never written down. It is also fragile in one specific way:
if a field is renamed in the prototype, the app still compiles — the missing
field shows up as a null inside a lesson at runtime.

## Decision

**Content is written in the prototype and nowhere else.** The prototype stays
read-only here. Inside the prototype, **text is data**: strings live in data
fields, never inside markup
([guide bodies](https://github.com/maximsan/brewpath/issues/271) closed the
one exception).

**The extracted JSON is a versioned contract between the prototype and the
app.** Every generated file carries a `schemaVersion`, written by the one
function that wraps every file. On startup, the app compares that version to
its own, and **refuses to load any file whose version is not exactly equal**,
naming the file and both numbers. Refusing is the entire behaviour — there is
no fallback and no degraded mode, because the files ship inside the app
binary, so a mismatch means the build itself is broken. A file with no
version fails the same way. The extractor's header documents which changes
require bumping the version.

**The JSON becomes the place content is written the day a second course is
started** — the first content the prototype was not built to hold. Until
then, extraction runs one way and the prototype is the source of truth. That
switch would be a new ADR replacing this one.

## Consequences

A mismatch between the app and its content files fails loudly at startup
instead of as a null deep inside a lesson. Fixing a typo in content requires
running the extractor and committing its output — it is not a one-line edit.
The version number exists in two places, the JavaScript extractor and the
Dart loader, and they cannot share a constant; a test checks that the
committed files carry the Dart side's number, so bumping only one side fails
CI. Content the prototype cannot represent cannot be written at all — which
is exactly what makes "a second course" the right moment to switch.
