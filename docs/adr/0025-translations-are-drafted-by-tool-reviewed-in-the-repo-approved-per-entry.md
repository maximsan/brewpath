# ADR-0025: Translations are drafted by tool, reviewed in the repo, approved per entry

- **Status:** accepted
- **Date:** 2026-09-13

## Context

[ADR-0008](0008-a-language-is-a-folder.md) settled that AI drafts a language and
the owner reviews it, but not where the review happens or what records that an
entry has been read. The map asked for named stages and owners
([#347](https://github.com/maximsan/brewpath/issues/347)).

Two facts constrain the answer. Translation happens **after** extraction, so the
tool reads the generated English banks and never the prototype. And the banks
already travel in an envelope stamped with the bank name and schema version, so
a language folder can carry bookkeeping beside its text.

## Decision

Four stages, two owners:

1. **Draft** — a tool reads the English banks and writes a language folder,
   filling only entries that are absent or stale.
2. **Review** — the owner reads the folder's diff in a pull request, the same
   way every other change is read. There is no second system.
3. **Approve** — an entry records the fingerprint of the English text it was
   approved against. Approval is per entry, not per file.
4. **Ship** — the folder goes in the app once every entry is approved.

The tool owns steps 1 and 4; the owner owns 2 and 3.

## Consequences

Per-entry fingerprints are what let the drafter re-run without argument: it can
tell a translation nobody has read from one the owner fixed by hand, so it never
overwrites a reviewed entry and never leaves a changed English line undrafted.
Per-file approval would have been simpler bookkeeping and would have thrown away
a whole file's review for one corrected English sentence.

The cost is that review is bounded by how much translated text the owner can
read, in languages they may not speak — which is the real limit on how fast
languages ship, and the reason the first wave is two.

Nothing here reaches the device: the fingerprints are the pipeline's, and
[ADR-0026](0026-a-stale-translation-stays-until-it-is-retranslated.md) keeps the
app from ever reading them.
