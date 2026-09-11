import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter_test/flutter_test.dart';

const _worn = CompanionConfig(
  roast: 'dark',
  hat: 'beanie',
  gear: 'shades',
  sprout: 'cherry',
);

void main() {
  group('copyWith — one axis at a time, which is how the wardrobe edits', () {
    test('the roast leaves the other three alone', () {
      expect(
        _worn.copyWith(roast: 'light'),
        const CompanionConfig(
          roast: 'light',
          hat: 'beanie',
          gear: 'shades',
          sprout: 'cherry',
        ),
      );
    });

    test('the hat leaves the other three alone', () {
      expect(_worn.copyWith(hat: 'cap').roast, 'dark');
      expect(_worn.copyWith(hat: 'cap').hat, 'cap');
      expect(_worn.copyWith(hat: 'cap').gear, 'shades');
      expect(_worn.copyWith(hat: 'cap').sprout, 'cherry');
    });

    test('the gear leaves the other three alone', () {
      expect(_worn.copyWith(gear: 'scarf').hat, 'beanie');
      expect(_worn.copyWith(gear: 'scarf').gear, 'scarf');
    });

    test('the sprout leaves the other three alone', () {
      expect(_worn.copyWith(sprout: 'bare').gear, 'shades');
      expect(_worn.copyWith(sprout: 'bare').sprout, 'bare');
    });

    test('naming nothing changes nothing', () {
      expect(_worn.copyWith(), _worn);
    });

    test('re-picking what is already on is not a change', () {
      expect(_worn.copyWith(hat: 'beanie') == _worn, isTrue);
    });
  });
}
