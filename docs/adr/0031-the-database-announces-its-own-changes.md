# ADR-0031: The database announces its own changes

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

## Decision

The repository announces its own writes. `SnapshotRepository.write()` publishes
the new snapshot on `changes`, and `ProgressSnapshotState` holds the single
subscription; every display provider derives from it and never invalidates
anything to see a write.

The announcement lives in `write()` because that is the one door: nothing else
in the app touches the snapshot row. A caller cannot forget a duty it does not
have, which is the whole of what #289 was.

The provider opens on `read()` and takes later versions from the stream. A
value that arrives only by subscription cannot answer a caller that merely
wants it now — nothing subscribes for a one-shot read, so its future never
completes — and several callers want exactly that.

**Not Drift's `watchSingle`**, which was the obvious mechanism and is the one
this started as. Cancelling a Drift query stream schedules a zero-duration
timer to close the query, and `testWidgets` asserts no timer is pending once
the widget tree is disposed. That check runs before any `tearDown`, so there is
no point at which the timer can be flushed; nineteen widget tests failed on it,
and neither keeping the provider alive nor pumping in teardown moved it. The
alternative was to relax the invariant for the whole widget suite, which trades
a real check in every test for one provider's convenience.

`SnapshotRepository.read()` stays, for two cases the stream cannot serve:

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
payments service, and the settings row, which is a second table the snapshot's
announcement does not cover.

## Consequences

A write to progress reaches every screen showing it with nothing to remember,
and a screen added later inherits that for free. The #299 assertion is gone,
because there is no queued announcement left to flush on resume.

The cost is that "read it back immediately" is no longer free. A caller that
writes and then reads the derived value in the same breath has to say so, and
two places do. That is a narrower duty than the one it replaces: it binds
the code doing the reading, which can see the problem, rather than every write
site in the app, which cannot.

What this does not buy, which watching the query would have: a change made to
the database from outside app code — a cloud restore, a background sync, a
second device — is still invisible. Nothing writes the snapshot that way today,
and the sync transport is deliberately absent, so the gap is theoretical until
one arrives. When it does, it arrives with a write path of its own, and that
path announces on `changes` like every other.

The mechanism is in-process and local: one broadcast stream, no network, no
connection, no reconnect.
