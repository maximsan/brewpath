import 'dart:async';

import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A transient "+N XP" chip that rises and fades, then removes itself via
/// [onComplete]. Mascot-free by design — the companion is reserved for the
/// bigger milestone moments. Honors reduced motion (no rise; a brief fade).
class XpGainToast extends StatefulWidget {
  /// Creates an [XpGainToast].
  const XpGainToast({required this.amount, this.onComplete, super.key});

  /// XP amount to show (e.g. 10 -> "+10 XP").
  final int amount;

  /// Called once the toast has finished its rise-and-fade.
  final VoidCallback? onComplete;

  @override
  State<XpGainToast> createState() => _XpGainToastState();
}

class _XpGainToastState extends State<XpGainToast>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 1000);
  static const double _riseDistance = 40;
  static const double _fadeInEnd = 0.2;
  static const double _fadeOutStart = 0.75;
  static const double _radius = 20;
  static const double _iconSize = 16;
  static const double _gap = 4;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onComplete?.call();
      });
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final label = '+${widget.amount} XP';

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final fadeIn = (progress / _fadeInEnd).clamp(0.0, 1.0);
          const fadeOutSpan = 1 - _fadeOutStart;
          final fadeOut = ((progress - _fadeOutStart) / fadeOutSpan).clamp(
            0.0,
            1.0,
          );
          final opacity = fadeIn * (1 - fadeOut);
          final dy = reduceMotion
              ? 0.0
              : -_riseDistance * Curves.easeOut.transform(progress);
          return Opacity(
            opacity: opacity,
            child: Transform.translate(offset: Offset(0, dy), child: child),
          );
        },
        child: Container(
          padding: _padding,
          decoration: BoxDecoration(
            color: mood.accent,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt,
                size: _iconSize,
                color: mood.accentInk,
              ),
              const SizedBox(width: _gap),
              Text(
                label,
                semanticsLabel: label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: mood.accentInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
