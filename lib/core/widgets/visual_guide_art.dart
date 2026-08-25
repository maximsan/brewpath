import 'package:brew_path/core/widgets/guide_marks/beans_marks.dart';
import 'package:brew_path/core/widgets/guide_marks/brew_marks.dart';
import 'package:brew_path/core/widgets/guide_marks/grind_marks.dart';
import 'package:brew_path/core/widgets/guide_marks/guide_mark.dart';
import 'package:brew_path/core/widgets/guide_marks/roast_marks.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Beside a row: large enough to tell eight drawings apart at a glance.
const double _rowSide = 36;

/// Wherever the drawing is the thing the learner came to look at: the
/// guide's sheet, and the lesson card that teaches it.
const double _fullSide = 180;

/// The two sizes a guide's drawing is asked for.
///
/// Two, not one per host: the lesson card that teaches a guide and the sheet
/// that keeps it want the same drawing at the same size, and giving each its
/// own value would be an invitation for them to drift.
enum VisualGuideArtSize {
  /// Beside a row on the Reference section.
  row,

  /// The illustration itself — in the guide's sheet, or on its lesson card.
  full;

  /// The height the drawing is given.
  double get side => switch (this) {
    VisualGuideArtSize.row => _rowSide,
    VisualGuideArtSize.full => _fullSide,
  };

  /// Its width: square beside a row, full-bleed otherwise. Kept on the enum
  /// with [side] so both size decisions are made in one place.
  double? get width => switch (this) {
    VisualGuideArtSize.row => _rowSide,
    VisualGuideArtSize.full => null,
  };
}

/// A guide's drawing.
///
/// **One drawing per subject, at whatever size it is asked for.** The row
/// thumbnail, the sheet illustration and the lesson card that teaches the
/// guide are the same painter, so they cannot drift apart.
///
/// It lives here rather than with the Reference section that first needed it
/// because two features draw it now — the convention being that anything two
/// features use moves out of both.
///
/// Excluded from the semantics tree at both sizes: eight unlabelled shapes
/// read out to a screen-reader user is worse than none. What each guide *is*
/// is carried by its title and its meta table.
class VisualGuideArt extends StatelessWidget {
  /// Creates a [VisualGuideArt].
  const VisualGuideArt({
    required this.subject,
    required this.size,
    super.key,
  });

  /// Which guide's drawing to paint.
  final String subject;

  /// How large to draw it.
  final VisualGuideArtSize size;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return ExcludeSemantics(
      child: SizedBox(
        width: size.width ?? double.infinity,
        height: size.side,
        child: CustomPaint(painter: guideMarkFor(subject, mood)),
      ),
    );
  }
}

/// The drawing for [subject].
///
/// A subject with no drawing yet falls back to a plain mark rather than an
/// empty box — the same fallback the collectible model documents for art that
/// does not exist. Every shipped subject has one; the fallback exists so a new
/// guide is unremarkable rather than broken.
GuideMark guideMarkFor(String subject, MoodColors mood) => switch (subject) {
  'roast' => RoastMark(mood),
  'caffeine' => CaffeineMark(mood),
  'grind' => GrindMark(mood),
  'distribution' => DistributionMark(mood),
  'extraction' => ExtractionMark(mood),
  'ratio' => RatioMark(mood),
  'anatomy' => AnatomyMark(mood),
  'variety' => VarietyMark(mood),
  _ => FallbackMark(mood),
};

/// The mark a subject with no drawing gets.
class FallbackMark extends GuideMark {
  /// Creates a [FallbackMark].
  const FallbackMark(super.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.6,
      size.height * 0.4,
    );
    paintBar(canvas, rect, mood.rule, radius: size.shortestSide * 0.08);
  }
}
