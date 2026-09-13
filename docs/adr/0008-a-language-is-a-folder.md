# ADR-0008: A language is a folder — English master, translated key-value files

- **Status:** accepted
- **Date:** 2026-08-24

## Context

Localization is planned for the first update after launch — Polish and
Belarusian first, Spanish and other popular languages later
([the localization map](https://github.com/maximsan/brewpath/issues/345)).
All of the app's text is already key + value: interface strings, and the
content banks the extractor emits under stable ids. The content contract
(ADR-0006) keeps authoring in the English prototype.

## Decision

Every user-visible text is a key + value. **English is the master.** A
language ships as a **folder**: a Flutter translation file for interface
strings, plus per-language copies of the content banks under the same stable
ids. The app loads the chosen language's folder and falls back to English per
entry. A language appears in the app only when its whole folder is translated
— no mixed-language app. AI drafts the translations; the owner reviews. The
prototype stays English-only; translation happens after extraction.

## Consequences

**One exception, named:** the words drawn inside the collectible illustrations
stay English in every language — [ADR-0019](0019-the-card-art-keeps-its-english-words.md).
Nothing else is exempt.

Adding a language is adding a folder — no code change, no prototype change.
The one line it does cost is in `pubspec.yaml`, which bundles a directory's own
files and not its subdirectories'.
An English fix marks the sibling entries stale by id, and
[ADR-0026](0026-a-stale-translation-stays-until-it-is-retranslated.md) rules
what the reader sees meanwhile; [ADR-0024](0024-a-language-ships-with-term-matching-search-and-voice-may-lag.md)
names what else a language must bring, and
[ADR-0025](0025-translations-are-drafted-by-tool-reviewed-in-the-repo-approved-per-entry.md)
the step that makes one. Interface strings move from the constants class into
translation files as the surfaces they belong to are touched. Revisit only if a target language needs
right-to-left script, which none of the named ones does.
