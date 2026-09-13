# ADR-0026: A stale translation stays until it is retranslated

- **Status:** accepted
- **Date:** 2026-09-13

## Context

An English card is corrected after Polish has shipped. The map asked what the
Polish reader sees, and how the pipeline notices
([#348](https://github.com/maximsan/brewpath/issues/348)).

[ADR-0008](0008-a-language-is-a-folder.md) already answers the easier half: a
piece of text with no translation falls back to English. It also rules that a
language appears only when its folder is whole — and falling back to English on
every corrected line would contradict that in the ordinary course of
maintenance, not as an edge case.

## Decision

**The old translation stays on screen.** Staleness changes nothing the reader
sees; the text is replaced when its retranslation ships.

Staleness is therefore a fact about the repository, not about the app. A piece
of text is stale when the fingerprint it carries no longer matches the English
of that id
([ADR-0025](0025-a-language-ships-once-complete-and-native-review-follows.md)),
and the drafting tool queues exactly those.

**English fallback covers what has no translation at all** — which, after a
language ships, means new course text. A lesson added or a card rewritten in
English reads in English for a Polish reader until it is translated. Complete is
the bar for *offering* a language, not a freeze on the course.

**To pull a translation, delete it.** A translation bad enough to retract — a
safety line, a factual retraction — is removed from the folder, and that piece
falls back to English immediately. There is no flag and nothing new on the
device: the retraction uses the same fallback everything else does.

## Consequences

The app never mixes languages except where the English is genuinely newer than
the translation, and the loader stays simple: a translated piece wins, an absent
one falls back, and there is nothing to compare. The fingerprints ride along in
the folder — it is the shipped artifact as well as the reviewed one — but the
loader drops them, so nothing on a device can read one.

The cost is accepted: between an English correction and its retranslation, a
Polish reader is told something the course no longer believes. That window is
bounded by the drafter queueing stale text, and the delete lever is the way out
when a window is too long to tolerate. Deletion is all or nothing for a piece of
text — a single sentence of a card cannot be pulled — which is the right shape
for an emergency and the wrong one for editing.
