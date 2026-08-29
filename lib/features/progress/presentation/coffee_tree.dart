import 'dart:async';

import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree_animation.dart';
import 'package:flutter/material.dart';

/// The Coffee Tree: the frame for [stage], wearing the grove [treatment], and
/// swaying.
///
/// Decides nothing about *which* tree: both the stage and the treatment arrive
/// from the caller, and the treatment is already reduced to a matrix and a
/// scale, so this widget knows nothing about species or lights.
///
/// **The sway lives here on purpose**, on by default — ADR-0011's ruling. It
/// is ambient identity rather than an event, so a screen added later cannot
/// forget it; the failure mode of an opt-in flag is a dead frozen tree that
/// reads as deliberate and goes unnoticed. Growth is the opposite — a from/to
/// pair with a lifecycle — and belongs to a separate widget wrapping this one,
/// which is why nothing here knows how to grow.
class CoffeeTree extends StatefulWidget {
  /// Creates a [CoffeeTree].
  const CoffeeTree({
    required this.stage,
    this.treatment = GroveTreatment.identity,
    this.size = defaultSize,
    this.animate = true,
    super.key,
  });

  /// Highest tree stage ever reached, as the snapshot stores it. Values
  /// outside the shipped frames clamp to seed and full growth.
  final int stage;

  /// The planted species' silhouette and the light it stands in, composed.
  final GroveTreatment treatment;

  /// Square edge the frame renders at.
  final double size;

  /// Whether the tree sways. When false — or when the platform asks for
  /// reduced motion ([MediaQueryData.disableAnimations]) — it holds upright
  /// and the controller stays idle. The design freezes the Profile hero this
  /// way (`screens.jsx:2586`).
  final bool animate;

  /// Hero-sized default, matching the design's preview block.
  static const double defaultSize = 176;

  /// The sway's rotation, and the silhouette's scale, named.
  ///
  /// Two `Transform`s are nested here and they mean different things, so a
  /// test that reached for "the Transform inside the tree" would be picking
  /// one by position. These let it pick by intent instead.
  static const swayKey = Key('coffeeTree.sway');

  /// The variety's silhouette scale — present only for a planted grove.
  static const silhouetteKey = Key('coffeeTree.silhouette');

  @override
  State<CoffeeTree> createState() => _CoffeeTreeState();
}

class _CoffeeTreeState extends State<CoffeeTree>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: treeSwayPeriod,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion lives in MediaQuery, so it is first readable here — the
    // same place `Roasty` reconciles its own controller.
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant CoffeeTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) _syncAnimation();
  }

  /// Reconciles the controller with the effective animate flag — the widget's
  /// [CoffeeTree.animate] AND platform reduced motion.
  void _syncAnimation() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.animate && !reduceMotion) {
      if (!_controller.isAnimating) unawaited(_controller.repeat());
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The picture itself: the frame, wearing the treatment if it has one.
  ///
  /// Arabica in Daylight is the real art, so it is painted with neither
  /// wrapper rather than through a matrix that happens to be the identity.
  Widget _frame() {
    final frame = Image.asset(
      treeStageAsset(widget.stage),
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      semanticLabel: treeStageLabel(widget.stage),
    );
    if (widget.treatment.isIdentity) return frame;

    return Transform.scale(
      key: CoffeeTree.silhouetteKey,
      scaleX: widget.treatment.silhouette.scaleX,
      scaleY: widget.treatment.silhouette.scaleY,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(widget.treatment.colorMatrix),
        child: frame,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final picture = _frame();

    // The silhouette scale sits *inside* this rotation, matching the design's
    // note that the variety transform is held on a wrapper so it cannot fight
    // the sway, which owns the transform on the image itself.
    return AnimatedBuilder(
      animation: _controller,
      // Built once: the frame does not depend on the sway's progress, so
      // rotating it must not rebuild the image on every tick.
      child: picture,
      builder: (context, child) => Transform.rotate(
        key: CoffeeTree.swayKey,
        angle: _controller.isAnimating
            ? treeSwayRadiansAt(_controller.value)
            : treeSwayHeldRadians,
        alignment: treeSwayOrigin,
        child: child,
      ),
    );
  }
}

/// The tree's place while the stored stage is still being read.
///
/// Holds the hero's footprint so the page does not jump, and says only that a
/// tree is coming: naming a stage here would announce a number that is about
/// to change, and for a grown tree that announcement would be false.
class CoffeeTreePlaceholder extends StatelessWidget {
  /// Creates a [CoffeeTreePlaceholder].
  const CoffeeTreePlaceholder({this.size = CoffeeTree.defaultSize, super.key});

  /// Square edge the placeholder reserves, matching [CoffeeTree.size].
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your coffee tree is loading',
      child: SizedBox(width: size, height: size),
    );
  }
}
