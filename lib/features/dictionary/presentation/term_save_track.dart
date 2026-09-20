import 'dart:math' as math;

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
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

  /// The mark a saved row leads with, sized to the strip the damping gives.
  static const double _markSize = 16;

  /// A saved row leads flush at the edge, with no inset at all.
  ///
  /// 22% of a 70px drag uncovers 15px and of a 100px drag 22px, so the mark
  /// clears the row at 73px of finger — just past the 64 a save commits at.
  /// The design's 12px inset is room a damped row never has.
  static const double _markInset = 0;

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
            padding: EdgeInsets.only(
              left: isSaved ? _markInset : AppSpacing.sm,
            ),
            child: isSaved ? _savedMark(mood) : _saveLabel(mood),
          ),
        ),
      ),
    );
  }

  Widget _saveLabel(MoodColors mood) =>
      SmallcapsLabel(save, color: mood.accentText);

  /// The mark first, then the words.
  ///
  /// A damped row uncovers a strip the words cannot fit in at any natural
  /// drag, so the thing that has to read early is the mark the row already
  /// carries. The words follow it for a drag that goes far enough.
  Widget _savedMark(MoodColors mood) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconMark(
        AppIcon.bookmark,
        active: true,
        size: _markSize,
        color: mood.inkMute,
      ),
      const SizedBox(width: AppSpacing.xs),
      SmallcapsLabel(alreadySaved, color: mood.inkMute),
    ],
  );
}
