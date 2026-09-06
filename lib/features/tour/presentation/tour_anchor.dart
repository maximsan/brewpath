import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:flutter/widgets.dart';

/// Marks the widget a Tour stop frames.
///
/// The four targets are drawn by three different owners — the Learn feed, the
/// shell's header and its tab bar — and the overlay that frames them belongs to
/// none of the three. An anchor is how they name themselves to it: a key the
/// layer measures, and nothing else. The wrapped widget is unchanged, and a
/// screen with no Tour over it pays nothing for carrying one.
///
/// **One anchor per stop, app-wide.** The keys are global because the thing
/// they identify is global — the Tour's third stop is *the* header, not a
/// header — and because two live anchors for one stop would leave the layer
/// measuring whichever it found first.
class TourAnchor extends StatelessWidget {
  /// Anchors [step] on [child].
  const TourAnchor({required this.step, required this.child, super.key});

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

  /// The stop whose frame lands on [child].
  final TourStep step;

  /// The widget the stop frames.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _keys[step], child: child);
}
