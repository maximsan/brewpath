import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One side of a flashcard: a label, the content, and what a tap does next.
///
/// Both faces are the same frame so the flip does not resize the card
/// mid-turn. Only the tint differs — the front carries a wash of accent, the
/// back is plain surface, which is the design's way of saying *this side is
/// the question* without a word (`dictionary-extras.jsx:193-201`).
class FlashcardFace extends StatelessWidget {
  /// Creates a [FlashcardFace].
  const FlashcardFace({
    required this.category,
    required this.label,
    required this.foot,
    required this.isFront,
    required this.child,
    super.key,
  });

  /// The category the term sits in, as its kicker.
  final String category;

  /// What this side is — the term, or the definition.
  final String label;

  /// The line at the foot: what a tap will do.
  final String foot;

  /// Whether this is the question side, which carries the accent wash.
  final bool isFront;

  /// The face's content, centred in it.
  final Widget child;

  /// The design's `borderRadius: 20` on the card.
  static const double _radius = 20;

  /// The design's `padding: '26px 24px'`.
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.gutter,
    vertical: 26,
  );

  /// How much accent the front's wash carries — the design's
  /// `color-mix(… accent 11%, surface)`.
  static const double _frontWash = 0.11;

  /// And how much its border carries — `… accent 22%, rule`.
  static const double _frontEdge = 0.22;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isFront
            ? Color.alphaBlend(
                mood.accent.withValues(alpha: _frontWash),
                mood.surface,
              )
            : mood.surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: isFront
              ? Color.alphaBlend(
                  mood.accent.withValues(alpha: _frontEdge),
                  mood.rule,
                )
              : mood.rule,
        ),
      ),
      child: Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SmallcapsLabel(category, color: mood.accent),
                ),
                const SizedBox(width: AppSpacing.xs),
                SmallcapsLabel(label),
              ],
            ),
            Expanded(child: Center(child: child)),
            Text(
              foot.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppText.micro(mood: mood),
            ),
          ],
        ),
      ),
    );
  }
}

/// The front: the word, and how to say it.
class FlashcardFront extends StatelessWidget {
  /// Creates a [FlashcardFront].
  const FlashcardFront({
    required this.category,
    required this.term,
    required this.pronunciation,
    super.key,
  });

  /// The term's category label.
  final String category;

  /// The word itself.
  final String term;

  /// Its respelling, when the bank carries one.
  final String? pronunciation;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return FlashcardFace(
      category: category,
      label: FlashcardsCopy.front,
      foot: FlashcardsCopy.tapToReveal,
      isFront: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            term,
            textAlign: TextAlign.center,
            style: AppText.display(mood: mood),
          ),
          if (pronunciation != null) ...[
            const SizedBox(height: AppSpacing.base),
            Text(
              pronunciation!,
              style: AppText.label(mood: mood, face: AppFace.mono),
            ),
          ],
        ],
      ),
    );
  }
}

/// The back: the word again, and what it means.
///
/// The term is repeated here on purpose — a definition alone, arrived at by a
/// flip, leaves the learner checking which card they are on.
class FlashcardBack extends StatelessWidget {
  /// Creates a [FlashcardBack].
  const FlashcardBack({
    required this.category,
    required this.term,
    required this.definition,
    super.key,
  });

  /// The term's category label.
  final String category;

  /// The word itself.
  final String term;

  /// Its one-line explanation.
  final String definition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return FlashcardFace(
      category: category,
      label: FlashcardsCopy.back,
      foot: FlashcardsCopy.tapToSeeTerm,
      isFront: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(term, style: AppText.title(mood: mood)),
          const SizedBox(height: AppSpacing.base),
          Text(
            definition,
            style: theme.textTheme.bodyMedium?.copyWith(color: mood.ink),
          ),
        ],
      ),
    );
  }
}
