# ADR-0009: The running prototype wins over the Design System catalogue

- **Status:** accepted
- **Date:** 2026-08-27

## Context

`prototype/` holds two descriptions of the same components, and they disagree.

`prototype/index.html` is the running prototype — the thing that boots and that
the app is built against. `prototype/Design System.html` is a catalogue of
components with its own stylesheet. Where both define a component, they mostly
agree; where they do not, there was no rule for which to follow.

Found while building the last two lesson card renderers (#391, #392). Audit F's
component matrix (#389) marked the app **wrong** on two entries, citing the
catalogue; the app matched the running prototype. Both sources were being
quoted as authoritative in the same tracker, on the same components.

| | `Design System.html` | `index.html` |
|---|---|---|
| `.mcq-choice` radius | 2px | `var(--r)` = 14px |
| `.match-item` radius | 2px | `var(--r)` = 14px |
| `.match-item.matched` | sage 10%, `--ink-mute` | sage 12%, `--ink` |
| `.mcq-choice.correct` / `.incorrect` | sage 12% / berry 8% | identical |
| `.pick-tile` | 14px | identical |

`docs/README.md` already ranks the prototype above any derived doc, but says
nothing about ranking the two prototype files against each other — so
`docs/design/` and `app_radii.dart` had transcribed the catalogue faithfully
and were not themselves at fault.

## Decision

**When the two disagree, `prototype/index.html` wins.** It is what a learner
would actually see, and it is the file that keeps moving — it was last edited
five days after the catalogue when this was found.

The catalogue stays useful for components the running prototype does not
exercise, and for the rules it states in prose. It is not authoritative on a
value the running prototype also sets.

A derived doc that transcribes a catalogue value the running prototype
contradicts is corrected to the running prototype, and says which value it
dropped, so the next reader does not "fix" it back.

## Consequences

**Easier.** A divergence report can be settled by reading one file. Audit F's
matrix (#389) can be read against `index.html` without re-litigating each
entry, and the two entries it marked wrong on this basis are not defects.

**Harder.** The catalogue is now a second-class source that still looks
authoritative when opened on its own. Anyone citing it for a value has to check
`index.html` first — this ADR is the only thing saying so.

**Revisit if** the catalogue becomes the maintained artifact, or gains a
component the running prototype never shows, in which case the ranking is worth
narrowing rather than reversing.

**Not settled here:** whether the catalogue's divergent values are stale or
deliberate. This rules on which the app follows, not on which is *right* — the
owner authors both.
