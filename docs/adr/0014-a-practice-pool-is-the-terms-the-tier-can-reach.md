# ADR-0014: Which words a practice game can ask about

- **Status:** accepted
- **Date:** 2026-09-01

## Context

Around 70 coffee words live in the dictionary. Two practice games ask the
learner about them: the Vocab game
([#98](https://github.com/maximsan/brewpath/issues/98)) and Flashcards
([#97](https://github.com/maximsan/brewpath/issues/97)). When we came to build
them, both ran into the same question and neither could answer it alone:

**If someone hasn't paid for the course, which words should a game ask them
about?**

Someone who hasn't paid gets 3 lessons out of 32
([ADR-0007](0007-free-tier-is-the-first-three-lessons.md)). That ADR said a game
should use the words those 3 lessons *mention*, not only the words they *teach* —
the 3 lessons teach just 6 words between them, and the shortest round is 5
questions, so going by "teach" would mean nearly the same round every time. But
it never said how to decide whether a lesson mentions a word.

## Decision

A game only asks about words the learner can actually get to.

- **Paid:** every word in the dictionary.
- **Not paid:** the words one of the 3 free lessons mentions. A word that no
  lesson teaches at all stays paid-only, which is what `docs/decisions.md` §12
  already says.

A lesson **mentions** a word if that word turns up in the text the lesson shows
on screen: its title, the writing on its cards, the answer choices, and so on.
Some words have a second name, and those count too — "Staling" is also called
"stale", so a lesson saying *"the coffee goes stale"* counts as mentioning it.

Two details decide whether this works:

**We look for whole words, not for letters sitting inside other words.** One of
the free lessons uses the word *"typical"*. The dictionary has a coffee variety
called *Typica*, taught in a lesson you have to pay for. If we searched for
letters inside words, we would find "Typica" inside "typical" and hand a paid
word to someone who hasn't paid. The same trap catches *"cascara"*, which
contains the letters of *SCA*.

**We only search the text the learner actually sees.** A lesson card holds more
than it displays — the colour used to draw a diagram, an internal name for which
picture to show. If we searched that too, a lesson could "mention" a word that
never appeared on screen.

We don't save how many words each group gets. We work it out from the list of
free lessons each time. ADR-0007 promised that growing the free tier means
editing that one list, and a saved count would break that.

Flashcards (#97) follows this rule rather than making up its own.

## Consequences

**Looking a word up isn't the same as being asked about it.** §12 decides what
the dictionary shows; this decides what a game asks. Someone who hasn't paid can
look up a word from lesson 20 and read it, but no game will ask them about it —
a question implies we taught it. The two rules differ on purpose, so don't
change one to match the other.

**Wrong answers come from the same list as the right one**, so a paid-only word
can't slip in as a wrong option.

**The word list follows the lesson text.** Rewrite a free lesson so that "crema"
drops out of it, and that word quietly leaves the free list — the rule didn't
change, the wording did. We accepted that. The tests check that someone who
hasn't paid has enough words to play a round, rather than checking for an exact
number.

**Come back to this** if we ever translate the course into a language that
doesn't put spaces between words. The "whole word" rule assumes spaces.
