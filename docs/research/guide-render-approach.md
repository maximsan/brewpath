# How the guide layer gets drawn

Research for [issue #339](https://github.com/maximsan/brewpath/issues/339), child of the
wayfinder map [#336](https://github.com/maximsan/brewpath/issues/336).

**Scope.** `prototype/guide.jsx` designs the four-step Today tour as a **card callout plus
an animated dim-and-highlight frame**. This document asks one question: can
`showcaseview` 5.1.0 — already a dependency, already wired in `lib/features/tour/` — render
that design, or is a hand-rolled layer the simpler and more faithful build? It does not
specify the tour's copy, stops or trigger rules; those belong to the spec ticket.

**Method.** Every `showcaseview` claim was read from the package's own 5.1.0 source in the
local pub cache (`~/.pub-cache/hosted/pub.dev/showcaseview-5.1.0/`), which is the exact code
`pubspec.yaml`'s `showcaseview: ^5.1.0` resolves to (`pubspec.yaml:3` of the package reads
`version: 5.1.0`). File and line references below point into that tree and are reproducible
by grep. Currency was re-checked live on pub.dev on 2026-08-24: 5.1.0 is still latest,
published ~2 months ago, MIT, verified publisher `simform.com`, 150 pub points, 3.11k likes,
190k weekly downloads. Design claims cite `prototype/guide.jsx` and `prototype/app.jsx` by
line, per the map's guardrail. Nothing below is asserted from memory.

---

## 0. The design, stated precisely

From `prototype/guide.jsx:53-84`, the layer is a single absolutely-positioned box over the
whole app frame, containing three things:

1. **A full-screen click shield** (`guide.jsx:56`) — a bare `inset:0` div with no handler.
   The comment is explicit: *"the page underneath is frozen while the tour runs"*. Nothing
   underneath is tappable, **including the highlighted target**.

2. **The frame** (`guide.jsx:58-63`) — a rounded rect inset 6px around the target
   (`left: rect.x - 6`, `width: rect.w + 12`), `borderRadius: 18`, with two coordinated
   parts:
   - `boxShadow: '0 0 0 1400px var(--dim-modal)'` — a 1400px spread shadow, which is how
     the design dims everything *outside* the rect while leaving the rect itself clear. It
     is a cutout expressed as a shadow.
   - `border: '1px solid color-mix(in oklab, var(--accent) 55%, transparent)'` — a **1px
     accent ring on the cutout's own edge**, at the same 18px radius.
   - `transition: left/top/width/height 320ms cubic-bezier(.3,.8,.3,1)` — the rect
     **animates its position and size** from the previous target to the next. Since only
     `left/top/width/height` are listed, the dim and the ring travel with it as one moving
     frame. This is the layer's signature motion.

3. **The card** (`guide.jsx:65-83`) — `left: 20, right: 20` (screen-width minus margins,
   not intrinsic width), placed **below** the target at `top: rect.y + rect.h + 20` or
   **above** it at `bottom: rect.areaH - rect.y + 20`, chosen by
   `below = (rect.y + rect.h) < (rect.areaH - 330)` (`guide.jsx:52`). Contents in order:
   a `"N of 4"` counter, title, body, then a row of **Skip (left) / dots (center) /
   Next–Done (right)** (`guide.jsx:71-82`).

Two further behaviours matter for the comparison:

- **Chrome targets.** Step 3 targets `[data-guide="today-header"]` and step 4 targets
  `.tabbar` (`guide.jsx:12-13`) — the shared header and the tab bar, both **outside** the
  scrolling feed. Both carry `scrollTop: true`, and the effect handler acts on it by
  setting `scroller.scrollTop = 0` (`guide.jsx:35`) — it scrolls the feed **to the top**, so
  the framed chrome reads in its natural context. Only non-chrome steps do
  scroll-into-view math (`guide.jsx:36-45`).
- **The layer's lifetime.** `app.jsx:1651` renders it as
  `{tourVisible && <TodayTour onFinish={finishTour}/>}`, where `tourVisible` requires
  `view === 'app' && tab === 'learn'` and no sheet or gate open (`app.jsx:1163-1164`). It
  is an ordinary conditional child of the app tree — leave the Learn tab and the layer is
  simply not rendered. It is not a detached overlay, and `.tabbar` is inside the same
  `#screenArea` root the layer covers (`app.jsx:1798`, `screens.jsx:2866`).

---

## 1. `showcaseview` 5.1.0 against that design

### 1.1 The frame cannot carry both its radius and its ring — blocked

The scrim is `ClipPath(clipper: ShapeClipper(...), child: ColoredBox(...))`
(`lib/src/utils/overlay_manager.dart:192-205`). `ShapeClipper` subtracts each target's
rounded rect from a full-screen path (`lib/src/utils/shape_clipper.dart:110-157`). **The
clipper paints no stroke** — a `ClipPath` has no border to give. Grepping the whole `lib/`
tree for `Border|strokeWidth|PaintingStyle` returns hits only in `arrow_painter.dart`,
`tooltip_wrapper.dart` and `tooltip_action_button.dart` — the tooltip and its buttons.
Nothing borders the cutout.

The ring can only come from `TargetWidget`, a transparent `Container` placed at the target
rect with `decoration: ShapeDecoration(shape: ...)`
(`lib/src/showcase/target_widget.dart:83-92`). Its shape is chosen by this ternary
(`target_widget.dart:88-90`):

```dart
shape: radius == null
    ? shapeBorder
    : RoundedRectangleBorder(borderRadius: radius!),
```

where `radius` is `Showcase.targetBorderRadius` and `shapeBorder` is
`Showcase.targetShapeBorder` (`lib/src/showcase/showcase_controller.dart:308-311`). That
produces a fork with no correct branch:

- **Set `targetBorderRadius: 18`** (what the shipped `TourStop` does at
  `lib/features/tour/presentation/tour_stop.dart:78`) → `radius != null`, so
  `targetShapeBorder` is **discarded** and replaced with a side-less
  `RoundedRectangleBorder`. The cutout is correctly rounded and **there is no ring**. This
  is why the shipped tour has no accent edge.
- **Leave `targetBorderRadius: null` and put the ring in `targetShapeBorder`**
  (`RoundedRectangleBorder(borderRadius: 18, side: BorderSide(color: accent, width: 1))`)
  → the ring paints at r=18, but the **cutout's** radius comes from a different field:
  `linkedShowcaseDataModel.radius = config.targetBorderRadius`
  (`showcase_controller.dart:258-263`), now null, so `ShapeClipper` falls back to
  `Constants.defaultTargetRadius`, which is **`Radius.circular(3)`**
  (`lib/src/utils/constants.dart:51`). The hole is a 3px-radius rect; the ring drawn over
  it is an 18px-radius rect. They visibly disagree at all four corners.

The two radii are read from two different fields and one of them is only honoured when the
other is null. There is no combination that yields an 18px cutout with an 18px accent ring —
which is precisely `guide.jsx:59-61`. Short of forking the package, the frame's defining
detail is unreachable.

### 1.2 The 320ms move between targets does not exist — blocked

The package never interpolates the highlight rect. Grepping the whole `lib/` tree for
`RectTween|Tween<Rect|AnimatedContainer|AnimatedPositioned|lerp|Tween(` returns **zero
hits**. `ShapeClipper` receives raw `Rect`s and `shouldReclip` compares them for equality
(`shape_clipper.dart:159-161`), so a new target repaints the hole at its new bounds — a hard
snap. The overlay is refreshed by `_overlayEntry?.markNeedsBuild()`
(`overlay_manager.dart:259`), a rebuild, not a transition.

The name that suggests otherwise is a false friend. `movingAnimationDuration` /
`disableMovingAnimation` belong entirely to `ToolTipWrapper`
(`lib/src/tooltip/tooltip_wrapper.dart:120-129`), and `movingAnimationListener` wires the
controller to loop forever — `completed → reverse()`, `isDismissed → forward()`
(`tooltip_wrapper.dart:299-313`). With `Constants.defaultAnimationDuration =
Duration(milliseconds: 2000)` (`constants.dart:61`) and
`toolTipSlideEndDistance = 7` (`showcase.dart` ctor default), it is a **2-second, 7-pixel
idle bob of the tooltip** — an attention-getting oscillation, not a transition between
targets, and not applied to the highlight at all. The vendor's own feature list says as
much: *"Animation and transition effects for tooltip"* (`doc/documentation.md:17`).

`scaleAnimation` is likewise a tooltip entrance, and is **force-disabled** whenever a custom
container is used: `disableScaleAnimation: (…) || config.container != null`
(`showcase_controller.dart:334-336`). So the design's one signature motion is absent, and
the custom card the design requires switches off what motion the package does have.

### 1.3 The card is reachable, its placement is not the design's — partial

`Showcase.withWidget(container: …)` renders an arbitrary widget as the tooltip
(`lib/src/showcase/showcase.dart:176-253`), so the counter/title/body/Skip/dots/Next card
can be built exactly. Two caveats:

- **Width.** The card is `left:20; right:20` — stretched, not intrinsic. `withWidget` lays
  out the container at its natural size inside a `MultiChildRenderObjectWidget` delegate,
  so matching the design means computing `MediaQuery.sizeOf(context).width - 40` by hand and
  hoping the delegate's `toolTipMargin` (default 14) and edge-clamping do not fight it.
- **Above/below.** The design's rule is a literal threshold —
  `(rect.y + rect.h) < (areaH - 330)` (`guide.jsx:52`), i.e. "below unless the target's
  bottom is within 330px of the frame's bottom". `showcaseview` decides placement in
  `render_position_delegate.dart` on its own logic, or takes a hard-coded
  `tooltipPosition`. Reproducing the design's threshold means computing it ourselves and
  passing `tooltipPosition` per step — at which point the delegate is being overridden, not
  used.

### 1.4 Chrome targets work; `scrollTop` does not — partial

A `Showcase` is just a wrapper around any widget with a `GlobalKey`, so the header and tab
bar are perfectly valid targets — the shipped tour already does this
(`lib/app/app_shell.dart:101` wraps `bottomNavigationBar` in a `TourStop`). What the
package cannot do is the design's other half. Its only scrolling is
`Scrollable.ensureVisible` on the **target** (`showcase_controller.dart`, `enableAutoScroll`);
there is no "return the feed to the top" behaviour. `guide.jsx:35` sets
`scroller.scrollTop = 0` for both chrome steps. Delivering that requires owning a
`ScrollController` and driving it in an `onStart` callback — our code either way.

### 1.5 The click shield is configurable — passes

`disableBarrierInteraction` on either the `Showcase` or the `ShowcaseView` makes barrier
taps inert (`showcase_controller.dart:195-198`), and `disableDefaultTargetGestures: true`
stops the target firing underneath (already set at `tour_stop.dart:81`). This matches
`guide.jsx:56`. No obstacle here.

### 1.6 The overlay outlives the screen by construction — the defect class, structurally

This is the criterion the ticket names, and the package fails it in a way configuration
cannot reach.

- The overlay is a **process-wide singleton**: `OverlayManager._instance`, a private static
  (`overlay_manager.dart:41-49`), holding one `OverlayEntry`.
- That entry is inserted into the **root** overlay:
  `OverlayManager.instance.updateState(context.findRootAncestorStateOfType<OverlayState>())`
  (`lib/src/showcase/showcase.dart:567-569`) — the root `Navigator`'s overlay, which sits
  **above** the whole `StatefulShellRoute` shell.
- Its lifetime is bound to a boolean, not to a widget:
  `OverlayManager.instance.update(show: isShowcaseRunning, scope: scope)`
  (`showcase_view.dart:351, 431, 648`). It hides only when the app explicitly calls
  `dismiss()` / runs past the last stop, or when `unregister()` runs
  (`showcase_view.dart:335-338`).
- **The package is entirely route-unaware.** Grepping `lib/` for
  `NavigatorObserver|ModalRoute|RouteAware|isCurrent` returns **zero hits**. Nothing in it
  observes navigation, so nothing in it can notice that the screen the tour describes is no
  longer on screen.

Now compose that with this app. `TourHost` registers the engine at the **shell**, and says
why: *"The Tour's engine is owned here, not on Learn: the last stop is the tab bar below,
which lives outside every branch"* (`lib/app/app_shell.dart:74-76`,
`tour_runner.dart:7-13`). `TourHost.dispose()` calls `_view.unregister()`
(`tour_runner.dart:91-94`) — but the shell is disposed only when the whole shell goes away,
never on a tab switch. And the per-stop cleanup cannot help either: `Showcase.dispose()`
calls `removeController` (`showcase.dart:612-620`), but `StatefulShellRoute` keeps its
branches alive by design, so the Learn subtree goes offstage **without** being disposed. No
controller is removed, `isShowcaseRunning` stays true, and a root-overlay entry above the
shell keeps painting the scrim and card over whichever tab the learner just opened.

