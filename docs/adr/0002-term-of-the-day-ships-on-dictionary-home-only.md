# ADR-0002: Term of the Day ships on Dictionary Home only

- **Status:** accepted
- **Date:** 2026-08-17

## Context

[Coffee Dictionary](https://github.com/maximsan/brewpath/issues/20) recorded
Term of the Day as rendering *"on LearnTab (`screens.jsx:718`) as well as
Dictionary Home"* and weighted it accordingly: one of only two daily-changing
surfaces in v1, and therefore a retention hook rather than a dictionary extra.
[Free-tier practice content](https://github.com/maximsan/brewpath/issues/57)
then justified its free-rotation-over-38 ruling by that venue — *"a daily
engagement surface on `LearnTab`"*.

Verification against the prototype found the citation false. `screens.jsx:718`
computes `const tod = dictTermOfDay()` and **never uses it** — a dead
computation, like `termCount` on the next line. The banner component's compact
variant (`dictionary.jsx:248`, clearly authored for a slim placement) **has no
render site anywhere**. The only real surfaces are Dictionary Home's `big`
banner (`dictionary.jsx:416`) and the detail screen it opens
(`dictionary-extras.jsx:12–66`).

That makes the Learn-tab placement planned-but-unbuilt design — the same
write-only dead state the Coffee Dictionary decision itself dropped the
recent-terms strip for, under the unbuilt-design precedent from
[#28](https://github.com/maximsan/brewpath/issues/28). Keeping it would have
meant porting an invention; the map's one precedent for that, Keep Sharp, was
kept only by *explicitly* marking it an invention.

## Decision

Term of the Day surfaces on **Dictionary Home only**: the `big` banner plus the
detail screen it opens. The Learn-tab placement and the banner's compact
variant **do not port**. The pick itself is unchanged — a pure `(date, tier)`
function with zero storage, free rotating over 38 terms and Plus over 46.

## Consequences

**Easy.** The build ([#96](https://github.com/maximsan/brewpath/issues/96))
narrows to one banner variant and one screen, and Term of the Day stays
entirely a dictionary-module concern — no Learn-tab wiring, no second surface
to keep consistent. `LearnTab`'s frozen clock (`new Date(2026, 4, 8)`) still
needs a real clock, but for its date header only; it is no longer entangled
with this feature.

**Hard.** The map's retention story thins: the *"only two daily-changing
surfaces in v1"* argument is withdrawn, leaving the streak as the Learn tab's
only daily hook. #57's free-pool ruling keeps its conclusion with a corrected
rationale — Dictionary Home is still a daily engagement surface, just a less
trafficked one — so the pressure the locked-term-1-day-in-6 rejection was
relieving is smaller than the record implied.

**Revisit if** v1 retention turns out to need a daily hook on the Learn tab.
That returns as a deliberate invention recorded in a superseding ADR — the
Keep Sharp route — not as a silent port of the dead code; the orphaned compact
banner variant is the natural starting point if it does.
