import 'dart:async';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/lessons/presentation/cards/content_card_view.dart';
import 'package:brew_path/features/lessons/presentation/lesson_progress_header.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/services/analytics/analytics_provider.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/content_card_grading.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immersive single-lesson flow: plays each card, then routes to completion.
class LessonScreen extends ConsumerStatefulWidget {
  /// Creates a [LessonScreen].
  const LessonScreen({
    required this.lessonId,
    super.key,
  });

  /// Id of the lesson to play.
  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  /// One nonce per attempt, seeding every card's choice order. Minted here and
  /// never stored, so a replay reorders and yesterday's order is unknowable.
  final int _nonce = mintLessonNonce();

  /// Resolved once. A future rebuilt inside `build` restarts the load on every
  /// frame, which reshuffles nothing but reloads everything.
  late final Future<LessonModel?> _lesson = ref
      .read(contentRepositoryProvider)
      .getLessonById(widget.lessonId);

  int _index = 0;
  int _correctCount = 0; // graded cards answered right — there is no second try
  bool _started = false; // ensures lesson_started fires exactly once

  void _logStartedOnce(LessonModel lesson) {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logEvent(
              'lesson_started',
              parameters: {
                'lesson_id': lesson.id,
                'module_id': lesson.moduleId,
              },
            ),
      );
    });
  }

  /// The only outcome signal a card sends. A wrong answer says nothing — it
  /// has already shown the learner what it needed to, inside the card.
  void _onSolved() => _correctCount++;

  void _onContinue(LessonModel lesson, List<ContentCard> played) {
    if (_index + 1 < played.length) {
      setState(() => _index++);
      return;
    }
    context.goTo(
      lessonCompletion(
        lesson.id,
        correct: _correctCount,
        // Mastery is scored over the cards that could be got wrong. Counting
        // the concept cards a learner only reads would cap every result below
        // full marks for having been taught something.
        total: gradedCards(played).length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // One future for both: the bar needs the lesson's title for the
    // bookmark's accessible name, and the body needs its cards. Resolving it
    // twice would be two chances for them to disagree about which lesson this
    // is.
    return FutureBuilder<LessonModel?>(
      future: _lesson,
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          actions: [
            // The design bookmarks a lesson **while it is being read**, not
            // off a list afterwards.
            if (snapshot.data case final lesson?)
              SavedBookmarkButton(
                savedKey: formatSavedKey(SavedKind.lesson, lesson.id),
                label: lesson.title,
              ),
          ],
        ),
        body: _buildBody(context, snapshot),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<LessonModel?> snap) {
    if (snap.connectionState != ConnectionState.done) {
      return Semantics(
        label: 'Loading the lesson',
        child: const LoadingIndicator(),
      );
    }
    if (snap.hasError) return ErrorView(message: '${snap.error}');

    final lesson = snap.data;
    if (lesson == null) {
      return const ErrorView(message: 'Lesson not found');
    }

    final played = playableCards(lesson.cards);
    if (played.isEmpty) {
      return Semantics(
        label: 'This lesson cannot be played yet.',
        excludeSemantics: true,
        child: const ErrorView(message: 'This lesson cannot be played yet.'),
      );
    }

    _logStartedOnce(lesson);
    return _lessonContent(lesson, played);
  }

  Widget _lessonContent(LessonModel lesson, List<ContentCard> played) {
    final card = contentCardView(
      played[_index],
      nonce: _nonce,
      cardIndex: _index,
      onSolved: _onSolved,
      onContinue: () => _onContinue(lesson, played),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LessonProgressHeader(
              eyebrow: lesson.moduleLabel,
              title: lesson.title,
              current: _index + 1,
              total: played.length,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Keyed by card so each one mounts fresh: a latched card must
            // never be reused for the next question.
            if (card != null)
              KeyedSubtree(key: ValueKey('${_nonce}_$_index'), child: card),
          ],
        ),
      ),
    );
  }
}
