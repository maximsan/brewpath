import 'package:brew_path/app/header_tier.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every location in the app gets exactly one kind of chrome, and the rule
/// lives in one place so a route added later cannot silently inherit the
/// wrong one.
///
/// ⚠️ **Tier is the chrome, not the navigator.** Settings runs on the root
/// navigator and is still `pushed`, because what the learner sees is a page
/// with a back arrow. Filing routes by their plumbing is the mistake this
/// table exists to prevent.
const _expectedTiers = <String, HeaderTier>{
  '/learn': HeaderTier.tabRoot,
  '/path': HeaderTier.tabRoot,
  '/cards': HeaderTier.tabRoot,
  '/profile': HeaderTier.tabRoot,
  '/learn/module/m1': HeaderTier.pushed,
  '/learn/dictionary': HeaderTier.pushed,
  '/learn/dictionary/term/arabica': HeaderTier.pushed,
  '/cards/c-m1l1': HeaderTier.pushed,
  '/profile/settings': HeaderTier.pushed,
  '/profile/streak': HeaderTier.pushed,
  '/learn/lesson/m1l1': HeaderTier.immersive,
  '/learn/lesson/m1l1/complete': HeaderTier.immersive,
  '/learn/module-summary/m1': HeaderTier.immersive,
  '/learn/mini-game/g-match': HeaderTier.immersive,
  '/learn/mini-game/g-match/play': HeaderTier.immersive,
  '/welcome': HeaderTier.immersive,
  '/loading': HeaderTier.immersive,
  '/onboarding/goal': HeaderTier.immersive,
  '/onboarding/name': HeaderTier.immersive,
  '/course-complete': HeaderTier.immersive,
};

void main() {
  group('the tier table', () {
    _expectedTiers.forEach((location, expected) {
      test('$location is $expected', () {
        expect(headerTierFor(location), expected);
      });
    });
  });

  group('the rule itself', () {
    test('only an exact branch root is a tab root', () {
      expect(headerTierFor('/learn/'), isNot(HeaderTier.tabRoot));
      expect(headerTierFor('/learnable'), isNot(HeaderTier.tabRoot));
    });

    test('an unknown page under a branch is pushed, not immersive', () {
      expect(headerTierFor('/learn/something-new'), HeaderTier.pushed);
    });

    test('matching is by whole segment, never substring', () {
      expect(
        headerTierFor('/cards/c-my-lesson-notes'),
        HeaderTier.pushed,
        reason: 'a card id containing "lesson" is not a lesson route',
      );
    });

    test('only a tab root shows the shell header', () {
      expect(HeaderTier.tabRoot.showsSharedHeader, isTrue);
      expect(HeaderTier.pushed.showsSharedHeader, isFalse);
      expect(HeaderTier.immersive.showsSharedHeader, isFalse);
    });
  });

  group('per-tab headings', () {
    final today = DateTime(2026, 5, 8);

    test('each tab names itself in the design vocabulary', () {
      expect(tabHeaderFor('/path', today: today)?.eyebrow, 'YOUR PATH');
      expect(
        tabHeaderFor('/path', today: today)?.title,
        'Beginner Foundations',
      );
      expect(tabHeaderFor('/cards', today: today)?.eyebrow, 'YOUR DECK');
      expect(tabHeaderFor('/cards', today: today)?.title, 'Collection');
      expect(tabHeaderFor('/profile', today: today)?.eyebrow, 'PROFILE');
      expect(
        tabHeaderFor('/profile', today: today, learnerName: 'Maya')?.title,
        'Hello, Maya.',
        reason: 'the learner gave a name at onboarding',
      );
      expect(
        tabHeaderFor('/profile', today: today)?.title,
        'Hello, there.',
        reason: 'they skipped it, and the same sentence still greets them',
      );
    });

    test('Learn titles itself with the day it is given', () {
      final tab = tabHeaderFor('/learn', today: today);
      expect(tab?.eyebrow, 'TODAY');
      expect(tab?.title, 'Friday, May 8');
    });

    test('Profile swaps the entry rather than adding to it', () {
      expect(
        tabHeaderFor('/profile', today: today)?.action,
        HeaderAction.settings,
      );
      for (final tab in ['/learn', '/path', '/cards']) {
        expect(
          tabHeaderFor(tab, today: today)?.action,
          HeaderAction.dictionary,
          reason: '$tab offers the dictionary',
        );
      }
    });

    test('a location that is not a tab root has no heading', () {
      expect(tabHeaderFor('/learn/dictionary', today: today), isNull);
      expect(tabHeaderFor('/learn/lesson/m1l1', today: today), isNull);
    });
  });

  group('what counts as scrolled', () {
    test('past the threshold collapses', () {
      expect(
        shouldCollapseHeader(
          pixels: collapseThreshold + 1,
          maxScrollExtent: 800,
          axis: Axis.vertical,
        ),
        isTrue,
      );
    });

    test('at rest, or barely moved, does not', () {
      for (final pixels in [0.0, collapseThreshold]) {
        expect(
          shouldCollapseHeader(
            pixels: pixels,
            maxScrollExtent: 800,
            axis: Axis.vertical,
          ),
          isFalse,
          reason: 'a thumb resting on the screen is not a scroll',
        );
      }
    });

    test('a tab with nothing to scroll never collapses', () {
      expect(
        shouldCollapseHeader(
          pixels: 200,
          maxScrollExtent: 0,
          axis: Axis.vertical,
        ),
        isFalse,
        reason: 'an overscroll bounce moves pixels with no content behind it',
      );
    });

    test('a carousel inside a tab is not the tab moving', () {
      expect(
        shouldCollapseHeader(
          pixels: 400,
          maxScrollExtent: 800,
          axis: Axis.horizontal,
        ),
        isFalse,
      );
    });
  });
}
