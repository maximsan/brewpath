# ADR-0006: The prototype authors v1, and the extracted JSON is the versioned contract

- **Status:** accepted
- **Date:** 2026-08-21

## Context

Course content is authored in [`prototype/`](../../prototype/), which is
read-only to this repository. `tool/extract_content.js` reads it, validates
the whole cross-reference graph, and writes the JSON banks into
`assets/content/generated/`, which ship inside the app. This arrangement had
never been written down, and nothing said which shape either side expected —
a prototype-side rename does not fail to compile, it surfaces as a null
inside a lesson at runtime.

## Decision

**The prototype remains the authoring environment for v1.** Content is
written there and nowhere else, and `prototype/` stays read-only here. In the
prototype, **copy is data**: strings are never authored inside markup
([guide bodies](https://github.com/maximsan/brewpath/issues/271) closed the
one gap).

**The extracted JSON is the versioned contract.** Every generated bank
carries a `schemaVersion`, stamped at the single function that builds every
envelope. The app compares it for **exact equality** and refuses any bank
that does not match, naming the asset and both numbers. Refusal is the whole
behaviour — no fallback, no degraded mode: the banks ship inside the binary,
so a mismatch is a build defect. An unstamped bank fails the same way. What
counts as breaking versus additive is documented in the extractor's own
header.

**JSON becomes the canonical authored format at the first post-v1 course** —
the first content the prototype was not built to hold. Until then extraction
is one-way and the prototype is authoritative. Promotion supersedes this
record; it is never amended into it.

## Consequences

A loader/bank mismatch is a loud refusal at startup instead of a null three
layers deep. Content changes require a Node run and a commit of regenerated
output, so a copy fix is not a one-line edit. The version exists twice — in
JavaScript and in Dart, which cannot share a constant — and a test asserts
the committed banks carry the Dart side's value, turning a one-sided bump
into a CI failure. Content the prototype cannot express cannot be authored;
that limit is exactly what makes the promotion trigger meaningful.
