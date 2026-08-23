import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One thing about the sample the learner can look at.
///
/// A closed cue has to *look* closed, not merely say so. The design draws it
/// with a dashed border over nothing and fills it in once it is read; a dashed
/// border is a painter's job in Flutter and not worth one here, so the fill and
/// the border weight carry the state instead. What matters is that the two
/// states differ before the words are read — a row whose only difference is its
/// text asks the learner to read every row to find the unread ones.
class BagpickCueRow extends StatelessWidget {
  /// Creates a [BagpickCueRow].
  const BagpickCueRow({
    required this.cue,
    required this.revealed,
    required this.isTell,
    required this.onInspect,
    super.key,
  });

  /// The observation this row offers.
  final BagpickCue cue;

  /// Whether the learner has looked at it.
  final bool revealed;

  /// Whether this was the cue that gave the answer away.
  final bool isTell;

  /// Null once the card has latched — nothing left to uncover.
  final VoidCallback? onInspect;

  static const double _labelWidth = 92;

  /// A closed cue's border, dimmed so it reads as an outline waiting to be
  /// filled rather than a box with something in it.
  static const double _closedBorder = 0.4;

  /// The tell's wash, once the answer is known.
  static const double _tellTint = 0.12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Semantics(
      button: onInspect != null,
      label: revealed
          ? '${cue.label}. ${cue.text}${isTell ? ' The tell.' : ''}'
          : '${cue.label}. Not yet inspected.',
      hint: onInspect == null ? null : 'Inspects the sample',
      excludeSemantics: true,
      child: InkWell(
        onTap: onInspect,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.chrome),
            border: Border.all(
              color: isTell
                  ? mood.accent
                  : mood.rule.withValues(alpha: revealed ? 1 : _closedBorder),
            ),
            color: switch ((isTell, revealed)) {
              (true, _) => mood.accent.withValues(alpha: _tellTint),
              (false, true) => mood.surface,
              (false, false) => null,
            },
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _labelWidth,
                child: Text(
                  cue.label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isTell ? mood.accent : mood.inkMute,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  revealed ? cue.text : 'Tap to inspect',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: revealed ? mood.ink : mood.inkMute,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
