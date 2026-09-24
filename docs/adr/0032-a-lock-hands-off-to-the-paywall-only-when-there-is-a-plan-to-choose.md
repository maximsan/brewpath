# ADR-0032: A lock hands off to the paywall only when there is a plan to choose

- **Status:** accepted
- **Date:** 2026-09-12

## Context

The design sends every lock through the paywall before it can take money: the
gate sheet's action opens the paywall, and the paywall sells. On the arm v1
ships — one one-time purchase, [ADR-0003](0003-one-time-purchase-no-trial.md)
— the sheet's button and the paywall's button carry the same words and the
same price, so the learner would tap a priced buy button to reach a priced buy
button, with nothing to decide on the second screen.

On the subscription and hybrid arms the sheet's button says *from* a
per-month figure, which names a number the learner cannot act on until they
pick a plan. Before this ruling the sheet bought the arm's default plan
without ever showing the choice.

The argument is in [#600](https://github.com/maximsan/brewpath/issues/600).

## Decision

A lock hands off to the paywall only when there is a plan to choose. One plan
on the arm and the sheet sells where it stands. More than one and the sheet's
action closes the sheet and opens the paywall, carrying the location the lock
was raised on; buying there lands on the welcome and *Back to learning*
returns to that location, and declining returns there directly.

The switch is what the store reports — the offering's plan count — so the
behaviour follows the arm and is never written down twice.

## Consequences

The sheet has two behaviours instead of one. On the arm where it takes money
it keeps the Restore, Terms and Privacy row App Review requires of anything
that does; on the arms where it hands off it drops that row and its purchase
facts, because it is no longer a surface that takes money.

The paywall gains a route outside the intro. The intro's own use of it is
unchanged on every arm.
