import 'dart:async';

import 'package:coffee_quest/features/onboarding/presentation/loading_animation.dart';
import 'package:coffee_quest/features/onboarding/presentation/onboarding_providers.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty.dart';
import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:coffee_quest/shared/theme/app_spacing.dart';
import 'package:coffee_quest/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Roasty wake-up sequence. Loops the [WakePhase] state machine
/// (sleep → drop → awake → sprout grows → idle bob → hold) while bootstrap
/// settles. Tap anywhere after the first cycle to skip; on bootstrap-ready
/// auto-advances to /welcome (the router redirect bounces returning users on
/// to /learn). When the platform requests reduced motion, the looping
/// animation is replaced by a static idle frame.
class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  /// Debug-only: loops the animation forever and disables auto-advance / skip. Compile-time and off by default
  /// Enable with `flutter run --dart-define=LOOP_LOADING=true`.
  static const bool _loopForever = bool.fromEnvironment('LOOP_LOADING');

  static const double _mascotSize = 170;
  static const Size _stageSize = Size(200, 280);
  static const double _captionGap = 56;
  static const double _wordmarkInset = 24;

  WakePhase _phase = WakePhase.sleeping;
  int _cycle = 0;
  bool _advancing = false;
  bool _reduceMotion = false;
  bool _started = false;
  Timer? _stepTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_reduceMotion) {
      // Skip the looping wake-up; show a static idle frame and leave as soon
      // as the bootstrap gate has resolved. Later resolution is caught by the
      // ref.listen in build().
      if (!_loopForever && ref.read(onboardingCompletedProvider).hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _advance());
      }
    } else {
      _scheduleNextStep();
    }
  }

  void _scheduleNextStep() {
    _stepTimer?.cancel();
    _stepTimer = Timer(_phase.duration, () {
      if (!mounted) return;
      setState(() {
        _phase = _phase.next;
        if (_phase == WakePhase.sleeping) _cycle++;
      });
      // Once the first full wake-up cycle has played and the bootstrap gate
      // has resolved, auto-advance. This guarantees the user sees the full
      // Roasty wake-up animation even when the DB read is near-instant.
      if (!_loopForever && _cycle >= 1 && !_advancing) {
        if (ref.read(onboardingCompletedProvider).hasValue) {
          _advance();
          return;
        }
      }
      _scheduleNextStep();
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  /// Leaves the loading screen for `/welcome`. The router redirect
  /// ([appRouter]) owns the gate→destination policy and bounces returning
  /// users on to `/learn`, so this screen does not duplicate that decision.
  Future<void> _advance() async {
    if (_advancing) return;
    _advancing = true;
    _stepTimer?.cancel();
    if (!mounted) return;
    context.goNamed('welcome');
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion && !_loopForever) {
      ref.listen(onboardingCompletedProvider, (_, next) {
        if (next.hasValue) _advance();
      });
    }

    final phase = _reduceMotion ? WakePhase.idleBob : _phase;

    return Scaffold(
      backgroundColor: AppColors.darkRoastBg,
      body: Semantics(
        label: 'Loading your lesson',
        liveRegion: true,
        child: GestureDetector(
          // Tap-anywhere is a manual skip available throughout the animation;
          // auto-advance still fires at the end of the first cycle once the
          // onboarding gate has resolved.
          behavior: HitTestBehavior.opaque,
          onTap: _loopForever ? null : _advance,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DropAndRoasty(phase: phase, mascotSize: _mascotSize),
                      const SizedBox(height: _captionGap),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: phase.showsCaption ? 1 : 0,
                        child: Column(
                          children: [
                            Text(
                              'Brewing your lesson',
                              style: AppTypography.captionItalic(),
                            ),
                            const SizedBox(height: AppSpacing.base),
                            const _PulsingDots(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: _wordmarkInset,
                  child: Center(
                    child: Text(
                      'COFFEE QUEST',
                      style: AppTypography.smallcaps().copyWith(
                        letterSpacing: 2.64, // 0.24em at 11px
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hosts Roasty plus the falling water-drop overlay (visible only during
/// [WakePhase.dropFalling]). The drop animates top → 41% via a 700ms tween.
class _DropAndRoasty extends StatefulWidget {
  const _DropAndRoasty({required this.phase, required this.mascotSize});

  final WakePhase phase;
  final double mascotSize;

  @override
  State<_DropAndRoasty> createState() => _DropAndRoastyState();
}

class _DropAndRoastyState extends State<_DropAndRoasty>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dropController;

  @override
  void initState() {
    super.initState();
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _maybeRunDrop();
  }

  @override
  void didUpdateWidget(covariant _DropAndRoasty oldWidget) {
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
      width: _LoadingScreenState._stageSize.width,
      height: _LoadingScreenState._stageSize.height,
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
                  top: frame.top * _LoadingScreenState._stageSize.height,
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
                          size: const Size(14, 20),
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

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  static const Duration _period = Duration(milliseconds: 1400);
  static const double _dotSize = 5;
  static const double _dotGap = AppSpacing.xxs + 2;

  /// Per-dot pulse offsets as fractions of [_period] — staggered by 0.2s
  /// (0s, 0.2s, 0.4s across the 1.4s period).
  static const List<double> _dotDelays = [0, 0.2 / 1.4, 0.4 / 1.4];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _period)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(pulsingDotOpacity(progress, _dotDelays[0])),
            const SizedBox(width: _dotGap),
            _dot(pulsingDotOpacity(progress, _dotDelays[1])),
            const SizedBox(width: _dotGap),
            _dot(pulsingDotOpacity(progress, _dotDelays[2])),
          ],
        );
      },
    );
  }

  Widget _dot(double opacity) {
    return Container(
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkRoastAccent.withValues(alpha: opacity),
      ),
    );
  }
}
