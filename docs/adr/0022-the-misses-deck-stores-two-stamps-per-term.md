# ADR-0022: The Misses deck stores two stamps per term, not a set of ids

- **Status:** accepted
- **Date:** 2026-09-06

## Context

The Vocab game's third deck holds the terms the learner got wrong. A wrong
answer in any deck adds a term, a correct answer in any deck takes it out
again, and the deck follows the learner across devices — so it lives in the
progress snapshot, in the scope Reset clears.

The obvious shape is a set of missed term ids. It cannot merge. Removal is a
real operation here, and the snapshot's join is a union: a term cleared on the
phone comes straight back from the tablet that still holds it, and no later
correct answer can ever dislodge it. Ruled at
[#298](https://github.com/maximsan/brewpath/issues/298).

## Decision

**Store per term two timestamps** — `lastMissedAt` and `lastCorrectAt`,
milliseconds since epoch — merged by taking the `max` of each stamp
independently. A term is in the deck when `lastMissedAt > lastCorrectAt`; a tie
clears it.

Milliseconds rather than day numbers, because miss-then-correct inside one
sitting is the ordinary way a term leaves the deck and a day cannot order it.

## Consequences

- Per-stamp `max` is idempotent, commutative and associative, so the snapshot
  stays a lattice join and the merge laws hold over the new field unchanged.
- **A correct answer writes a key even for a term this device never saw
  missed.** It has to: the peer may hold a miss this device has not seen, and a
  clear that cannot out-stamp it is a clear that never happens. The record is
  therefore every answered term, which is why the field is `termAnswers` and
  not `missedTerms`.
- The map is bounded by the glossary rather than by the misses — a couple of
  hundred entries of two integers — so it needs no pruning or cap, and the deck
  has no decay.
- Reset empties the deck by construction, because the field sits inside
  `ClearedByReset` and the wipe is one assignment.
- A device with a badly wrong clock can hold a term in or out of the deck until
  it is corrected, the same limit the snapshot's other stamped fields carry.
