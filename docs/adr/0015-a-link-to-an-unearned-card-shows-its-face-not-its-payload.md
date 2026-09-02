# ADR-0015: A link to an unearned card shows its face, not its payload

- **Status:** accepted
- **Date:** 2026-09-02

## Context

A shared `/card/<id>` link usually names a card its recipient has not earned —
under the free tier that is the normal case, not an edge one. Two rulings
disagreed about what they should then see.
[#34](https://github.com/maximsan/brewpath/issues/34) ruled a locked preview.
[#385](https://github.com/maximsan/brewpath/issues/385) shipped the opposite —
the link opens nothing — because the grid masks an unearned card and honouring
the link would hand out through a URL what the tile withholds.

The masking is not really about sharing. A sender can only share a card they
earned, and a recipient seeing something they do not have is the whole point of
sending it. What the masking protects against is **guessing**: ids read `c1`,
`c2`, `c-m2l1`, so anyone can walk the collection by typing. A link and a typed
URL are indistinguishable to the app, so both rulings were pricing the same
request differently.

## Decision

**An unearned card renders its face and nothing else.** The art, the title, the
lesson that earns it, and a way in.

**Its payload stays withheld** — not the summary, not the keepsake line. Those
are the reward for finishing the lesson, and they are what a guesser would be
farming.

A guesser therefore learns a card exists and what it is called, which is close
to what the grid already tells them: a muted silhouette reading `???`.

## Consequences

The share is worth sending, and the collection keeps the part worth collecting.

Two shipped things now diverge from this ruling and change when
[#171](https://github.com/maximsan/brewpath/issues/171) builds it:

- `lib/features/cards/presentation/card_deep_link.dart` opens nothing for an
  unearned card, and its comment states that as the rule.
- `test/widget/features/cards/card_sheet_test.dart` asserts it — *"a link to an
  unearned card opens nothing"*.

The card sheet gains a second state, so it can no longer assume its card is
earned. If the free tier ever widens far enough that most links land on earned
cards, the withholding buys less and is worth revisiting.
