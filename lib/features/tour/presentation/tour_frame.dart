import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';

/// The dim, with a hole in it, and the ring around the hole.
///
/// **One painter, not two layers.** The design writes the pair as a single box
/// — `boxShadow: '0 0 0 1400px var(--dim-modal)'` with a `border` on the same
/// element — so the cut-out and its ring can never disagree about where the
/// target is or how round its corners are. Painting them together is what keeps
/// that true here.
///
/// The dim is [OverlayColors.dimModal]'s colour **without its blur**, which is
/// the one place in the app that splits the pair: a backdrop blur behind this
/// overlay would blur the cut-out too — the widget the stop exists to point at,
/// and the one thing on screen that has to stay sharp. The design draws no blur
/// here either, for the same reason.
class TourFramePainter extends CustomPainter {
  /// Paints the dim around [frame], ringed in [accent].
  const TourFramePainter({required this.frame, required this.accent});

  /// The design's `borderRadius: 18` on the frame. Off `AppRadii.chrome` (14)
  /// and deliberately so: the token's own note gives a component that needs its
  /// own radius the slack of 12–20, and this one is a frame *around* a card
  /// rather than the card, so it has to read as the looser shape.
  static const double radius = 18;

  /// The design's `color-mix(in oklab, accent 55%, transparent)` on the ring.
  static const double ringOpacity = 0.55;

  /// The ring's own width — the design's `1px solid`.
  static const double ringWidth = 1;

  /// The hole, in the layer's coordinates, or null before the first
  /// measurement — in which case the dim covers everything.
  final Rect? frame;

  /// The mood's accent, which the ring is drawn from.
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Offset.zero & size;
    final dim = Paint()..color = OverlayColors.dimModal.color;
    final hole = frame;
    if (hole == null) {
      canvas.drawRect(screen, dim);
      return;
    }

    final cutout = RRect.fromRectAndRadius(hole, const Radius.circular(radius));
    canvas
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(screen),
          Path()..addRRect(cutout),
        ),
        dim,
      )
      ..drawRRect(
        cutout,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth
          ..color = accent.withValues(alpha: ringOpacity),
      );
  }

  @override
  bool shouldRepaint(TourFramePainter oldDelegate) =>
      oldDelegate.frame != frame || oldDelegate.accent != accent;
}

/// The frame, travelling from wherever it was to [frame].
///
/// The move is the layer's signature motion: the design animates
/// `left/top/width/height` together over 320ms, so the dim and the ring arrive
/// as one object rather than the hole jumping and the ring catching up.
class TourFrame extends StatelessWidget {
  /// Draws the dim around [frame].
  const TourFrame({required this.frame, super.key});

  /// The design's `320ms cubic-bezier(.3,.8,.3,1)` — quick to leave, slow to
  /// arrive, which is what makes the frame read as *placed* rather than slid.
  static const Duration moveDuration = Duration(milliseconds: 320);

  /// That cubic, as Flutter spells it.
  static const Curve moveCurve = Cubic(0.3, 0.8, 0.3, 1);

  /// Where the hole is, or null before the first measurement.
  final Rect? frame;

  @override
  Widget build(BuildContext context) {
    final accent = context.mood.accent;
    // Reduced motion gets a cut rather than a slide: the frame still has to
    // *arrive*, so the move cannot be dropped, only shortened to nothing.
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : moveDuration;

    // Nothing measured yet: the dim is drawn whole, with no hole to travel
    // from. Animating from an absent rect would grow the frame out of the
    // top-left corner, which is not a move the design makes.
    final measured = frame;
    if (measured == null) {
      return CustomPaint(
        size: Size.infinite,
        painter: TourFramePainter(frame: null, accent: accent),
      );
    }

    return TweenAnimationBuilder<Rect?>(
      tween: RectTween(end: measured),
      duration: duration,
      curve: moveCurve,
      builder: (context, moving, _) => CustomPaint(
        // The dim is the whole layer; only the hole moves.
        size: Size.infinite,
        painter: TourFramePainter(frame: moving, accent: accent),
      ),
    );
  }
}
