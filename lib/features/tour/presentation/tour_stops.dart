import 'package:flutter/widgets.dart';
import 'package:showcaseview/showcaseview.dart';

/// The Tour's four stops, in scroll order.
///
/// The order of [inScrollOrder] *is* the Tour: `startShowCase` plays the keys
/// in list order, so the sequence the spec locked lives here rather than in the
/// screens that anchor them. Stops 1–3 are anchored on Learn and stop 4 on the
/// app shell's tab bar, which is why the keys cannot live on either screen.
///
/// The keys are top-level rather than per-`State` because since `showcaseview`
/// 5.x a `Showcase` key is a **registry identifier**, not a key attached to the
/// element — so the usual objection to a shared `GlobalKey` (two live trees
/// fighting over one element) does not apply, and a stable identity is what
/// lets the shell and Learn name the same stop.
abstract final class TourStops {
  /// The scope every [ShowcaseView] and `Showcase` in the Tour is registered
  /// under. Named rather than default so a stray registration elsewhere in the
  /// app can never capture the Tour's stops.
  static const String scope = 'brewpath.tour';

  /// Stop 1 — the Today card: the daily loop and the streak.
  static final GlobalKey today = GlobalKey();

  /// Stop 2 — the practice area: the replay list and the mini-games, together,
  /// because they are one idea ("practice, your way") rather than two.
  static final GlobalKey practice = GlobalKey();

  /// Stop 3 — the modules section: a finite course that pays on first
  /// completion.
  static final GlobalKey modules = GlobalKey();

  /// Stop 4 — the bottom tab bar: the three tabs the Tour never visits.
  static final GlobalKey tabs = GlobalKey();

  /// The stops as the engine plays them.
  static List<GlobalKey> get inScrollOrder => [today, practice, modules, tabs];
}
