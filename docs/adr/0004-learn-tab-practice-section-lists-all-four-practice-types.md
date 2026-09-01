# ADR-0004: The Learn tab's practice section lists all four practice types

- **Status:** accepted
- **Date:** 2026-08-19

## Context

The domain model has four practice types — mini-games, the vocab game,
flashcards, lesson replay — and the streak, the daily allowance and Keep Sharp
all count all four. The Learn tab listed only two. The missing two are a free
learner's cheapest streak paths: one activity protects the day, where
mini-games cost both under the daily cap.

## Decision

The section renames to **`PRACTICE`** and lists **all four types**. The vocab
game and flashcards lead the Games group as its first entries, slim rows
marked FREE (owner-accepted shape, 22 Aug 2026). Both are free with no lock
treatment — content-scoped, never feature-gated — an explicit invention over
the prototype, ruled at
[practice rows](https://github.com/maximsan/brewpath/issues/182).

**This adds entry points and nothing else.** The rows open the same surfaces
Dictionary Home's quick chips open; the chips remain; pools, tier scoping,
streak and allowance accounting are untouched; no new state exists.

## Consequences

Each row lands with its surface's build
([flashcards](https://github.com/maximsan/brewpath/issues/97),
[vocab game](https://github.com/maximsan/brewpath/issues/98)); the rename
rides whichever builds first. An empty flashcards deck must not be a dead
end — answered once, for both entry points, on the flashcards ticket.

**Revisit if** the practice family gains a fifth type: this section and Keep
Sharp's rotation must stay the same list.
