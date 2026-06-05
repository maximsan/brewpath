import 'package:coffee_quest/features/onboarding/presentation/loading_animation.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty.dart';
import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Hosts Roasty plus the falling water-drop overlay (visible only during
/// [WakePhase.dropFalling]). The drop animates top → 41% via a 700ms tween.
class RoastyStage extends StatefulWidget {
  const RoastyStage({required this.phase, required this.mascotSize, super.key});

  final WakePhase phase;
  final double mascotSize;

  @override
  State<RoastyStage> createState() => _RoastyStageState();
}

class _RoastyStageState extends State<RoastyStage>
    with SingleTickerProviderStateMixin {
  static const Size _stageSize = Size(200, 280);
  static const Duration _dropDuration = Duration(milliseconds: 700);
  static const Size _dropSize = Size(14, 20);

  late final AnimationController _dropController;

  @override
  void initState() {
    super.initState();
    _dropController = AnimationController(vsync: this, duration: _dropDuration);
    _maybeRunDrop();
  }

  @override
  void didUpdateWidget(covariant RoastyStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) _maybeRunDrop();
  }

  void _maybeRunDrop() {
    if (widget.phase.showsDrop) {
      _dropController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _stageSize.width,
      height: _stageSize.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Roasty(state: widget.phase.roastyState, size: widget.mascotSize),
          if (widget.phase.showsDrop)
            AnimatedBuilder(
              animation: _dropController,
              builder: (context, _) {
                final frame = wakeDropFrame(_dropController.value);
                return Positioned(
                  top: frame.top * _stageSize.height,
                  child: Opacity(
                    opacity: frame.opacity,
                    child: Transform(
                      transform: Matrix4.diagonal3Values(
                        frame.scaleX,
                        frame.scaleY,
                        1,
                      ),
                      child: ExcludeSemantics(
                        child: CustomPaint(
                          size: _dropSize,
                          painter: _DropPainter(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = AppColors.darkRoastWaterDrop;
    final path = Path()
      ..moveTo(7, 0)
      ..cubicTo(9, 6, 13, 10, 13, 14)
      ..arcToPoint(
        const Offset(1, 14),
        radius: const Radius.circular(6),
        clockwise: false,
      )
      ..cubicTo(1, 10, 5, 6, 7, 0)
      ..close();
    canvas.drawPath(path, fill);
    final highlight = Paint()
      ..color = AppColors.darkRoastWaterDropHi.withValues(alpha: 0.7);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(5, 11), width: 3, height: 4.8),
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
