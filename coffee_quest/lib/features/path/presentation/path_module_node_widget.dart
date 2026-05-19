import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';

/// A single node in the vertical learning path: title, lesson dots
/// (filled = complete), and a locked/unlocked icon.
class PathModuleNodeWidget extends StatelessWidget {
  const PathModuleNodeWidget({super.key, required this.item});

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
    return ListTile(
      onTap: () => _onTap(context),
      leading: Icon(
        item.isLocked
            ? Icons.lock_outline
            : (item.isComplete ? Icons.check_circle : Icons.lock_open),
        color: item.isComplete ? Colors.green : null,
      ),
      title: Text(item.module.title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            for (var i = 0; i < item.totalCount; i++)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  i < item.completedCount
                      ? Icons.circle
                      : Icons.circle_outlined,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
