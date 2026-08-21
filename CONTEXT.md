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

**Kind** (mini-game):
A mini-game mechanic (match, quiz, bagpick, …) — the code's `kind` field.
Several games can share one kind
([#190](https://github.com/maximsan/brewpath/issues/190)).

**Game** (mini-game):
One catalog entry: a kind, exactly one course topic, and a bank of rounds,
under a persistent id. What the streak, the daily allowance and tier gating
count; free iff its topic's module is unlocked
([ADR-0005](docs/adr/0005-mini-games-are-many-games-per-kind-gated-by-topic.md);
free-pair invariant:
[ADR-0001](docs/adr/0001-free-tier-carries-two-mini-game-formats.md)).
_Avoid_: "format" for mini-games — it meant both kind and game and caused two
corrections; retired at [#190](https://github.com/maximsan/brewpath/issues/190)

**Round** (mini-game):
One board or question inside a game's bank. A run plays the whole bank.

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

## Tiers

**BrewPath Plus**:
The paid tier ("Plus" after first mention; what it includes:
`docs/decisions.md` §11, [#30](https://github.com/maximsan/brewpath/issues/30)).
_Avoid_: Premium

## Dictionary

**Lesson term**:
A dictionary term taught by a lesson. Browsable by everyone; free access gets
the short explanation (§12).

**Reference term**:
A dictionary term no lesson teaches. Plus-only; absent from free search,
categories, Term of the Day, flashcards and mini-games (§12,
[#57](https://github.com/maximsan/brewpath/issues/57); the count is derived,
not fixed — re-derive rather than quote).
_Avoid_: "not yet learned" (a reference term can never become Learned)

**Term of the Day**:
A pure `(date, tier)` pick over the terms carrying a full explanation — zero
storage, and free and Plus rotate different pools, so not the same term for
everyone (§12, [#20](https://github.com/maximsan/brewpath/issues/20),
[#57](https://github.com/maximsan/brewpath/issues/57)). Surfaces on Dictionary
Home only
([ADR-0002](docs/adr/0002-term-of-the-day-ships-on-dictionary-home-only.md));
never a qualifying activity
([#33](https://github.com/maximsan/brewpath/issues/33)).
_Avoid_: a Learn-tab or Today surface (the prototype's Learn-tab hook is dead
code; ruled out)

## Sync and storage

**Progress snapshot**:
The envelope of a device's progress that two devices converge under a pure
merge ([#14](https://github.com/maximsan/brewpath/issues/14)). Stored at
schema v6.

**Tombstone**:
The record a Reset or Delete publishes so a syncing peer cannot walk the wipe
back ([#93](https://github.com/maximsan/brewpath/pull/93)).