That is the shipped defect, and it is not a wiring mistake — it is what "a singleton overlay
in the root navigator, hidden only by an explicit call" means in a shell router. Fixing it
inside the package means adding our own navigation listener that calls `dismiss()` on every
branch change: a correction bolted on top, which can be forgotten, mis-ordered, or defeated
by any future route that also fails to fire. **The bug stays representable.**

### 1.7 Reduced motion — wireable, and already wired

Not automatic (`MediaQuery.disableAnimations` appears nowhere in the package), but
`disableMovingAnimation`, `disableScaleAnimation` and `scrollDuration` are mutable fields on
`ShowcaseView` and the shipped `TourHost` already drives all three from
`MediaQuery.disableAnimationsOf` in `didChangeDependencies` (`tour_runner.dart:68-83`). This
criterion is a wash between the options — note only that under this design the thing needing
a reduced-motion path is the 320ms frame move, which §1.2 shows the package does not have.

---

## 2. The hand-rolled layer — and why it should not be an `OverlayEntry`

The ticket frames the alternative as "an `OverlayEntry` layer measuring anchors via
`GlobalKey`/`CompositedTransformTarget`". The research finds the `OverlayEntry` half of that
framing is the part to drop, and dropping it is what wins the lifetime criterion.

An `OverlayEntry` is a *detached* child of an `Overlay` — inserted and removed by imperative
calls, with a lifetime managed by whoever remembers to remove it. Putting our own entry in
the root overlay reproduces §1.6's failure mode exactly. Putting it in a branch-local
overlay does not help either: `StatefulShellRoute` keeps branches alive, so the owning
`State.dispose()` still never fires on a tab switch.

