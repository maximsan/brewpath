# ADR-0006: The prototype authors v1, and the extracted JSON is the versioned contract

- **Status:** accepted
- **Date:** 2026-08-21

## Context

BrewPath's course content is authored in [`prototype/`](../../prototype/), a
React application that is **read-only** to this repository. `tool/extract_content.js`
reads it, validates the whole cross-reference graph, and writes ten JSON banks
into `assets/content/generated/`, which ship inside the app bundle.

This is an unusual arrangement and it has never been written down, so it reads
as an accident rather than a decision. Three pressures make writing it down
worth doing now:

- **The content is real.** Thirty-two lessons, seventy-two dictionary terms,
  twelve Coffee Challenges and the grove's two axes are all authored there.
  Moving authoring is no longer a small job.
- **The extractor renames nothing.** Prototype field names are emitted verbatim
  and Dart takes idiomatic names through serialization annotations. A
  prototype-side rename therefore does not fail to compile — it surfaces as a
  null inside a lesson, at the card that needed the field, in front of a
  learner.
- **Nothing stated which shape either side expected.** While the extractor and
  the app are regenerated together from one repository that is invisible. It
  stops being invisible the moment they can drift: a second course, a new card
  kind, or an extractor edit without a rerun.

The question underneath — *when does the extracted JSON stop being a build
artefact and become the canonical, hand-edited format?* — has never been
answered. Left unanswered, it gets answered under deadline by whoever hits it
first.

## Decision

> **Rule added (23 Aug 2026, from [Guide body copy is authored inside
> JSX](https://github.com/maximsan/brewpath/issues/271)):** in the prototype,
> **copy is data** — strings are never authored inside markup; markup renders
> data fields. The visual-guide bodies were the one gap, closed at the source
> the same day.

**The prototype remains the authoring environment for v1.** Course content is
written there and nowhere else. `prototype/` stays read-only to this repository:
it is the design source the app is measured against, so an edit there moves the
thing we are measuring ourselves by.

**The extracted JSON is the versioned contract between the design source and
the app**, not an incidental build artefact. Every generated bank carries a
`schemaVersion`; the extractor stamps it at the single function that builds
every envelope, and the app refuses any bank not written against the version it
reads, naming the asset and both numbers. Refusal is the whole behaviour —
there is no fallback bank and no degraded mode, because the banks ship inside
the binary and a mismatch is a build defect rather than a runtime condition.

The version is compared for **exact equality, not a minimum**. The two sides
always ship together, so any difference in either direction is a defect, and a
range check would wave through the stale-bank case the version exists to catch.
An unstamped bank fails for the same reason: that is precisely the output that
shipped before this contract existed.

What counts as a breaking change versus an additive one is documented in the
extractor's own header, next to the code whose change triggers a bump.

**The named trigger for promoting JSON to the canonical authored format is the
first post-v1 course** — the first content authored that the prototype was not
built to hold. Until that trigger fires, extraction stays one-way and the
prototype stays authoritative.

## Consequences

**What this makes easy.** A loader/bank mismatch becomes a loud refusal at
startup instead of a null three layers in. The design source stays a single
place, so a designer changes content without touching Dart. The extractor keeps
its all-or-nothing guarantee, and the version rides along inside the envelope it
already writes. Adding a bank costs nothing: it is stamped because it came
through the one envelope function.

**What this makes hard.** Content changes require a Node run and a commit of
regenerated output, so a copy fix is not a one-line edit. The version number
exists twice — in JavaScript and in Dart, which cannot share a constant — so it
can be bumped on one side only; a test reads the committed banks and asserts
they carry the Dart side's value, which converts that into a CI failure rather
than a refusal on a learner's device. And the arrangement inherits the
prototype's shape: content the prototype cannot express cannot be authored,
which is exactly what makes the promotion trigger meaningful rather than
arbitrary.

**What has to be revisited if this is wrong.** If content changes start
outpacing the prototype — a second course, a card kind the prototype cannot
represent, or non-engineers needing to edit copy without running Node — the
trigger has fired and JSON becomes canonical. Promotion means the extractor
becomes a one-time migration rather than a build step, the JSON gains an
authoring story of its own (validation, review, whatever replaces the
prototype's own checks), and this ADR is superseded rather than amended. The
`schemaVersion` this establishes is what makes that migration writable: it is
the thing a future migration would key off.

If the version proves too coarse — banks needing to move independently — note
that the extractor validates the reference graph *across* banks and writes all
or none, so they cannot meaningfully sit at different versions without that
guarantee going first.
