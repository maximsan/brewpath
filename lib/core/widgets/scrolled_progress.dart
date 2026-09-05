import 'package:flutter/material.dart';

/// The 0→1 a bar's chrome fades in on as the page under it scrolls.
///
/// Every top bar in the design fades the same way — *"transition: background
/// 260ms ease, backdrop-filter 260ms ease, border-color 260ms ease"* — and
/// each one has to answer reduced motion. This is the one place that answer is
/// written: **a zero duration, not a dropped animator**, which is safe here
/// because a `TweenAnimationBuilder` given `Duration.zero` simply arrives on
/// the next frame.
///
/// A progress rather than a flag, because what fades is a whole filter: a bar
/// that switched its blur on at the end of a tint fade would pop, and a
/// builder handed the fraction can scale both halves of the token together.
class ScrolledProgress extends StatelessWidget {
  /// Creates a [ScrolledProgress].
  const ScrolledProgress({
    required this.isScrolled,
    required this.duration,
    required this.builder,
    this.child,
    super.key,
  });

  /// Whether the page under the bar has scrolled far enough to need chrome.
  final bool isScrolled;

  /// How long the fade takes when motion is allowed.
  final Duration duration;

  /// Draws the bar at the progress it has reached.
  final ValueWidgetBuilder<double> builder;

  /// What the bar carries, built once and handed back unchanged each frame.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isScrolled ? 1 : 0),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : duration,
      curve: Curves.ease,
      builder: builder,
      child: child,
    );
  }
}