The prototype already shows the correct shape, and it is simpler than either: **an ordinary
widget in the tree, conditionally built.** `app.jsx:1651` renders
`{tourVisible && <TodayTour/>}` gated on `tab === 'learn'`. The Flutter analogue is a
`Stack` in the shell's `Scaffold` body whose top child is the guide layer, built only when
`navigationShell.currentIndex` is the Learn branch and the tour is running. The shell is the
right host for the same reason `TourHost` already lives there — the tab bar is stop 4 — but
because the layer is a *child in the tree* rather than a detached entry:

- Switching tabs rebuilds the shell with a different index, the condition is false, and the
  layer is **not built**. There is no entry to leak, no `dismiss()` to remember, no observer
  to wire. The defect is not fixed; it is **unrepresentable** — which is exactly what the
  ticket asks for.
- The same gate absorbs the design's other suppression rules for free — no tour over a
  sheet or gate (`app.jsx:1164`) — as boolean terms rather than more imperative teardown.

What the layer costs us, concretely:

| Piece | Build |
| --- | --- |
| Anchor measurement | A `GlobalKey` per target; `findRenderObject()` → `localToGlobal` against the shell's box. Same measurement `guide.jsx:20-28` does, and the same one `TargetPositionService` does inside the package. Re-measure on a post-frame callback and on metrics change. |
| The frame | One `AnimatedPositioned` (or an `AnimationController` + `RectTween`) at 320ms with the design's cubic — the animation the package lacks — wrapping a `DecoratedBox` with a `BoxDecoration(borderRadius: 18, border: 1px accent)`. |
| The dim | The design's 1400px spread shadow has a direct Flutter equivalent: a `BoxShadow` with a large `spreadRadius` and zero blur on the same box, so dim and ring animate as one object and the §1.1 fork never arises. `OverlayColors.dimModal` is already the token (`lib/shared/theme/overlay_colors.dart:36`). |
| The card | A plain `Positioned` + `Column` — the same widget either option requires (§1.3), minus the fight with the delegate over width and placement. |
| The shield | An `IgnorePointer`-free `GestureDetector` behind everything with an empty `onTap`. One widget. |
| Step/scroll choreography | The step index, the `scrollTop: true` handling and the scroll-into-view math (`guide.jsx:29-45`) — **ours in both options**, per §1.4. |
| Reduced motion | The `AnimationController`'s duration reads `MediaQuery.disableAnimationsOf` — `Duration.zero` makes the move a cut. |

