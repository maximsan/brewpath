import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/learn/presentation/module_card_widget.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayLessonProvider);
    final modules = ref.watch(modulesWithProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabLearn)),
      body: modules.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TodayCard(today: today.asData?.value),
            const SizedBox(height: 16),
            for (final item in list) ModuleCardWidget(item: item),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.today});

  final LessonModel? today;

  @override
  Widget build(BuildContext context) {
    final lesson = today;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.local_cafe),
        title: Text(
          lesson == null ? "You're all caught up!" : "Today's lesson",
        ),
        subtitle: Text(lesson?.title ?? 'No lessons left to study.'),
        trailing: lesson == null ? null : const Icon(Icons.play_arrow),
        onTap: lesson == null
            ? null
            : () => context.go('/learn/lesson/${lesson.id}'),
      ),
    );
  }
}
