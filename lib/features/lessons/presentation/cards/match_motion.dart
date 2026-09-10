import 'dart:async';

import 'package:brew_path/features/lessons/presentation/cards/match_line.dart';
import 'package:flutter/material.dart';

/// Plays the design's `matchSnap` once, whenever [generation] changes.
///
/// Keyed on a counter rather than a bool so two locks in a row each animate;
/// reduced motion gets no controller at all, which is the app's rule.
class MatchSnapBox extends StatefulWidget {
  /// Wraps [child] in the snap.
  const MatchSnapBox({
    required this.generation,
    required this.child,
    super.key,
  });

  /// Bumped by the board every time this tile locks a trait.
  final int generation;

  /// The tile that scales.
  final Widget child;

  @override
  State<MatchSnapBox> createState() => _MatchSnapBoxState();
}

class _MatchSnapBoxState extends State<MatchSnapBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: matchSnapDuration,
  );
  late final CurvedAnimation _snap = CurvedAnimation(
    parent: _controller,
    curve: matchSnapCurve,
  );

  @override
  void didUpdateWidget(MatchSnapBox old) {
    super.didUpdateWidget(old);
    if (widget.generation == old.generation) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    unawaited(_controller.forward(from: 0));
  }

  @override
  void dispose() {
    _snap.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _snap,
    builder: (context, child) => Transform.scale(
      scale: matchSnapScale(_snap.value),
      child: child,
    ),
    child: widget.child,
  );
}

/// Plays the design's `matchWrongShake` once, whenever [generation] changes.
class MatchShakeBox extends StatefulWidget {
  /// Wraps [child] in the shake.
  const MatchShakeBox({
    required this.generation,
    required this.child,
    super.key,
  });

  /// Bumped by the board on every wrong drop this tile was part of.
  final int generation;

  /// The tile that moves.
  final Widget child;

  @override
  State<MatchShakeBox> createState() => _MatchShakeBoxState();
}

class _MatchShakeBoxState extends State<MatchShakeBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: matchWrongShakeDuration,
  );
  late final CurvedAnimation _shake = CurvedAnimation(
    parent: _controller,
    curve: Curves.ease,
  );

  @override
  void didUpdateWidget(MatchShakeBox old) {
    super.didUpdateWidget(old);
    if (widget.generation == old.generation) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    unawaited(_controller.forward(from: 0));
  }

  @override
  void dispose() {
    _shake.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _shake,
    builder: (context, child) => Transform.translate(
      offset: Offset(matchShakeOffset(_shake.value), 0),
      child: child,
    ),
    child: widget.child,
  );
}
