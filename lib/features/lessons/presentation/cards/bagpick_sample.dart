import 'package:brew_path/features/lessons/presentation/cards/bagpick_process.dart';
import 'package:brew_path/features/lessons/presentation/cards/green_bean.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The bag, its origin line, and the three seeds drawn from it.
///
/// While the process is hidden the bag reads as an open question — an accent
/// border over a faint accent wash — and settles to an ordinary surface once
/// the call is made. That change of state is the design's, and it is what
/// makes the bag feel unopened rather than merely unlabelled.
class BagpickSample extends StatelessWidget {
  /// Creates a [BagpickSample].
  const BagpickSample({
    required this.card,
    required this.revealedProcess,
    super.key,
  });

  /// The round being played.
  final BagpickCard card;

  /// The process, once called — null while the bag is still unlabelled.
  final String? revealedProcess;

  /// How each of the three seeds lies, and how big it is — the design's own
  /// values, kept as one list so a seed's angle and size cannot drift apart.
  static const List<({double degrees, double size})> _seeds = [
    (degrees: -22, size: 72),
    (degrees: 7, size: 82),
    (degrees: -6, size: 72),
  ];

  /// The wash behind an unopened bag.
  static const double _hiddenTint = 0.05;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final hidden = revealedProcess == null;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        border: Border.all(color: hidden ? mood.accent : mood.rule),
        color: hidden
            ? mood.accent.withValues(alpha: _hiddenTint)
            : mood.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.bag,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: mood.inkMute,
                ),
              ),
              _ProcessPill(process: revealedProcess),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(card.origin, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: 'A sample of three green beans from this bag.',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var seed = 0; seed < _seeds.length; seed++) ...[
                  if (seed > 0) const SizedBox(width: AppSpacing.xs),
                  GreenBean(
                    bean: card.bean,
                    seed: seed,
                    size: _seeds[seed].size,
                    degrees: _seeds[seed].degrees,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

/// Reads "Process hidden" until the call is made, then names it.
class _ProcessPill extends StatelessWidget {
  const _ProcessPill({required this.process});

  final String? process;

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.xxs,
  );

  /// The wash behind the answer once it is known.
  static const double _revealedTint = 0.12;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final hidden = process == null;
    final tint = hidden ? mood.accent : mood.sage;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: tint),
        color: hidden ? null : tint.withValues(alpha: _revealedTint),
      ),
      child: Text(
        hidden ? 'Process hidden' : processLabel(process!),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: tint),
      ),
    );
  }
}
