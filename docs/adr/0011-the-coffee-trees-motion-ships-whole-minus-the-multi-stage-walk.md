# ADR-0011: The Coffee Tree's motion ships whole, minus the multi-stage walk

- **Status:** accepted
- **Date:** 2026-08-29

## Context

The design animates the Coffee Tree in code; nothing is baked into the
images. There are five pieces: a slow permanent rocking (the sway), a
cross-fade between stage images, a bounce when a new stage lands, an
expanding ring of light, and drifting leaf particles.
[#136](https://github.com/maximsan/brewpath/issues/136) shipped the tree as a
still image and left the motion to this decision. Two reward screens
([#382](https://github.com/maximsan/brewpath/issues/382),
[#384](https://github.com/maximsan/brewpath/issues/384)) were waiting on it.
The full argument and measurements:
[#88](https://github.com/maximsan/brewpath/issues/88).

## Decision

**All five pieces are built**: sway, cross-fade, bounce, ring, leaves.

**One thing from the prototype is not built: animating through several stages
in one go.** The prototype can play stage 3 → 4 → 5 as a sequence. The app
never needs that, because one lesson can only ever grow the tree by one
stage (see Consequences). The growth animation crosses exactly one stage.

**The one exception is sync.** When progress made on another device arrives
by CloudKit merge, the stored stage can jump several steps at once. That
jump is shown without any growth animation: the animation belongs to the
moment the user earned the stage, not to the moment a sync reported it.

**The sway is part of the tree widget itself**, on by default, with an
`animate` flag to turn it off — the same design `Roasty` uses. **The growth
animation is a separate widget that wraps the tree**, because it needs a
start stage, an end stage and a completion callback, and the Profile screen
needs none of that.

**With reduced motion turned on, only the cross-fade plays.** Nothing moves:
no slide, no bounce, no ring, no leaves. The completion callback still
fires — the reward screens wait on it, and a callback that never fires would
freeze them.

**The ring and the leaves are drawn on a `Canvas`** (the same way Roasty's
glow is drawn), with the timing math in a plain Dart file beside the widget,
so the numbers can be unit-tested without rendering anything.

## Consequences

The growth animation crosses one stage because one lesson causes at most
one: the tree's growth points (`TREE_THRESHOLDS` in `prototype/data.jsx`)
are several lessons apart, and finishing a lesson raises the completed count
by one. If the course is ever restructured so that finishing one lesson
crosses two growth points, the animation will show only the final stage and
skip the one between — revisit this record then.

Builds: [#382](https://github.com/maximsan/brewpath/issues/382),
[#384](https://github.com/maximsan/brewpath/issues/384),
[#420](https://github.com/maximsan/brewpath/issues/420).
