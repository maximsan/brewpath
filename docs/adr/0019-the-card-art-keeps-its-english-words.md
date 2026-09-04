# ADR-0019: The card art keeps its English words

- **Status:** accepted
- **Date:** 2026-09-04

## Context

Nineteen of the thirty-seven collectible illustrations have words drawn into
them — `BITTER`, `COARSE`, `NO OXYGEN`, `SKIN · PULP · GEL · SEED`. They are
part of the drawing, extracted from the design source rather than written by
the app ([#480](https://github.com/maximsan/brewpath/issues/480)).

[ADR-0008](0008-a-language-is-a-folder.md) says every user-visible text is a
key and a value, and that a language appears only when its whole folder is
translated. A word inside an SVG is neither a key nor a value, so adding a
Polish folder can never reach it.

## Decision

**The illustrations stay English in every language.** This is a named
exception to ADR-0008, not an oversight in it.

The alternative — stripping the text out and drawing it in Flutter from
translatable strings — was weighed and declined for now. It is still open if
the words turn out to matter once a second language ships.

## Consequences

A Polish or Belarusian learner reads a translated app with English words
inside nineteen card illustrations. The words are coffee vocabulary the app
teaches in English anyway, and at tile size they are about three points tall —
texture rather than reading. In the card sheet, at 150, they are legible and
plainly English.

ADR-0008's "no mixed-language app" now has one place where it is not true, and
this is that place. Anything *else* untranslatable is still a defect.

Revisit when a second language ships and someone can see the result: the way
back is to strip the `<text>` elements in the extractor, which already carries
each one's position, size, anchor and colour token, and draw them over the art.
