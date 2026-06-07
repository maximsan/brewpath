import 'package:coffee_quest/features/onboarding/presentation/loading/loading_animation.dart';
import 'package:coffee_quest/features/onboarding/presentation/onboarding_providers.dart';
import 'package:coffee_quest/features/onboarding/presentation/loading/wake_sequence_controller.dart';
import 'package:coffee_quest/features/onboarding/presentation/loading/widgets/pulsing_dots.dart';
import 'package:coffee_quest/features/onboarding/presentation/loading/widgets/roasty_stage.dart';
import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:coffee_quest/shared/theme/app_spacing.dart';
import 'package:coffee_quest/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Roasty wake-up sequence. A [WakeSequenceController] loops the [WakePhase]
/// state machine (sleep → drop → awake → sprout grows → brewing → hold) while
/// bootstrap settles; this screen is a thin view over it. Tap anywhere to skip;
/// on bootstrap-ready it auto-advances to /welcome (the router redirect bounces
/// returning users on to /learn). When the platform requests reduced motion,
/// the looping animation is replaced by a static idle frame.
class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  /// Debug-only: loops the animation forever and disables auto-advance / skip.
  /// Off by default, so release builds are safe by construction. See the README
  /// "Run-time flags" section to enable it.
  static const bool _loopForever = bool.fromEnvironment('LOOP_LOADING');

  static const double _mascotSize = 170;
  static const double _captionGap = 56;
  static const double _wordmarkInset = 24;
  static const Duration _captionFade = Duration(milliseconds: 300);
  static const double _wordmarkLetterSpacing = 2.64; // 0.24em at 11px

  late final WakeSequenceController _controller;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _controller = WakeSequenceController(
      reduceMotion: reduceMotion,
      loopForever: _loopForever,
      isGateResolved: () => ref.read(onboardingCompletedProvider).hasValue,
      onAdvance: _advance,
    )..addListener(_onSequenceStep);
    _controller.start();
    if (reduceMotion) {
      // The looping path advances from inside its own timer; the static path
      // has no timer, so kick a gate check once the first frame is laid out
      // (later resolution is caught by the ref.listen in build()).
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _controller.notifyGateResolved(),
      );
    }
  }

  void _onSequenceStep() {
    if (mounted) setState(() {});
  }

  /// Leaves the loading screen for `/welcome`. The router redirect
  /// ([appRouter]) owns the gate→destination policy and bounces returning
  /// users on to `/learn`, so this screen does not duplicate that decision.
  void _advance() {
    if (!mounted) return;
    context.goNamed('welcome');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.reduceMotion && !_loopForever) {
      ref.listen(onboardingCompletedProvider, (_, next) {
        if (next.hasValue) _controller.notifyGateResolved();
      });
    }

    final phase = _controller.phase;

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
          onTap: _loopForever ? null : _controller.skip,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoastyStage(phase: phase, mascotSize: _mascotSize),
                      const SizedBox(height: _captionGap),
                      AnimatedOpacity(
                        duration: _captionFade,
                        opacity: phase.showsCaption ? 1 : 0,
                        child: Column(
                          children: [
                            Text(
                              'Brewing your lesson',
                              style: AppTypography.captionItalic(),
                            ),
                            const SizedBox(height: AppSpacing.base),
                            const PulsingDots(),
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
                        letterSpacing: _wordmarkLetterSpacing,
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
