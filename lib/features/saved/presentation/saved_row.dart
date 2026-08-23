import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One saved thing: what it is, and the bookmark that takes it off.
///
/// The bookmark is the same control that put it here, so unsaving from the
/// shelf and unsaving from the thing itself are the same gesture.
class SavedRow extends StatelessWidget {
  /// Creates a [SavedRow] for [item].
  const SavedRow({required this.item, required this.onOpen, super.key});

  /// The row's content.
  final SavedItem item;

  /// Opens what the row names.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmallcapsLabel(item.subtitle),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.mood.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            SavedBookmarkButton(savedKey: item.key, label: item.title),
          ],
        ),
      ),
    );
  }
}
