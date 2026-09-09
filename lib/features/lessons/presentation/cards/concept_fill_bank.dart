import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_option_tile.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_tints.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_fill_state.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The words on offer for a concept sentence, one group per blank.
///
/// Below the sentence rather than inside it, as the design has it: a blank in
/// the prose is a slot waiting, and the words to put in it are a bank. Each
/// group carries the blank's own authored label, which the app dropped for as
/// long as the options sat in the sentence.
class ConceptFillBank extends StatelessWidget {
  /// Creates a [ConceptFillBank].
  const ConceptFillBank({
    required this.blanks,
    required this.picks,
    required this.checked,
    required this.onPick,
    super.key,
  });

  /// Each blank, keyed by its position in the sentence.
  final Map<int, FillBlank> blanks;

  /// Position → the word picked for it.
  final Map<int, String> picks;

  /// Whether the card has been checked, which is what marks the options.
  final bool checked;

  /// Called with the position and the word tapped.
  final void Function(int position, String option) onPick;

  @override
  Widget build(BuildContext context) {
    final entries = blanks.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, entry) in entries.indexed) ...[
          if (index > 0) SizedBox(height: OffTokens.fillGroupGap.value),
          _Group(
            blank: entry.value,
            pick: picks[entry.key],
            checked: checked,
            onPick: (option) => onPick(entry.key, option),
          ),
        ],
      ],
    );
  }
}

/// One blank's label and the words on offer for it.
class _Group extends StatelessWidget {
  const _Group({
    required this.blank,
    required this.pick,
    required this.checked,
    required this.onPick,
  });

  final FillBlank blank;
  final String? pick;
  final bool checked;
  final ValueChanged<String> onPick;

  /// One word on offer, marked from the pick and whether the card is solved.
  Widget _option(String option, VoidCallback pick) {
    final mark = ConceptOptionMark.of(
      option: option,
      answer: blank.answer,
      pick: this.pick,
      checked: checked,
    );
    return _Option(
      option: option,
      mark: mark,
      faded: checked && mark == ConceptOptionMark.none,
      onTap: checked ? null : pick,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (blank.label.isNotEmpty) ...[
          SmallcapsLabel(blank.label),
          const SizedBox(height: AppSpacing.xs),
        ],
        Row(
          children: [
            for (final (index, option) in blank.options.indexed) ...[
              if (index > 0) SizedBox(width: OffTokens.fillOptionGap.value),
              Expanded(
                child: _option(option, () => onPick(option)),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// One word on offer, in the frame every picking card draws options in.
class _Option extends StatelessWidget {
  const _Option({
    required this.option,
    required this.mark,
    required this.faded,
    required this.onTap,
  });

  final String option;
  final ConceptOptionMark mark;

  /// Whether the card is solved and this word means nothing either way.
  final bool faded;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final tone = switch (mark) {
      ConceptOptionMark.none => null,
      ConceptOptionMark.picked => mood.accent,
      ConceptOptionMark.right => mood.sage,
      ConceptOptionMark.wrong => mood.berry,
    };
    // Three washes, as the design writes them: 12% behind the answer, 8%
    // behind a wrong pick, 10% behind a pick nothing has judged yet.
    final wash = switch (mark) {
      ConceptOptionMark.wrong => CardTints.wrongWash,
      ConceptOptionMark.picked => CardTints.pickedWash,
      _ => CardTints.wash,
    };

    final tile = CardOptionTile(
      semanticsLabel: _spoken,
      onTap: onTap,
      borderColor: tone,
      fillColor: tone?.withValues(alpha: wash),
      // The word stays ink in every state: the design colours the border and
      // the wash, never the option's own text.
      child: Text(
        option,
        textAlign: TextAlign.center,
        style: AppText.body(color: mood.ink),
      ),
    );

    // Once solved, a word that was neither picked nor the answer steps back.
    if (!faded) return tile;
    return Opacity(opacity: CardTints.solvedOpacity, child: tile);
  }

  /// What the row says aloud — the word, and what became of it. A colour is
  /// the only thing distinguishing a marked option on screen.
  String get _spoken => switch (mark) {
    ConceptOptionMark.none => option,
    ConceptOptionMark.picked => '$option, chosen',
    ConceptOptionMark.right => '$option, the answer',
    ConceptOptionMark.wrong => '$option, not the answer',
  };
}
