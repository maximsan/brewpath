import 'package:brew_path/features/mini_games/domain/mini_game_tier.dart';
import 'package:brew_path/features/monetization/domain/foundations_faq_tail.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/profile/domain/help_faq.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'help_faq_provider.g.dart';

/// The FAQ with its counts filled in from the shipped banks.
///
/// Joins here so [helpFaq] stays a pure function of three values, and a wrong
/// count fails in a unit test rather than on the screen.
@riverpod
Future<List<HelpQuestion>> helpQuestions(Ref ref) async {
  final games = await ref.watch(contentRepositoryProvider).getMiniGameFormats();

  return helpFaq(
    pitch: await ref.watch(plusPitchProvider.future),
    freeGames: freeMiniGameIds(games).length,
    foundationsTail: await ref.watch(foundationsFaqTailProvider.future),
  );
}
