import 'package:flutter/material.dart';

/// The design's `fade-up`: 260ms ease-out, from four pixels down.
///
/// One rule with more than one host — the design gives every card that arrives
/// over the page the same entrance, and the guide layer alone has two of them.
///
/// Reduced motion gets no animator at all rather than a zero-duration one —
/// the honest reading of "no animation", and the app's rule elsewhere.
class FadeUp extends StatelessWidget {
  /// Fades [child] up as it arrives.
  const FadeUp({required this.child, super.key});

  static const Duration _duration = Duration(milliseconds: 260);
  static const double _rise = 4;

  /// What arrives.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: _duration,
      curve: Curves.easeOut,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, _rise * (1 - progress)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
