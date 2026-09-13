# ADR-0024: Every module a learner can reach opens and shuts

- **Status:** accepted
- **Date:** 2026-09-12

## Context

`prototype/disclosure.jsx` makes one flag decide two things: a header that
cannot be tapped has its panel forced open (`open = !collapsible ? true : …`).
Path sets `canCollapse = allDone && !mod.locked`, so the design pins the module
a learner is working through open and gives it no caret — leaving them unable
to fold away the section taking the most room on the screen.

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
to `PathModuleDensity.opensUnasked`. It is a reading position, so it is not
persisted; a relaunch returns to the default.

The prototype draws the other rule, and
[`docs/design/07-components.md`](../design/07-components.md) records its formula
as the design's — both true of the prototype, neither true of the app, which is
why that section points here. **A drop reconciliation will find this divergence
again.** Under [`docs/README.md`](../README.md)'s precedence a ruling beats the
prototype: leave the app alone.

**Revisit if Path stops being one screen.** The densities exist because five
modules and thirty-two lessons share it; paginate the course and the question
of what folds away changes shape.
