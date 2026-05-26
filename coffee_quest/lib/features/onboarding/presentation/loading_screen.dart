import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/features/onboarding/presentation/onboarding_providers.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_state.dart';
import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:coffee_quest/shared/theme/app_typography.dart';

/// Roasty wake-up sequence. Loops a 6-step state machine
/// (sleep → drop → awake → sprout grows → idle bob → hold) while bootstrap
/// settles. Tap anywhere after the first cycle to skip; on bootstrap-ready
/// auto-advances to /welcome or /learn depending on the onboarding gate.
class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  static const _stepDurations = <Duration>[
    Duration(milliseconds: 1200), // 0 sleeping
    Duration(milliseconds: 800), // 1 drop falling
    Duration(milliseconds: 600), // 2 awake (eyes open)
    Duration(milliseconds: 700), // 3 sprout grows
    Duration(milliseconds: 1800), // 4 idle bob with caption
    Duration(milliseconds: 1400), // 5 hold, then loop
  ];

  int _step = 0;
  int _cycle = 0;
  bool _advancing = false;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _scheduleNextStep();
  }

  void _scheduleNextStep() {
    _stepTimer?.cancel();
    _stepTimer = Timer(_stepDurations[_step], () {
      if (!mounted) return;
      setState(() {
        if (_step >= _stepDurations.length - 1) {
          _step = 0;
          _cycle++;
        } else {
          _step++;
        }
      });
      // Once the first full wake-up cycle has played and the bootstrap gate
      // has resolved, auto-advance. This guarantees the user sees the full
      // Roasty wake-up animation even when the DB read is near-instant.
      if (_cycle >= 1 && !_advancing) {
        final gate = ref.read(onboardingCompletedProvider);
        if (gate.hasValue) {
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

  Future<void> _advance() async {
    if (_advancing) return;
    _advancing = true;
    _stepTimer?.cancel();
    final completed = await ref.read(onboardingCompletedProvider.future);
    if (!mounted) return;
    context.go(completed ? '/learn' : '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final captionVisible = _step >= 4;

    return Scaffold(
      backgroundColor: AppColors.darkRoastBg,
      body: GestureDetector(
        // Tap-anywhere is a manual skip available throughout the animation;
        // auto-advance still fires at the end of the first cycle once the
        // onboarding gate has resolved.
        behavior: HitTestBehavior.opaque,
        onTap: _advance,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DropAndRoasty(step: _step),
                    const SizedBox(height: 56),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: captionVisible ? 1 : 0,
                      child: Column(
                        children: [
                          Text(
                            'Brewing your lesson',
                            style: AppTypography.captionItalic(),
                          ),
                          const SizedBox(height: 14),
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
                bottom: 24,
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
    );
  }
}

/// Hosts Roasty plus the falling water drop overlay (visible only during
/// step 1). The drop animates top → 41% via a 700ms tween.
class _DropAndRoasty extends StatefulWidget {
  const _DropAndRoasty({required this.step});

  final int step;

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
    if (oldWidget.step != widget.step) _maybeRunDrop();
  }

  void _maybeRunDrop() {
    if (widget.step == 1) {
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
    final roasty = _LoadingRoasty(step: widget.step);
    return SizedBox(
      width: 200,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          roasty,
          if (widget.step == 1)
            AnimatedBuilder(
              animation: _dropController,
              builder: (context, _) {
                final t = _dropController.value;
                // Mirrors loading-drop-fall keyframes (top 14% → 41%, fade
                // in 0–30%, squash from 75% on impact).
                final top = 0.14 + (0.41 - 0.14) * t.clamp(0.0, 0.75) / 0.75;
                final opacity = t < 0.3
                    ? t / 0.3
                    : (t > 0.85 ? (1 - t) / 0.15 : 1.0);
                final scaleX = t > 0.75 ? 1.0 + (t - 0.75) / 0.25 * 0.6 : 1.0;
                final scaleY = t > 0.75 ? 1.0 - (t - 0.75) / 0.25 * 0.6 : 1.0;
                return Positioned(
                  top: top * 280,
                  child: Opacity(
                    opacity: opacity.clamp(0, 1),
                    child: Transform(
                      transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
                      child: CustomPaint(
                        size: const Size(14, 20),
                        painter: _DropPainter(),
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

class _LoadingRoasty extends StatelessWidget {
  const _LoadingRoasty({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    // Steps 0/1: sleep state (sprout already shrunk).
    // Step 2/3: awake — sprout still shrunk during 2, grows on 3.
    // Steps 4/5: idle — sprout fully grown, breath loop.
    if (step <= 1) {
      return const Roasty(state: RoastyState.sleep, size: 170);
    }
    if (step <= 3) {
      return const Roasty(state: RoastyState.awake, size: 170);
    }
    return const Roasty(state: RoastyState.idle, size: 170);
  }
}

class _DropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = const Color(0xFF6FA3C8);
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
      ..color = const Color(0xFFA9CFE3).withValues(alpha: 0.7);
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
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotOpacity(double t, double delay) {
    final phase = (t - delay) % 1.0;
    final p = phase < 0 ? phase + 1 : phase;
    // 0..0.5..1 → 0.22 → 1 → 0.22
    final wave = (1 - (p - 0.5).abs() * 2).clamp(0.0, 1.0);
    return 0.22 + (1 - 0.22) * wave;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(_controller.value, 0.0),
            const SizedBox(width: 6),
            _dot(_controller.value, 0.2 / 1.4),
            const SizedBox(width: 6),
            _dot(_controller.value, 0.4 / 1.4),
          ],
        );
      },
    );
  }

  Widget _dot(double t, double delay) {
    final opacity = _dotOpacity(t, delay);
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkRoastAccent.withValues(alpha: opacity),
      ),
    );
  }
}
