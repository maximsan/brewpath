# BrewPath

The domain glossary: the vocabulary the product rulings, the design reference
and the code must share. Terms link the ruling that defined them —
`docs/decisions.md` (frozen, `§`-cited) or the owning GitHub issue.

## Course

**Foundations**:
The finite beginner course — five modules, thirty-two lessons, fixed order
(`docs/decisions.md` §1). Completing it has a proper ending, then Today
switches to Keep Sharp.
_Avoid_: the course (when another course could ever be meant)

**Preview lesson**:
One of the two lessons that are free permanently, with unlimited replay
(§7, [#29](https://github.com/maximsan/brewpath/issues/29)).

**Coffee Challenge**:
A small real-world task (brew, taste, compare). Never counts toward the streak
or the daily allowance (§4).
_Avoid_: Brew Challenge (renamed)

**Collectible card**:
One of thirty-seven cards unlocked automatically by first-time completions —
one per lesson, one per module. No rarity, no duplicates.

## Practice and the streak

**Activity**:
One unit of learning or practice work — a new lesson, a completed replay, one
standalone mini-game run, a vocab round, or a flashcard review. The unit both
the streak rule and the daily allowance count (§5).
_Avoid_: "format" for this meaning — see below

**Practice type**:
A kind of practice: mini-games, vocab game, flashcards, or lesson replay.
What Keep Sharp recommends (§6,
[#56](https://github.com/maximsan/brewpath/issues/56)).

**Format** (mini-game):
An individual mini-game variant (e.g. `g-match`, `g-quiz`). Two formats are
free; the rest are premium (§5,
[ADR-0001](docs/adr/0001-free-tier-carries-two-mini-game-formats.md)).
_Avoid_: using "format" for a practice type or an activity

**Qualifying activity**:
An activity whose completion protects the streak for that local calendar day
(§2–3, [#33](https://github.com/maximsan/brewpath/issues/33); mini-game
specifics: §5, [#59](https://github.com/maximsan/brewpath/issues/59)).

**Streak**:
Consecutive local calendar days each holding a qualifying completion. Advances
at most once per day; derived from the stored set of active days
([#17](https://github.com/maximsan/brewpath/issues/17)).

**Streak freeze**:
An earned, automatically spent token that preserves the streak across one
missed day. Free for all users; full mechanics in §10,
[#58](https://github.com/maximsan/brewpath/issues/58).

**Keep Sharp**:
The Today recommendation after Foundations: one practice type for the day,
rewarding nothing but the streak (§1, §6,
[#56](https://github.com/maximsan/brewpath/issues/56)).

**Daily activity allowance**:
The free tier's per-day cap on full activities (§8,
[#65](https://github.com/maximsan/brewpath/issues/65)).
_Avoid_: daily cap on lessons (it caps practice volume, not course pace)

## Progress

**Points**:
Flat first-completion currency — measures showing up, not skill. Replays and
practice pay nothing (§9,
[#16](https://github.com/maximsan/brewpath/issues/16)).
_Avoid_: XP, score

**Mastery**:
Best-ever per-lesson knowledge, a `{correct, total}` pair. Improvable by
replay, never decreases ([#16](https://github.com/maximsan/brewpath/issues/16)).
_Avoid_: bestScore (replaced at schema v5)

**Coffee Tree**:
The ten-stage plant that is the single picture of course progress. Grows only
on first-time lesson completions; only a deliberate reset returns it to seed.
_Avoid_: plant (in code and rulings; "plant" is fine in user-facing prose)

## Dictionary

**Lesson term**:
A dictionary term taught by a lesson. Browsable by everyone; free access gets
the short explanation (§12).

**Reference term**:
A dictionary term no lesson teaches. Premium-only; absent from free search,
categories, Term of the Day, flashcards and mini-games (§12,
[#57](https://github.com/maximsan/brewpath/issues/57); the count is derived,
not fixed — re-derive rather than quote).
_Avoid_: "not yet learned" (a reference term can never become Learned)

## Sync and storage

**Progress snapshot**:
The envelope of a device's progress that two devices converge under a pure
merge ([#14](https://github.com/maximsan/brewpath/issues/14)). Stored at
schema v6.

**Tombstone**:
The record a Reset or Delete publishes so a syncing peer cannot walk the wipe
back ([#93](https://github.com/maximsan/brewpath/pull/93)).
