import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What a finished drill scored, and the words that go under it.
///
/// The bands are shared; the words are the caller's, so a mini-game and a
/// vocab drill do not read as though one wrote the other.
typedef DrillOutcome = ({
  int score,
  int total,
  String encouragement,
  bool celebratory,
});

/// One of the two ways out of a results screen.
typedef DrillAction = ({String label, VoidCallback onPressed});

/// The end of a run: what was scored, a word about it, and the two ways out.
///
/// One results screen for every drill in the app, so finishing cannot come to
/// mean two different things — the roast meter's consolidation (#381) a layer
/// up.
///
/// Nothing here is written anywhere: the score lives as long as this screen
/// does, and the *fact* that a run finished is recorded by the player.
class DrillResultsView extends StatelessWidget {
  /// A drill that was **scored**: so many right out of so many asked.
  const DrillResultsView({
    required DrillOutcome outcome,
    required this.primary,
    required this.secondary,
    super.key,
  }) : _headline = null,
       _note = null,
       _message = null,
       _outcome = outcome;

  /// A drill that was **counted**, not scored — [headline] things done, with
  /// [note] naming what they were.
  ///
  /// Flashcards is the case: a review teaches and never marks, so there is no
  /// score to report and `12 / 12` would invent one. The chassis is the same;
  /// what changes is that the big value stands alone under a word.
  const DrillResultsView.counted({
    required String headline,
    required String note,
    required String message,
    required this.primary,
    required this.secondary,
    super.key,
  }) : _headline = headline,
       _note = note,
       _message = message,
       _outcome = null;

  /// The score and the words for it, on a scored drill.
  final DrillOutcome? _outcome;

  /// The value, the word under it and the line below, on a counted one.
  final String? _headline;
  final String? _note;
  final String? _message;

  /// The filled action: running it back.
  final DrillAction primary;

  /// The quieter way out.
  final DrillAction secondary;

  static const double _companionSize = 120;

  /// Nothing to celebrate *above* on a counted drill: finishing a deck is
  /// finishing a deck, so it takes the lesson-sized pose either way.
  bool get _celebratory => _outcome?.celebratory ?? false;

  /// The big value.
  String get _value {
    final outcome = _outcome;
    return _headline ?? '${outcome!.score} / ${outcome.total}';
  }

  /// The line under it.
  String get _line => _message ?? _outcome!.encouragement;

  /// One sentence, so a reader gets the result rather than three fragments.
  String get _announcement => _outcome == null
      ? '$_value $_note. $_line'
      : 'Run complete. You scored ${_outcome.score} '
            'out of ${_outcome.total}. ${_outcome.encouragement}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Semantics(
                  label: _announcement,
                  excludeSemantics: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The score decides the pose: the module-sized
                      // celebration at or above the mark, the lesson-sized one
                      // below. No line — the encouragement below says it.
                      CompanionCelebration(
                        reaction: _celebratory
                            ? CompanionReaction.moduleComplete
                            : CompanionReaction.lessonComplete,
                        size: _companionSize,
                        builder: (context, companion, line) => companion,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        _value,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: mood.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (_note != null) ...[
                        SmallcapsLabel(_note),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      Text(
                        _line,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: mood.inkMute,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                PrimaryButton(
                  label: primary.label,
                  onPressed: primary.onPressed,
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: secondary.onPressed,
                    child: Text(secondary.label),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
