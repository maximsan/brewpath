# ADR-0025: A language ships with term matching; search and the voice may lag

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
  mention of `кава`.
- **Search** matches a typed query against term names and aliases only — never
  the definitions — folding accents through a fixed Latin-1 table that Polish
  `ł ą ę ś ź ż ć ń` and all Cyrillic fall outside.
- **The voice** reads a term aloud. [ADR-0012](0012-the-pronunciation-voice-is-the-platforms-through-stts.md)
  puts it on the platform's synthesizer, so which languages exist is the
  device's answer, not ours. Neither iOS nor Android publishes a Belarusian
  voice.

## Decision

**Term matching ships with the language.** The boundary test asks whether the
neighbouring character is a letter or a digit in any script, and each language
folder carries its own aliases. Because Polish and Belarusian inflect where
English does not, **a term's aliases are its inflected forms**: the drafting
tool generates them and review checks them. They are search keys rather than
prose, so review is what holds them, not the completeness test.

**Search and the voice may lag.** Search keeps the folding it has: an unfolded
letter makes matching stricter, never wrong. The voice asks the platform
whether it can speak the tag and hides the control when it cannot.

**The pronunciation hint is per language, and optional.** A language supplies
its own respelling or none; where it has none, the app shows nothing. English
respellings (`uh-RAB-ih-kuh`, `S-L twenty-eight`) are written for English
speakers and are never shown to a reader of another language.

## Consequences

The split is between *wrong* and *less helpful*. A mis-matched term silently
resizes the free practice pool, and nothing on screen says so; a query that
needs its diacritics typed is visible to the reader and costs them nothing they
can't see.

**Belarusian ships silent, and that is not a lag.** No platform voice exists for
it, so the control is simply absent and no hint replaces it — waiting would mean
never shipping the language. Aliases carrying inflections make those lists long,
perhaps ten forms where English needs three; that length is the price of the
free pool being right, and search benefits from the same forms.

Revisit search's folding if a shipped language's readers report missing their
own terms — it matters more than it looks, because search reads names and
aliases and nothing else.
