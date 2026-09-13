# ADR-0026: A stale translation stays until it is retranslated

- **Status:** accepted
- **Date:** 2026-09-13

## Context

An English card is corrected after Polish has shipped. The map asked what the
Polish reader sees, and how the pipeline notices
([#348](https://github.com/maximsan/brewpath/issues/348)).

[ADR-0008](0008-a-language-is-a-folder.md) already answers the easier half: an
entry with no translation falls back to English. It also rules that a language
appears only when its folder is whole — no mixed-language app — and falling back
to English on every corrected line would contradict that in the ordinary course
of maintenance, not as an edge case.

## Decision

**The old translation stays on screen.** Staleness changes nothing the reader
sees; the entry is replaced when its retranslation is reviewed and approved.

Staleness is therefore a fact about the repository, not about the app. An entry
is stale when the fingerprint it was approved against
([ADR-0025](0025-translations-are-drafted-by-tool-reviewed-in-the-repo-approved-per-entry.md))
no longer matches the English entry of that id, and the drafting tool queues
exactly those entries. English fallback remains only for an entry that has no
translation at all.

## Consequences

The app never mixes languages mid-screen, and the loader stays simple: a
translated entry wins, an absent one falls back, and no fingerprint is ever
shipped or read on a device.

The cost is real and is accepted: between an English correction and its reviewed
translation, a Polish reader is told something the course no longer believes.
That window is bounded by review, which is why the drafter queues stale entries
rather than merely reporting them.

Revisit if a correction is ever urgent enough that showing English would be
better than showing the old translation — a safety or factual retraction, which
no card has needed yet.
