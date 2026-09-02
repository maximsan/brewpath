# ADR-0002: Term of the Day ships on Dictionary Home only

- **Status:** accepted
- **Date:** 2026-08-17

## Context

Two earlier decisions treated Term of the Day as a daily reason to open the
Learn tab, citing the prototype as showing it there. That citation is false.
In the prototype, the Learn tab computes the term and never displays it —
the computation is dead code. A compact version of the banner exists in the
code but is not rendered anywhere either. The term really appears in two
places only: the banner on Dictionary Home, and the detail screen that
banner opens. Argument:
[Coffee Dictionary](https://github.com/maximsan/brewpath/issues/20),
[free practice content](https://github.com/maximsan/brewpath/issues/57).

## Decision

Term of the Day appears on **Dictionary Home only**: the banner, and the
detail screen it opens. The Learn-tab placement and the compact banner are
not built. How the term is picked does not change: a pure function of the
date and the user's tier, storing nothing.

## Consequences

The streak becomes the only thing on the Learn tab that changes daily. If v1
retention turns out to need a second daily element there, that is a new
decision recorded in a new ADR — the unused compact banner is the natural
starting point. It must not arrive as a silent port of the dead code.

Build ticket: [Term of the Day](https://github.com/maximsan/brewpath/issues/96).
