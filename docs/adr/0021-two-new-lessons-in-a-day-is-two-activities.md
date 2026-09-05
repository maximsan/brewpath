# ADR-0021: Two new lessons in a day is two activities, not a separate refusal

- **Status:** accepted
- **Date:** 2026-09-05

## Context

`docs/decisions.md` §8 caps a free learner at two full learning/practice
activities a day, then adds a second rule: *"A free user cannot complete two
new lessons in one day."* Its list of allowed combinations leaves two lessons
out.

That clause was written when §7 gave the free tier **two** preview lessons and
the plan around it was a lesson a day. Pacing was the point.
[ADR-0007](0007-free-tier-is-the-first-three-lessons.md) replaced that with a
fixed set of three named lessons, so the free learner now reaches the same wall
whatever pace they take — the clause only decides whether that takes two days
or three.

The count and the clause also disagree about the same tap.
[#216](https://github.com/maximsan/brewpath/issues/216) requires that *"the
first two run normally"*, and the clause would refuse the second when the
second is a new lesson. Asked at
[#508](https://github.com/maximsan/brewpath/issues/508).

## Decision

**The two-activity count is the whole cap.** Two new lessons in a day is two
activities and is allowed; the clause does not bind.

Nothing in the app enforces a rule about *what kind* of activity was spent —
`mayStartActivity` counts entries and reads none of their types.

## Consequences

- A free learner can finish the three preview lessons in two days rather than
  three. That is the cost, and it is accepted: the preview is bounded by
  content, not by waiting, which is what §7 says.
- §8's allowed-combinations list is no longer exhaustive. It carries an
  amendment note pointing here, as §7's count does to ADR-0007.
- The cap stays a rule about volume alone. Had the clause been kept, the gate
  would need a second refusal that the Plus pitch cannot honestly sell —
  removing the *daily cap* is a named benefit, and this refusal would not have
  been one.
