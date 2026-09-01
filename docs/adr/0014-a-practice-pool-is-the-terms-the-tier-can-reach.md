# ADR-0014: A practice pool is the terms the learner's tier can reach

- **Status:** accepted
- **Date:** 2026-09-01

## Context

What a drill may ask was an open question owned by nobody: the Vocab game
([#98](https://github.com/maximsan/brewpath/issues/98)) and Flashcards
([#97](https://github.com/maximsan/brewpath/issues/97)) each carried "are
reference-only terms fair quiz material?", and neither could answer it alone.

[ADR-0007](0007-free-tier-is-the-first-three-lessons.md) had already named the
rule — the practice vocab pool is the terms the free lessons **mention**, not
the ones they teach — but nothing said how a mention is decided, and nothing in
the app computed one.

## Decision

**A practice pool is whatever the learner's tier can reach.** Plus is drilled on
the whole glossary, reference terms included. Free is drilled on the **lesson
terms its free lessons mention** — never a reference term, which
`docs/decisions.md` §12 rules premium whatever mentions it.

**A mention is a term's name or one of its aliases appearing as a whole word in
a lesson's *visible* copy** — what a card renders, not the authored data it does
not (a cue's `tell` is an id; a visual card's subject is an axis slug). Whole
word, or *scale* reads as a mention of *SCA*.

**The pool is derived on every read and its size is stored nowhere**, which is
what makes ADR-0007's promise — that widening the free tier is a change to one
list — true rather than aspirational.

#97 inherits this and owes no decision of its own.

## Consequences

**What a drill may ask is not what the dictionary may show.** §12 governs the
latter and [#217](https://github.com/maximsan/brewpath/issues/217) builds it;
the two rules agree that reference terms are premium, and differ deliberately on
lesson terms — a free learner may *read* one the course has not reached, and may
not be *drilled* on it, because a question implies the course taught you. Neither
rule may be adjusted to match the other by anyone who notices they differ.

Both sides of a generated round are drawn from this one list, so scoping cannot
be half-applied: a premium term cannot reach a free learner as a wrong answer
either.

The cost is that the pool follows lesson prose — re-authoring a free lesson can
move it with no rule touched. Accepted, and bounded by tests asserting
properties rather than totals: that free can fill the shortest round, and that
it sits strictly between the taught-by reading and the glossary.

Revisit if the mention rule has to survive a language whose word boundaries are
not spaces.
