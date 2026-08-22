import 'package:brew_path/app/header_tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every route in the app gets exactly one kind of chrome, and the rule lives
/// in one place so a route added later cannot silently inherit the wrong one.
void main() {
  group('tab roots', () {
    test('the four branch roots wear the shared header', () {
      for (final location in ['/learn', '/path', '/cards', '/profile']) {
        expect(
          headerTierFor(location),
          HeaderTier.tabRoot,
          reason: '$location is a tab the learner switches to',
        );
      }
    });
  });

  group('pushed pages', () {
    test('a page pushed inside a branch brings its own bar', () {
      const pushed = [
        '/learn/module/m1',
        '/learn/dictionary',
        '/learn/dictionary/term/arabica',
        '/cards/c-m1l1',
      ];
      for (final location in pushed) {
        expect(
          headerTierFor(location),
          HeaderTier.pushed,
          reason: '$location is pushed, so it carries a back arrow instead',
        );
      }
    });
  });

  group('immersive flows', () {
    test('a lesson, its completion and the mini-games show no chrome', () {
      const immersive = [
        '/learn/lesson/m1l1',
        '/learn/lesson/m1l1/complete',
        '/learn/module-summary/m1',
        '/learn/mini-game/g-match',
        '/learn/mini-game/g-match/play',
        '/profile/settings',
      ];
      for (final location in immersive) {
        expect(
          headerTierFor(location),
          HeaderTier.immersive,
          reason: '$location escapes the shell entirely',
        );
      }
    });
  });

  group('the rule itself', () {
    test('only an exact branch root is a tab root', () {
      expect(headerTierFor('/learn/'), isNot(HeaderTier.tabRoot));
      expect(headerTierFor('/learnable'), isNot(HeaderTier.tabRoot));
    });

    test('an unknown location under a branch is treated as pushed', () {
      expect(headerTierFor('/learn/something-new'), HeaderTier.pushed);
    });

    test('a location outside every branch gets no header', () {
      for (final location in ['/welcome', '/loading', '/onboarding/goal']) {
        expect(headerTierFor(location), HeaderTier.immersive);
      }
    });

    test('only a tab root shows the shell header', () {
      expect(HeaderTier.tabRoot.showsSharedHeader, isTrue);
      expect(HeaderTier.pushed.showsSharedHeader, isFalse);
      expect(HeaderTier.immersive.showsSharedHeader, isFalse);
    });
  });

  group('per-tab titles', () {
    test('each tab root names itself in the design vocabulary', () {
      expect(headerTitleFor('/path')?.eyebrow, 'YOUR PATH');
      expect(headerTitleFor('/path')?.title, 'Beginner Foundations');
      expect(headerTitleFor('/cards')?.eyebrow, 'YOUR DECK');
      expect(headerTitleFor('/cards')?.title, 'Collection');
      expect(headerTitleFor('/profile')?.eyebrow, 'PROFILE');
    });

    test('Learn titles itself with the day it is given', () {
      final title = headerTitleFor('/learn', today: DateTime(2026, 5, 8));
      expect(title?.eyebrow, 'TODAY');
      expect(
        title?.title,
        'Friday, May 8',
        reason: 'the date is passed in, never read from the clock here',
      );
    });

    test('a non-tab-root has no title', () {
      expect(headerTitleFor('/learn/dictionary'), isNull);
    });
  });
}
