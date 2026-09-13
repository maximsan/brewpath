# ADR-0026: A language ships once complete, and native review follows

- **Status:** accepted
- **Date:** 2026-09-13

## Context

[ADR-0008](0008-a-language-is-a-folder.md) settled that AI drafts a language and
the owner reviews it, but not where review happens, what records that a piece of
text has been read, or what "whole" means. The map asked for named stages and
owners ([#347](https://github.com/maximsan/brewpath/issues/347)).

Two facts shape the answer. Translation happens **after** extraction, so the
tool reads the generated English banks and never the prototype. And a language
is about **4,700 pieces of text, some 35,600 words** — a short novel. An
approval gate an approver cannot read is bookkeeping, not a gate, and holding a
language until someone has read all of it end to end is how languages never
ship.

## Decision

**A language goes live when it is complete, not when it has been read.** The
tool drafts it, the tool marks it complete, and a test proves that claim
independently. Native review follows afterwards, piece by piece, and reaches
readers in later updates.

**Complete means every piece of reader-facing prose** — lessons, the dictionary,
the app's own labels, the companion's lines. The pronunciation hints
[ADR-0025](0025-a-language-ships-with-term-matching-search-and-voice-may-lag.md)
made optional do not hold a language back, and alias lists are search keys that
review holds rather than the completeness test.

**Each piece of text carries two marks:** which English text it was translated
from, and whether a native speaker has read it. The first is a fingerprint — when
the English changes, the fingerprint stops matching and the tool knows that piece
needs redoing. The second is what lets anyone ask what nobody has read yet.

Marks are **per piece of text, not per entry**: a typo fixed in a term's long
explanation must not re-open its name, its example and its quiz, and at the
lesson banks one entry is a whole lesson with every card in it.

## Consequences

Readers of a new language get agent-drafted wording until review catches up.
That is the cost of shipping at all, and it is bounded: the marks say exactly
what is unread, so review is a queue that drains rather than a wall to climb
before the first reader arrives.

Two marks and a per-piece grain are more bookkeeping than one mark per entry
would have been. It buys the only two questions worth asking — *what has the
English outrun?* and *what has nobody read?* — and it keeps ordinary maintenance
cheap, which at 35,600 words a language is what decides whether the second
language ever happens.

A language cannot be complete while any reader-facing text sits outside the
mechanism, which is why [#604](https://github.com/maximsan/brewpath/issues/604)
blocks every language: the companion's lines are prose no folder can reach.
