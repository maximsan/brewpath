import 'package:brew_path/features/studio/domain/companion_draft.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter_test/flutter_test.dart';

const _worn = CompanionConfig(
  roast: 'dark',
  hat: 'beanie',
  gear: 'scarf',
  sprout: 'flower',
);

void main() {
  group('opening on what is worn', () {
    test('a fresh draft matches the outfit it opened on', () {
      expect(CompanionDraft.of(_worn).outfit, _worn);
    });

    test('and is not dirty against it', () {
      expect(CompanionDraft.of(_worn).isDirtyAgainst(_worn), isFalse);
    });
  });

  group('changing one axis', () {
    test('the roast leaves the other three alone', () {
      final draft = CompanionDraft.of(_worn).withRoast('light');

      expect(draft.outfit.roast, 'light');
      expect(draft.outfit.hat, _worn.hat);
      expect(draft.outfit.gear, _worn.gear);
      expect(draft.outfit.sprout, _worn.sprout);
    });

    test('the hat leaves the other three alone', () {
      final draft = CompanionDraft.of(_worn).withHat('cap');

      expect(draft.outfit.hat, 'cap');
      expect(draft.outfit.roast, _worn.roast);
    });

    test('the gear leaves the other three alone', () {
      final draft = CompanionDraft.of(_worn).withGear('glasses');

      expect(draft.outfit.gear, 'glasses');
      expect(draft.outfit.sprout, _worn.sprout);
    });

    test('the sprout leaves the other three alone', () {
      final draft = CompanionDraft.of(_worn).withSprout('none');

      expect(draft.outfit.sprout, 'none');
      expect(draft.outfit.hat, _worn.hat);
    });

    test('makes the draft dirty', () {
      expect(
        CompanionDraft.of(_worn).withRoast('light').isDirtyAgainst(_worn),
        isTrue,
      );
    });
  });

  group('changing back', () {
    test('a learner who undoes their own pick has nothing to apply', () {
      final draft = CompanionDraft.of(_worn)
          .withRoast('light')
          .withRoast(
            _worn.roast,
          );

      expect(draft.isDirtyAgainst(_worn), isFalse);
    });

    test('re-picking what is already worn is not a change', () {
      expect(
        CompanionDraft.of(_worn).withHat(_worn.hat).isDirtyAgainst(_worn),
        isFalse,
      );
    });
  });
}
