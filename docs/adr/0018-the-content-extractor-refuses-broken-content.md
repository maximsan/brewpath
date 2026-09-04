# ADR-0018: The content extractor refuses broken content, and computes what used to be typed twice

- **Status:** accepted
- **Date:** 2026-09-04

## Context

The course is written in the prototype and turned into the app's content
files by `tool/extract_content.js`. For its first months the script only
checked that ids resolved. A dictionary term could point at a lesson that
never mentions it and every check still passed — that is how the false
pointers in [#20](https://github.com/maximsan/brewpath/issues/20) reached
users. [#100](https://github.com/maximsan/brewpath/issues/100) rebuilt the
checks; this records the two rules they work by.

## Decision

**A field written in two places is computed from one.** A lesson's module
label, and the module list's copy of each lesson's title, points and time,
are generated from their source at extraction. If the typed copy disagrees,
the run fails and names both values. Nothing is silently corrected.

**Every check refuses to write. There is no warning level.** A check that
can be ignored is a check nobody reads. A genuine exception is allowed by
name, with a reason, in `tool/extract_content/exceptions.json` — a file the
repo owns, so it survives the prototype being replaced. An entry that names
nothing, or names something that no longer needs the exception, fails the
run.

## Consequences

Fixing content means editing the prototype, never the generated files.

A new content rule lands green or not at all, so a rule sometimes waits for
the owner's content edits — three did in
[#486](https://github.com/maximsan/brewpath/pull/486).

The exceptions file is the place to look when a check seems wrong. It must
never become a list of switched-off rules; every entry says why it is there.
