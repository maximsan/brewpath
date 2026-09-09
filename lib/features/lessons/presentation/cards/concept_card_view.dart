import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/core/widgets/fill_slot.dart';
import 'package:brew_path/features/lessons/domain/concept_card_parts.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_fill_bank.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_fill_state.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_meta_table.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The verdict when every blank was filled with its answer.
const String _allCorrect = 'All correct';

/// The teaching card: a fill-in-the-blank sentence, prose, and a meta table.
///
/// The words are picked from a bank **below** the sentence and committed with
/// *Check answers*, at which point each slot marks the learner's own word,
/// right or wrong (ADR-0023). Still ungraded: nothing here reports success,
/// because mastery counts the cards a learner can get wrong and this teaches.
class ConceptCardView extends StatefulWidget {
  /// Creates a [ConceptCardView].
  const ConceptCardView({
    required this.card,
    required this.onContinue,
    super.key,
  });

  /// The card's content.
  final ConceptCard card;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  State<ConceptCardView> createState() => _ConceptCardViewState();
}

class _ConceptCardViewState extends State<ConceptCardView> {
  /// Blank position → the word picked for it. Changeable until committed.
  final Map<int, String> _picks = {};
  bool _checked = false;

  Map<int, FillBlank> get _blanks => blanksIn(widget.card);

  bool get _allPicked => _picks.length == _blanks.length;

  bool get _allRight => _blanks.entries.every(
    (blank) => _picks[blank.key] == blank.value.answer,
  );

  void _pick(int position, String option) {
    if (_checked) return;
    setState(() => _picks[position] = option);
  }

  void _check() {
    if (_checked || !_allPicked) return;
    setState(() => _checked = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = widget.card;

    // A sentence authored with no blank has nothing to commit, so it reads
    // like the prose it is: latched on arrival, no Check answers. Every
    // authored concept card has one, but the shape is representable.
    final nothingToFill = _blanks.isEmpty;

    return CardShell(
      latched: nothingToFill || _checked,
      onContinue: widget.onContinue,
      label: card.label,
      title: card.title,
      commit: nothingToFill
          ? null
          : CardCommit(
              label: AppLabels.checkAnswers,
              onCommit: _allPicked ? _check : null,
            ),
      children: [
        _FillSentence(parts: card.fill, picks: _picks, checked: _checked),
        const SizedBox(height: AppSpacing.lg),
        ConceptFillBank(
          blanks: _blanks,
          picks: _picks,
          checked: _checked,
          onPick: _pick,
        ),
        if (_checked) ...[
          const SizedBox(height: AppSpacing.lg),
          AnswerFeedback(
            verdict: _allRight ? _allCorrect : notQuiteVerdict,
            outcome: _allRight ? Verdict.right : Verdict.wrong,
            // The design hands the block the card's *second* paragraph: a
            // reply to a checked answer rather than prose.
            explanation: supportIn(card),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        for (final paragraph in proseIn(card)) ...[
          Text(paragraph, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (card.meta.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          ConceptMetaTable(rows: card.meta),
        ],
      ],
    );
  }
}

/// The sentence, with a slot standing in for each blank.
///
/// One flowing paragraph rather than a `Wrap` of separate `Text` runs: a wrap
/// breaks between runs, so a literal could only ever break at its own edges
/// and the prose read as loose columns.
class _FillSentence extends StatelessWidget {
  const _FillSentence({
    required this.parts,
    required this.picks,
    required this.checked,
  });

  final List<ConceptFillPart> parts;
  final Map<int, String> picks;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text.rich(
      TextSpan(
        style: theme.textTheme.titleMedium,
        children: [
          for (var position = 0; position < parts.length; position++)
            switch (parts[position]) {
              FillLiteral(:final text) => TextSpan(text: text),
              FillBlank(:final answer) => fillSlotSpan(
                FillSlot(
                  word: picks[position],
                  state: conceptFillState(
                    pick: picks[position],
                    answer: answer,
                    checked: checked,
                  ),
                ),
              ),
            },
        ],
      ),
    );
  }
}
