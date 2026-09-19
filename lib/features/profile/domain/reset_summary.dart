import 'package:brew_path/features/cards/domain/cards_grid.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/challenges/domain/challenge_completion.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/domain/tree_stage_names.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reset_summary.g.dart';

/// One measure a reset clears: what it is called, and this learner's figure.
typedef ResetMeasure = ({String label, String value});

/// What the reset sheet's seven lines are called, in the design's order.
abstract final class ResetSummaryCopy {
  /// Days in a row, as Profile's streak card counts them.
  static const streak = 'Daily streak';

  /// Points, as Profile's progress line counts them.
  static const points = 'Points earned';

  /// Lessons finished, as Profile's progress line counts them.
  static const lessons = 'Lessons completed';

  /// Collectibles owned, out of the bank.
  static const cards = 'Cards collected';

  /// Challenges brewed, out of the bank.
  static const challenges = 'Coffee challenges';

  /// Everything on the Saved shelf.
  static const saved = 'Saved items';

  /// The tree, whose figure is where it goes rather than where it is.
  static const tree = 'Your coffee tree';
}

/// The learner's own figures for the seven measures Reset clears.
///
/// Every one is read through the provider the Profile tab reads, so the sheet
/// and the tab cannot disagree about what is about to be thrown away.
@riverpod
Future<List<ResetMeasure>> resetSummary(Ref ref) async {
  // Every watch resolved before the first await: a rebuild mid-flight must not
  // find a watch on the far side of an async gap.
  final streakDays = ref.watch(streakProvider.future);
  final points = ref.watch(totalPointsProvider.future);
  final lessons = ref.watch(completedLessonsProvider.future);
  final cards = ref.watch(cardsWithCollectionProvider.future);
  final bank = ref.watch(challengeBankProvider.future);
  final brewed = ref.watch(completedChallengesProvider.future);
  final shelf = ref.watch(savedShelfProvider.future);

  final owned = await cards;
  final tally = challengeTally(bank: await bank, completed: await brewed);

  return [
    (label: ResetSummaryCopy.streak, value: _days(await streakDays)),
    (label: ResetSummaryCopy.points, value: '${await points} pts'),
    (label: ResetSummaryCopy.lessons, value: '${(await lessons).count}'),
    (
      label: ResetSummaryCopy.cards,
      value: _fraction(earnedCount(owned), owned.length),
    ),
    (
      label: ResetSummaryCopy.challenges,
      value: _fraction(tally.brewed, tally.total),
    ),
    // Counted off the shelf rather than off the stored keys, as the Profile
    // card is: the sheet must not promise a row the shelf would skip.
    (label: ResetSummaryCopy.saved, value: '${savedShelfCount(await shelf)}'),
    (
      label: ResetSummaryCopy.tree,
      value: 'Back to ${treeStageName(freshTreeStage)}',
    ),
  ];
}

String _days(int streak) => '$streak ${streak == 1 ? 'day' : 'days'}';

String _fraction(int held, int total) => '$held of $total';
