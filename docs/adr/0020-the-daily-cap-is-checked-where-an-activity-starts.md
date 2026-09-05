# ADR-0020: The daily activity cap is checked where an activity starts

- **Status:** accepted
- **Date:** 2026-09-05

## Context

A free learner may do two activities a day (`docs/decisions.md` §8). Something
has to refuse the third, and there were two places to put that check.

**In the router.** Everything else the app refuses is refused there. One
function looks at the address the learner is heading for, decides whether they
may open it, and says where to send them instead. Screens do not make that
decision themselves — that rule is written down in `CLAUDE.md`, and the
onboarding gate, the Studio door and the course wall all follow it.

**On the way in.** Each row or button that opens a lesson or a drill asks
first, and shows the Plus sheet instead when the day is spent.

The router does not work for this one, and the reason is specific to a daily
cap. The router's decision **re-runs on its own** whenever the data behind it
changes — that is how buying the course unlocks a lesson without the learner
doing anything. Finishing an activity changes exactly that data, and it happens
**while the learner is still standing on the activity's own screen**. So at the
moment someone finishes their second lesson, the router would run again, find
them on a screen the cap now refuses, and move them off it — taking away the
results of the lesson they had just finished.

No other refusal has this problem, because a lesson already completed never
becomes locked again (ADR-0016). A cap on *how much* you may do cannot make
that promise: doing the thing is what spends it.

## Decision

The cap is checked where an activity starts, not in the router.

## Consequences

- The question is only ever asked about a screen the learner has not reached
  yet, so nobody is thrown out of something they are in the middle of.
- **Nothing catches a check that was forgotten.** Had the router owned this,
  a screen that failed to ask would still have been refused on arrival. Now a
  new way to start an activity that does not ask is simply a way around the
  cap. Two things make that mistake loud rather than silent: the four
  destinations that begin an activity are marked as such, and the ordinary
  navigation call refuses a marked destination outright while developing and
  in every test.
- This holds only while every way into an activity is a tap inside the app.
  The app claims `/card/*` links from outside and nothing else, so today there
  is no other way in. If that changes, this decision needs looking at again
  rather than patching.
- A drill that restarts in place — *Play again* — has to ask too. It never
  navigates anywhere, so nothing else would.
- The remaining allowance is worked out afresh every time it is asked, rather
  than being remembered and updated when the day's activity changes. A
  remembered answer that misses an update hands out a free activity, which is
  worth more than the reading it saves.
