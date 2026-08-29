# ADR-0011: The Coffee Tree's motion ships whole, minus the multi-stage walk

- **Status:** accepted
- **Date:** 2026-08-29

## Context

The design specifies the Coffee Tree's motion in code rather than baking it
into the art: an infinite ±0.8°/6 s sway (`CoffeePersona`,
`prototype/flavor-wheel.jsx:147`), and a growth celebration built from a
360 ms crossfade, a 600 ms spring bounce, a 900 ms glow ring and 1200 ms
drifting leaf particles (`AnimatedTree`, `prototype/flavor-wheel.jsx:211`).

[#136](https://github.com/maximsan/brewpath/issues/136) shipped the tree as a
still frame — `CoffeeTree` renders one of ten PNGs wearing a grove treatment,
and its own doc comment defers motion to this decision. Two reward screens
([#382](https://github.com/maximsan/brewpath/issues/382),
[#384](https://github.com/maximsan/brewpath/issues/384)) were blocked on it,
because building the growth inside a screen ticket would settle the question
by accident for every future consumer.

Three pressures shaped the ruling. The sway is a **permanent** animation on
screens a learner leaves open, which `CLAUDE.md`'s reduced-motion rule
addresses but the battery question does not. The ring and the leaves are the
most expensive pieces and the least load-bearing. And the map's standing rule
for art is that the prototype is *a strong reference, not a binding spec* —
divergence is allowed, but must be earned rather than drift into being.

## Decision

**All five pieces ship**: sway, crossfade, bounce, glow ring and leaf
particles.

**The multi-stage walk does not.** `AnimatedTree` walks every intermediate
stage and divides a ~1.1 s budget across the swaps, which only earns its keep
if `to - from` can exceed 1. It cannot: `TREE_THRESHOLDS`
(`prototype/data.jsx:2963`) resolves to `[4, 7, 10, 13, 16, 19, 22, 25, 32]`,
a minimum gap of three lessons, and a completion advances the count by one.
The crossfade is single-stage, and `perSwap` is not ported.

**A stage jump arriving from a CloudKit merge lands without animating.** That
merge is the one path that can cross several stages at once, since the stored
stage is a max-merged floor. Growth belongs to the moment it was earned, not
the moment a sync reported it.

**The sway lives inside `CoffeeTree`**, on by default, with an `animate` flag
to freeze it — the shape `Roasty` already has. **Growth lives in a separate
widget wrapping `CoffeeTree`.**

**Under reduced motion the cross-fade survives and everything that moves is
dropped** — no translate, no bounce, no ring, no leaves. `onDone` still fires.

The ring and the leaves are **painted on `Canvas`**, following
`roasty_particles.dart`, with the curve math in a pure sibling `*_animation.dart`
file.

## Consequences

**Makes easy.** The reward screens mount one component and inherit every
ruling, including the reduced-motion behaviour their acceptance criteria
require. The Profile hero keeps a contract of "a stage in, a frame out". Sway
cannot be forgotten on a screen added later — the failure mode of an opt-in
flag is a dead frozen tree that reads as deliberate and goes unnoticed. The
timings are unit-testable without pumping a widget.

**Makes hard.** A future course whose module sizes put two thresholds within
one lesson of each other would silently skip a stage instead of walking it.
The guard is `TREE_THRESHOLDS`' minimum gap, so a content change that narrows
it revisits this record.

**A trap.** `onDone` must fire under reduced motion. If it is wired to an
animation completion callback that never runs when animations are disabled,
the reward screens stall on a beat that never ends.

**Revisit if** the growth celebration starts reading as clutter in practice —
though note it fires only **nine times** across the whole course, and the
prototype's own comment (`prototype/rewards.jsx:78-79`) confirms most
completions cross no threshold at all.

**Withdrawn during the decision.** A cut of the ring and the leaves was
proposed on the grounds that they would collide with Roasty's confetti. They
do not: both reward screens run Roasty as a separate full-screen beat first
(`prototype/rewards.jsx:26-33`) and swap to the tree afterwards. The cut was
withdrawn rather than kept on a different rationale.

Decided on [#88](https://github.com/maximsan/brewpath/issues/88). Builds at
[#382](https://github.com/maximsan/brewpath/issues/382),
[#384](https://github.com/maximsan/brewpath/issues/384) and
[#420](https://github.com/maximsan/brewpath/issues/420).
