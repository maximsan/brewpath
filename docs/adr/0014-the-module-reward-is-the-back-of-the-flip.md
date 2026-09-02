# ADR-0014: The module reward is the back of the flip, not a screen after it

- **Status:** accepted
- **Date:** 2026-08-31

## Context

The design source describes the end of a module in two conflicting ways. The
running prototype plays **one screen** that turns over to reveal the earned
collectible card. But four companion documents — `module.html`,
`lesson.html`, `screens-overview.html` and `v1 Readiness Audit.html` — list
the card as a **separate screen** that follows, and a finished
`ModuleRewardCardScreen` exists in the code to be that screen. The full
argument and evidence:
[#230](https://github.com/maximsan/brewpath/issues/230).

## Decision

**Finishing a module shows one screen.** First a full-screen Roasty
celebration (held 2.2 seconds), then the completion screen, and then — when
the user taps *Turn it over* — the whole screen turns over and shows the
card on its back. The back has a control that turns it back again.

**`ModuleRewardCardScreen` is not built.** In the running prototype it is
unreachable: the only function that navigates to it
(`continueFromModuleComplete` in `prototype/app.jsx`) is never called. It
can be opened only through the `?screen=` URL parameter, which exists for
design review. Its content is also a duplicate — the same heading, the same
card, the same button as the back of the flip.

The card cannot appear in both places: that would show the user the same
card twice in a row, under the same heading, with the same button.

## Consequences

The end of a module is one route with two beats, not the "two routes" the
original ticket described and not the "four beats over two routes"
[Audit C](https://github.com/maximsan/brewpath/issues/373) corrected it to —
both counted a screen that is never reached.

A finished, unreachable screen stays in the prototype, and four companion
documents still describe it as a real step. Anyone auditing against those
documents will report a missing screen. This record is the answer to that
report — it has already happened once.

**Revisit if** the prototype ever wires `module-card` into the real flow.
That would mean the missing call was a mistake to be fixed, not a leftover
to be ignored.
