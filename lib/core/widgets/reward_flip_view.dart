import 'dart:async';

import 'package:brew_path/core/widgets/reward_flip.dart';
import 'package:flutter/material.dart';

/// A reward screen turning over between its two faces.
///
/// **Exactly one face is ever built.** Both occupy the same box, and a face
/// left in the tree past the swap is seen mirror-imaged through the rest of
/// the turn — the artefact the design's `backface-visibility: hidden`
/// prevents and Flutter has no equivalent of. It is also what keeps the two
/// faces' controls out of each other's semantics.
///
/// Shared by both endings, which turn identically; what differs is only what
/// each face draws and what asks for the turn.
class RewardFlipView extends StatelessWidget {
  /// Creates a [RewardFlipView].
  const RewardFlipView({
    required this.turn,
    required this.front,
    required this.back,
    super.key,
  });

  /// The turn's progress, already eased. `0` face-on, `1` fully over.
  ///
  /// An [Animation], not the controller: a `CurvedAnimation` built here would
  /// be built on **every frame of the turn** and never disposed, each one
  /// leaving a status listener on the controller it wrapped.
  final Animation<double> turn;

  /// The report side.
  final WidgetBuilder front;

  /// The card side.
  final WidgetBuilder back;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: turn,
      builder: (context, _) => Transform(
        alignment: rewardFlipOrigin,
        transform: flipTransform(
          progress: turn.value,
          perspective: rewardFlipPerspective,
        ),
        child: flipShowsBack(turn.value)
            // Turned again so the back reads upright rather than mirrored: it
            // is drawn on the far side of a card already half way round.
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateY(flipAngle(flipTurnedOver)),
                child: back(context),
              )
            : front(context),
      ),
    );
  }
}

/// Drives a reward screen's turn, honouring reduced motion.
///
/// Mixed in rather than copied: both endings need the same controller, the
/// same disposal, and the same rule about what a learner who has asked for
/// less motion gets — the *result* of the turn, not a faster one, because a
/// rotation in depth has no gentle version.
mixin RewardFlipController<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  /// The turn itself, driven `0` → `1`.
  ///
  /// Built in [initState] rather than lazily: a `late final` the learner never
  /// turns is first created by `dispose()` reaching for it, and `createTicker`
  /// then looks up an ancestor of a widget that is already deactivated.
  late final AnimationController flip;

  /// The same turn, eased — what a face is drawn from.
  ///
  /// Built once beside the controller, because a curve built in `build` is
  /// built on every frame of the turn and disposed on none of them. The
  /// controller keeps the plain 0→1 the geometry is written in.
  late final CurvedAnimation flipProgress;

  @override
  void initState() {
    super.initState();
    flip = AnimationController(vsync: this, duration: rewardFlipDuration);
    flipProgress = CurvedAnimation(parent: flip, curve: rewardFlipCurve);
  }

  /// Whether the card face is the one showing.
  bool get isShowingCard => flipShowsBack(flip.value);

  /// Turns to the named face.
  void turnTo({required bool showCard}) {
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      flip.value = flipRestValue(showingBack: showCard);
      return;
    }
    // Fire and forget: nothing waits on the turn finishing, and the faces
    // swap off the controller's value rather than off its future.
    unawaited(showCard ? flip.forward() : flip.reverse());
  }

  @override
  void dispose() {
    flipProgress.dispose();
    flip.dispose();
    super.dispose();
  }
}
