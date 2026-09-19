import 'package:brew_path/core/widgets/confirm_sheet.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/domain/tree_stage_names.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reset_summary.g.dart';

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

  /// The tree, whose value is where it goes rather than where it is.
  static const tree = 'Your coffee tree';
}

/// The learner's own figures for the seven measures Reset clears.
///
/// **Their numbers, not an inventory of storage fields** — seeing *12 days* is
/// what makes someone stop. Every one is a measure Profile already shows, read
/// through the same providers so the sheet and the tab cannot disagree.
@riverpod
Future<List<ConfirmLine>> resetSummary(Ref ref) async {
  // Every watch resolved before the first await: a rebuild mid-flight must not
  // find a watch on the far side of an async gap.
  final streakDays = ref.watch(streakProvider.future);
  final points = ref.watch(totalPointsProvider.future);
  final lessons = ref.watch(completedLessonsProvider.future);
  final cards = ref.watch(cardsWithCollectionProvider.future);
  final challengeBank = ref.watch(challengeBankProvider.future);
  final brewed = ref.watch(completedChallengesProvider.future);
  final shelf = ref.watch(savedShelfProvider.future);

  final bank = await challengeBank;
  final completedIds = await brewed;
  final owned = await cards;

  return [
    ConfirmLine(
      label: ResetSummaryCopy.streak,
      value: _days(await streakDays),
    ),
    ConfirmLine(
      label: ResetSummaryCopy.points,
      value: '${await points} pts',
    ),
    ConfirmLine(
      label: ResetSummaryCopy.lessons,
      value: '${(await lessons).count}',
    ),
    ConfirmLine(
      label: ResetSummaryCopy.cards,
      value: _fraction(
        owned.where((card) => card.isCollected).length,
        owned.length,
      ),
    ),
    ConfirmLine(
      label: ResetSummaryCopy.challenges,
      // Counted against the bank's own length, and only for challenges the
      // bank still carries — exactly as Profile's challenge row counts them.
      value: _fraction(
        bank.where((challenge) => completedIds.contains(challenge.id)).length,
        bank.length,
      ),
    ),
    ConfirmLine(
      label: ResetSummaryCopy.saved,
      // Counted off the shelf rather than off the stored keys, as the Profile
      // card is: the sheet must not promise a row the shelf would skip.
      value: '${savedShelfCount(await shelf)}',
    ),
    ConfirmLine(
      label: ResetSummaryCopy.tree,
      value: 'Back to ${treeStageName(freshTreeStage)}',
    ),
  ];
}

String _days(int streak) => '$streak ${streak == 1 ? 'day' : 'days'}';

String _fraction(int held, int total) => '$held of $total';
