import 'dart:async';

import 'package:brew_path/features/dictionary/domain/flashcard_destination.dart';
import 'package:brew_path/features/dictionary/domain/vocab_destination.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_mark.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_mark.dart';
import 'package:brew_path/features/learn/presentation/practice/replay_row.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The dictionary drills, leading the Learn tab's **Games** group.
///
/// ADR-0004 rules that the practice section lists all four practice types, and
/// that these rows lead the Games group as its first entries rather than
/// sitting beside it — one container for everything playable.
///
/// **Free, with no lock treatment, always visible.** The drills are content-
/// scoped, never feature-gated: a free learner plays them over the terms their
/// lessons reached, which is a smaller pool rather than a locked door. A lock
/// mark here would say the opposite of what is true, and these are a free
/// learner's cheapest streak path. What the meta line says instead is the
/// design's: `FREE` while the course is not owned, the drill's time once it is.
///
/// Both rows (#97, #98), in the design's order — Flashcards leads. The
/// Flashcards row is here whether or not the deck has cards: this row is how a
/// learner finds out flashcards exist, and an empty deck opens the drill's
/// teaching state, which is written for that arrival.
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
  static const String _freeMeta = 'Free';
  static const String _ownedMeta = '~2 min';

  String get _meta => hasCourse ? _ownedMeta : _freeMeta;

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
          title: FlashcardsCopy.title,
          sub: FlashcardsCopy.practiceRowEyebrow,
          meta: _meta,
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
          meta: _meta,
          onTap: () => unawaited(context.pushActivity(vocabGame)),
        ),
      ],
    );
  }
}
