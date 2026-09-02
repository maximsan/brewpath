import 'package:brew_path/features/cards/domain/card_unlock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('earnLine', () {
    test('names the lesson when the card comes from one', () {
      expect(
        earnLine(lessonTitle: 'What coffee actually is', moduleTag: 'Beans'),
        'Earn this by completing What coffee actually is',
      );
    });

    test('falls back to the module when no lesson awards the card', () {
      // A module-awarded card has no lesson to name, and a card whose lesson
      // this build does not carry must still say something true.
      expect(
        earnLine(lessonTitle: null, moduleTag: 'Beans'),
        'Earn this by finishing Beans',
      );
    });

    test('an empty lesson title is treated as no lesson', () {
      expect(
        earnLine(lessonTitle: '', moduleTag: 'Beans'),
        'Earn this by finishing Beans',
      );
    });
  });
}
