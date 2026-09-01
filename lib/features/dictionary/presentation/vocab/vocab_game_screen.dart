import 'dart:async';

import 'package:brew_path/app/day_surfaces.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/drill_bands.dart';
import 'package:brew_path/core/widgets/drill_results_view.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/features/dictionary/domain/vocab_completion.dart';
import 'package:brew_path/features/dictionary/domain/vocab_providers.dart';
import 'package:brew_path/features/dictionary/domain/vocab_round.dart';
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_question_view.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_setup_view.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_teaching_view.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// *Guess the term* — setup, the rounds, then the score.
///
/// The whole drill is three states of one screen rather than three routes: the
/// score never outlives the run, so routing to it would mean handing a number
/// to the router only to hand it straight back — the same shape the mini-game
/// player takes.
///
/// The drill holds a single seed, minted when the rounds are dealt and
/// re-minted by Play again, which decides the terms asked, the wrong answers
/// offered, and the order of the four options. Nothing about it is persisted.
class VocabGameScreen extends ConsumerStatefulWidget {
  /// Creates a [VocabGameScreen].
  const VocabGameScreen({super.key});

  @override
  ConsumerState<VocabGameScreen> createState() => _VocabGameScreenState();
}

class _VocabGameScreenState extends ConsumerState<VocabGameScreen> {
  /// Null until the learner picks, so the default can follow the pools —
  /// Saved when there is enough on it, All otherwise.
  VocabDeck? _deck;
  int _length = vocabLengths.first;

  List<VocabRound> _rounds = const [];
  int _index = 0;
  int? _picked;
  int _score = 0;
  bool _recorded = false;

  /// Whether the rounds have been dealt. A drill with no rounds is at setup.
  bool get _playing => _rounds.isNotEmpty;

  VocabChoice _choiceFor(VocabPools pools) => (
    deck: resolveVocabDeck(
      chosen:
          _deck ??
          (vocabDeckAvailable(pools.saved.length)
              ? VocabDeck.saved
              : VocabDeck.all),
      savedPoolSize: pools.saved.length,
    ),
    length: _length,
  );

  void _start(VocabPools pools) {
    final choice = _choiceFor(pools);
    final pool = pools.forDeck(choice.deck);
    final seed = mintVocabSeed();

    setState(() {
      _deck = choice.deck;
      _rounds = buildVocabRounds(
        pool: pool,
        // Always the accessible set, never the deck: the Saved deck asks about
        // bookmarks but must draw its wrong answers from everything the tier
        // reaches — and scoping only one side is the leak #57 named.
        distractorSource: pools.accessible,
        length: resolveVocabLength(
          chosen: choice.length,
          poolSize: pool.length,
        ),
        seed: seed,
      );
      _index = 0;
      _picked = null;
      _score = 0;
      _recorded = false;
    });
  }

  void _pick(int index) => setState(() {
    _picked = index;
    if (_rounds[_index].isCorrect(index)) _score++;
  });

  void _next() {
    setState(() {
      _index++;
      _picked = null;
    });
    // Recorded here rather than where the score is drawn: a repository write
    // fired from `build` runs during the build phase, which is a hazard even
    // when a guard flag keeps it to one write.
    if (_index >= _rounds.length) _recordRoundOnce();
  }

  /// Back to setup, with the rounds dropped so the drill is startable again.
  void _changeRound() => setState(() {
    _rounds = const [];
    _index = 0;
    _picked = null;
    _score = 0;
  });

  /// Leaves the drill, back to wherever it was opened from.
  ///
  /// Both entry points push, so the usual answer is a pop — which returns the
  /// learner to the dictionary they were browsing rather than stranding them
  /// on Today having lost their place. Keep Sharp's CTA *goes* rather than
  /// pushes, like every other recommendation destination, and that is the case
  /// the fallback is for.
  void _done() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    context.goNamed(AppRoutes.learn.name);
  }

  /// A finished drill records that it happened — once, and only on reaching
  /// the score. An abandoned drill never gets here, so it writes nothing.
  void _recordRoundOnce() {
    if (_recorded) return;
    _recorded = true;
    unawaited(
      recordVocabRound(
        ref.read(snapshotRepositoryProvider),
        DateTime.now(),
      ).then((_) {
        if (!mounted) return;
        // One finished round marks the day, and everything that reads the day
        // is derived — so the surfaces that were covered by this drill have to
        // be told to look again.
        invalidateDaySurfaces(ref);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pools = ref.watch(vocabPoolsProvider);
    final total = _rounds.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const IconMark(AppIcon.close),
          tooltip: AppLabels.close,
          onPressed: _done,
        ),
        title: _playing && _index < total
            ? RoastMeter(
                position: _index + 1,
                total: total,
                semanticsLabel: VocabCopy.progress(_index + 1, total),
              )
            : null,
      ),
      body: pools.when(
        loading: () => Semantics(
          label: VocabCopy.loading,
          child: const LoadingIndicator(),
        ),
        error: (error, _) => Semantics(
          label: VocabCopy.loadFailed,
          excludeSemantics: true,
          child: ErrorView(message: '$error'),
        ),
        data: _buildDrill,
      ),
    );
  }

  Widget _buildDrill(VocabPools pools) {
    if (pools.accessible.length < vocabMinimumPool) {
      return VocabTeachingView(onDone: _done);
    }
    if (!_playing) {
      return VocabSetupView(
        pools: pools,
        choice: _choiceFor(pools),
        onChoice: (choice) => setState(() {
          _deck = choice.deck;
          _length = choice.length;
        }),
        onStart: () => _start(pools),
      );
    }
    if (_index >= _rounds.length) return _results(pools);

    final round = _rounds[_index];
    final isLast = _index + 1 >= _rounds.length;

    return VocabQuestionView(
      // Keyed by round so an answered question's marks never carry over into
      // the next one.
      key: ValueKey(_index),
      question: (
        round: round,
        categoryLabel: pools.categoryLabels[round.answer.categoryId],
      ),
      picked: _picked,
      onPick: _pick,
      next: (
        label: isLast ? VocabCopy.seeScore : VocabCopy.next,
        onPressed: _next,
      ),
    );
  }

  Widget _results(VocabPools pools) {
    final total = _rounds.length;

    return DrillResultsView(
      outcome: (
        score: _score,
        total: total,
        encouragement: VocabCopy.encouragement(score: _score, total: total),
        celebratory: isCelebratoryScore(score: _score, total: total),
      ),
      primary: (
        label: VocabCopy.playAgain,
        onPressed: () => _start(pools),
      ),
      secondary: (label: VocabCopy.changeRound, onPressed: _changeRound),
    );
  }
}
