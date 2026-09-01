# ADR-0014: Which words a practice game can ask about

- **Status:** accepted
- **Date:** 2026-09-01

## Context

The dictionary has around 70 coffee words in it. Two practice games ask the
learner about those words: the Vocab game
([#98](https://github.com/maximsan/brewpath/issues/98)) and Flashcards
([#97](https://github.com/maximsan/brewpath/issues/97)).

When we came to build them, both tickets ran into the same question, and
neither one could answer it on its own:

**If someone hasn't paid for the course, which words should a game ask them
about?**

Two things made that hard to answer.

First, not every word is taught. Most of them have a lesson that explains them.
A handful don't — they're words you'd see on a bag of coffee, but no lesson
covers them. We call those **reference words**, and `docs/decisions.md` §12 says
they're for paying users only.

Second, someone who hasn't paid gets 3 lessons out of 32
([ADR-0007](0007-free-tier-is-the-first-three-lessons.md)). That ADR said a game
should use the words those 3 lessons *mention*, rather than only the words they
*teach*. The 3 free lessons teach 6 words between them, and the shortest round
is 5 questions — so going by "teach" would mean almost the same 6 words every
time you played. But ADR-0007 never said how to decide whether a lesson
"mentions" a word.

## Decision

A game only asks about words the learner can actually get to.

- **If they've paid:** any word in the dictionary, reference words included.
- **If they haven't:** the word needs a lesson that teaches it, *and* it needs
  to turn up in one of the 3 free lessons. Reference words are never included,
  even if a free lesson happens to say one.

A lesson **mentions** a word when that word, or one of its other names, appears
as a whole word in text the lesson actually puts on screen.

Two things there are deliberate:

- **Whole word.** Otherwise "scale" would count as saying "SCA".
- **Text on screen.** A lesson card also carries data we never display, like an
  internal id or a colour. If we searched that too, a lesson could "mention" a
  word the learner never saw.

We don't save how many words each group gets. We work it out from the list of
free lessons every time we need it. ADR-0007 promised that making the free tier
bigger is a matter of editing that one list, and saving a count somewhere else
would break that promise.

Flashcards (#97) follows this same rule. It doesn't get to make up its own.

## Consequences

**Looking a word up and being asked about it are two different things, on
purpose.** §12 decides which words someone can look up in the dictionary. This
file decides which words a game can ask them about.

Both agree that reference words are for paying users. They disagree about taught
words: someone who hasn't paid can look up a word from lesson 20 and read it,
but a game will never ask them about it. Looking something up is fine. Asking a
question about it suggests we already taught it, and we haven't.

If you spot that these two rules don't line up, that's intentional. Please don't
change one to match the other.

**The wrong answers come from the same list as the right one.** Every question
has one correct answer and three wrong ones, and all four are picked from the
list above. That way a paying-only word can't slip in as a wrong answer.

**The word list depends on how the lessons are written.** If someone rewrites a
free lesson and the word "crema" drops out of it, that word quietly leaves the
free list. The rule didn't change — only the lesson text did. We decided that's
an acceptable price. The tests check things like "someone who hasn't paid has
enough words to play a round" instead of checking for an exact number, so normal
rewording won't break the build.

**Come back to this** if we ever translate the course into a language that
doesn't put spaces between words. The "whole word" rule assumes spaces.
