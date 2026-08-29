import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/features/tour/presentation/tour_stops.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

/// Owns the Tour's engine for as long as the app shell is on screen.
///
/// `ShowcaseView` is a controller registered in a global registry rather than
/// an inherited widget, so *something* has to own its lifetime — this is that
/// something, and it lives at the shell because stop 4 is the bottom tab bar,
/// which no tab can reach. Registering per-screen instead would leave the tab
/// bar unable to join the run its own list order ends with.
class TourHost extends ConsumerStatefulWidget {
  /// Creates a [TourHost] around [child].
  const TourHost({
    required this.activeBranchIndex,
    required this.child,
    super.key,
  });

  /// Which of the shell's four branches is on screen.
  ///
  /// The host outlives every tab, which is exactly why it has to be told: a
  /// spotlight anchored on Learn kept floating over Path once the tab changed,
  /// because nothing here disposes on a branch switch. Passed as a value
  /// rather than read from the router so the rule is a widget input — a test
  /// changes it directly, with no route to drive.
  final int activeBranchIndex;

  /// The shell this host wraps.
  final Widget child;

  /// Whether [context] sits inside a host, and so inside a subtree where the
  /// Tour's engine is registered.
  ///
  /// A `Showcase` throws outright when its scope has no registered view, which
  /// would make every stop a hard dependency on the shell — a screen pumped on
  /// its own, or rendered outside the tab structure, would crash rather than
  /// simply have no Tour. Stops ask this first and render their child plain
  /// when the answer is no.
  static bool isHosted(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TourScopeMarker>() != null;

  @override
  ConsumerState<TourHost> createState() => _TourHostState();
}

/// Marks the subtree in which [TourHost] has registered the engine.
class _TourScopeMarker extends InheritedWidget {
  const _TourScopeMarker({required super.child});

  @override
  bool updateShouldNotify(_TourScopeMarker oldWidget) => false;
}

class _TourHostState extends ConsumerState<TourHost> {
  /// How long the engine takes to bring an off-screen stop into view. Long
  /// enough to read as movement rather than a jump cut, and zeroed outright
  /// under reduced motion.
  static const _scrollDuration = Duration(milliseconds: 400);

  late final ShowcaseView _view;

  @override
  void initState() {
    super.initState();
    _view = ShowcaseView.register(
      scope: TourStops.scope,
      // The make-or-break feature: three of the four stops can be below the
      // fold on a small phone, and the engine scrolls to them itself.
      enableAutoScroll: true,
      // Announces each tooltip as a live region, so the stop's locked copy is
      // what a screen reader reads when the spotlight moves.
      semanticEnable: true,
      onFinish: _stopped,
      onDismiss: (_) => _stopped(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read here rather than in initState: reduced motion is a MediaQuery value
    // and can change while the app is open. The fields are mutable on purpose,
    // so a mid-session change lands on the next stop rather than requiring a
    // restart.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _view
      ..disableMovingAnimation = reduceMotion
      ..disableScaleAnimation = reduceMotion
      // Not merely faster — zero. The spotlight still has to *arrive* at an
      // off-screen stop, so the scroll happens either way; reduced motion
      // makes it a cut rather than a slide.
      ..scrollDuration = reduceMotion ? Duration.zero : _scrollDuration;
  }

  /// Ends a running Tour the way Skip does, leaving a finished one alone.
  ///
  /// `dismiss()` fires `onDismiss` whether or not a stop is on screen, so the
  /// guard is what keeps an ordinary tab switch from announcing the end of a
  /// Tour nobody started.
  void _endIfRunning() {
    if (!_view.isShowcaseRunning) return;
    _view.dismiss();
  }

  void _stopped() {
    if (!mounted) return;
    ref.read(tourRunningProvider.notifier).set(running: false);
  }

  @override
  void didUpdateWidget(TourHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The stops belong to the tab that anchors them. Leaving that tab ends the
    // Tour rather than carrying it along, which is what the callout did.
    //
    // Next frame, not this one: the branch changes *during* a build, and
    // ending the Tour writes `tourRunningProvider`, which Riverpod refuses
    // mid-build. Waiting a frame is invisible — the overlay is torn down
    // before the new tab has been painted with anything over it.
    //
    // Whether a Tour was running is read *now*, at the switch, not in the
    // callback: Replay switches tabs and then starts the stops, and a check
    // deferred to the next frame would find that new Tour and end it.
    final branchChanged =
        widget.activeBranchIndex != oldWidget.activeBranchIndex;
    if (branchChanged && _view.isShowcaseRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _endIfRunning();
      });
    }
  }

  @override
  void dispose() {
    _view.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _TourScopeMarker(child: widget.child);
}

/// Plays the four stops in scroll order.
///
/// Flips [tourRunningProvider] first and starts on the next frame, because the
/// flag is what makes the Learn list mount every child — starting in the same
/// frame would ask the engine to scroll to a stop that is not in the tree yet.
///
/// Writes nothing. `tourSeen` is the intro overlay's business, which is what
/// lets Replay reuse this untouched.
void startTourStops(WidgetRef ref) {
  ref.read(tourRunningProvider.notifier).set(running: true);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ShowcaseView.getNamed(
      TourStops.scope,
    ).startShowCase(TourStops.inScrollOrder);
  });
}
