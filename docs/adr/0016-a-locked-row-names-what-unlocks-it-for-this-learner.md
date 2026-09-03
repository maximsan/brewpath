# ADR-0016: A locked row names what unlocks it for this learner

- **Status:** accepted
- **Date:** 2026-09-01

## Context

Two locks look the same on screen and are not. One opens when you finish the
module before it. The other only opens when you buy the course, and no amount
of learning moves it — free is `m1l1`, `m1l2` and `m1l3`, permanently
([ADR-0007](0007-free-tier-is-the-first-three-lessons.md)).

The app wrote the first sentence over both. Someone who had not bought the
course read *"Finish Beans to unlock"* on Processing, which they cannot do,
because finishing Beans needs four lessons they do not own.

Ruled by the owner on [#91](https://github.com/maximsan/brewpath/issues/91),
which has the argument.

## Decision

**A locked row names the thing that would actually unlock it for the person
reading it.** When both locks are true at once, the purchase wins: someone who
cannot buy the course will never finish the module before it either.

| Surface | Has not bought it | Owns the course |
|---|---|---|
| Path lesson row | lock mark, `Part of Foundations`, tap opens the offer | no lock |
| Path module row | lock mark, `Part of Foundations · {n} lessons`, tap opens the offer | `Finish {previous} to unlock` |
| Reference shelf | `Visual guides come with the full course`, tap opens the offer | `Unlocks with {lesson}` |
| Today's lead card | lock mark, `Continues in Foundations`, then `{n} lessons ahead`, tap opens the offer | the ordinary lesson card |

The purchase lock is drawn in accent, progression in ink-mute — except on
Today's card, which *is* the accent, so its lock takes the accent's own ink. A
purchase-locked row stays tappable, because it is where someone meets the wall
and it should offer the way past. A lesson already finished never locks.

## Consequences

Every row that draws a lock now needs to know whether the reader owns the
course, not just how far they have got. Path reads that once, in
`pathModulesProvider`, and passes it down; otherwise every row widget would
reach for a provider of its own. Today reads it the same way, in
`LearnListView`.

Which lock applies is one function, `isLessonPurchaseLocked`, because three
surfaces and the router all have to give the same answer — and a rule copied
four times is four rules waiting to disagree.

While the entitlement is still loading, treat it as **not owned**. That is what
`courseEntitlement` asks of every caller.

**Revisit if the free set stops being a fixed list of lessons.** The rule above
assumes a row can be told which lock applies to it.
