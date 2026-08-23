import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What an empty shelf says.
///
/// It teaches the bookmark rather than reporting a count of zero: the learner
/// most likely to open an empty shelf is the one who has not found the control
/// yet.
class SavedEmptyView extends StatelessWidget {
  /// Creates a [SavedEmptyView].
  const SavedEmptyView({super.key});

  /// The copy, named so a test can assert it without re-spelling it.
  static const message =
      'Nothing saved yet. Tap the bookmark on any lesson, term or visual '
      'guide and it lands here for quick review.';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your saved shelf is empty',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_outline,
                size: AppSpacing.xxl,
                color: context.mood.inkMute,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: context.mood.inkMute),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
