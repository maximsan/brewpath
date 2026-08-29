import 'package:brew_path/features/mini_games/domain/mini_game_tier.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pitch, counted against the **real shipped banks**.
///
/// A fixture would prove only that the fixture and the string agree. The trap
/// this feature invites is a paywall that passes its own test while lying
/// about the app, so every assertion here is a *relationship* over the real
/// content — free plus remaining equals the whole course — never a number
/// typed twice.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlusPitch pitch;
  late int allLessons;
  late int allGames;
  late int allTerms;

  setUpAll(() async {
    final content = ContentRepository();
    final lessons = await content.getLessons();
    final games = await content.getMiniGameFormats();
    final terms = await DictionaryRepository().getTerms();

    allLessons = lessons.length;
    allGames = games.length;
    allTerms = terms.length;
    pitch = derivePlusPitch(lessons: lessons, games: games, terms: terms);
  });

  test('the course splits exactly into free and remaining', () {
    expect(pitch.remainingLessons + freeLessonIds.length, allLessons);
  });

  test('every free lesson is a lesson the course actually holds', () async {
    // Otherwise the free tier could name a lesson that does not exist and the
    // remaining count would silently overstate what Plus buys.
    final ids = (await ContentRepository().getLessons())
        .map((lesson) => lesson.id)
        .toSet();
    expect(ids, containsAll(freeLessonIds));
  });

  test('the catalog splits exactly into free and locked games', () async {
    final games = await ContentRepository().getMiniGameFormats();
    expect(pitch.lockedGames + freeMiniGameIds(games).length, allGames);
  });

  test('reference terms are the ones no lesson teaches', () async {
    final terms = await DictionaryRepository().getTerms();
    final taught = terms.where((term) => term.lessonId != null).length;
    expect(pitch.referenceTerms + taught, allTerms);
  });

  test('there is something left to sell', () {
    // A pitch offering nothing is the one state the copy cannot survive, and
    // it is reachable by a content change rather than a code change.
    expect(pitch.remainingLessons, greaterThan(0));
    expect(pitch.lockedGames, greaterThan(0));
    expect(pitch.referenceTerms, greaterThan(0));
  });

  test('the shelf cap comes from the shelf, not from the pitch', () {
    expect(pitch.savedFreeCap, savedFreeMax);
  });

  group('the bullets', () {
    test('lead with the course and end with the cosmetics', () {
      final bullets = PlusCopy.bulletsFor(pitch);
      expect(bullets, hasLength(3));
      // The ranking is the product's statement about what is worth most, so
      // it is asserted rather than left to whoever edits the list next.
      expect(bullets.first.body, contains('${pitch.remainingLessons}'));
      expect(bullets.last.body, contains('${pitch.savedFreeCap}'));
    });

    test('carry every counted quantity', () {
      final spoken = PlusCopy.bulletsFor(pitch).map((b) => b.body).join(' ');
      expect(spoken, contains('${pitch.remainingLessons}'));
      expect(spoken, contains('${pitch.lockedGames}'));
      expect(spoken, contains('${pitch.referenceTerms}'));
    });
  });
}
