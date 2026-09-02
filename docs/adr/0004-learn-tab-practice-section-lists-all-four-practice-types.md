# ADR-0004: The Learn tab's practice section lists all four practice types

- **Status:** accepted
- **Date:** 2026-08-19

## Context

The app has four kinds of practice: mini-games, the vocab game, flashcards,
and replaying a finished lesson. The streak counts all four; the daily limit
counts all four; Keep Sharp recommends all four. But the Learn tab's practice
section listed only two of them — lessons and mini-games. The two missing
kinds are the cheapest way for a free user to keep a streak: one vocab round
or one flashcard session protects the day, while mini-games need two runs and
that uses up the whole daily limit.

## Decision

The section is renamed to **`PRACTICE`** and lists **all four kinds**. The
vocab game and flashcards appear as two slim rows marked FREE at the top of
the Games group (shape accepted by the owner, 22 Aug 2026). Neither row ever
shows a lock: what they contain depends on which lessons are free, but the
features themselves are never paid. The prototype does not have these rows —
adding them is a deliberate invention, ruled at
[practice rows](https://github.com/maximsan/brewpath/issues/182).

**The rows are entry points and nothing more.** They open the same two
screens that the quick chips on Dictionary Home already open. The chips
stay. No pool, count, streak rule or limit changes, and no new state is
stored.

## Consequences

Each row is built together with its screen
([flashcards](https://github.com/maximsan/brewpath/issues/97),
[vocab game](https://github.com/maximsan/brewpath/issues/98)); the section
rename goes in with whichever of the two is built first. A user with no
saved flashcards must still see something useful — that is decided once, on
the flashcards ticket, for both entry points.

**Revisit if** a fifth kind of practice is added: this section and Keep
Sharp's rotation must always show the same list.
