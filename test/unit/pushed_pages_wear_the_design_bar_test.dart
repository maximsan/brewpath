import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

/// A page opened from a tab wears the design's bar, not Material's.
///
/// Fifteen screens each answered the question their own way, which is how the
/// app came to have fifteen stock `AppBar`s where the design has one bar
/// composed twice (#513). The sweep is a one-off; this is what keeps it swept
/// — a new screen that reaches for `AppBar` fails here rather than being
/// noticed a year later.
void main() {
  /// The screens still allowed to draw one, and why.
  ///
  /// All six are full-screen flows rather than pages opened from a tab, so
  /// they want the design's *floating* bar rather than its back bar — a
  /// different component and a different ticket (#525). They are listed rather
  /// than pattern-matched so converting one fails this test, which is what
  /// stops the list going stale after the ticket lands.
  const sanctioned = <String, String>{
    'lib/features/lessons/presentation/lesson_screen.dart':
        'the lesson player: close, the bean and its count, save — #395 '
        'settled what it carries, #525 owns the chrome under it',
    'lib/features/mini_games/presentation/mini_game_intro_screen.dart':
        'a full-screen flow, waiting on #525',
    'lib/features/mini_games/presentation/mini_game_player_screen.dart':
        'a full-screen flow, waiting on #525',
    'lib/features/dictionary/presentation/vocab/vocab_game_screen.dart':
        'a full-screen flow, waiting on #525',
    'lib/features/dictionary/presentation/flashcards_screen.dart':
        'a full-screen flow, waiting on #525',
    'lib/features/dictionary/presentation/term_of_day_screen.dart':
        'a full-screen flow, waiting on #525',
  };

  test('no page opened from a tab hand-rolls a bar', () {
    final offenders = dartSourcesUnder('lib')
        .where((file) => !sanctioned.containsKey(file.path))
        .where(
          (file) =>
              withoutComments(file.readAsStringSync()).contains('AppBar('),
        )
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'a pushed page goes through SubScreenScaffold, which carries the '
          "design's bar, the scroll flag and the room the scroll leaves for "
          'it. A stock AppBar is a solid strip that never gets out of the '
          'way, and it is not what the design draws. Found:\n'
          '${offenders.join('\n')}',
    );
  });

  test('every sanctioned screen still draws one', () {
    // An exemption nobody needs is a hole in the guard: once #525 converts a
    // screen, its entry has to come out.
    for (final entry in sanctioned.entries) {
      final source = withoutComments(
        dartSourcesUnder(
          'lib',
        ).firstWhere((file) => file.path == entry.key).readAsStringSync(),
      );

      expect(
        source.contains('AppBar('),
        isTrue,
        reason:
            '${entry.key} is exempted as "${entry.value}" but no longer draws '
            'an AppBar — drop the exemption rather than leaving a hole in the '
            'guard',
      );
    }
  });
}
