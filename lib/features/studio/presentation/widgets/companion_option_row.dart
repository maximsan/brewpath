import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/studio/domain/grove_swatch.dart';
import 'package:brew_path/shared/models/content/companion_option.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Wash behind a picked option — the design's `accent 12%` on this screen.
///
/// **Not the grove's ten.** `GroveSelection` records its own recipe for the
/// plant rows and light pills; the wardrobe states twelve, and its picked
/// label takes the accent where the grove's does not. Two screens, two
/// recipes, both quoted from the design. Recorded so neither is levelled.
const double _pickedWash = 0.12;

/// The colour dot on a roast, at the design's 16px.
const double _swatchSize = 16;

/// Alpha on the swatch's hairline, the design's `ink 18%`.
const double _swatchEdgeAlpha = 0.18;

/// The design's minimum for this control, which is also the platform's.
const double _minTarget = 44;

/// One axis of Roasty's outfit: its name, and the picks laid out in a row.
///
/// Scrolls sideways rather than wrapping — the design gives each axis a single
/// line, so five gear options stay one gesture rather than becoming two rows
/// that push the next axis off the screen.
class CompanionOptionRow extends StatelessWidget {
  /// Creates a [CompanionOptionRow].
  const CompanionOptionRow({
    required this.label,
    required this.options,
    required this.value,
    required this.onSelect,
    super.key,
  });

  /// What the axis is called, in smallcaps above the row.
  final String label;

  /// The picks on offer, in the bank's order.
  final List<CompanionOption> options;

  /// The id currently drawn on the preview.
  final String value;

  /// Picks one.
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmallcapsLabel(label, isHeader: true),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in options) ...[
                  _OptionPill(
                    option: option,
                    selected: option.id == value,
                    onSelect: () => onSelect(option.id),
                  ),
                  if (option != options.last)
                    const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionPill extends StatelessWidget {
  const _OptionPill({
    required this.option,
    required this.selected,
    required this.onSelect,
  });

  final CompanionOption option;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final swatch = _swatch;

    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      excludeSemantics: true,
      child: Material(
        color: selected ? mood.accent.withValues(alpha: _pickedWash) : null,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onSelect,
          customBorder: const StadiumBorder(),
          child: Container(
            constraints: const BoxConstraints(minHeight: _minTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: ShapeDecoration(
              shape: StadiumBorder(
                side: BorderSide(color: selected ? mood.accent : mood.rule),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (swatch != null) ...[
                  Container(
                    width: _swatchSize,
                    height: _swatchSize,
                    decoration: BoxDecoration(
                      color: swatch,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: mood.ink.withValues(alpha: _swatchEdgeAlpha),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  option.label,
                  style: AppText.support(
                    mood: mood,
                    face: selected ? AppFace.control : AppFace.ui,
                    color: selected ? mood.accent : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The roast's colour dot; every other axis is shown by its drawing.
  Color? get _swatch {
    final authored = option.swatch;
    return authored == null ? null : swatchColor(authored);
  }
}
