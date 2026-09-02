# ADR-0009: The running prototype wins over the Design System catalogue

- **Status:** accepted
- **Date:** 2026-08-27

## Context

The design source contains two descriptions of the same components.
`prototype/index.html` is the running prototype — the app people click
through, and the thing the Flutter app is built to match.
`prototype/Design System.html` is a catalogue of components with its own
stylesheet. Where the two disagree, there was no rule saying which one to
follow, and both were being cited as authoritative on the same components:
an audit marked the app wrong on two components by citing the catalogue,
while the app matched the running prototype. Example: the catalogue gives
answer-choice tiles a 2px corner radius; the running prototype gives them
`var(--r)`, which is 14px. `docs/README.md` already said the prototype beats
any document derived from it, but said nothing about these two files against
each other.

## Decision

**Where the two files disagree, `prototype/index.html` wins.** It is what a
user would actually see, and it is the file that is still being edited.

The catalogue remains useful for two things: components the running
prototype never shows, and rules it states in prose. It is not authoritative
for any value the running prototype also sets.

Any derived document that copied a catalogue value is corrected to the
running prototype's value, and must name the value it dropped — so the next
reader does not "fix" it back to the catalogue.

## Consequences

A disagreement about a component is now settled by reading one file. The
catalogue still looks authoritative when opened on its own, and this ADR is
the only thing that says it is not. The two files have since been compared
line by line: see *"The two prototype files, diffed in full"* in
`docs/design/03-design-system.md`.

**Revisit if** the catalogue becomes the file that is maintained, or gains a
component the running prototype never shows.

**Not settled here:** whether the catalogue's differing values are outdated
or intentional. This ADR only rules on which file the app follows — the
owner writes both.
