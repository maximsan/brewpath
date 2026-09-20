import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// Bordered selectable tile — the design's `.pick-card`: a two-column grid of
/// title and description against whatever the caller puts on the right.
///
/// Selection is the design system's *"Selection = double stroke … never a
/// fill"*: the edge turns accent and reads as two, and nothing else moves.
class PickCard extends StatelessWidget {
  /// Creates a [PickCard] — title and description left, [trailing] right.
  const PickCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.trailing,
    super.key,
  }) : _centred = false,
       titleFace = null;

  /// Creates a centred [PickCard] — title over description, both centred, in
  /// the tighter box the design gives a card that holds a figure.
  const PickCard.centred({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.titleFace,
    super.key,
  }) : _centred = true,
       trailing = null;

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

  /// What sits in the right column — a count, a mark, nothing.
  final Widget? trailing;

  /// The face a centred card sets its title in, where the design asks for one
  /// the step does not carry: the whole-deck card's figure is `pc-title
  /// ff-mono` while the round lengths beside it stay on the display face.
  final AppFace? titleFace;

  /// Whether the card is laid out centred rather than as two columns.
  final bool _centred;

  /// The design's wash over a card the learner cannot choose — its `dim()`.
  static const double _unavailableOpacity = 0.45;

  /// What a selected edge reads as: the design's `1px` border plus its
  /// `inset 0 0 0 1px` in the same colour.
  static const double _selectedStroke = 2;

  /// Whether to draw this card as unavailable.
  ///
  /// Untappable is **not** unavailable: the design dims a deck below its
  /// minimum, but leaves the whole-deck card — `pick-card selected` at
  /// `cursor: default` — at full strength, because a card that is already the
  /// answer states what you get rather than refusing a choice.
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
    return Material(
      color: mood.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: _centred
              ? const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.xs,
                )
              : EdgeInsets.all(OffTokens.pickCardPadding.value),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? mood.accent : mood.rule,
              width: selected ? _selectedStroke : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadii.chrome),
          ),
          child: _centred ? _centredBody(mood) : _rowBody(mood),
        ),
      ),
    );
  }

  Widget _rowBody(MoodColors mood) => Row(
    children: [
      Expanded(child: _text(mood, AppText.heading(mood: mood))),
      if (trailing case final trailing?) ...[
        const SizedBox(width: AppSpacing.md),
        trailing,
      ],
    ],
  );

  Widget _centredBody(MoodColors mood) => _text(
    mood,
    AppText.title(mood: mood, face: titleFace),
    align: TextAlign.center,
  );

  Widget _text(
    MoodColors mood,
    TextStyle titleStyle, {
    TextAlign align = TextAlign.start,
  }) => Column(
    crossAxisAlignment: align == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    children: [
      Text(title, style: titleStyle, textAlign: align),
      const SizedBox(height: AppSpacing.xxs),
      Text(
        description,
        style: AppText.support(mood: mood),
        textAlign: align,
      ),
    ],
  );
}
