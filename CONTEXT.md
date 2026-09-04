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
One of the **three** lessons (`m1l1`–`m1l3`) that are free permanently, with
unlimited replay. The free set is a named lesson list everything else derives
from (§7, [#29](https://github.com/maximsan/brewpath/issues/29); count and
lesson-binding:
[ADR-0007](docs/adr/0007-free-tier-is-the-first-three-lessons.md)).

**Coffee Challenge**:
A small real-world task (brew, taste, compare). Never counts toward the streak
or the daily allowance (§4).
_Avoid_: Brew Challenge (renamed)

**Collectible card**:
One of thirty-seven cards unlocked automatically by first-time completions —
one per lesson, one per module. No rarity, no duplicates.

**Module Reward**:
One of the five collectible cards awarded for completing a whole module
(Beans · Processing · Roasting · Grind · Brew). Part of the thirty-seven, and
shown in the Cards grid.
_Avoid_: Field Guide **as the name for the category** (renamed; the code
already said `MODULE_REWARDS`). The five cards keep their authored titles —
*Beans Field Guide* and its siblings — the way a book keeps its name: those
are what the cards are *called*, not what they *are*.

**Visual guide**:
One of the eight illustrated references the course teaches — roast, grind,
extraction, ratio, anatomy, variety, caffeine, distribution. Unlocks on first
completion of the earliest lesson that teaches it, is saveable under a `g:`
key, and is listed in the Reference row on Path. Never shown beside a
collectible ([#106](https://github.com/maximsan/brewpath/issues/106)).
_Avoid_: training card, training guide (renamed)

**Subject**:
The axis naming a visual guide (`roast`, `grind`, `variety`) and the value its
`g:` save key carries.
_Avoid_: variant (the prototype's former field name here, renamed to
`visualGuide:` — and retired mini-game vocabulary besides; see **Kind**/**Game**)

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
count; free iff its topic's **teaching lesson** is free
([ADR-0005](docs/adr/0005-mini-games-are-many-games-per-kind-gated-by-topic.md),
lesson-binding per
[ADR-0007](docs/adr/0007-free-tier-is-the-first-three-lessons.md);
free-games invariant:
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

**Saved shelf**:
The one place holding what a learner bookmarked — **lessons, dictionary terms
and visual guides**, stored as prefixed keys (`l:` / `t:` / `g:`, and a guide
by its *subject*). Reached from the shared header, free with a soft cap, and
cleared by Reset. Removal is always allowed, including at the cap
([#60](https://github.com/maximsan/brewpath/issues/60), §5.7).
_Avoid_: Favourites, favorites (the prototype's second name for this screen);
card favourites (never a design feature — `c:` was never a key, and the app's
heart toggle was removed in [#108](https://github.com/maximsan/brewpath/issues/108))

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

## Onboarding

**Tour**:
The one-time, skippable walkthrough of the Learn tab — four stops, each
explaining a mechanic. Auto-runs once per device when Learn first shows with
`tourSeen` unset; replayable from Profile
([#191](https://github.com/maximsan/brewpath/issues/191)). Never a qualifying
activity.
_Avoid_: walking tour, walkthrough, coach marks

## Content pipeline

**Carried** (authored field):
A field the extractor reads out of the prototype into a bank — copied as is,
or folded into another value
([#485](https://github.com/maximsan/brewpath/issues/485)).

**Skipped** (authored field):
A field left behind on purpose, with its reason on record beside the
extractor ([#485](https://github.com/maximsan/brewpath/issues/485)).

**Forgotten** (authored field):
A field that is neither carried nor skipped. The extractor refuses to run
until it becomes one or the other
([#485](https://github.com/maximsan/brewpath/issues/485)).
_Avoid_: "ignored", "unused" — neither says whether anyone decided.

## Sync and storage

**Progress snapshot**:
The envelope of a device's progress that two devices converge under a pure
merge ([#14](https://github.com/maximsan/brewpath/issues/14)). Stored at
schema v6.

**Install stamp**:
The one recorded instant saying when this account began — written when the
database is created, restamped by Delete Account, untouched by Reset. Stored at
schema v11 and device-local: never in the progress snapshot, because it dates
this copy of the app rather than the learner
([ADR-0013](docs/adr/0013-the-joined-line-dates-the-install-and-old-devices-are-not-back-dated.md)).
Absent on every database created before v11, and Profile's `Joined` line falls
back to the earliest active day for those.
_Avoid_: join date (the line's word, not the stored fact — the two differ
exactly on the devices using the fallback)

**Tombstone**:
The record a Reset or Delete publishes so a syncing peer cannot walk the wipe
back ([#93](https://github.com/maximsan/brewpath/pull/93)).
