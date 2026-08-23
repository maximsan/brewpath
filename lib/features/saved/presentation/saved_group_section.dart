import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_row.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One heading and its rows.
///
/// Only built for a non-empty group — "hidden when empty" is a property of the
/// derivation, not a rule this widget remembers.
class SavedGroupSection extends StatelessWidget {
  /// Creates a [SavedGroupSection] for [group].
  const SavedGroupSection({
    required this.group,
    required this.onOpen,
    super.key,
  });

  /// The group to draw.
  final SavedGroup group;

  /// Opens the thing a row names.
  final void Function(SavedItem item) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SmallcapsLabel(group.label),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${group.items.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.mood.inkMute,
                ),
              ),
            ],
          ),
        ),
        for (final item in group.items)
          SavedRow(item: item, onOpen: () => onOpen(item)),
      ],
    );
  }
}
