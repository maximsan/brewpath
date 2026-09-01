# ADR-0014: A practice pool is the terms the learner's tier can reach

- **Status:** accepted
- **Date:** 2026-09-01

## Context

The Coffee Dictionary is free and ungated in full — every learner may read
every entry ([#20](https://github.com/maximsan/brewpath/issues/20)). What a
*drill* may ask is a different question, and it was open in two tickets at
once: the Vocab game ([#98](https://github.com/maximsan/brewpath/issues/98))
and Flashcards ([#97](https://github.com/maximsan/brewpath/issues/97)) each
carried "are reference-only terms fair quiz material?" with neither owning it.

[ADR-0007](0007-free-tier-is-the-first-three-lessons.md) had already ruled that
the practice vocab pool is the **mentioned-in** terms of the free lessons, and
`docs/decisions.md` §2 records why *mentioned in* beat *taught by*: the
taught-by reading leaves a free learner too few terms to complete a single
round, which makes the game unplayable rather than merely small. Neither
document said how a mention is decided, and nothing in the app computed one.

## Decision

**A practice pool is whatever the learner's tier can reach.** Plus is drilled
on the whole glossary, reference-only terms included; free is drilled on the
terms its free lessons mention. This is the reference-only-terms ruling, and
#97 inherits it — flashcards intersect the saved shelf with the same set rather
than deciding it again.

**A mention is a term's name or one of its aliases appearing as a whole word in
a lesson's *visible* text** — the copy a card actually renders, never the
authored data it does not (a cue's `tell` is an id, a visual card's subject is
an axis slug). Whole word, because substring matching reads *scale* as a
mention of *SCA*.

**No count of the pool is written down anywhere.** It is derived from the free
lesson list on every read, which is what makes ADR-0007's promise — that
widening the free tier is a change to one list — true rather than aspirational.

## Consequences

The design's "12 free terms" is now a stale figure: it was measured on the
two-lesson tier ADR-0007 replaced, and the rule reproduces exactly 12 on that
pair while giving 17 on the current three lessons. Both sides of a generated
round — the terms asked about and the wrong answers offered — are drawn from
this one list, so a premium term name cannot leak to a free learner through
either.

The cost is that the pool depends on lesson prose: re-authoring a free lesson
can move it without anyone touching a rule. That is accepted, and bounded by
tests asserting properties rather than totals — that free can fill the shortest
round, that it is strictly wider than taught-by and strictly narrower than the
glossary. Revisit if the mention rule ever has to survive a language whose word
boundaries are not spaces.
