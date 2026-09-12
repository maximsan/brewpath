# ADR-0024: Every module a learner can reach opens and shuts

- **Status:** accepted
- **Date:** 2026-09-12

## Context

`prototype/disclosure.jsx` makes one flag decide two things: a header that
cannot be tapped has its panel forced open (`open = !collapsible ? true : …`).
Path sets `canCollapse = allDone && !mod.locked`, so the module a learner is
working through is pinned open and carries no caret at all.

[#596](https://github.com/maximsan/brewpath/issues/596) ported that rule, and
the owner ruled it wrong: a learner cannot fold away the one module that takes
the most room on the screen. The prototype is the design source, so this is a
deliberate departure from it rather than a porting mistake — the first on this
screen.

Ruled by the owner on [#596](https://github.com/maximsan/brewpath/issues/596),
which has the argument.

## Decision

**Every module a learner can reach carries a caret and answers a tap.** Only
the module still being worked through lists its lessons before it is asked to.

| Density | Caret | On arrival |
|---|---|---|
| `active` — reachable, unfinished | yes | open |
| `complete` — every lesson done | yes | shut |
| `locked` — not yet reached | no | shut, and has no lessons to draw |

A locked module keeps neither caret nor lesson list: there is nothing behind it
to open, so a caret would be a control over nothing.

`Disclosure` therefore **states** its open flag rather than inferring it from
`collapsible`. The two are independent: a header can be fixed and its panel
open, fixed and shut, or a toggle.

## Consequences

Path holds the open state per module — what the learner last said, falling back
to `PathModuleDensity.opensUnasked` — instead of a set of opened modules. It is
a reading position, so it is not persisted; a relaunch returns to the default.

The prototype still draws the old rule, and
[`docs/design/07-components.md`](../design/07-components.md) still records its
formula as the design's. Both are correct about the prototype and wrong about
the app, which is why that section now points here. **A future drop
reconciliation will find this divergence again** — it is a ruling, so under
[`docs/README.md`](../README.md)'s precedence it beats the prototype, and the
answer is to leave the app alone.

**Revisit if Path stops being one screen.** The densities exist because five
modules and thirty-two lessons share it; paginate the course and the question
of what folds away changes shape.
