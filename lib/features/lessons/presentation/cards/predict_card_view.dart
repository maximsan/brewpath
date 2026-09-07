import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/lessons/domain/held_guess.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/pick_tile_row.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The opening card: a framing paragraph and one binary guess, ungraded on
/// purpose — the guess is *held*, and the closing `recall` card resolves it
/// minutes later. Marking it here would spend the tension the lesson is built
/// on, which is why the card reports no success at all. Two tiles side by side
/// rather than a row list, and changeable up to Continue, because nothing is
/// scored and so nothing is protected by latching.
class PredictCardView extends StatefulWidget {
  /// Creates a [PredictCardView].
  const PredictCardView({
    required this.card,
    required this.options,
    required this.onContinue,
    this.onGuess,
    super.key,
  });

  /// The card's content.
  final PredictCard card;

  /// The two guesses, already in display order.
  final List<String> options;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  /// Fired with each guess, including a changed one — the guess stays editable
  /// until Continue, so the last one taken is what the recall card resolves.
  final ValueChanged<HeldGuess>? onGuess;

  @override
  State<PredictCardView> createState() => _PredictCardViewState();
}

class _PredictCardViewState extends State<PredictCardView> {
  int? _selectedIndex;

  void _guess(int index) {
    setState(() => _selectedIndex = index);
    widget.onGuess?.call(
      HeldGuess(pick: widget.options[index], answer: widget.card.answer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        PickTileRow(
          options: widget.options,
          chosenIndex: _selectedIndex,
          onChoose: _guess,
        ),
        if (_selectedIndex case final chosen?) ...[
          const SizedBox(height: AppSpacing.md),
          AnswerFeedback(
            verdict: 'Your guess · ${widget.options[chosen]}',
            outcome: Verdict.held,
            explanation: card.hold,
            placement: VerdictPlacement.heldGuess,
          ),
        ],
      ],
    );
  }
}
