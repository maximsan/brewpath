import 'dart:math' as math;

import 'package:brew_path/features/progress/presentation/tree_growth_animation.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The disc the tree stands on — the design's `.at-ground`.
///
/// **Always drawn, growth or not.** It is the ground rather than part of the
/// beat: a tree floating on the page reads as a cut-out, and the design paints
/// this under every `AnimatedTree` whether or not it moves.
class TreeGroundPainter extends CustomPainter {
  /// Creates a [TreeGroundPainter].
  const TreeGroundPainter(this.mood);

  /// Where the ground takes its colours from.
  final MoodColors mood;

  /// Where the ellipse sits: the design's `at 50% 62%`.
  static const double _centreY = 0.62;

  /// How wide the ground reads against the tree's box.
  static const double _spread = 0.66;

  /// The accent that warms the very centre — the design's `accent 4%`.
  static const double _warmth = 0.04;

  /// How present the surface is at the ground's midpoint — the design's
  /// `surface 70%` stop.
  static const double _midOpacity = 0.7;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * _centreY),
      width: size.width,
      height: size.height * _spread,
    );
    final warm = Color.alphaBlend(
      mood.accent.withValues(alpha: _warmth),
      mood.surface,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            warm,
            mood.surface.withValues(alpha: _midOpacity),
            mood.bg,
          ],
          stops: const [0, 0.4, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(TreeGroundPainter oldDelegate) => oldDelegate.mood != mood;
}

/// The ring that blooms out of the tree as a new stage lands — the design's
/// `treeGlow` keyframes.
///
/// Painted rather than built, following the app's one existing celebration
/// glow (`roasty_particles.dart`), with the curves in the pure sibling so the
/// timings are testable without a frame.
class TreeGlowPainter extends CustomPainter {
  /// Creates a [TreeGlowPainter].
  const TreeGlowPainter({required this.colour, required this.progress});

  /// The ring's colour, at full strength; opacity comes from [progress].
  final Color colour;

  /// How far through the glow's own life it is, in `0..1`.
  final double progress;

  /// How much accent the ring carries at its brightest — the design's `45%`.
  static const double _strength = 0.45;

  /// The design's `inset: 8%`.
  static const double _inset = 0.08;

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = treeGlowOpacityAt(progress);
    if (opacity <= 0) return;

    final inset = size.shortestSide * _inset;
    final base = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final scale = treeGlowScaleAt(progress);
    final rect = Rect.fromCenter(
      center: base.center,
      width: base.width * scale,
      height: base.height * scale,
    );

    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colour.withValues(alpha: _strength * opacity),
            colour.withValues(alpha: 0),
          ],
          stops: const [0, 0.7],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(TreeGlowPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.colour != colour;
}

/// The leaves a growth throws — the design's `leafDrift`, seven of them,
/// staggered.
class TreeLeafPainter extends CustomPainter {
  /// Creates a [TreeLeafPainter].
  const TreeLeafPainter({required this.elapsed, required this.mood});

  /// Time since the new frame landed. Leaves start [treeLeafLead] after it.
  final Duration elapsed;

  /// Where the leaves take their colours from.
  final MoodColors mood;

  /// Where the spray starts, down the tree's box — the design's `top: 30%`.
  static const double _originY = 0.3;

  /// A sage leaf's size, in logical pixels.
  static const Size _leaf = Size(12, 5);

  /// An accent dot's diameter.
  static const double _dot = 6;

  /// How quickly a leaf fades in — the design's `15%`.
  static const double _fadeIn = 0.15;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * _originY);
    for (var index = 0; index < treeLeafCount; index++) {
      _paintLeaf(canvas, origin, index);
    }
  }

  void _paintLeaf(Canvas canvas, Offset origin, int index) {
    final progress = phaseProgress(
      elapsed: elapsed,
      starts: treeLeafLead + treeLeafStagger * index,
      lasts: treeLeafDuration,
    );
    if (progress <= 0 || progress >= 1) return;

    final drift = treeLeafDrift(index);
    final opacity = progress <= _fadeIn
        ? progress / _fadeIn
        : 1 - (progress - _fadeIn) / (1 - _fadeIn);
    final isDot = treeLeafIsDot(index);

    canvas
      ..save()
      ..translate(
        origin.dx + drift.dx * progress,
        origin.dy + drift.dy * progress,
      )
      ..rotate(drift.turns * progress * 2 * math.pi);

    final paint = Paint()
      ..color = (isDot ? mood.accent : mood.sage).withValues(
        alpha: opacity.clamp(0.0, 1.0),
      );
    if (isDot) {
      canvas.drawCircle(Offset.zero, _dot / 2, paint);
    } else {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: _leaf.width,
          height: _leaf.height,
        ),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(TreeLeafPainter oldDelegate) =>
      oldDelegate.elapsed != elapsed || oldDelegate.mood != mood;
}
