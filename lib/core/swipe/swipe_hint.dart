import 'dart:async';

import 'package:brew_path/core/swipe/swipe_hint_providers.dart';
import 'package:brew_path/core/swipe/swipe_hint_timing.dart';
import 'package:brew_path/core/swipe/swipe_motion.dart';
import 'package:brew_path/core/swipe/swipe_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The first run of one surface's gesture, as its caller reads it.
class SwipeHintState {
  /// Creates a [SwipeHintState].
  const SwipeHintState({
    required this.showing,
    required this.used,
    required this.offset,
    required this.markUsed,
  });

  /// Whether the caption is up.
  final bool showing;

  /// Whether the gesture has been used before. What a standing affordance dims
  /// against: bright under the hint, then quiet once it has taught itself.
  final bool used;

  /// Where the nudge has the element right now. Pass it to a [SwipeNudge].
  final double offset;

  /// Call the moment the gesture is used. Stops the hint and records it.
  final VoidCallback markUsed;
}

/// The first-run hint: nudge twice, with a caption, **every time the surface
/// opens until the gesture is used**.
///
/// Never once ever, and never capped at a count — a cap only ever fires on the
/// learner who has not learned the gesture, who needs the explanation more the
/// third time, not less.
class SwipeHint extends ConsumerStatefulWidget {
  /// Creates a [SwipeHint] for [surface].
  const SwipeHint({
    required this.surface,
    required this.builder,
    this.enabled = true,
    this.nudge = swipeDefaultNudge,
    super.key,
  });

  /// Which gesture this hint teaches, and whose used-flag retires it.
  final SwipeSurface surface;

  /// Paints the surface against the hint's state.
  final Widget Function(BuildContext context, SwipeHintState hint) builder;

  /// Whether there is anything to teach yet — an empty deck has no gesture.
  final bool enabled;

  /// How far the first nudge travels, signed like the drag it imitates.
  final double nudge;

  @override
  ConsumerState<SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends ConsumerState<SwipeHint> {
  final List<Timer> _timers = [];
  bool _showing = false;
  double _offset = 0;
  bool _played = false;

  /// What the stored flag says. An unresolved read counts as used, so a
  /// standing affordance starts quiet rather than flashing bright on launch.
  bool _usedStored = true;

  /// Latched: a gesture used on this surface stays used for as long as it is
  /// on screen. The provider re-reads while the write is still in flight, and
  /// a hint rearmed by that stale read would replay itself mid-swipe.
  bool _usedHere = false;

  bool get _used => _usedHere || _usedStored;

  @override
  void initState() {
    super.initState();
    _usedStored = _storedSays(ref.read(swipesUsedProvider).asData?.value);
    _arm();
    ref.listenManual(
      swipesUsedProvider,
      (_, next) => _onKnown(next.asData?.value),
    );
  }

  bool _storedSays(Set<String>? known) =>
      known?.contains(widget.surface.id) ?? true;

  @override
  void didUpdateWidget(SwipeHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) _arm();
  }

  /// Takes the stored flag as it now reads and arms or retires the hint.
  void _onKnown(Set<String>? known) {
    final stored = _storedSays(known);
    if (stored == _usedStored) return;
    setState(() => _usedStored = stored);
    if (_used) {
      _stop();
    } else {
      _played = false;
      _arm();
    }
  }

  void _arm() {
    if (_used || _played || !widget.enabled) return;
    _played = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void _stop() {
    _cancelTimers();
    if (!mounted) return;
    setState(() {
      _showing = false;
      _offset = 0;
    });
  }

  void _markUsed() {
    if (_usedHere) return;
    setState(() => _usedHere = true);
    _stop();
    unawaited(markSwipeUsed(ref, widget.surface));
  }

  /// Reduced motion drops the nudge and keeps the caption, which then holds
  /// longer because there is no movement to read it against.
  void _play() {
    if (!mounted) return;
    final reduced = MediaQuery.disableAnimationsOf(context);
    setState(() => _showing = true);
    if (!reduced) {
      for (final step in swipeNudgeSteps(widget.nudge)) {
        _timers.add(
          Timer(step.at, () => setState(() => _offset = step.offset)),
        );
      }
    }
    _timers.add(
      Timer(
        reduced ? swipeHintReducedDuration : swipeHintDuration,
        () => setState(() => _showing = false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    SwipeHintState(
      showing: _showing,
      used: _used,
      offset: _offset,
      markUsed: _markUsed,
    ),
  );
}

/// Slides [child] by the hint's nudge, over the design's 420ms.
class SwipeNudge extends StatelessWidget {
  /// Creates a [SwipeNudge].
  const SwipeNudge({required this.offset, required this.child, super.key});

  static const Duration _travel = Duration(milliseconds: 420);

  /// Where the nudge has the element, from [SwipeHintState.offset].
  final double offset;

  /// The surface being nudged — the swipe and its affordance together.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: offset),
      duration: _travel,
      curve: SwipeMotion.settleCurve,
      builder: (context, value, child) =>
          Transform.translate(offset: Offset(value, 0), child: child),
      child: child,
    );
  }
}
