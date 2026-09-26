import 'dart:async';

import 'package:brew_path/features/dictionary/domain/flashcard_destination.dart';
import 'package:brew_path/features/dictionary/domain/vocab_destination.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_mark.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_mark.dart';
import 'package:brew_path/features/learn/presentation/practice/replay_row.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The dictionary drills, leading the Today tab's **Games** group as plain
/// rows ahead of the kind sub-groups (ADR-0004).
///
/// **Free, with no lock treatment, always visible.** The drills are content-
/// scoped, never feature-gated: a free learner plays them over the terms their
/// lessons reached, which is a smaller pool rather than a locked door.
class PracticeDrillsWidget extends StatelessWidget {
  /// Creates a [PracticeDrillsWidget].
  const PracticeDrillsWidget({super.key});

  /// How many rows this draws — the Games group counts them in with the
  /// catalog's, and a second copy of the number is a second thing to keep in
  /// step.
  static const int rowCount = 2;

  /// The design's `<ReplayIcon kind={it.kind}/>` at its default `size = 20`.
  static const double _markSize = 20;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReplayRow(
          icon: FlashcardsMark(
            size: _markSize,
            color: mood.inkMute,
            accent: mood.accent,
          ),
          title: context.strings.flashcardsTitle,
          sub: context.strings.practiceDrillEyebrow,
          starts: true,
          onTap: () => unawaited(context.pushActivity(flashcardReview)),
        ),
        ReplayRow(
          icon: VocabMark(
            size: _markSize,
            color: mood.inkMute,
            accent: mood.accent,
          ),
          title: context.strings.vocabTitle,
          sub: context.strings.practiceDrillEyebrow,
          starts: true,
          onTap: () => unawaited(context.pushActivity(vocabGame)),
        ),
      ],
    );
  }
}
