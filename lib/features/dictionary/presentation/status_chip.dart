import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_status_style.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The dot's diameter, and the ring's weight when it is not filled.
const double _markSize = 9;
const double _ringWidth = 1.5;

/// Wash behind the chip.
const double _chipWash = 0.12;

/// Where a term sits on the path — a mark and a word, never one alone.
///
/// The design pairs `StatusGlyph` with `StatusChipMini` (`dictionary.jsx:82`,
/// `:120`) where the app printed a bare string. The mark carries it at a
/// glance; the word carries it for anyone the colour does not reach, which is
/// why the two never separate — the three states differ by hue, and hue is the
/// one thing a screen reader cannot report.
class StatusChip extends StatelessWidget {
  /// Creates a [StatusChip].
  const StatusChip({required this.status, super.key});

  /// The state being shown.
  final DictionaryStatus status;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final colour = status.colorFrom(mood);

    return Semantics(
      label: status.label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colour.withValues(alpha: _chipWash),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _markSize,
              height: _markSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status.isFilled ? colour : null,
                border: status.isFilled
                    ? null
                    : Border.all(color: colour, width: _ringWidth),
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              status.label,
              style: AppText.micro(mood: mood, face: AppFace.mono),
            ),
          ],
        ),
      ),
    );
  }
}
