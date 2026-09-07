import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One quiet line under the streak: the bean, the lessons, the points.
///
/// This is what the design has where the app had three more stat tiles. The
/// numbers are a footnote to the tree and the streak above them, so they get a
/// line rather than cards.
class ProfileProgressLine extends StatelessWidget {
  /// Creates a [ProfileProgressLine].
  const ProfileProgressLine({
    required this.lessons,
    required this.points,
    super.key,
  });

  /// The bean beside the numbers.
  static const double _markSize = 13;

  /// Lessons finished.
  final int lessons;

  /// Points earned.
  final int points;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final line =
        '$lessons ${lessons == 1 ? 'lesson' : 'lessons'} · $points points';

    return Semantics(
      label: line,
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconMark(AppIcon.bean, size: _markSize, color: mood.inkMute),
          const SizedBox(width: AppSpacing.xs - 1),
          Text(
            line.toUpperCase(),
            style: AppText.label(mood: mood, face: AppFace.mono),
          ),
        ],
      ),
    );
  }
}
