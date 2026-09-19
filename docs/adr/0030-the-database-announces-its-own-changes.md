# ADR-0030: The database announces its own changes

- **Status:** accepted
- **Date:** 2026-09-19

## Context

Progress was read from the database once, cached behind a provider, and
refreshed only when the code that wrote it remembered to say so. Every write
carried a second duty: change the row, then invalidate whatever displayed it.

The duty was forgotten twice in reviewed code. Reset Progress announced eight
things and not the ninth, so a wiped shelf kept its old count
([#289](https://github.com/maximsan/brewpath/issues/289)). And because an
announcement is a queued thing that arrives at a moment nobody chose, one of
them landed inside a route transition's build and tripped a framework assertion
([#299](https://github.com/maximsan/brewpath/issues/299)).

Drift can watch a query and re-run it when a write touches a table it read.
Nothing in the app used it.

## Decision

A screen reads progress through `SnapshotRepository.watch()`, a stream, and
never invalidates anything to see its own write. `progressSnapshotProvider` is
the single subscription; every display provider derives from it.

`SnapshotRepository.read()` stays, for two cases that a stream cannot serve:

- **A read-modify-write.** It needs the value at the instant it edits it, and a
  stream's latest delivered value may already be behind. `LessonCompletionService`
  is the clearest case: it samples the qualifying-day set before its writes and
  again after, and a stream would collapse the two.
- **A read taken straight after a write, whose answer must reflect it.** The
  stream will deliver, but not necessarily before the next line runs. Two sites
  need this and say so where they do it: the completion screen asking which
  lesson is queued behind this one, and the course-completion hand-off reading
  its own acknowledgement before it navigates.

What is not stored in the snapshot keeps its explicit refresh: the content bank
loaded from assets, the clock behind `currentDayProvider`, entitlement from the
payments service, and the settings row, which is a second table no snapshot
stream covers.

## Consequences

A write to progress reaches every screen showing it with nothing to remember,
and a screen added later inherits that for free. The #299 assertion is gone,
because there is no queued announcement left to flush on resume.

The cost is that "read it back immediately" is no longer free. A caller that
writes and then reads the derived value in the same breath has to say so, and
two places do. That is a narrower duty than the one it replaces: it binds
the code doing the reading, which can see the problem, rather than every write
site in the app, which cannot.

Drift's own change tracking is now load-bearing. It is in-process and local:
no network, no connection, no reconnect.
