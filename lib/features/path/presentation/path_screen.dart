import 'package:coffee_quest/core/constants/app_labels.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/path/presentation/path_module_node_widget.dart';
import 'package:coffee_quest/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Path tab: the vertical learning journey of module nodes.
class PathScreen extends ConsumerWidget {
  /// Creates a [PathScreen].
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesWithProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppLabels.tabPath)),
      body: modules.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PathHeader(modules: list),
            const SizedBox(height: 20),
            for (var i = 0; i < list.length; i++)
              PathModuleNodeWidget(
                item: list[i],
                isFirst: i == 0,
                isLast: i == list.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

/// Journey summary above the trail: how many modules are fully complete,
/// with an overall progress bar.
class _PathHeader extends StatelessWidget {
  const _PathHeader({required this.modules});

  final List<ModuleWithProgress> modules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = modules.length;
    final done = modules.where((m) => m.isComplete).length;
    final progress = total == 0 ? 0.0 : done / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your journey',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$done of $total modules complete',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          minHeight: AppSpacing.xs,
          borderRadius: BorderRadius.circular(AppSpacing.xxs),
          backgroundColor: colors.surfaceContainerHighest,
          color: colors.primary,
        ),
      ],
    );
  }
}
