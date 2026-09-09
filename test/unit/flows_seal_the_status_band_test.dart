import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

// Which bar each full-screen flow wears (#525). A run is sealed from the first
// frame, because the card scrolls under it; a page that opens on a drawing
// shows nothing until its content moves.
void main() {
  const sealed = [
    'lib/features/lessons/presentation/lesson_screen.dart',
    'lib/features/mini_games/presentation/mini_game_player_screen.dart',
    'lib/features/dictionary/presentation/flashcards_screen.dart',
    'lib/features/dictionary/presentation/vocab/vocab_game_screen.dart',
  ];

  const onScroll = [
    'lib/features/mini_games/presentation/mini_game_intro_screen.dart',
    'lib/features/dictionary/presentation/term_of_day_screen.dart',
  ];

  String read(String path) => withoutComments(
    dartSourcesUnder(
      'lib',
    ).firstWhere((file) => file.path == path).readAsStringSync(),
  );

  test('a run seals its bar from the first frame', () {
    for (final path in sealed) {
      expect(
        read(path).contains('FloatTopbar.sealed('),
        isTrue,
        reason: '$path is a run: the card passes under an opaque bar',
      );
    }
  });

  test('a page that opens on a drawing seals its bar on scroll', () {
    for (final path in onScroll) {
      final source = read(path);
      expect(
        source.contains('FloatTopbar.sealed('),
        isFalse,
        reason: '$path opens on a drawing, which a fill would sit on',
      );
      expect(source.contains('FloatTopbar('), isTrue);
      expect(
        source.contains('isScrolled:'),
        isTrue,
        reason: 'its bar arrives with the content, so it needs the flag',
      );
    }
  });
}
