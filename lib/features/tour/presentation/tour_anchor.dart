import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:flutter/widgets.dart';

/// Marks the widget a Tour stop frames.
///
/// The four targets are drawn by three owners — the Learn feed, the shell's
/// header and its tab bar — and the overlay that frames them belongs to none
/// of the three; an anchor is a key it measures, and nothing else. The keys
/// are global because a stop identifies *the* header, not a header.
class TourAnchor extends StatelessWidget {
  /// Anchors [step] on [child], framing it [inset] inside its own box.
  const TourAnchor({
    required this.step,
    required this.child,
    this.inset = EdgeInsets.zero,
    super.key,
  });

  /// The keys, one per stop, created once for the life of the process.
  ///
  /// A `GlobalKey` cannot be `const`, so they cannot sit on [TourStep] itself;
  /// this map is the nearest thing to a field on it.
  static final Map<TourStep, GlobalKey> _keys = {
    for (final step in TourStep.values) step: GlobalKey(),
  };

  /// Where [step]'s target is in the tree, or null while nothing renders it.
  ///
  /// Null is ordinary rather than exceptional: the Learn feed builds its
  /// children lazily, so a stop below the fold has no context until the feed
  /// has been asked to keep it mounted.
  static BuildContext? contextFor(TourStep step) => _keys[step]?.currentContext;

  /// What [step]'s anchor calls padding rather than content, or nothing where
  /// it has none.
  ///
  /// Read off the same element the layer measures, so the box and the inset it
  /// is taken off always come from one laid-out frame.
  static EdgeInsets insetFor(TourStep step) {
    final anchored = _keys[step]?.currentWidget;
    return anchored is _Anchored ? anchored.inset : EdgeInsets.zero;
  }

  /// The stop whose frame lands on [child].
  final TourStep step;

  /// The part of this box that is the owner's padding, which the frame leaves
  /// out — the design frames the content box.
  final EdgeInsets inset;

  /// The widget the stop frames.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _Anchored(key: _keys[step], inset: inset, child: child);
}

/// Carries the key the layer measures and the inset it measures with, so both
/// are read from one place in the tree rather than from a map beside it.
class _Anchored extends StatelessWidget {
  const _Anchored({required this.inset, required this.child, super.key});

  final EdgeInsets inset;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
