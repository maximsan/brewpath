import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Uppercase label used for screen breadcrumbs and section dividers throughout
/// onboarding.
///
/// Set in IBM Plex Sans, not mono: the design has both `.smallcaps` (Plex Sans
/// 500) and `.smallcaps-mono`, and onboarding's kickers use the former
/// (`onboarding.jsx:195,202`). Mono is for figures and answer-feedback labels.
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
      style: AppText.label(mood: context.mood, color: color),
    );
  }
}
