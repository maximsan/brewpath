# ADR-0024: A language ships with term matching; search and voice may lag

- **Status:** accepted
- **Date:** 2026-09-13

## Context

Three things read the content's language rather than merely displaying it, and
[the localization map](https://github.com/maximsan/brewpath/issues/345) asked
which of them must be ready before a language is allowed to ship
([#346](https://github.com/maximsan/brewpath/issues/346)).

- **Term matching** decides which dictionary terms a lesson mentions, and
  [ADR-0014](0014-a-practice-pool-is-the-terms-the-tier-can-reach.md) makes that
  the free tier's practice pool. Its word-boundary test counted only `a`–`z` and
  `0`–`9` as word characters, so in a script with no ASCII letters every
  position reads as a word boundary: in Belarusian, `кавамашына` counted as a
  mention of `кава`. A term's aliases are also its inflections, which are
  per-language by definition.
- **Search** matches a typed query against term names and aliases, folding
  accents through a fixed Latin-1 table. Polish `ł ą ę ś ź ż ć ń` and all
  Cyrillic fall outside that table, so `lyzka` does not find `łyżka`.
- **The voice** reads a term aloud. [ADR-0012](0012-the-pronunciation-voice-is-the-platforms-through-stts.md)
  puts it on the platform's synthesizer, so which languages exist is the
  device's answer, not ours.

## Decision

**Term matching ships with the language.** The boundary test asks whether the
neighbouring character is a letter or a digit in any script, and each language
folder carries its own aliases. A language is not admitted until both are done.

**Search and the voice may lag.** Search keeps working with the folding it has:
an unfolded letter makes matching stricter, never wrong. The voice asks the
platform whether it can speak the tag and hides the control when it cannot.

## Consequences

The split is between *wrong* and *less helpful*. A mis-matched term silently
resizes the free practice pool, and nothing on screen says so; a query that
needs its diacritics typed, or a missing speaker button, is visible to the
reader and costs them nothing they can't see.

The cost is that a language can ship with search a learner has to type
carefully into, and with no pronunciation at all on a device whose owner has
installed no voice for it. Revisit search's folding if a shipped language's
readers report missing their own terms.
