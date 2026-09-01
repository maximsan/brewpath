# ADR-0014: Drills only quiz a learner on terms their tier can reach

- **Status:** accepted
- **Date:** 2026-09-01

## Context

The dictionary holds about 73 coffee terms. Two practice drills quiz the learner
on them: the Vocab game ([#98](https://github.com/maximsan/brewpath/issues/98))
and Flashcards ([#97](https://github.com/maximsan/brewpath/issues/97)).

Both tickets asked the same question, and neither could answer it alone: **which
terms may a drill quiz a free learner on?**

Two things stood in the way.

First, not every term is taught. Most have a lesson that teaches them. About
eight do not — words you meet on a coffee bag rather than in the course. We call
those **reference terms**, and `docs/decisions.md` §12 says they are for paying
learners only.

Second, a free learner owns 3 of the 32 lessons
([ADR-0007](0007-free-tier-is-the-first-three-lessons.md)). That ADR said a drill
should use the terms those free lessons *mention*, not only the ones they
*teach*, because teaching alone leaves too few terms to fill a round. But it
never said how to tell whether a lesson mentions a term.

## Decision

A drill quizzes a learner only on terms their tier can reach.

- **Paying learner:** every term, reference terms included.
- **Free learner:** the term must be taught by some lesson *and* be named in one
  of the three free lessons. Never a reference term, even if a free lesson
  happens to name one.

A lesson **mentions** a term when the term's name, or one of its aliases,
appears as a whole word in the text that lesson puts on screen. Both parts of
that matter:

- *Whole word*, so that "scale" does not count as a mention of the term "SCA".
- *Text on screen*, because a lesson card also carries data the app never
  displays, such as an internal id or a colour value. Searching that too would
  let a lesson "mention" a word the learner never sees.

We never store how many terms a tier gets. We work it out from the list of free
lessons each time it is needed. ADR-0007 promised that widening the free tier is
a change to that one list; a stored count would break that promise.

Flashcards (#97) uses this rule and does not decide it again.

## Consequences

**Reading a term and being quizzed on it are different, on purpose.** §12 decides
what the dictionary *shows*; this ADR decides what a drill *asks*. Both agree
reference terms are paid-only. They differ on taught terms: a free learner can
look up a term from lesson 20 and read it, but will never be quizzed on it.
Looking a word up is fine; being asked it implies the course taught you, and it
has not. If someone later notices the two rules differ, that is intended. Please
do not change one to match the other.

**A question's wrong answers come from the same list as its right one**, so a
paid-only term cannot slip in as one of the three wrong options either.

**The pool follows the lesson text.** If someone rewrites a free lesson and the
word "crema" drops out of it, that term quietly leaves the free pool — no rule
changed, only the wording. We accepted that. The tests check statements like "a
free learner has enough terms to play a round" rather than exact numbers, so
ordinary rewording does not fail the build.

**Revisit this** if the course is ever translated into a language that does not
put spaces between words, because the whole-word rule assumes spaces.
