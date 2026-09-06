import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Wash behind a picked row or pill — the design's `accent 10%`.
///
/// **Not** `CardTints.wash`'s 12%: that is the lesson cards' mark, and this is
/// a different surface with its own recipe. Ten, because `GROVE_SELECTED`
/// says ten.
const double _pickedWash = 0.10;

/// How the grove draws "picked", shared by the plant rows and the light pills.
///
/// One recipe, because the prototype makes it one: *"GROVE_SELECTED is the one
/// selected-state recipe on this screen, shared by the plant rows and the light
/// chips so 'picked' looks identical in both"*. Two copies is how they stop
/// looking identical.
///
/// It is a **fill plus an accent border**, which reads against the design
/// system's general *"Selection = double stroke … never a fill"*. The running
/// prototype defines this screen's own recipe and outranks a derived doc, so
/// the fill is right here and the general rule still governs everywhere it has
/// not been overridden. Recorded so it is not "corrected" back.
@immutable
class GroveSelection {
  const GroveSelection._();

  /// The wash behind a picked surface, or null when it is not picked.
  static Color? fill(MoodColors mood, {required bool picked}) =>
      picked ? mood.accent.withValues(alpha: _pickedWash) : null;

  /// The outline: accent when picked, the plain rule otherwise.
  static Color edge(MoodColors mood, {required bool picked}) =>
      picked ? mood.accent : mood.rule;
}
