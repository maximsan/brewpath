import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/path/presentation/path_node_card.dart';
import 'package:brew_path/features/path/presentation/path_node_rail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A single node in the vertical learning path: a state-colored circle on the
/// connecting rail plus a content card with the module icon, title, and
/// progress. Locked taps surface the unlock hint instead of navigating.
class PathModuleNodeWidget extends StatelessWidget {
  /// Creates a [PathModuleNodeWidget].
  const PathModuleNodeWidget({
    required this.item,
    required this.isFirst,
    required this.isLast,
    super.key,
  });

  /// The module paired with its progress.
  final ModuleWithProgress item;

  /// Whether this is the first node (the rail trims its top connector).
  final bool isFirst;

  /// Whether this is the last node (the rail trims its bottom connector).
  final bool isLast;

  static const double _cardBottomGap = 12;

  void _onTap(BuildContext context) {
    if (item.isLocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(AppLabels.lockedModuleMessage)),
        );
      return;
    }
    context.go('/learn/module/${item.module.id}');
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PathNodeRail(item: item, isFirst: isFirst, isLast: isLast),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : _cardBottomGap),
              child: PathNodeCard(item: item, onTap: () => _onTap(context)),
            ),
          ),
        ],
      ),
    );
  }
}
