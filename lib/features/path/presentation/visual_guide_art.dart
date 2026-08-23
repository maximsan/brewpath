import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How much of the drawing's box the generic mark fills.
const double _markToSideRatio = 2;

/// Beside a row: large enough to tell eight drawings apart at a glance.
const double _rowSide = 36;

/// In the sheet: the thing the learner came to look at.
const double _sheetSide = 180;

/// The two sizes a guide's drawing is asked for.
enum VisualGuideArtSize {
  /// Beside a row on the Reference section.
  row,

  /// The illustration in the guide's sheet.
  sheet;

  /// The height the drawing is given.
  double get side => switch (this) {
    VisualGuideArtSize.row => _rowSide,
    VisualGuideArtSize.sheet => _sheetSide,
  };

  /// Its width: square beside a row, full-bleed in the sheet. Kept on the enum
  /// with [side] so both size decisions are made in one place.
  double? get width => switch (this) {
    VisualGuideArtSize.row => _rowSide,
    VisualGuideArtSize.sheet => null,
  };
}

/// A guide's drawing.
///
/// ⚠️ **A placeholder for now.** The eight real drawings are their own effort,
/// deliberately: one painter family per subject, built to be legible at both
/// sizes so the row thumbnail and the sheet illustration cannot drift apart —
/// and reused later by the lesson `visual` card renderer. Until they land,
/// every subject gets the same generic mark, which is the fallback the
/// collectible model already documents for art that does not exist yet.
///
/// It is excluded from the semantics tree at both sizes: eight unlabelled
/// shapes read out to a screen-reader user is worse than none.
class VisualGuideArt extends StatelessWidget {
  /// Creates a [VisualGuideArt].
  const VisualGuideArt({
    required this.subject,
    required this.size,
    super.key,
  });

  /// Which guide's drawing to paint. Unused while the mark is generic, and
  /// carried anyway because it is what the real drawings are chosen by.
  final String subject;

  /// How large to draw it.
  final VisualGuideArtSize size;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return ExcludeSemantics(
      child: Container(
        width: size.width ?? double.infinity,
        height: size.side,
        decoration: BoxDecoration(
          color: mood.surface,
          border: Border.all(color: mood.rule),
          borderRadius: BorderRadius.circular(AppRadii.chrome),
        ),
        child: Icon(
          Icons.auto_stories_outlined,
          size: size.side / _markToSideRatio,
          color: mood.inkMute,
        ),
      ),
    );
  }
}
