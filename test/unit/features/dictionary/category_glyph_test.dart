import 'package:brew_path/features/dictionary/domain/category_glyph.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every category the bank ships has its own mark', () async {
    // Asserted against the real bank, not a list written here: a category
    // added without a mark would otherwise ship drawing nothing, and the
    // screen that lists them is the one place that would show it.
    final categories = await DictionaryRepository().getCategories();
    expect(categories, isNotEmpty);

    for (final category in categories) {
      expect(
        categoryGlyph(category.id),
        isNotNull,
        reason: '${category.id} has no mark',
      );
    }
  });

  test('no two categories share a mark', () {
    // The design's own rule for this set: "no two topics share a mark".
    const ids = [
      'beans',
      'processing',
      'roasting',
      'brewing',
      'espresso',
      'sensory',
      'equipment',
      'trade',
    ];
    final marks = ids.map(categoryGlyph).toList();

    expect(marks.toSet().length, ids.length);
  });

  test('an unknown category has no mark, rather than the wrong one', () {
    expect(categoryGlyph('fermentation'), isNull);
  });
}
