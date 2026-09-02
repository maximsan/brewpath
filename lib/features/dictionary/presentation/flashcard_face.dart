import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_category_mark.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// One side of a flashcard: its category, which side this is, the content, and
/// what a tap does next.
///
/// Both faces are the same frame so the flip does not resize the card mid-turn.
/// Only the tint differs — the front carries a wash of accent, the back is
/// plain surface, which is how the design says *this side is the question*
/// without a word.
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
  final DictionaryCategoryMark category;

  /// What this side is — the term, or the definition.
  final String label;

  /// The line at the foot: what a tap will do.
  final String foot;

  /// Whether this is the question side, which carries the accent wash.
  final bool isFront;

  /// The face's content, centred in it.
  final Widget child;

  /// The design's `borderRadius: 20` — inside `AppRadii.chrome`'s documented
  /// 12–20 slack, at the loose end because this card *is* the screen.
  static const double _radius = 20;

  /// The design's `CatGlyph size={15}` on a face.
  static const double _markSize = 15;

  /// The front's wash: `color-mix(… accent 11%, surface)` fading to plain
  /// surface by `64%` along the design's `158deg` sweep.
  static const double _washStrength = 0.11;
  static const double _washEnd = 0.64;

  /// And its border — `color-mix(… accent 22%, rule)`.
  static const double _edgeStrength = 0.22;

  /// `158deg`, which sweeps from the top-left corner toward the lower right.
  static const Alignment _washFrom = Alignment.topLeft;
  static const Alignment _washTo = Alignment.bottomRight;

  /// The design's `boxShadow: 0 16px 36px rgba(0,0,0,0.18)` — what makes the
  /// card sit *above* the page rather than be drawn on it.
  static const List<BoxShadow> _lift = [
    BoxShadow(color: Color(0x2E000000), blurRadius: 36, offset: Offset(0, 16)),
  ];

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isFront ? null : mood.surface,
        gradient: isFront ? _wash(mood) : null,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: isFront ? _edge(mood) : mood.rule),
        boxShadow: _lift,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: OffTokens.flashcardFacePadding.value,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: CategoryKicker(category: category, size: _markSize),
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

  LinearGradient _wash(MoodColors mood) => LinearGradient(
    begin: _washFrom,
    end: _washTo,
    colors: [
      Color.alphaBlend(
        mood.accent.withValues(alpha: _washStrength),
        mood.surface,
      ),
      mood.surface,
    ],
    stops: const [0, _washEnd],
  );

  Color _edge(MoodColors mood) => Color.alphaBlend(
    mood.accent.withValues(alpha: _edgeStrength),
    mood.rule,
  );
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

  /// The term's category.
  final DictionaryCategoryMark category;

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

  /// The term's category.
  final DictionaryCategoryMark category;

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
