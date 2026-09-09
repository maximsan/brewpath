import 'dart:async';

import 'package:brew_path/features/lessons/presentation/cards/tastefix_reaction.dart';
import 'package:flutter/material.dart';

/// Plays the panel's own reaction once: a pulse when the fix worked, a shake
/// when it did not, and nothing at all under reduced motion.
class TastefixReactionBox extends StatefulWidget {
  /// Wraps [child] in the reaction [reaction] calls for.
  const TastefixReactionBox({
    required this.reaction,
    required this.child,
    super.key,
  });

  /// How the cup answered the fix.
  final TastefixReaction reaction;

  /// The panel that moves.
  final Widget child;

  @override
  State<TastefixReactionBox> createState() => _TastefixReactionBoxState();
}

class _TastefixReactionBoxState extends State<TastefixReactionBox>
    with SingleTickerProviderStateMixin {
  /// Rests at 0, where both readings are the identity, so a card that is never
  /// answered draws exactly what it would have drawn without a controller.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: tastefixShakeDuration,
  );

  /// Built once beside the controller. A curve minted per build would leave a
  /// listener on the controller for every frame the panel has ever drawn.
  late final CurvedAnimation _shake = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );
  late final CurvedAnimation _pulse = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void didUpdateWidget(TastefixReactionBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reaction = widget.reaction;
    if (reaction == oldWidget.reaction ||
        reaction == TastefixReaction.unfixed) {
      return;
    }
    // Reduced motion lands the reaction in one frame: the chips and the panel
    // are already in their answered state, and only the movement is dropped.
    if (MediaQuery.disableAnimationsOf(context)) return;
    _controller.duration = reaction.isBalanced
        ? tastefixPulseDuration
        : tastefixShakeDuration;
    unawaited(_controller.forward(from: 0));
  }

  @override
  void dispose() {
    _shake.dispose();
    _pulse.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balanced = widget.reaction.isBalanced;
    final eased = balanced ? _pulse : _shake;

    return AnimatedBuilder(
      animation: eased,
      builder: (context, child) => balanced
          ? Transform.scale(
              scale: tastefixPulseScale(eased.value),
              child: child,
            )
          : Transform.translate(
              offset: Offset(tastefixShakeOffset(eased.value), 0),
              child: child,
            ),
      child: widget.child,
    );
  }
}
