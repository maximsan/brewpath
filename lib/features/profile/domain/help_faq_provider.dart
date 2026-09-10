import 'package:brew_path/features/mini_games/domain/mini_game_providers.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_tier.dart';
import 'package:brew_path/features/monetization/domain/foundations_faq_tail.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/profile/domain/help_faq.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'help_faq_provider.g.dart';

/// The FAQ, with the Foundations answer filled in once the banks have answered.
///
/// Synchronous on purpose: the four questions are always drawn, and only the
/// one answer that is counted waits — in its own row, never in front of the
/// list.
@riverpod
List<HelpQuestion> helpQuestions(Ref ref) {
  final games = ref.watch(miniGameFormatsProvider).asData?.value;

  return helpFaq(
    pitch: ref.watch(plusPitchProvider).asData?.value,
    freeGames: games == null ? null : freeMiniGameIds(games).length,
    foundationsTail: ref.watch(foundationsFaqTailProvider).asData?.value,
  );
}
