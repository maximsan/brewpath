import 'dart:async';

import 'package:brew_path/features/dictionary/domain/flashcard_destination.dart';
import 'package:brew_path/features/dictionary/domain/vocab_destination.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_mark.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_mark.dart';
import 'package:brew_path/features/learn/presentation/practice/replay_row.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The dictionary drills, leading the Learn tab's Games group (ADR-0004).
///
/// Free, unlocked and always visible: the drills are content-scoped, never
/// feature-gated, so the meta line reads `FREE` until the course is owned and
/// the drill's time after. Flashcards leads and is here whether or not the
/// deck has cards, because this row is how a learner finds out they exist.
class PracticeDrillsWidget extends StatelessWidget {
  /// Creates a [PracticeDrillsWidget].
  const PracticeDrillsWidget({required this.hasCourse, super.key});

  /// Whether the learner owns the course, which is what the meta line reads.
  final bool hasCourse;

  /// How many rows this draws — the Games group counts them in with the
  /// catalog's, and a second copy of the number is a second thing to keep in
  /// step.
  static const int rowCount = 2;

  /// The marks' drawn size, matching the kind glyphs they sit above.
  static const double _markSize = 20;

  /// What the rows say about cost, and about time once cost is settled.
  String _meta(AppLocalizations strings) =>
      hasCourse ? strings.practiceTwoMinutes : strings.practiceFree;

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
          sub: context.strings.flashcardsPracticeRowEyebrow,
          meta: _meta(context.strings),
          onTap: () => unawaited(context.pushActivity(flashcardReview)),
        ),
        ReplayRow(
          icon: VocabMark(
            size: _markSize,
            color: mood.inkMute,
            accent: mood.accent,
          ),
          title: VocabCopy.title,
          sub: VocabCopy.rowSubtitle,
          meta: _meta(context.strings),
          onTap: () => unawaited(context.pushActivity(vocabGame)),
        ),
      ],
    );
  }
}
