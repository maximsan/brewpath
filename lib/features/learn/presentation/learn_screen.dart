import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/active_challenge_card.dart';
import 'package:brew_path/features/challenges/presentation/saved_challenges_list.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/module_card_widget.dart';
import 'package:brew_path/features/learn/presentation/practice_any_lesson_widget.dart';
import 'package:brew_path/features/learn/presentation/today_card_widget.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_providers.dart';
import 'package:brew_path/features/mini_games/presentation/mini_games_catalog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Learn tab: today's lesson, the module list, and practice sections.
class LearnScreen extends ConsumerWidget {
  /// Creates a [LearnScreen].
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayLessonProvider);
    final keepSharp = ref.watch(keepSharpRecommendationProvider);
    final keepSharpDone = ref.watch(keepSharpAcknowledgedTodayProvider);
    final modules = ref.watch(modulesWithProgressProvider);
    final finishedLessons = ref.watch(completedLessonsWithModuleProvider);
    final miniGames = ref.watch(miniGameFormatsProvider);
    final challenge = ref.watch(activeChallengeProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppLabels.tabLearn),
        // The design's top-right pair; Saved is not built yet and lands with
        // its own ticket.
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: DictionaryHomeScreen.title,
            onPressed: () => context.pushNamed(AppRoutes.dictionary.name),
          ),
        ],
      ),
      body: modules.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            TodayCardWidget(
              today: today.asData?.value,
              keepSharp: keepSharp.asData?.value,
              keepSharpDone: keepSharpDone.asData?.value ?? false,
            ),
            // The brew in play sits under the day's lesson: a sibling card,
            // because what to learn and what to go and make are two questions
            // and a learner can have both open at once.
            if (challenge != null) ...[
              const SizedBox(height: 12),
              ActiveChallengeCard(challenge: challenge),
            ],
            const SavedChallengesList(),
            const SizedBox(height: 24),
            const SectionHeader('Practice a finished lesson'),
            const SizedBox(height: 12),
            PracticeAnyLessonWidget(
              lessons: finishedLessons.asData?.value ?? const [],
            ),
            const SizedBox(height: 24),
            const SectionHeader('Mini-games'),
            const SizedBox(height: 12),
            MiniGamesCatalogWidget(
              formats: miniGames.asData?.value ?? const [],
            ),
            const SizedBox(height: 24),
            const SectionHeader('Modules'),
            const SizedBox(height: 12),
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              ModuleCardWidget(item: list[i]),
            ],
          ],
        ),
      ),
    );
  }
}