Extracted per the repo's rules, the geometry (which side the card takes, the frame rect, the
scroll delta) is pure-Dart in a sibling `*_animation.dart` and unit-testable without pumping
a widget — where the package's equivalents are private render objects we cannot test.

**On "code owned".** The honest comparison is not "our layer vs zero". Keeping the package
means owning the `withWidget` card, a hand-computed width, a per-step `tooltipPosition` to
reproduce the placement threshold, a `ScrollController` for `scrollTop`, a navigation
listener to force `dismiss()` on branch change — plus a frame whose ring is unreachable and
whose 320ms move does not exist. That is most of the layer's logic, written as
configuration and workarounds around a package, plus a dependency, plus the parts of its
behaviour we must actively suppress. The hand-rolled layer is a handful of widgets and one
`AnimationController` that render the design directly.

---

## 3. Verdict per criterion

| Criterion (#339) | `showcaseview` 5.1.0 | Hand-rolled in-tree layer |
| --- | --- | --- |
| **Custom overlay shape** (18px cutout + 1px accent ring) | ❌ **Blocked.** No stroke on the clip path; ring and cutout read two different fields and `target_widget.dart:88-90` honours `targetShapeBorder` only when `targetBorderRadius` is null, which drops the cutout to `Radius.circular(3)` (§1.1) | ✅ One `BoxDecoration` — border and large-spread shadow on the same box |
| **Animated frame between targets** (320ms, custom cubic) | ❌ **Absent.** Zero rect interpolation in the package; `movingAnimation` is a 2s/7px tooltip bob (§1.2), and a custom container force-disables the scale animation | ✅ `AnimatedPositioned` / `RectTween`, the design's curve verbatim |
| **Fully custom card** | ⚠️ `withWidget` renders it, but width and above/below placement fight the layout delegate; the design's 330px threshold must be computed and forced per step (§1.3) | ✅ `Positioned` + `Column`, placement rule as written |
| **Chrome targets** (header, tab bar) | ⚠️ Targets fine; the design's `scrollTop: true` reset has no package equivalent — our `ScrollController` either way (§1.4) | ⚠️ Same work, same cost |
| **Click shield** | ✅ `disableBarrierInteraction` + `disableDefaultTargetGestures` (§1.5) | ✅ One `GestureDetector` |
| **Overlay dies with the screen** | ❌ **Structurally cannot.** Singleton entry in the root overlay above the shell, hidden only by an explicit call, zero route-awareness; `StatefulShellRoute` keeps branches alive so no dispose fires. Any fix is a bolt-on that can be forgotten (§1.6) | ✅ **Unrepresentable.** A conditional child of the shell's `Stack` — a different tab simply does not build it |
| **Reduced motion** | ⚠️ Wireable, already wired — but there is no frame animation to reduce (§1.7) | ⚠️ Wireable: controller duration from `MediaQuery.disableAnimationsOf` |
| **Code owned** | Card + width math + per-step position + `ScrollController` + a dismiss-on-navigation listener + a dependency, and still off-design | Frame + card + shield + measurement + choreography, on-design, geometry unit-testable |

---

## 4. Recommendation

**Build the guide layer by hand, as an in-tree `Stack` child of the app shell, and drop
`showcaseview`.**

`showcaseview` is a healthy, well-maintained package — that is not in question. It is built
for a different picture: a *spotlight with a tooltip*. The guide layer is a *moving bordered
frame with a card*, and two of its defining properties are not configuration gaps but
structural ones.

**The disqualifiers, concretely:**

1. **The accent ring cannot coexist with the cutout radius.** `target_widget.dart:88-90`
   discards `targetShapeBorder` whenever `targetBorderRadius` is set, and the clipper's
   radius falls back to `Radius.circular(3)` when it is not — so it is an 18px hole with no
   ring, or an 18px ring around a 3px hole. `guide.jsx:59-61` asks for both.
2. **The 320ms frame move does not exist.** Zero rect interpolation anywhere in the package;
   the similarly-named `movingAnimation` is a 2-second, 7-pixel idle bob of the *tooltip*
   (`constants.dart:61`, `tooltip_wrapper.dart:299-313`), and using a custom card
   force-disables the scale animation too (`showcase_controller.dart:334-336`). The layer's
   signature motion would simply be missing.
3. **The tab-persistence defect cannot be made impossible.** A singleton `OverlayEntry` in
   the root overlay above the shell, hidden only by an explicit call, with no route
   awareness (§1.6) — against a `StatefulShellRoute` that keeps branches alive, so no
   dispose ever fires. The shipped bug is the architecture behaving as designed. Any repair
   is a listener we must remember to keep correct; the ticket asks for a shape where that
   class of bug **cannot** occur.

Points 1 and 2 mean the package cannot draw the design. Point 3 means it cannot hold the
property the rebuild exists to guarantee. The remaining criteria are either a wash (chrome
scrolling, reduced motion) or slightly favour the hand-rolled layer (card placement).

**Implementation notes for the build ticket:**

- Host the layer in the shell's `Scaffold` body as the top child of a `Stack`, gated on the
  Learn branch index plus the tour-running flag — never an `OverlayEntry`. The tab bar must
  be *inside* the stacked area for step 4, matching `#screenArea` in the prototype.
- Frame: one animated box with `BoxDecoration(borderRadius: 18, border: 1px accent @55%)`
  plus a zero-blur, large-`spreadRadius` `BoxShadow` in `OverlayColors.dimModal` — dim and
  ring move as one object. Note 18px is off `AppRadii.chrome` (14) and needs an `OffTokens`
  entry with its reason, or a ruling from the spec ticket.
- Extract the geometry — frame rect, above/below choice (the 330px threshold), scroll delta
  — into a pure sibling `*_animation.dart` per the repo's Code Quality Rules.
- Reduced motion: the controller's duration is `Duration.zero` under
  `MediaQuery.disableAnimationsOf`, making the move a cut. The map lists this as an open
  item; this is the mechanism, the treatment is the spec ticket's call.
- Removing the dependency retires `lib/features/tour/presentation/tour_runner.dart` and
  `tour_stop.dart` along with `showcaseview` in `pubspec.yaml`.

---

## 5. Why #192's choice does not bind this

[#192](https://github.com/maximsan/brewpath/issues/192) chose `showcaseview` and recorded it
in [`tour-package.md`](tour-package.md). That research is sound for what it asked. Its own
§0 names the deciding criterion — *"the package must scroll the target into view itself …
That is the make-or-break criterion in #192"* — and it evaluated candidates against a
spotlight-tooltip tour with auto-scroll, because that was the design #191 had specified.

Per #336's root-cause note, that design was invented rather than read from the prototype.
The real design is a callout-and-frame layer whose deciding criteria are a bordered animated
frame and a screen-bound lifetime — neither of which #192 tested, and both of which the
package fails. Auto-scroll, the criterion that decided #192, is worth ~15 lines of
`ScrollController` here and is needed in both options anyway (§1.4).

`tour-package.md` should be left in place as the record of an earlier decision, with a
pointer to this document noting that the design it was chosen for no longer applies.

---

## Sources

- **`showcaseview` 5.1.0 source**, read 2026-08-24 from the local pub cache
  (`~/.pub-cache/hosted/pub.dev/showcaseview-5.1.0/`), the resolved version for
  `showcaseview: ^5.1.0`:
  `lib/src/utils/overlay_manager.dart` (singleton, root-overlay entry, `ClipPath` scrim,
  no stroke), `lib/src/utils/shape_clipper.dart` (cutout paths, `shouldReclip`),
  `lib/src/showcase/target_widget.dart:83-92` (the radius/shapeBorder ternary),
  `lib/src/utils/constants.dart:51,53,61` (`defaultTargetRadius` = 3,
  `defaultTargetShapeBorder` = r8, `defaultAnimationDuration` = 2000ms),
  `lib/src/showcase/showcase_controller.dart:243-341` (rect model, target/tooltip build,
  forced `disableScaleAnimation` with a container), `lib/src/tooltip/tooltip_wrapper.dart`
  (moving/scale controllers, the looping `movingAnimationListener`),
  `lib/src/showcase/showcase.dart:176-253, 551-620` (`withWidget` ctor, root-overlay
  lookup, dispose), `lib/src/showcase/showcase_view.dart:325-352` (`unregister`,
  `updateOverlay`), `lib/src/showcase/showcase_service.dart:174-179` (`removeController`),
  `doc/documentation.md:17` ("Animation and transition effects for tooltip").
  Negative results (zero hits over `lib/`): `RectTween|Tween<Rect|AnimatedContainer|
  AnimatedPositioned|lerp|Tween(` and `NavigatorObserver|ModalRoute|RouteAware|isCurrent`.
- **pub.dev**, [showcaseview](https://pub.dev/packages/showcaseview), read 2026-08-24:
  5.1.0 latest (~2 months old), MIT, verified publisher `simform.com`, 150 pub points,
  3.11k likes, 190k weekly downloads.
- **Design source** (read-only, per CLAUDE.md): `prototype/guide.jsx:9-86` (TOUR_STEPS,
  `TodayTour`, frame, card, shield), `prototype/app.jsx:1163-1164, 1651, 1798` (visibility
  gate, render site, root), `prototype/screens.jsx:2866` (`.tabbar`).
- **This repo:** `lib/app/app_shell.dart:60-101` (shell, `TourHost`, tab bar as a stop),
  `lib/features/tour/presentation/tour_runner.dart` (engine ownership, reduced-motion
  wiring), `lib/features/tour/presentation/tour_stop.dart:60-83` (current stop config),
  `lib/shared/theme/overlay_colors.dart:36` (`dimModal`),
  `lib/shared/theme/app_radii.dart:27` (`chrome` = 14), `pubspec.yaml:53`.
