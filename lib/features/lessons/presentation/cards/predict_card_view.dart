import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The opening card: a framing paragraph and one binary guess.
///
/// Ungraded, and deliberately so — the guess is *held*, not marked. The card
/// knows the answer and does not say it; the lesson's closing `recall` card is
/// what resolves it, some minutes later. Marking the guess here would spend
/// the tension the whole lesson is built on, which is why this card exposes no
/// success callback at all: there is nothing to be right about yet.
class PredictCardView extends StatefulWidget {
  /// Creates a [PredictCardView].
  const PredictCardView({
    required this.card,
    required this.options,
    required this.onContinue,
    super.key,
  });

  /// The card's content.
  final PredictCard card;

  /// The two guesses, already in display order.
  final List<ChoiceOption> options;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  State<PredictCardView> createState() => _PredictCardViewState();
}

class _PredictCardViewState extends State<PredictCardView> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final card = widget.card;
    final latched = _selectedIndex != null;

    return CardShell(
      latched: latched,
      onContinue: widget.onContinue,
      label: card.label,
      title: card.title,
      children: [
        Text(card.body, style: theme.textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        Text(
          card.question,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ChoiceList(
          options: widget.options,
          selectedIndex: _selectedIndex,
          onSelect: (index) => setState(() => _selectedIndex = index),
          revealAnswer: false,
        ),
        if (latched) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            card.hold,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mood.inkMute,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
