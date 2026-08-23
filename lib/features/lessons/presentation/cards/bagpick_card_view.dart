import 'package:brew_path/features/lessons/presentation/cards/bagpick_cue_row.dart';
import 'package:brew_path/features/lessons/presentation/cards/bagpick_process.dart';
import 'package:brew_path/features/lessons/presentation/cards/bagpick_sample.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Blind bag: an unlabelled lot, a sample of three seeds, and three things
/// worth inspecting. Call the process from the look alone.
///
/// Unlike its graded siblings this is not a picker with decoration. The
/// **inspection is the card**: each cue is uncovered by a tap, and a learner
/// who commits without looking has guessed rather than read. Committing
/// reveals every cue at once and marks the one that was the real tell, so the
/// feedback teaches what should have been noticed rather than only whether the
/// answer was right.
class BagpickCardView extends StatefulWidget {
  /// Creates a [BagpickCardView].
  const BagpickCardView({
    required this.card,
    required this.options,
    required this.onSolved,
    required this.onContinue,
    super.key,
  });

  /// The round being played.
  final BagpickCard card;

  /// The process keys in display order, already seeded.
  final List<String> options;

  /// Fired once, only if the committed call was right.
  final CardSolved onSolved;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  State<BagpickCardView> createState() => _BagpickCardViewState();
}

class _BagpickCardViewState extends State<BagpickCardView> {
  final Set<String> _inspected = {};
  String? _called;

  bool get _latched => _called != null;
  bool get _wasCorrect => _called == widget.card.answer;

  void _inspect(String cueId) {
    if (_latched) return;
    setState(() => _inspected.add(cueId));
  }

  void _call(int index) {
    // Latch before the callback: the host may rebuild synchronously on the
    // success signal, and a card that had not yet latched would take a second
    // tap. Same rule as `GradedPicker`.
    final choice = widget.options[index];
    setState(() => _called = choice);
    if (choice == widget.card.answer) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final theme = Theme.of(context);

    return CardShell(
      latched: _latched,
      onContinue: widget.onContinue,
      label: 'BLIND BAG · READ THE BEANS',
      children: [
        BagpickSample(
          card: card,
          revealedProcess: _latched ? card.answer : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          card.prompt,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final cue in card.cues) ...[
          BagpickCueRow(
            cue: cue,
            // Committing opens everything: the learner has earned the whole
            // reading, including the cues they never thought to check.
            revealed: _latched || _inspected.contains(cue.id),
            isTell: _latched && card.tell == cue.id,
            onInspect: _latched ? null : () => _inspect(cue.id),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.xs),
        ChoiceList(
          options: [
            for (final option in widget.options)
              ChoiceOption(
                text: processLabel(option),
                isCorrect: option == card.answer,
              ),
          ],
          selectedIndex: _called == null
              ? null
              : widget.options.indexOf(_called!),
          onSelect: _call,
          revealAnswer: true,
        ),
        if (_latched) ..._verdict(theme, context.mood, card),
      ],
    );
  }

  /// What the call was worth, and why.
  ///
  /// The verdict line is coloured by outcome, as the design's own feedback
  /// block is: right and wrong reading the same weight of type differ only in
  /// their wording, which a learner scanning back over a run will not catch.
  List<Widget> _verdict(ThemeData theme, MoodColors mood, BagpickCard card) => [
    const SizedBox(height: AppSpacing.xs),
    Text(
      _wasCorrect ? 'Called it.' : '${processLabel(card.answer)}, actually.',
      style: theme.textTheme.titleSmall?.copyWith(
        color: _wasCorrect ? mood.sage : mood.warn,
        fontWeight: FontWeight.w600,
      ),
    ),
    const SizedBox(height: AppSpacing.xxs),
    Text(card.explanation, style: theme.textTheme.bodyMedium),
  ];
}
