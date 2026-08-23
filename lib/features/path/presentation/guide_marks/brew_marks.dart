import 'package:brew_path/features/path/presentation/guide_marks/guide_mark.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:flutter/material.dart';

/// A spectrum with a marker: the shape both brew guides share.
///
/// Extraction runs sour → balanced → bitter; ratio runs weak → strong. Each
/// names its own ends in its meta table, so the drawing carries the axis and
/// the marker, and no words.
class _SpectrumMark extends GuideMark {
  const _SpectrumMark(
    super.mood, {
    required this.ends,
    required this.markerAt,
  });

  /// The colour at each end of the band.
  final (Color, Color) ends;

  /// Where the marker sits, as a fraction across.
  final double markerAt;

  @override
  void paint(Canvas canvas, Size size) {
    final band = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.42,
      size.width * 0.84,
      size.height * 0.16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(band, Radius.circular(band.height / 2)),
      Paint()
        ..shader = LinearGradient(
          colors: [ends.$1, ends.$2],
        ).createShader(band),
    );

    // The marker: where a cup you are aiming for sits on the axis.
    final x = band.left + band.width * markerAt;
    canvas.drawCircle(
      Offset(x, band.center.dy),
      size.shortestSide * 0.085,
      Paint()..color = mood.bg,
    );
    canvas.drawCircle(
      Offset(x, band.center.dy),
      size.shortestSide * 0.085,
      Paint()
        ..color = mood.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.028,
    );
  }
}

/// Extraction: sour through balanced to bitter, marked in the middle.
class ExtractionMark extends _SpectrumMark {
  /// Creates an [ExtractionMark].
  const ExtractionMark(super.mood)
    : super(ends: (ArtColors.sour, ArtColors.roastDark), markerAt: 0.5);
}

/// Coffee-to-water ratio: weak through strong, marked at the baseline.
class RatioMark extends _SpectrumMark {
  /// Creates a [RatioMark].
  const RatioMark(super.mood)
    : super(ends: (ArtColors.cream, ArtColors.roastDeep), markerAt: 0.42);
}
