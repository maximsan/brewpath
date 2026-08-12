import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// IBM Plex Mono uppercase label used for screen breadcrumbs and section
/// dividers throughout onboarding. Matches the `.smallcaps` style in the
/// design bundle.
class SmallcapsLabel extends StatelessWidget {
  /// Creates a [SmallcapsLabel].
  const SmallcapsLabel(this.text, {this.color, super.key});

  /// The label text (rendered uppercase).
  final String text;

  /// Optional text color; defaults to the mood's muted ink.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppText.label(
        mood: context.mood,
        color: color,
        face: AppFace.mono,
      ),
    );
  }
}
