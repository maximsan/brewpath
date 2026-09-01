# ADR-0002: Term of the Day ships on Dictionary Home only

- **Status:** accepted
- **Date:** 2026-08-17

## Context

Two decisions weighted Term of the Day as a Learn-tab retention hook. The
citation behind that was false: the Learn tab computes the term and never
renders it — dead code — and the banner's compact variant, authored for a slim
placement, has no render site anywhere. The only real surfaces are Dictionary
Home's banner and the detail screen it opens. Argument:
[Coffee Dictionary](https://github.com/maximsan/brewpath/issues/20),
[free practice content](https://github.com/maximsan/brewpath/issues/57).

## Decision

Term of the Day surfaces on **Dictionary Home only**: the big banner and the
detail screen it opens. The Learn-tab placement and the compact banner variant
do not port. The pick stays a pure `(date, tier)` function with no storage.

## Consequences

The streak becomes the Learn tab's only daily hook. If v1 retention turns out
to need another one there, it returns as a deliberate invention in a
superseding ADR — the orphaned compact banner is the natural starting point —
never as a silent port of the dead code.

Build: [Term of the Day](https://github.com/maximsan/brewpath/issues/96).
