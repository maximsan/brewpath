import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every category the bank ships gets its own mark', () async {
    // Asserted against the real bank, not a list written here. `moduleMark`
    // falls back to `beans` for a name the design has never drawn, so a new
    // category would silently share a mark rather than draw none — which is
    // the design's one rule for this set: "no two topics share a mark".
    final categories = await DictionaryRepository().getCategories();
    expect(categories, isNotEmpty);

    final marks = categories.map((c) => moduleMark(c.id)).toList();
    expect(
      marks.toSet().length,
      categories.length,
      reason: 'two categories fell back to the same mark',
    );
  });

  test('a topic the design never drew falls back, and says so', () {
    // Documented on `moduleMark`: reaching the fallback means content named a
    // topic the design has not drawn, which is a design question.
    expect(moduleMark('fermentation'), AppIcon.beans);
  });
}
