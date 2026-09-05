import 'package:brew_path/features/tour/domain/micro_tip_place.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which screens the tip layer will speak on, read straight off the address.
///
/// The rule that matters most here is the silent one: anything the layer does
/// not recognise is [TipPlace.elsewhere], so a lesson, a mini-game, a drill and
/// every settings page get no tip without anyone having to remember to exclude
/// them.
void main() {
  group('the places a tip fires on', () {
    test('the Learn tab', () {
      expect(tipPlaceFor('/learn'), TipPlace.learnTab);
    });

    test('the Path tab', () {
      expect(tipPlaceFor('/path'), TipPlace.pathTab);
    });

    test("the dictionary's index, but not a term inside it", () {
      expect(tipPlaceFor('/learn/dictionary'), TipPlace.dictionary);
      expect(
        tipPlaceFor('/learn/dictionary/term/crema'),
        TipPlace.otherInShell,
      );
    });

    test('the Studio', () {
      expect(tipPlaceFor('/profile/studio'), TipPlace.studio);
    });
  });

  group('the places a saved tip can land on', () {
    test('the shelf, the collection and Profile keep the tab bar', () {
      for (final location in ['/learn/saved', '/cards', '/profile']) {
        expect(tipPlaceFor(location), TipPlace.otherInShell, reason: location);
      }
    });

    test("today's term is a page over the tab bar", () {
      expect(tipPlaceFor('/learn/term-of-the-day'), TipPlace.termOfDay);
    });
  });

  group('the places no tip may appear on', () {
    test('a lesson and its ending', () {
      expect(tipPlaceFor('/learn/lesson/m1l1'), TipPlace.elsewhere);
      expect(tipPlaceFor('/learn/lesson/m1l1/complete'), TipPlace.elsewhere);
    });

    test('a module ending, a mini-game and the two drills', () {
      for (final location in [
        '/learn/module-summary/m1',
        '/learn/mini-game/cupping',
        '/learn/mini-game/cupping/play',
        '/learn/flashcards',
        '/learn/vocab-game',
      ]) {
        expect(tipPlaceFor(location), TipPlace.elsewhere, reason: location);
      }
    });

    test('settings and everything under it', () {
      for (final location in [
        '/profile/settings',
        '/profile/settings/help',
        '/profile/settings/help/app-guide',
        '/profile/tree',
        '/profile/streak',
      ]) {
        expect(tipPlaceFor(location), TipPlace.elsewhere, reason: location);
      }
    });

    test('onboarding', () {
      for (final location in [
        '/loading',
        '/welcome',
        '/meet-roasty',
        '/onboarding/name',
      ]) {
        expect(tipPlaceFor(location), TipPlace.elsewhere, reason: location);
      }
    });

    test('an address nothing matches', () {
      expect(tipPlaceFor('/nowhere'), TipPlace.elsewhere);
      expect(tipPlaceFor(''), TipPlace.elsewhere);
    });
  });

  group('where the card sits', () {
    test('clears the tab bar on every in-shell screen', () {
      for (final place in [
        TipPlace.learnTab,
        TipPlace.pathTab,
        TipPlace.dictionary,
        TipPlace.otherInShell,
      ]) {
        expect(place.showsTabBar, isTrue, reason: place.name);
        expect(place.takesTips, isTrue, reason: place.name);
      }
    });

    test('sits near the screen edge on the two pages over the bar', () {
      expect(TipPlace.studio.showsTabBar, isFalse);
      expect(TipPlace.termOfDay.showsTabBar, isFalse);
      expect(TipPlace.studio.takesTips, isTrue);
      expect(TipPlace.termOfDay.takesTips, isTrue);
    });

    test('takes no tip at all elsewhere', () {
      expect(TipPlace.elsewhere.takesTips, isFalse);
    });
  });
}
