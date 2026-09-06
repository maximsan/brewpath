import 'package:brew_path/core/widgets/pick_card.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/dictionary/domain/vocab_providers.dart';
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What a learner has picked so far — the two choices travel together because
/// changing the deck can change which lengths are still honest.
typedef VocabChoice = ({VocabDeck deck, int length});

/// The drill's first screen: pick a deck, pick a length, start.
///
/// The lengths offered are only those the active pool can fill. That is not
/// politeness — offering *Deep 12* over a nine-term deck would either repeat
/// terms or quietly shorten the round, and both make the number on the button
/// a lie.
class VocabSetupView extends StatelessWidget {
  /// Creates a [VocabSetupView].
  const VocabSetupView({
    required this.pools,
    required this.choice,
    required this.onChoice,
    required this.onStart,
    super.key,
  });

  /// The tier-scoped pools both decks are drawn from.
  final VocabPools pools;

  /// The learner's current selection, already resolved against the pools.
  final VocabChoice choice;

  /// Called with the new selection.
  final ValueChanged<VocabChoice> onChoice;

  /// Deals the first round.
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final poolSize = pools.forDeck(choice.deck).length;
    final fits = vocabLengthsFor(poolSize);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(VocabCopy.title, style: AppText.display(mood: mood)),
            const SizedBox(height: AppSpacing.xs),
            Text(VocabCopy.setupBlurb, style: AppText.body(mood: mood)),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(VocabCopy.deckHeading),
            const SizedBox(height: AppSpacing.xs),
            _DeckCard(
              deck: VocabDeck.saved,
              choice: choice,
              size: pools.saved.length,
              onChoice: onChoice,
            ),
            const SizedBox(height: AppSpacing.xs),
            _DeckCard(
              deck: VocabDeck.all,
              choice: choice,
              size: pools.accessible.length,
              onChoice: onChoice,
              hasCourse: pools.hasCourse,
            ),
            const SizedBox(height: AppSpacing.xs),
            _DeckCard(
              deck: VocabDeck.misses,
              choice: choice,
              size: pools.missed.length,
              onChoice: onChoice,
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(VocabCopy.lengthHeading),
            const SizedBox(height: AppSpacing.xs),
            _Lengths(
              fits: fits,
              poolSize: poolSize,
              choice: choice,
              onChoice: onChoice,
            ),
            if (choice.deck != VocabDeck.all &&
                poolSize < vocabLengths.last) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                choice.deck == VocabDeck.misses
                    ? VocabCopy.longerMissRoundsHint
                    : VocabCopy.longerRoundsHint,
                style: AppText.support(mood: mood),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: VocabCopy.start, onPressed: onStart),
          ],
        ),
      ),
    );
  }
}

/// One deck row: its name, what it holds, and how many terms that is.
class _DeckCard extends StatelessWidget {
  const _DeckCard({
    required this.deck,
    required this.choice,
    required this.size,
    required this.onChoice,
    this.hasCourse = false,
  });

  final VocabDeck deck;
  final VocabChoice choice;
  final int size;
  final ValueChanged<VocabChoice> onChoice;

  /// Only the All deck reads this: its name is a claim about how much of the
  /// dictionary is in play, and the two tiers hold different amounts.
  final bool hasCourse;

  @override
  Widget build(BuildContext context) {
    final available = deck == VocabDeck.all || vocabDeckAvailable(size);
    // Calling a free learner's pool "the whole glossary" would be a claim
    // their own dictionary screen contradicts — it shows every entry to
    // everyone, and the drill reaches only part of it.
    final title = switch (deck) {
      VocabDeck.saved => VocabCopy.savedDeck,
      VocabDeck.all => hasCourse ? VocabCopy.allDeck : VocabCopy.yourTermsDeck,
      VocabDeck.misses => VocabCopy.missesDeck,
    };
    final note = switch (deck) {
      VocabDeck.saved =>
        available ? VocabCopy.savedDeckReady : VocabCopy.savedDeckShort,
      VocabDeck.all =>
        hasCourse ? VocabCopy.allDeckNote : VocabCopy.yourTermsNote,
      VocabDeck.misses =>
        available ? VocabCopy.missesDeckReady : VocabCopy.missesDeckShort,
    };

    return PickCard(
      title: '$title · $size',
      description: note,
      selected: choice.deck == deck,
      onTap: available
          ? () => onChoice((deck: deck, length: choice.length))
          : null,
    );
  }
}

/// The three length cards, or the whole-deck card when none of them fits.
class _Lengths extends StatelessWidget {
  const _Lengths({
    required this.fits,
    required this.poolSize,
    required this.choice,
    required this.onChoice,
  });

  final List<int> fits;
  final int poolSize;
  final VocabChoice choice;
  final ValueChanged<VocabChoice> onChoice;

  @override
  Widget build(BuildContext context) {
    if (fits.isEmpty) {
      return PickCard(
        title: '$poolSize',
        description: VocabCopy.wholeDeck,
        selected: true,
        onTap: null,
      );
    }

    final active = resolveVocabLength(
      chosen: choice.length,
      poolSize: poolSize,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final length in vocabLengths)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: PickCard(
              title: '$length',
              description: VocabCopy.lengthNames[length] ?? '',
              selected: active == length,
              onTap: fits.contains(length)
                  ? () => onChoice((deck: choice.deck, length: length))
                  : null,
            ),
          ),
      ],
    );
  }
}
