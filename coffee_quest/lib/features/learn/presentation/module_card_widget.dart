import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';

/// Module summary card for the Learn list: title, lesson count, progress bar,
/// and lock state. Locked taps surface the unlock hint instead of navigating.
class ModuleCardWidget extends StatelessWidget {
  const ModuleCardWidget({super.key, required this.item});

  final ModuleWithProgress item;

  void _onTap(BuildContext context) {
    if (item.isLocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(AppStrings.lockedModuleMessage)),
        );
      return;
    }
    context.go('/learn/module/${item.module.id}');
  }

  @override
  Widget build(BuildContext context) {
    final m = item.module;
    return Card(
      child: ListTile(
        leading: Icon(item.isLocked ? Icons.lock_outline : Icons.menu_book),
        title: Text(m.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text('${item.completedCount} / ${item.totalCount} lessons'),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: item.progress),
          ],
        ),
        trailing: item.isComplete
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () => _onTap(context),
      ),
    );
  }
}
