import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The key/value pair table under a concept card's prose.
///
/// Nothing to do with the fill mechanic beside it, which is why it sits here.
class ConceptMetaTable extends StatelessWidget {
  /// Creates a [ConceptMetaTable].
  const ConceptMetaTable({required this.rows, super.key});

  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    row.first,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: mood.inkMute,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(row.last, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
