import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/lessons/domain/lesson_completion_service.dart';
import 'package:coffee_quest/shared/models/coffee_card_model.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';

class _Reward {
  const _Reward({required this.lesson, this.card});
  final LessonModel lesson;
  final CoffeeCardModel? card;
}

class LessonCompletionScreen extends ConsumerStatefulWidget {
  const LessonCompletionScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonCompletionScreen> createState() =>
      _LessonCompletionScreenState();
}

class _LessonCompletionScreenState
    extends ConsumerState<LessonCompletionScreen> {
  late final Future<_Reward> _future = _completeAndLoad();

  /// Persists the completion exactly once. `LessonCompletionService` is
  /// idempotent, so a rebuild or revisit will not double-award XP/cards.
  Future<_Reward> _completeAndLoad() async {
    final content = ref.read(contentRepositoryProvider);
    final lesson = await content.getLessonById(widget.lessonId);
    if (lesson == null) {
      throw StateError('Lesson ${widget.lessonId} not found');
    }
    await ref.read(lessonCompletionServiceProvider).completeLesson(lesson);

    CoffeeCardModel? card;
    final cardId = lesson.cardId;
    if (cardId != null) {
      final cards = await content.getCards();
      card = cards.where((c) => c.id == cardId).firstOrNull;
    }
    return _Reward(lesson: lesson, card: card);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_Reward>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const LoadingIndicator();
            }
            if (snap.hasError) return ErrorView(message: '${snap.error}');
            final reward = snap.data!;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.celebration, size: 72),
                  const SizedBox(height: 16),
                  Text(
                    'Lesson complete!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+${reward.lesson.xpReward} XP',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (reward.card != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.style),
                        title: Text(reward.card!.title),
                        subtitle: Text(reward.card!.moduleTag),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => context.go('/learn'),
                    child: const Text(AppStrings.continueLabel),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
