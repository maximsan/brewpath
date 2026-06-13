import 'package:flutter/material.dart';

/// Small uppercase-weight heading that introduces a list section.
///
/// Shared across screens to keep section labels visually consistent.
class SectionHeader extends StatelessWidget {
  /// Creates a [SectionHeader].
  const SectionHeader(this.title, {super.key});

  /// The section heading text.
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
