import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The teaching card: a fill-in-the-blank sentence, prose, and a meta table.
///
/// Ungraded, and the sentence is rigged to stay that way — **a blank resolves
/// to its authored answer whichever word is tapped**, so the learner always
/// leaves holding the correct sentence. The choice is a moment of commitment,
/// not a test, which is why nothing here reports success.
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
  /// Blank position → the option index tapped. A filled blank never reopens.
  final Map<int, int> _filled = {};

  List<int> get _blankPositions => [
    for (var index = 0; index < widget.card.fill.length; index++)
      if (widget.card.fill[index] is FillBlank) index,
  ];

  bool get _allFilled => _filled.length == _blankPositions.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = widget.card;

    return CardShell(
      latched: _allFilled,
      onContinue: widget.onContinue,
      label: card.label,
      title: card.title,
      children: [
        _FillSentence(
          parts: card.fill,
          filled: _filled,
          onFill: (position, choice) =>
              setState(() => _filled[position] = choice),
        ),
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

/// The sentence, laid out as wrapping inline runs so a blank sits in the text
/// rather than beside it.
class _FillSentence extends StatelessWidget {
  const _FillSentence({
    required this.parts,
    required this.filled,
    required this.onFill,
  });

  final List<ConceptFillPart> parts;
  final Map<int, int> filled;
  final void Function(int position, int choice) onFill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var position = 0; position < parts.length; position++)
          switch (parts[position]) {
            FillLiteral(:final text) => Text(
              text,
              style: theme.textTheme.titleMedium,
            ),
            FillBlank(:final answer, :final options) => _Blank(
              answer: answer,
              options: options,
              chosen: filled[position],
              onChoose: (choice) => onFill(position, choice),
            ),
          },
      ],
    );
  }
}

/// One blank: two words to tap, then the authored answer, locked.
class _Blank extends StatelessWidget {
  const _Blank({
    required this.answer,
    required this.options,
    required this.chosen,
    required this.onChoose,
  });

  final String answer;
  final List<String> options;
  final int? chosen;
  final void Function(int choice) onChoose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    if (chosen != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: mood.sage.withValues(alpha: _filledTint),
          borderRadius: BorderRadius.circular(AppRadii.chrome),
        ),
        child: Text(
          answer,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < options.length; index++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: OutlinedButton(
              onPressed: () => onChoose(index),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                side: BorderSide(color: mood.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.chrome),
                ),
              ),
              child: Text(options[index]),
            ),
          ),
      ],
    );
  }
}

/// Tint strength behind a resolved blank.
const double _filledTint = 0.22;

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
                      fontWeight: FontWeight.w600,
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
