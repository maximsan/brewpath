import 'dart:async';

import 'package:brew_path/features/onboarding/presentation/loading/loading_animation.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Three accent dots that pulse in a staggered loop beneath the loading
/// caption. Opacity is derived by the pure [pulsingDotOpacity] helper.
class PulsingDots extends StatefulWidget {
  /// Creates a [PulsingDots].
  const PulsingDots({super.key});

  @override
  State<PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<PulsingDots>
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
    _controller = AnimationController(vsync: this, duration: _period);
    unawaited(_controller.repeat());
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
        final accent = context.mood.accent;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(accent, pulsingDotOpacity(progress, _dotDelays[0])),
            const SizedBox(width: _dotGap),
            _dot(accent, pulsingDotOpacity(progress, _dotDelays[1])),
            const SizedBox(width: _dotGap),
            _dot(accent, pulsingDotOpacity(progress, _dotDelays[2])),
          ],
        );
      },
    );
  }

  Widget _dot(Color accent, double opacity) {
    return Container(
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: opacity),
      ),
    );
  }
}
