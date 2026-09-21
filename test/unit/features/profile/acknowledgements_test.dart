import 'package:brew_path/features/profile/domain/acknowledgements.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter_test/flutter_test.dart';

DictionaryTerm _term(String id, List<DictionarySource> sources) =>
    DictionaryTerm(
      id: id,
      term: id,
      categoryId: 'beans',
      shortExplanation: 'short',
      sources: sources,
    );

void main() {
  test('names a work once however many terms cite it', () {
    const sca = DictionarySource(label: 'SCA', url: 'https://sca.coffee');

    final sources = acknowledgedSources([
      _term('a', const [sca]),
      _term('b', const [sca]),
    ]);

    expect(sources, [sca]);
  });

  test('keeps one label twice when it carries two addresses', () {
    const print = DictionarySource(label: 'Barista Hustle');
    const online = DictionarySource(
      label: 'Barista Hustle',
      url: 'https://baristahustle.com',
    );

    final sources = acknowledgedSources([
      _term('a', const [print]),
      _term('b', const [online]),
    ]);

    expect(sources, hasLength(2));
  });

  test('orders by name, not by where the bank happens to put the term', () {
    final sources = acknowledgedSources([
      _term('a', const [DictionarySource(label: 'Zephyr')]),
      _term('b', const [DictionarySource(label: 'atlas')]),
      _term('c', const [DictionarySource(label: 'Barista Magazine')]),
    ]);

    expect(
      sources.map((source) => source.label),
      ['atlas', 'Barista Magazine', 'Zephyr'],
    );
  });

  test('a term with no sources contributes none', () {
    expect(acknowledgedSources([_term('masl', const [])]), isEmpty);
  });
}
