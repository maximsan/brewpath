import 'dart:math' as math;

import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What a right swipe on a term row would do, uncovered behind it.
///
/// Driven by the **undamped** travel: a saved row moves 22% of the drag, so
/// keying this to the movement left a 60px swipe explaining itself at 0.3 over
/// 13px, which is how "already saved" came to look like a dead list.
class TermSaveTrack extends StatelessWidget {
  /// Creates a [TermSaveTrack] for a row that is or is not [isSaved].
  const TermSaveTrack({
    required this.travel,
    required this.isSaved,
    super.key,
  });

  /// What an unsaved row's track says the gesture does.
  static const String save = 'Save';

  /// What a saved row's says instead, so the resistance explains itself.
  static const String alreadySaved = 'Already saved';

  /// The finger's own distance, from `SwipeDrag.travel` — or the nudge's,
  /// which teaches the same gesture. Leftward uncovers nothing.
  final double travel;

  /// Whether the row is already on the shelf.
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return ExcludeSemantics(
      child: Opacity(
        opacity: swipeCaptionOpacity(math.max(travel, 0)),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: SmallcapsLabel(
              isSaved ? alreadySaved : save,
              color: isSaved ? mood.inkMute : mood.accentText,
            ),
          ),
        ),
      ),
    );
  }
}
