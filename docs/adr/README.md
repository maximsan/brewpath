# Architecture Decision Records

One file per decision, named `NNNN-kebab-case-title.md` with a zero-padded
sequential number (`0001-…`, `0002-…`). Numbers are never reused, and a
superseded ADR is kept in place with its status updated rather than deleted.

Each record follows this shape:

```markdown
# ADR-NNNN: Title

- **Status:** proposed | accepted | superseded by ADR-NNNN
- **Date:** YYYY-MM-DD

## Context

What forced a decision. The constraints, the pressures, what was already true.

## Decision

What was chosen, stated in the present tense.

## Consequences

What this makes easy, what it makes hard, and what has to be revisited if it
turns out to be wrong.
```

ADRs are written lazily — when a decision actually gets made, usually via
`/grill-with-docs`. Don't backfill the whole history. Consumer rules for agents
live in [`docs/agents/domain.md`](../agents/domain.md).
