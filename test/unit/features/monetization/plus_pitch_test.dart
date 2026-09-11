import 'package:brew_path/features/mini_games/domain/mini_game_tier.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/monetization/domain/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

// Counted against the real shipped banks: a fixture would prove only that the
// fixture and the string agree, and the trap here is a paywall that passes its
// own test while lying about the app. So every assertion is a relationship over
// the real content — free plus remaining equals the whole course — never a
// number typed twice.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlusPitch pitch;
  late int allLessons;
  late int allGames;
  late int allTerms;

  setUpAll(() async {
    final content = ContentRepository();
    final modules = await content.getModules();
    final lessons = await content.getLessons();
    final games = await content.getMiniGameFormats();
    final terms = await DictionaryRepository().getTerms();

    allLessons = lessons.length;
    allGames = games.length;
    allTerms = terms.length;
    pitch = derivePlusPitch(
      modules: modules,
      lessons: lessons,
      games: games,
      terms: terms,
    );
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

  test('the paid modules are exactly the ones with no free lesson', () async {
    final modules = await ContentRepository().getModules();
    final paid = modules
        .where(
          (module) => !module.lessons.any((lesson) => isLessonFree(lesson.id)),
        )
        .map((module) => module.n)
        .toList();

    expect(pitch.firstPaidModule, paid.first);
    expect(pitch.lastPaidModule, paid.last);
    expect(paidModulesLine(pitch), contains('${paid.first}–${paid.last}'));
  });

  test('a premium format is a kind with no free game at all', () async {
    final games = await ContentRepository().getMiniGameFormats();
    final free = freeMiniGameIds(games).toSet();
    final freeKinds = {
      for (final game in games)
        if (free.contains(game.id)) game.kind,
    };
    final allKinds = {for (final game in games) game.kind};

    expect(pitch.premiumFormats, allKinds.length - freeKinds.length);
    expect(pitch.premiumFormats, greaterThan(0));
  });

  test(
    'the formats the pitch names are premium in the shipped banks',
    () async {
      // The line writes two examples by name; a free tier that grew to include
      // one of them would make the line wrong, so the kinds are checked.
      final games = await ContentRepository().getMiniGameFormats();
      final free = freeMiniGameIds(games).toSet();
      final freeKinds = {
        for (final game in games)
          if (free.contains(game.id)) game.kind,
      };
      final named = paywallBenefitsFor(pitch)[1];

      expect(named.detail, contains('Taste-fix'));
      expect(named.detail, contains('dial-in'));
      expect(freeKinds, isNot(contains('tastefix')));
      expect(freeKinds, isNot(contains('slider')));
      expect(
        named.title,
        'The ${spelledCount(pitch.premiumFormats)} premium formats',
      );
    },
  );

  test('a small count is spelled as the design writes it', () {
    expect(spelledCount(5), 'five');
    expect(spelledCount(0), 'zero');
    expect(spelledCount(11), '11');
  });

  test('the module line survives every shape of free tier', () {
    PlusPitch withModules(int first, int last) => PlusPitch(
      remainingLessons: 1,
      lockedGames: 1,
      premiumFormats: 1,
      firstPaidModule: first,
      lastPaidModule: last,
      referenceTerms: 1,
      savedFreeCap: 1,
    );

    expect(paidModulesLine(withModules(2, 5)), 'Modules 2–5, every lesson');
    expect(paidModulesLine(withModules(3, 3)), 'Module 3, every lesson');
    expect(paidModulesLine(withModules(0, 0)), 'Every lesson');
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
