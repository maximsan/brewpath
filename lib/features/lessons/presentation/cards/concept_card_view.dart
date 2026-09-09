import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/core/widgets/fill_slot.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_fill_bank.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_fill_state.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The commit affordance, before anything has been checked.
const String _checkLabel = 'Check answers';

/// The verdict when every blank was filled with its answer.
const String _allCorrect = 'All correct';

/// The teaching card: a fill-in-the-blank sentence, prose, and a meta table.
///
/// The words are picked from a bank **below** the sentence, all of them, and
/// then committed with *Check answers* — at which point each slot marks the
/// learner's own word. Still ungraded: nothing here reports success, because
/// mastery counts the cards a learner can get wrong and this teaches (#546).
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

  /// The blanks in the sentence, keyed by their position in it.
  Map<int, FillBlank> get _blanks => {
    for (var index = 0; index < widget.card.fill.length; index++)
      if (widget.card.fill[index] case final FillBlank blank) index: blank,
  };

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

    return CardShell(
      latched: _checked,
      onContinue: widget.onContinue,
      label: card.label,
      title: card.title,
      commit: CardCommit(
        label: _checkLabel,
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
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        for (final paragraph in card.paragraphs) ...[
          Text(paragraph, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (card.meta.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          _MetaTable(rows: card.meta),
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

/// The key/value pair table under a concept card's prose.
class _MetaTable extends StatelessWidget {
  const _MetaTable({required this.rows});

  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    row.first,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: mood.inkMute,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(row.last, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
