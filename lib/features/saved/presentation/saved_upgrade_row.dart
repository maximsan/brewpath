import 'package:brew_path/features/saved/presentation/saved_gate.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The offer a free learner sees once their shelf is full.
///
/// It sits on the shelf rather than only appearing at the moment of refusal,
/// because a learner who has hit the cap already knows they are stuck — what
/// they need is the way out, where the limit is felt.
class SavedUpgradeRow extends StatelessWidget {
  /// Creates a [SavedUpgradeRow].
  const SavedUpgradeRow({super.key});

  /// The copy, named so a test can assert it without re-spelling it.
  static const message =
      'Your shelf is full. Unlock Plus to save without a '
      'limit.';

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      child: InkWell(
        // Until the gate sheet exists (#89) the offer explains itself rather
        // than opening onto nothing.
        onTap: () => showSavedCapReached(context),
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: mood.surface,
            border: Border.all(color: mood.rule),
            borderRadius: BorderRadius.circular(AppRadii.chrome),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: mood.inkMute),
                ),
              ),
              Icon(Icons.chevron_right, color: mood.accent),
            ],
          ),
        ),
      ),
    );
  }
}
