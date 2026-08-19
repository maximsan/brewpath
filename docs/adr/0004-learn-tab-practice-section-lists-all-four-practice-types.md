# ADR-0004: The Learn tab's practice section lists all four practice types

- **Status:** accepted
- **Date:** 2026-08-19

## Context

The domain model defines four practice types (mini-games, vocab game,
flashcards, lesson replay); the streak counts all four
([#33](https://github.com/maximsan/brewpath/issues/33)), the daily allowance
counts all four ([#65](https://github.com/maximsan/brewpath/issues/65)), and
Keep Sharp recommends all four from the Learn tab
([#56](https://github.com/maximsan/brewpath/issues/56)). Yet the tab's
`PRACTICE AGAIN` section (`screens.jsx:864-902`) lists only two — completed
Lessons and Mini-games. The Vocab game and Flashcards live two taps away on
Dictionary Home, even though they are a free user's *cheapest* streak paths
(one activity protects the day; mini-games cost both under the daily cap).

## Decision

The section lists **all four practice types**. It renames to **`PRACTICE`**,
and the Vocab game and Flashcards join as **slim rows** (single entry points,
not collapsible groups) beside the existing Lessons and Mini-games groups.
Both rows are **free with no lock treatment** — they are content-scoped, never
feature-gated. This is an **explicit invention** over the prototype (the Keep
Sharp precedent), ruled at
[#182](https://github.com/maximsan/brewpath/issues/182).

**This adds an entry point and nothing else.** The rows open the same two
surfaces Dictionary Home's quick chips open; the chips remain; pools, tier
scoping, streak and allowance accounting are untouched, and no new state
exists anywhere.

## Consequences

Free streak paths become discoverable where practice lives, feeding the daily
loop that surfaces the paywall. Each row lands with its surface's build
([#97](https://github.com/maximsan/brewpath/issues/97),
[#98](https://github.com/maximsan/brewpath/issues/98)); the rename rides
whichever builds first. The empty flashcards deck must not be a dead end —
behavior defers to #97's open question, answered once for both entry points.
The design docs describing `LearnTab` (`docs/design/07-components.md`, §4 IA)
must be updated when the rows ship, and the prototype backfill batch
([#154](https://github.com/maximsan/brewpath/issues/154)) carries the design
prompt. Revisit if the practice family gains a fifth type — the section and
Keep Sharp's rotation must stay the same list.
