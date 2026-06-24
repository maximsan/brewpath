import 'dart:async';

import 'package:coffee_quest/features/companion/application/companion_providers.dart';
import 'package:coffee_quest/features/companion/domain/companion_mood.dart';
import 'package:coffee_quest/features/companion/domain/companion_reaction.dart';
import 'package:coffee_quest/features/companion/domain/companion_state_mapping.dart';
import 'package:coffee_quest/features/companion/presentation/companion_handle.dart';
import 'package:coffee_quest/features/companion/presentation/roasty.dart';
import 'package:coffee_quest/features/companion/presentation/roasty_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The high-level, engagement-aware companion. Renders [Roasty] driven by the
/// app-global mood ([companionMoodProvider]) plus any transient reaction fired
/// through [handle]. A one-shot reaction plays, then the companion reverts to
/// its mood; the mood is the resting baseline.
class Companion extends ConsumerStatefulWidget {
  /// Creates a [Companion].
  const Companion({
    this.handle,
    this.size = _defaultSize,
    this.animate = true,
    super.key,
  });

  static const double _defaultSize = 160;

  /// Optional per-instance reaction trigger. Without one the companion simply
  /// reflects its mood.
  final CompanionHandle? handle;

  /// Rendered size, forwarded to [Roasty].
  final double size;

  /// Whether to animate; forwarded to [Roasty] (which also honors reduced
  /// motion).
  final bool animate;

  @override
  ConsumerState<Companion> createState() => _CompanionState();
}

class _CompanionState extends ConsumerState<Companion> {
  Timer? _revertTimer;

  @override
  void initState() {
    super.initState();
    widget.handle?.addListener(_onHandleChanged);
    // A reaction may already be pending if the host fired before mount.
    _scheduleRevert(widget.handle?.reaction);
  }

  @override
  void didUpdateWidget(covariant Companion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handle != widget.handle) {
      oldWidget.handle?.removeListener(_onHandleChanged);
      widget.handle?.addListener(_onHandleChanged);
    }
  }

  @override
  void dispose() {
    _revertTimer?.cancel();
    widget.handle?.removeListener(_onHandleChanged);
    super.dispose();
  }

  void _onHandleChanged() {
    if (!mounted) return;
    setState(() {});
    _scheduleRevert(widget.handle?.reaction);
  }

  /// On a new reaction, schedules an auto-revert to mood after the one-shot's
  /// duration. Looping reaction poses are left until cleared or replaced.
  void _scheduleRevert(CompanionReaction? reaction) {
    _revertTimer?.cancel();
    if (reaction == null) return;
    final reactionState = roastyStateFor(
      mood: CompanionMood.idle,
      reaction: reaction,
    );
    if (roastyLoops(reactionState)) return;
    _revertTimer = Timer(roastyDuration(reactionState), () {
      if (mounted) widget.handle?.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mood = ref.watch(companionMoodProvider);
    final state = roastyStateFor(
      mood: mood,
      reaction: widget.handle?.reaction,
    );
    return Roasty(
      state: state,
      size: widget.size,
      animate: widget.animate,
      replayKey: widget.handle?.replay,
    );
  }
}
