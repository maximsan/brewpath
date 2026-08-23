# Which package renders the Tour

Research for [issue #192](https://github.com/maximsan/brewpath/issues/192), child of the
wayfinder map [#191](https://github.com/maximsan/brewpath/issues/191).

**Scope.** The Tour is a one-time, skippable, replayable guided walkthrough of the Learn
tab. This document vets the coach-mark/showcase packages against the five criteria in
#192 and recommends one (or from-scratch as the explicit fallback). It does not design
the Tour's stops or copy — that belongs to the implementation ticket (#195).

**Method.** Every pub.dev number was read live from pub.dev on 2026-08-20, not from
recollection. Every API claim was verified against the package's own source on GitHub
(`master` of each repo, matching the released version) or its in-repo documentation;
file and line references below point at those sources. Repo-activity facts come from the
GitHub API (`pushed_at`, `open_issues_count`, license). Nothing below is asserted from
memory.

---

## 0. The constraint that decides this

The Learn tab is **one scrollable list** —
`lib/features/learn/presentation/learn_screen.dart:34` builds a
`ListView(children: [TodayCardWidget, …, ModuleCardWidget×N])`. A Tour stop near the
bottom (the module list) can be off-screen on a small device, so the package must scroll
the target into view itself, in order, mid-tour. That is the make-or-break criterion in
#192, and it is the criterion on which the two candidates split.

One nuance to carry into implementation: `ListView(children:)` uses
`SliverChildListDelegate`, which constructs the child *widgets* eagerly but still mounts
their *elements* lazily as they scroll into the viewport (plus `cacheExtent`). Any
package that scrolls via `Scrollable.ensureVisible` needs the target's element mounted.
See §1.2 for the vendor-documented caveat and the two mitigations.

---

## 1. `showcaseview` 5.1.0 — the recommendation

### 1.1 Health

| Fact | Value | Source |
| --- | --- | --- |
| Version / recency | 5.1.0, published ~June 2026 ("2 months ago" on 2026-08-20); repo last push 2026-07-30 | pub.dev package page; GitHub API `pushed_at` |
| Publisher | `simform.com` (verified) | pub.dev |
| License | MIT | pub.dev; GitHub API `license.spdx_id` |
| Score / adoption | 150 pub points, 3,110 likes, **192k downloads/week**; 1,926 stars, 6 open issues | pub.dev; GitHub API |
| Dart/Flutter | `sdk: '>=3.0.0 <4.0.0'`, Flutter SDK dep | `pubspec.yaml` of the package |

The 5.x line is an active rework: 5.0.0 deprecated the old `ShowCaseWidget` in favour of
a context-free `ShowcaseView.register()` controller, and 5.0.x–5.1.0 shipped a steady
stream of fixes including an accessibility one (tooltip announced via a `Semantics` live
region, changelog #586) and a `go_router` + Semantics fix (#622) — relevant since this
app is on go_router 17.x (`CHANGELOG.md` of the package).

### 1.2 Ordered stops with auto-scroll in a ListView — passes, with a documented caveat

- `ShowcaseView.register(enableAutoScroll: true, scrollDuration: …)` turns on
  auto-scroll globally; each `Showcase` can override it with its own
  `enableAutoScroll` (`lib/src/showcase_view.dart:145-153`,
  `lib/src/showcase/showcase.dart:525-527`).
- The scroll is a real `Scrollable.ensureVisible(_context, duration:
  showcaseView.scrollDuration, alignment: config.scrollAlignment)`
  (`lib/src/showcase/showcase_controller.dart:171-189`), with over-scroll settling
  handled (5.0.1 changelog, PR #583).
- The vendor documents the lazy-list caveat verbatim (`doc/documentation.md`, "Auto
  Scrolling"): *"in order to scroll to a widget it needs to be attached with widget
  tree. If you are using a scrollview that renders widgets on demand like
  ListView.builder, it is possible that the widget to be showcased is not attached to
  the widget tree"* — and documents the escape hatch: attach a `ScrollController` and
  pre-scroll in the `onStart` callback.
- For this app the caveat is mild: the Learn list is a **fixed, small child list**, not
  `ListView.builder`. Two safe mitigations, either sufficient: give the ListView a
  generous `cacheExtent` while the Tour runs (mounts every child), or use the
  documented `onStart` + `ScrollController` pre-scroll. `skipIfTargetNotPresent`
  (5.0.2) and `isTargetRendered(key)` (5.1.0) exist as guard rails if a target is ever
  missing.
- Stops are ordered by construction: `startShowCase(List<GlobalKey> widgetIds)` plays
  the keys in list order (`lib/src/showcase/showcase_view.dart:253`).

### 1.3 Skip and programmatic restart — passes

- **Skip:** `ShowcaseView.dismiss()` ends the whole tour and fires the `onDismiss`
  callback with the key it was dismissed at (`showcase_view.dart:319`). A skip button
  can be placed in the tooltip via the built-in `TooltipActionButton` /
  `tooltipActions`, or in a custom tooltip.
- **Restart (replay from Profile):** `startShowCase` is a plain method on the
  registered `ShowcaseView` — callable at any time, any number of times, with an
  optional `delay` (`showcase_view.dart:253-260`). Since 5.x this is context-free
  (`ShowcaseView.get()`), so a Profile-screen action can trigger a replay on the Learn
  tab after switching branches.

### 1.4 Theming from mood tokens — passes

`Showcase` takes plain `Color`/`double` parameters — `overlayColor` (default
`Colors.black45`), `overlayOpacity`, `tooltipBackgroundColor`, `textColor`
(`lib/src/showcase/showcase.dart:73-78, 317-340`); 5.0.2 added overlay color/opacity on
the `ShowcaseView` level too (changelog #634). Nothing is hardcoded past the defaults,
so the scrim can be fed from `OverlayColors.scrim` and the tooltip from `context.mood`
at build time. `Showcase.withWidget` exists for a fully custom tooltip if the default
layout ever fights the design.

### 1.5 Reduced motion — wireable, not automatic

The package does **not** read `MediaQuery.disableAnimations` itself (no hit in the
source). It does expose the levers to honour it: `disableMovingAnimation` and
`disableScaleAnimation` at both the `ShowcaseView` and per-`Showcase` level
(`showcase_view.dart:130-140`, `showcase.dart:85-86, 379-385`), plus `scrollDuration`.
The Tour wrapper sets all three from `MediaQuery.disableAnimationsOf(context)` — same
pattern this repo already mandates for loading/empty/error states (CLAUDE.md, Code
Quality Rules).

---

## 2. `tutorial_coach_mark` 1.3.3 — fails the make-or-break criterion

### 2.1 Health

| Fact | Value | Source |
| --- | --- | --- |
| Version / recency | 1.3.3, published ~Oct 2025 ("10 months ago"); repo last push 2025-10-17 | pub.dev; GitHub API |
| Publisher | `rafaelbarbosatec.com` (verified) | pub.dev |
| License | MIT | pub.dev; GitHub API |
| Score / adoption | 150 pub points, 1,595 likes, 206k downloads; 613 stars, **60 open issues** | pub.dev; GitHub API |
| Dart/Flutter | `sdk: '>=2.12.0 <4.0.0'` — Dart 3 compatible | package `pubspec.yaml` |

Healthy but noticeably quieter than showcaseview: ten months without a release, 60 open
issues, and an order of magnitude fewer weekly downloads.

### 2.2 Against the criteria

- **Auto-scroll: absent.** The entire `lib/` tree (13 files) contains no
  `Scrollable.ensureVisible`, no `ScrollController`, no scrolling code of any kind —
  verified by grep over the fetched source. Targets are located by `GlobalKey` rect
  only; an off-screen target gets a spotlight drawn at a stale or missing rect. The
  app would have to own the "scroll each stop into view, wait for settle, then advance"
  choreography itself — which is most of the hard part of the Tour. README confirms by
  omission (no scrolling section).
- **Skip / restart: good.** `textSkip` / `onSkip` / `hideSkip` / `alignSkip` /
  `showSkipInLastTarget`; programmatic `show(context:)`, `skip()`, `finish()`,
  `next()`, `previous()`, `goTo(i)` (README).
- **Theming: good.** `colorShadow`, `opacityShadow`, fully custom content widgets per
  target (README).
- **Reduced motion: wireable.** `focusAnimationDuration`, `unFocusAnimationDuration`,
  `pulseEnable: false` (README; 1.3.1 added `AnimationBehavior.preserve`).

A fine package for tours whose targets are all on screen. That is not this tour.

---

## 3. The rest of the field — no third contender

Checked live on pub.dev, 2026-08-20:

| Package | Why not |
| --- | --- |
| `flutter_intro` 3.4.0 | 594 likes but last published **22 months ago**; README documents no scrolling to off-screen targets. |
| `onboarding_overlay` 3.2.3 | Unverified uploader, 375 likes; README documents no auto-scroll. |
| `feature_discovery` 0.14.2 | Dormant (0.x, community forks circulating); Material feature-discovery pattern, not an ordered tour. |
| `features_tour`, `overlay_tooltip`, `overmark`, `coachmark`, `spotlight_guide`, … | All niche: ≤ 240 likes, most under 10, none with the maintenance record or adoption to prefer over showcaseview. |

## 4. From-scratch — not warranted

The fallback exists for the case where both candidates fail. One candidate passes every
criterion, including the make-or-break one, with an actively maintained, verified-
publisher, MIT, massively adopted implementation. Hand-rolling an overlay + spotlight +
tooltip-positioning + scroll-choreography stack would re-create exactly the code
showcaseview already maintains (its `lib/src/tooltip/` positioning layer alone is nine
files).

---

## 5. Verdict

| Criterion (#192) | `showcaseview` 5.1.0 | `tutorial_coach_mark` 1.3.3 |
| --- | --- | --- |
| Maintenance / Dart 3 / license / score | ✅ verified publisher, pushed 2026-07-30, Dart ≥3.0, MIT, 150 pts, 192k/wk | ✅ verified publisher, MIT, 150 pts — but last release Oct 2025, 60 open issues |
| Ordered stops + auto-scroll in ListView | ✅ `enableAutoScroll` via `Scrollable.ensureVisible`; documented lazy-mount caveat with two workable mitigations (§1.2) | ❌ no scrolling code exists in the package |
| Skip + programmatic restart | ✅ `dismiss()`; `startShowCase(keys)` re-callable, context-free | ✅ `onSkip` / `show(context:)` |
| Theming from mood tokens | ✅ `overlayColor` / `overlayOpacity` / `tooltipBackgroundColor` / `textColor` params; `withWidget` for full custom | ✅ `colorShadow` / `opacityShadow` / custom widgets |
| Reduced motion | ⚠️ not automatic; `disableMovingAnimation` + `disableScaleAnimation` + `scrollDuration` wired from `MediaQuery.disableAnimations` by us | ⚠️ not automatic; durations + `pulseEnable` wired by us |

**Recommendation: `showcaseview` 5.1.0.** It is the only vetted package that scrolls
ordered stops into view inside a scrollable list, and it passes every other criterion
outright. Implementation notes for #195: use the 5.x `ShowcaseView.register()` API (the
`ShowCaseWidget` seen in most tutorials is deprecated); mitigate the lazy-mount caveat
per §1.2; wire the two animation-disable flags and `scrollDuration` to
`MediaQuery.disableAnimations`; drive scrim/tooltip colors from
`OverlayColors` / `context.mood`.

## Sources

- pub.dev package pages, read 2026-08-20: [showcaseview](https://pub.dev/packages/showcaseview),
  [tutorial_coach_mark](https://pub.dev/packages/tutorial_coach_mark),
  [flutter_intro](https://pub.dev/packages/flutter_intro),
  [onboarding_overlay](https://pub.dev/packages/onboarding_overlay), plus pub.dev search
  for the long tail.
- showcaseview source & docs (`master`, matching 5.1.0):
  [`lib/src/showcase/showcase_controller.dart`](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/blob/master/lib/src/showcase/showcase_controller.dart)
  (`scrollIntoView` / `Scrollable.ensureVisible`),
  [`lib/src/showcase/showcase_view.dart`](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/blob/master/lib/src/showcase/showcase_view.dart)
  (`startShowCase`, `dismiss`, `enableAutoScroll`, animation flags),
  [`lib/src/showcase/showcase.dart`](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/blob/master/lib/src/showcase/showcase.dart)
  (theming params),
  [`doc/documentation.md`](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/blob/master/doc/documentation.md)
  ("Auto Scrolling" caveat + escape hatch),
  [`CHANGELOG.md`](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/blob/master/CHANGELOG.md).
- tutorial_coach_mark source (`master`, matching 1.3.3):
  [`lib/`](https://github.com/RafaelBarbosatec/tutorial_coach_mark/tree/master/lib)
  (grep for scroll code — zero hits),
  [`README.md`](https://github.com/RafaelBarbosatec/tutorial_coach_mark/blob/master/README.md),
  [`CHANGELOG.md`](https://github.com/RafaelBarbosatec/tutorial_coach_mark/blob/master/CHANGELOG.md).
- GitHub API repo metadata for both repos (`pushed_at`, `open_issues_count`, license),
  read 2026-08-20.
- This repo: `lib/features/learn/presentation/learn_screen.dart:34` (the Learn tab's
  `ListView`).
