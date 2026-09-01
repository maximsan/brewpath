# ADR-0015: A locked row names what unlocks it for this learner

- **Status:** accepted
- **Date:** 2026-09-01

## Context

Two different locks look identical on screen. **Progression** opens by
learning — finish the module before it. The **purchase** does not open by
learning at all (ADR-0007: free is `m1l1`, `m1l2`, `m1l3`, permanently).

The app had been writing the progression sentence over both. A free learner
looking at *Processing* read *"Finish Beans to unlock"* — advice they cannot
take, because finishing Beans needs four lessons they do not own. The same
sentence sat under the Reference shelf, where it is worse: the earliest visual
guide is taught by `m1l6`, so **no lesson a free learner can complete will ever
open that section**.

Ruled by the owner on
[#91](https://github.com/maximsan/brewpath/issues/91) (22 Aug), for the
Reference row specifically. [#260](https://github.com/maximsan/brewpath/issues/260)
had already shipped the prototype's single string —
*"Visual guides unlock as lessons teach them"* — and recorded in its own body
that it was honest to both readings and useful to neither.

## Decision

**A locked row names the thing that would actually unlock it for the learner
reading it.** Where both locks are true at once, **the purchase wins**: someone
who cannot buy the course will never finish the module before it either, so
naming that module is the less true of the two answers.

This is one rule over three surfaces, and they read their words from one place
(`LockedRowCopy`):

| Surface | Free learner | Owns the course |
|---|---|---|
| Path lesson row | accent lock mark, `Part of Foundations`, tap raises the offer | no lock |
| Path module row | accent lock, `Part of Foundations · {n} lessons`, tap raises the offer | `Finish {previous} to unlock` |
| Reference shelf | `Visual guides come with the full course`, tap raises the offer | `Unlocks with {lesson}` |

The purchase lock is drawn in **accent**, progression in **ink-mute**, which is
the design's own split (`screens.jsx:1336` against `:1338`) and the design
system's rule that accent means *there is something to do*. A purchase-locked
row therefore stays tappable: it is the visible edge of the one-time purchase,
and a dead row refuses without ever saying what it costs.

A **completed** lesson is never purchase-locked. The wall can move behind a
learner, and replay is what they keep.

## Consequences

**Easier.** The free learner now meets the wall where it is, rather than
discovering it by tapping. Every locked surface answers the same question the
same way, and the words have one home, so a fourth locked surface inherits the
rule instead of re-deciding it.

**Harder.** Two locks now have to be distinguished wherever one is drawn — a
row needs to know the learner's entitlement, not just the course's shape. Path
reads it once, in `pathModulesProvider`, and passes it down as data; the
alternative is every row widget reaching for a provider of its own.

**Unresolved entitlement reads as locked**, which is what `courseEntitlement`
asks of every caller. Path awaits it with the rest of its banks, so there is no
frame in which a half-built Path is drawn at all.
