import 'package:brew_path/features/dictionary/domain/save_swipe_nudge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? target(List<String> ids, {Set<String> saved = const {}}) =>
      firstUnsavedAboveFold(ids, isSaved: saved.contains);

  test('teaches on the first row when nothing is saved', () {
    expect(target(const ['a', 'b', 'c']), 'a');
  });

  test('skips saved rows, which damp and would demonstrate nothing', () {
    expect(target(const ['a', 'b', 'c'], saved: const {'a', 'b'}), 'c');
  });

  test('never reaches past the fold, where the caption cannot be checked', () {
    final rows = List.generate(dictionaryRowsAboveFold + 3, (i) => 'row$i');
    final saved = rows.take(dictionaryRowsAboveFold).toSet();

    expect(firstUnsavedAboveFold(rows, isSaved: saved.contains), isNull);
  });

  test('teaches on the last reachable row when it is the only unsaved one', () {
    final rows = List.generate(dictionaryRowsAboveFold, (i) => 'row$i');
    final saved = rows.take(dictionaryRowsAboveFold - 1).toSet();

    expect(
      firstUnsavedAboveFold(rows, isSaved: saved.contains),
      'row${dictionaryRowsAboveFold - 1}',
    );
  });

  test('nudges nothing when the list is empty', () {
    expect(target(const []), isNull);
  });

  test('handles a list shorter than the fold', () {
    expect(target(const ['a'], saved: const {'a'}), isNull);
    expect(target(const ['a']), 'a');
  });
}
