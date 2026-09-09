# ADR-0023: The concept card shows the word you picked

- **Status:** accepted
- **Date:** 2026-09-09

## Context

The concept card's sentence has one or more blanks and a bank of words below
it. Two behaviours were in the app's history at once: fill the blank with the
**authored answer** whichever word was tapped, or fill it with the **picked**
word and grade it after a *Check answers* step.

The design does the second — the blank shows the pick, and the grading happens
on the commit. A stale comment atop it claimed the first, and that comment is
what got implemented. No ADR or ledger entry recorded a decision either way.
Ruled at [#546](https://github.com/maximsan/brewpath/issues/546).

## Decision

**The blank shows the word the learner picked**, and the card grades it when
they press *Check answers*. A wrong pick stays visible and is marked wrong;
the authored answer is revealed by the verdict block, not by the blank.

## Consequences

- The card can be got wrong. 66 authored cards that always looked right now
  show a wrong pick as wrong. It stays **ungraded** — it reports no success, so
  mastery does not move either way.
- It matches every other graded picker in the app, so "tap, commit, see the
  mark" is one rule rather than one rule with an exception.
- The smoke walk has to press *Check answers* before *Continue*, and to pick a
  different option per blank — a walk that always taps the first live option
  never fills a two-blank card.
- The prototype's own header comment contradicts its code here. This ADR is the
  answer to that contradiction; a re-drop that keeps the comment does not
  reopen it.
