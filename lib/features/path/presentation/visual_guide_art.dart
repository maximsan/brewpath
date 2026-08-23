import 'package:brew_path/features/path/presentation/guide_marks/beans_marks.dart';
import 'package:brew_path/features/path/presentation/guide_marks/brew_marks.dart';
import 'package:brew_path/features/path/presentation/guide_marks/grind_marks.dart';
import 'package:brew_path/features/path/presentation/guide_marks/guide_mark.dart';
import 'package:brew_path/features/path/presentation/guide_marks/roast_marks.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

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
/// **One drawing per subject, at whatever size it is asked for.** The row
/// thumbnail and the sheet illustration are the same painter, so they cannot
/// drift apart — and the lesson `visual` card renderer will reuse them, which
/// makes that work a layout job rather than an art job.
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
