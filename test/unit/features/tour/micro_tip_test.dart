import 'package:brew_path/features/tour/domain/micro_tip.dart';
import 'package:flutter_test/flutter_test.dart';

/// The seven tips' copy, pinned word for word, and the list that remembers
/// which have been shown.
///
/// The copy is asserted here rather than at each trigger because it is the one
/// thing about a tip that no behaviour test would notice going wrong: a card
/// that shows on the right beat with the wrong sentence passes every other
/// check in this suite.
void main() {
  test('there are exactly seven tips, each with its own id', () {
    expect(MicroTip.values, hasLength(7));
    expect(
      MicroTip.values.map((tip) => tip.id).toSet(),
      hasLength(MicroTip.values.length),
    );
  });

  test('every tip carries the copy the ruling fixed', () {
    expect(MicroTip.path.eyebrow, 'YOUR PATH');
    expect(MicroTip.path.title, 'The whole course, in order');
    expect(
      MicroTip.path.body,
      'Each finished lesson unlocks the next, top to bottom. The diamonds '
      'branching off the line are hands-on Coffee Challenges.',
    );

    expect(MicroTip.brew.eyebrow, 'COFFEE CHALLENGE');
    expect(MicroTip.brew.title, 'A real brew, not a quiz');
    expect(
      MicroTip.brew.body,
      'Make it at your own pace within 48 hours, then log the result here on '
      'Today. Logging it earns the challenge’s stamp.',
    );

    expect(MicroTip.tree.eyebrow, 'COFFEE TREE');
    expect(MicroTip.tree.title, 'Your tree just grew');
    expect(
      MicroTip.tree.body,
      'Completing that lesson pushed it toward harvest. Only core lessons '
      'grow it — see it any time from your Profile.',
    );

    expect(MicroTip.saved.eyebrow, 'SAVED');
    expect(MicroTip.saved.title, 'Kept for later');
    expect(
      MicroTip.saved.body,
      'Everything you save waits behind the ribbon at the top of Today — '
      'lessons, terms and guides on one shelf.',
    );

    expect(MicroTip.dictionary.eyebrow, 'DICTIONARY');
    expect(MicroTip.dictionary.title, 'Every term you’ve met');
    expect(
      MicroTip.dictionary.body,
      'Terms join your Dictionary as lessons introduce them. Search them '
      'here, or drill them with flashcards.',
    );

    expect(MicroTip.freeze.eyebrow, 'STREAK FREEZE');
    expect(MicroTip.freeze.title, 'A safety net you’ve earned');
    expect(
      MicroTip.freeze.body,
      'Every 7 streak days in a row earns a freeze; you hold one at a time. '
      'Miss a day and it’s spent for you — your streak survives.',
    );

    expect(MicroTip.studio.eyebrow, 'STUDIO');
    expect(MicroTip.studio.title, 'Make it yours');
    expect(
      MicroTip.studio.body,
      'Dress Roasty and choose your tree’s variety and light. The look '
      'you set here applies everywhere in the app.',
    );
  });

  test('a tip is announced as its three lines, in order', () {
    expect(
      MicroTip.saved.announcement,
      '${MicroTip.saved.eyebrow}. ${MicroTip.saved.title}. '
      '${MicroTip.saved.body}',
    );
  });

  group('the stored seen list', () {
    test('reads an empty column as nothing seen', () {
      expect(MicroTipsSeen.decode(''), isEmpty);
    });

    test('round-trips the ids it was given', () {
      final stored = MicroTipsSeen.encode({
        MicroTip.path.id,
        MicroTip.freeze.id,
      });

      expect(MicroTipsSeen.decode(stored), {
        MicroTip.path.id,
        MicroTip.freeze.id,
      });
    });

    test('keeps ids this build does not recognise', () {
      // A device that has been on a newer build carries tips this one has
      // never heard of. Trimming them would show them again on the next
      // upgrade, which is the one thing "once ever" must not do.
      final stored = MicroTipsSeen.withTip('atlas', MicroTip.path);

      expect(MicroTipsSeen.decode(stored), {'atlas', MicroTip.path.id});
      expect(MicroTip.byId('atlas'), isNull);
    });

    test('adding a tip already on the list changes nothing', () {
      final once = MicroTipsSeen.withTip('', MicroTip.tree);

      expect(MicroTipsSeen.withTip(once, MicroTip.tree), once);
    });

    test('names a tip by its stored id', () {
      expect(MicroTip.byId(MicroTip.studio.id), MicroTip.studio);
    });
  });
}
