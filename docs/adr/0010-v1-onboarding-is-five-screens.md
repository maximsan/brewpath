# ADR-0010: v1 onboarding is five screens, and the question flow is v2

- **Status:** accepted
- **Date:** 2026-08-28

## Context

`prototype/v1 Readiness Audit.html` defers the personalization question flow —
goal, brewer, level, reminders — to v2, *"because nothing reads the answers
yet, so they cost taps and return nothing."* In its v1 cut, Meet Roasty goes
straight to Learn.

The app built the flow anyway. Goal and brewer ship, and `onboardingCompleted`
gates the entire app behind them, so every learner answers questions no screen
reads. [#370](https://github.com/maximsan/brewpath/issues/370) raised the
conflict and asked which way it falls.

It falls the audit's way, with one addition the audit does not carry: the
paywall, which [#242](https://github.com/maximsan/brewpath/issues/242) already
owns, closes the flow rather than Learn opening straight after Meet Roasty.

## Decision

**v1 onboarding is five screens, in this order:**

1. **Loading** — Roasty. *Not an onboarding step.* It is the app's boot screen,
   reached on every cold start, and first-run's first sight only by accident of
   ordering. It lives under `features/onboarding/` for filing reasons alone.
2. **Welcome** — "Learn coffee. / Grow a tree.", over the seed-to-tree video.
   No Roasty: the design's own comment on this screen reads *"No Roasty here."*
3. **Meet Roasty** — a screen of its own. The app collapsed it into Welcome;
   the v1 cut keeps both ("App intro — 2 scr").
4. **Name** — optional, and the only optional step.
5. **Paywall.**

**Goal, brewer, level and reminders leave the v1 flow.** They are v2, pinned to
the four-question depth v2 will ship.

**The name step stays, and the name becomes editable.** It is kept because
nothing else in v1 can supply a name — there is no account, no Sign in with
Apple, and Firebase is gated off — while the one thing that reads it, Profile's
`Hello, {name}.`, already carries the design's own `Hello, there.` fallback for
anyone who skips. A step that can be skipped at no cost, and whose answer can be
changed afterwards, is worth one tap; the same step with no way to correct a
typo is not. So Settings gains a row that writes `learnerName`.

## Consequences

**The name screen owes a design.** The prototype has no name step anywhere, so
there is no component or theme for it to follow — today it draws a stock
Material `TextField` with an `OutlineInputBorder`, which no other screen in the
app does. It cannot be brought to parity until the screen is authored in the
design source, which the owner holds. Until then this is a known, recorded
divergence rather than an oversight.

**Two things the app ships become false the moment goal and brewer leave.** The
name screen's eyebrow reads `ONBOARDING · 3 OF 3`, and Welcome carries Meet
Roasty's framing and copy instead of its own. Both are build work, not
decisions.

**The router's gate stops depending on the question flow.** `onboardingCompleted`
must still gate the app — the flow is shorter, not absent — but nothing
downstream may read a goal or a brewer, because after this no learner supplies
one.

**The Tour's trigger rules are defined relative to the flow this shortens** and
have to be re-read against it — [#336](https://github.com/maximsan/brewpath/issues/336)
holds that map.

**Where the build lives:** the intro screens are
[#383](https://github.com/maximsan/brewpath/issues/383), the paywall is
[#242](https://github.com/maximsan/brewpath/issues/242), and the cut itself —
goal and brewer out, the eyebrow, the name screen's parity — plus the Settings
row are the two tickets this ADR is closed with.

**Revisit** when something actually reads a goal or a brewer. Deferring them is
a statement about v1's readers, not about the questions.
