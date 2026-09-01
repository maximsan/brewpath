# ADR-0011: The Coffee Tree's motion ships whole, minus the multi-stage walk

- **Status:** accepted
- **Date:** 2026-08-29

## Context

`CoffeePersona` and `AnimatedTree` specify the tree's motion in code rather
than baking it into the art. [#136](https://github.com/maximsan/brewpath/issues/136)
shipped the tree as a still frame and deferred the motion here, blocking two
reward screens. Argument and evidence: [#88](https://github.com/maximsan/brewpath/issues/88).

## Decision

All five pieces ship: sway, crossfade, bounce, glow ring, leaf particles.

**The multi-stage walk does not.** The crossfade is single-stage and `perSwap`
is not ported — `TREE_THRESHOLDS` sit at least three lessons apart and a
completion advances the count by one, so nothing but a CloudKit merge can
cross two stages. **That merge lands without animating.**

**Sway lives inside `CoffeeTree`**, on by default, with an `animate` flag to
freeze it. **Growth lives in a separate widget wrapping it.**

**Under reduced motion the cross-fade survives and everything that moves is
dropped.** `onDone` still fires.

The ring and the leaves are painted on `Canvas`, with their curve math in a
pure sibling `*_animation.dart`.

## Consequences

The single-stage crossfade shows every stage only while consecutive
`TREE_THRESHOLDS` sit more than one lesson apart — today the minimum gap is
three (`[4, 7, 10, 13, 16, 19, 22, 25, 32]`, from `prototype/data.jsx:2963`).
A content change that narrows any gap to one revisits this record.

`onDone` wired to an animation completion callback will never fire under
reduced motion, stalling the reward screens on a beat that never ends.

Builds: [#382](https://github.com/maximsan/brewpath/issues/382),
[#384](https://github.com/maximsan/brewpath/issues/384),
[#420](https://github.com/maximsan/brewpath/issues/420).
