# ADR-0009: The running prototype wins over the Design System catalogue

- **Status:** accepted
- **Date:** 2026-08-27

## Context

`prototype/` holds two descriptions of the same components: `index.html`, the
running prototype the app is built against, and `Design System.html`, a
catalogue with its own stylesheet. Where they disagree there was no rule for
which to follow, and both were being quoted as authoritative in the same
tracker on the same components — an audit marked the app wrong on two
entries, citing the catalogue, while the app matched the running prototype
(found on the lesson-card radii: the catalogue says 2px, the running
prototype `var(--r)` = 14px). `docs/README.md` ranks the prototype above any
derived doc, but said nothing about ranking the two prototype files against
each other.

## Decision

**When the two disagree, `prototype/index.html` wins.** It is what a learner
would actually see, and it is the file that keeps moving.

The catalogue stays useful for components the running prototype does not
exercise, and for the rules it states in prose. It is not authoritative on a
value the running prototype also sets.

A derived doc that transcribed a catalogue value the running prototype
contradicts is corrected to the running prototype, and says which value it
dropped, so the next reader does not "fix" it back.

## Consequences

A divergence report is settled by reading one file. The catalogue is now a
second-class source that still looks authoritative when opened on its own —
this ADR is the only thing saying so. Both files have since been diffed in
full: see *"The two prototype files, diffed in full"* in
`docs/design/03-design-system.md`.

**Revisit if** the catalogue becomes the maintained artifact, or gains a
component the running prototype never shows.

**Not settled here:** whether the catalogue's divergent values are stale or
deliberate. This rules on which the app follows — the owner authors both.
