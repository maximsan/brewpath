# ADR-0010: v1 onboarding is five screens, and the question flow is v2

- **Status:** accepted
- **Date:** 2026-08-28

## Context

The Readiness Audit moved the onboarding questions — goal, brewer, level,
reminders — to v2. Its reason: no screen in v1 reads the answers, so the
questions cost the user taps and give nothing back. The app had already
built part of that flow anyway: the goal and brewer screens exist, and the
app cannot be used until they are answered — even though nothing ever reads
the answers. [The onboarding conflict](https://github.com/maximsan/brewpath/issues/370)
asked which side wins. The audit's side wins, with one addition the audit
does not have: the flow ends on the paywall
([#242](https://github.com/maximsan/brewpath/issues/242)), not by dropping
the user straight into the Learn tab.

## Decision

**v1 onboarding is these five screens, in this order:**

1. **Loading.** This is the app's boot screen, shown on every cold start. It
   is first in the flow only because a first start is still a start. The
   code lives under `features/onboarding/` purely as a filing choice.
2. **Welcome** — "Learn coffee. / Grow a tree." over the seed-to-tree video.
   Roasty does not appear here; the design's own comment on this screen says
   so.
3. **Meet Roasty** — its own screen. The app had merged it into Welcome; the
   design keeps them separate.
4. **Name** — the user may type a name or skip.
5. **Paywall** — the Plus offer. The user may buy, or close it and go
   straight into the app ([#242](https://github.com/maximsan/brewpath/issues/242);
   the prototype's paywall has an `onClose` that does exactly this,
   `app.jsx:1457`). Buying is never required to finish onboarding.

Nothing in this flow is a gate: the name and the purchase are both optional.
What remains mandatory is only passing through the screens once.

**The goal, brewer, level and reminders questions leave v1.** They return in
v2, and v2 ships four questions — not more.

**The name stays, and it becomes editable.** Nothing else in v1 can supply a
name: there is no account and no sign-in. The one screen that uses it,
Profile's "Hello, {name}.", already has a fallback for users who skip.
Settings gains a row where the user can change the name later, so a typo is
fixable.

**The app's start-up gate stops depending on the questions.** The
`onboardingCompleted` flag still decides whether onboarding runs, but no code
may read a goal or a brewer — after this decision, no user ever enters one.

## Consequences

~~**The name screen still needs a design.**~~ **Resolved.** The owner designed
it in the design source on 3 Sep 2026, and #407 built the screen to it — the
question, the support line, the shared text field, and Continue beside a skip.
It carries no step counter, because the design numbers none of the intro
screens.

**The two screens are deleted, not kept as unlisted routes.** The Readiness
Audit suggested leaving them reachable by deep link for review. A route with
no entry point is a second thing to keep working, and git has the screens, so
#407 removed `GoalScreen`, `BrewerScreen` and their routes outright. Their two
Drift columns stay: dropping a column is a schema version and a fixture to
match, which is worth doing when the questions come back and not to tidy away
two nulls.

The Tour's rules about when it starts were written against the longer flow
and have to be re-checked against this shorter one —
[the Tour map](https://github.com/maximsan/brewpath/issues/336).

Builds: [the intro screens](https://github.com/maximsan/brewpath/issues/383),
[the onboarding paywall](https://github.com/maximsan/brewpath/issues/242),
plus the removal of the questions and the Settings row.

**Revisit** when some feature actually reads a goal or a brewer. The
questions were deferred because nothing reads them — not because they are
bad questions.
