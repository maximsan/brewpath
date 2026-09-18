# ADR-0029: A language ships the same number of Roasty's lines as English

- **Status:** accepted
- **Date:** 2026-09-17

## Context

Roasty answers six moments with a handful of interchangeable lines each — four
ways to say "lesson done", three for "module done" — and picks one at random.
Making them reachable by a language folder
([#604](https://github.com/maximsan/brewpath/issues/604)) forced a shape, and
the shape decides whether a language may ship a different number of them.

Storing each occasion's lines as one list would let Polish ship two where
English has four, because the overlay replaces a field wholesale. But a list is
one field, and the translation marks are per field (ADR-0026), so fixing one
English typo would mark every line in that occasion as needing another read.

## Decision

One record per line, each with an id of its own. A language fills the same
slots English has.

An id is assigned once and kept when the line's words are edited: that is what
holds a translation onto its line, and what makes a typo fix re-stale one line
instead of its neighbours.

## Consequences

A translator who wants fewer lines than English cannot have them; they
translate all of them, loosely if need be. Nothing counts Roasty's quips, so
the cost is a translator's freedom, not a reader's experience.

Lifting this later means letting a language drop a line — a rule the overlay
does not have today, where empty text means omit rather than fall back to
English. It is additive, so it can wait until a language actually asks.
