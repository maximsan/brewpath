import 'package:flutter/animation.dart';

/// The design's durations and easings, so a timing is stated once.
///
/// Mood-independent, like `AppSpacing` — a `static const` on a class with no
/// `of(context)`, so a painter can read one with no `BuildContext`.
abstract final class AppMotion {
  /// The design's `320ms cubic-bezier` move, which the Tour's frame travels
  /// over and a match line snaps home over.
  static const Duration expand = Duration(milliseconds: 320);

  /// The design's `240ms` disclosure: the panel's growth and the glyph's turn,
  /// one duration because they move as one thing.
  static const Duration disclosure = Duration(milliseconds: 240);

  /// The panel's own `cubic-bezier(.2,.8,.2,1)` — away fast, settling slowly.
  static const Curve disclosurePanel = Cubic(0.2, 0.8, 0.2, 1);

  /// The glyph's `cubic-bezier(.4,0,.2,1)`, which leaves later than the panel.
  static const Curve disclosureGlyph = Cubic(0.4, 0, 0.2, 1);
}
