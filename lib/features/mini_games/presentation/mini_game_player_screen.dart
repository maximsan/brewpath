import 'dart:async';

import 'package:brew_path/app/day_surfaces.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/drill_bands.dart';
import 'package:brew_path/core/widgets/drill_results_view.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/features/lessons/presentation/cards/content_card_view.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_completion.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_providers.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_run.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Runs one mini-game: its rounds in this run's order, then the results.
///
/// The run holds a single nonce, minted when it begins and re-minted by Play
/// again, which decides both the round order and each round's choice order.
/// Nothing about the run is persisted.
///
/// Results are a state of this screen rather than a route of their own: the
/// score never outlives the run, so routing to it would mean handing a number
/// to the router only to hand it straight back.
class MiniGamePlayerScreen extends ConsumerStatefulWidget {
  /// Creates a [MiniGamePlayerScreen].
  const MiniGamePlayerScreen({required this.formatId, super.key});

  /// Catalog id of the format being played.
  final String formatId;

  @override
  ConsumerState<MiniGamePlayerScreen> createState() =>
      _MiniGamePlayerScreenState();
}

class _MiniGamePlayerScreenState extends ConsumerState<MiniGamePlayerScreen> {
  int _nonce = mintRunNonce();
  int _index = 0;
  int _score = 0;
  bool _recorded = false;

  void _onSolved() => _score++;

  void _onContinue() => setState(() => _index++);

  /// A finished run records that it happened — once, and only on reaching the
  /// results. An abandoned run never gets here, so it writes nothing.
  void _recordRunOnce() {
    if (_recorded) return;
    _recorded = true;
    unawaited(
      recordMiniGameRun(
        ref.read(snapshotRepositoryProvider),
        widget.formatId,
        DateTime.now(),
      ).then((_) {
        if (!mounted) return;
        // The second different game of the day marks it, and everything that
        // reads the day is derived — so it has to be told to look again. The
        // Learn tab is *covered* by this run rather than replaced, so it never
        // rebuilds on its own and the card would otherwise still be asking for
        // a game the learner just played.
        invalidateDaySurfaces(ref);
      }),
    );
  }

  /// Another run, if the day still holds one.
  ///
  /// Asked here as well as at the intro: this restarts an activity without
  /// navigating, so nothing else would ask (#216).
  Future<void> _playAgain() async {
    if (!await context.mayStartAnotherActivity() || !mounted) return;
    setState(() {
      // A fresh run is a fresh completion: playing the same game twice leaves
      // two entries, which the day's rule counts as one game.
      _recorded = false;
      _nonce = mintRunNonce();
      _index = 0;
      _score = 0;
    });
  }

  /// Leaves the mini-game entirely, back to the catalog it was launched from.
  ///
  /// Deliberately not `pop`: the stack under a run is intro → play, so popping
  /// would drop the learner back onto the how-to-play screen they already
  /// dismissed. The intro's own Close does pop, because there the previous
  /// screen *is* where they came from.
  void _done() => context.goNamed(AppRoutes.learn.name);

  @override
  Widget build(BuildContext context) {
    final rounds = ref.watch(miniGameRoundsProvider(widget.formatId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const IconMark(AppIcon.close),
          tooltip: 'Close',
          onPressed: _done,
        ),
        title: rounds.maybeWhen(
          data: (data) => data.isEmpty || _index >= data.length
              ? null
              : RoastMeter(
                  position: _index + 1,
                  total: data.length,
                  semanticsLabel: 'Round ${_index + 1} of ${data.length}',
                ),
          orElse: () => null,
        ),
      ),
      body: rounds.when(
        loading: () => Semantics(
          label: 'Loading the rounds',
          child: const LoadingIndicator(),
        ),
        error: (error, _) => Semantics(
          label: 'These rounds could not be loaded.',
          excludeSemantics: true,
          child: ErrorView(message: '$error'),
        ),
        data: _buildRun,
      ),
    );
  }

  Widget _buildRun(List<ContentCard> bank) {
    if (bank.isEmpty) {
      return Semantics(
        label: 'This mini-game has no rounds yet.',
        excludeSemantics: true,
        child: const ErrorView(message: 'This mini-game has no rounds yet.'),
      );
    }

    final played = roundsForRun(bank, _nonce);
    if (_index >= played.length) {
      _recordRunOnce();
      return DrillResultsView(
        outcome: (
          score: _score,
          total: played.length,
          encouragement: runEncouragement(
            score: _score,
            total: played.length,
          ),
          celebratory: isCelebratoryScore(
            score: _score,
            total: played.length,
          ),
        ),
        primary: (label: 'Play again', onPressed: _playAgain),
        secondary: (label: 'Done', onPressed: _done),
      );
    }

    final card = contentCardView(
      played[_index],
      nonce: _nonce,
      cardIndex: _index,
      onSolved: _onSolved,
      onContinue: _onContinue,
    );
    if (card == null) {
      return Semantics(
        label: 'This round cannot be shown yet.',
        excludeSemantics: true,
        child: const ErrorView(message: 'This round cannot be shown yet.'),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        // Keyed by round so each round mounts a fresh card: a latched card
        // must never be reused for the next statement.
        child: KeyedSubtree(key: ValueKey('${_nonce}_$_index'), child: card),
      ),
    );
  }
}
