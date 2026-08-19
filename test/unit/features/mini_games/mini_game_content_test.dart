import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The shipped bank against the renderers that must play it. A format in
/// `playableMiniGameIds` whose rounds this build cannot render would pass
/// every other test and fail in a learner's hands.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('g-match ships five boards, every one of them a match card', () async {
    final rounds = await ContentRepository().getMiniGameRounds('g-match');

    expect(rounds, hasLength(5));
    expect(rounds, everyElement(isA<MatchCard>()));
    for (final round in rounds.cast<MatchCard>()) {
      expect(round.pairs, isNotEmpty);
      expect(round.prompt, isNotEmpty);
    }
  });

  test('g-quiz ships six statements, every one of them a quiz card', () async {
    final rounds = await ContentRepository().getMiniGameRounds('g-quiz');

    expect(rounds, hasLength(6));
    expect(rounds, everyElement(isA<QuizCard>()));
  });
}
