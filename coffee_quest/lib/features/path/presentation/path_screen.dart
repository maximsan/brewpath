import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/path/presentation/path_module_node_widget.dart';

class PathScreen extends ConsumerWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesWithProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabPath)),
      body: modules.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (_, i) => PathModuleNodeWidget(item: list[i]),
        ),
      ),
    );
  }
}
