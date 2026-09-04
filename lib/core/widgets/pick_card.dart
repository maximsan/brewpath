import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Bordered selectable tile — the design's `.pick-card`: title and
/// description on the left, a circular indicator on the right that fills when
/// selected.
///
/// Built for the onboarding goal and brewer screens, which ADR-0010 moved to
/// v2 and #407 parked; the vocab game's deck picker is the live caller.
class PickCard extends StatelessWidget {
  /// Creates a [PickCard].
  const PickCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// Card title (the option name).
  final String title;

  /// Supporting description shown under the title.
  final String description;

  /// Whether this card is the current selection.
  final bool selected;

  /// Called when the card is tapped. **Null disables the card** — which is
  /// what a caller passes for an option the rules cannot offer, because an
  /// empty callback leaves the row announced as a button that does nothing.
  final VoidCallback? onTap;

  /// The design's wash over a card the learner cannot choose
  /// (`dictionary-extras.jsx:367`'s `dim()`).
  static const double _unavailableOpacity = 0.45;

  /// Whether to draw this card as unavailable.
  ///
  /// Untappable is **not** the same as unavailable, and the design draws the
  /// difference: it dims a deck below its minimum and a round length the pool
  /// cannot fill, but leaves the whole-deck card — `pick-card selected` at
  /// `cursor: default` — at full strength. A card that is already the answer
  /// is a statement, not a refused choice, so only an unselected card with
  /// nowhere to go is dimmed.
  bool get _isUnavailable => onTap == null && !selected;

  @override
  Widget build(BuildContext context) {
    final card = _card(context);
    return _isUnavailable
        ? Opacity(opacity: _unavailableOpacity, child: card)
        : card;
  }

  Widget _card(BuildContext context) {
    final mood = context.mood;
    final borderColor = selected ? mood.accent : mood.rule;
    return Material(
      color: mood.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(AppRadii.editorial),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.heading(mood: mood),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(description, style: AppText.support(mood: mood)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PickIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickIndicator extends StatelessWidget {
  const _PickIndicator({required this.selected});

  static const double _size = 28;
  static const double _innerDotSize = 14;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? mood.accent : mood.rule),
      ),
      child: selected
          ? Center(
              child: Container(
                width: _innerDotSize,
                height: _innerDotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mood.accent,
                ),
              ),
            )
          : null,
    );
  }
}
