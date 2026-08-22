import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The dictionary the app actually ships, asserted against the bundled banks.
///
/// Counts are derived, never quoted: the catalog has grown several times, and
/// a test that hardcodes a total fails on authoring rather than on a defect.
/// What is pinned is what would change *meaning* if it moved — chiefly which
/// terms no lesson teaches.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DictionaryRepository dictionary;
  late ContentRepository content;

  setUp(() {
    dictionary = DictionaryRepository();
    content = ContentRepository();
  });

  group('the dictionary', () {
    test('loads every term and every category off the bundled banks', () async {
      expect(await dictionary.getTerms(), isNotEmpty);
      expect(await dictionary.getCategories(), isNotEmpty);
    });

    test('gives every term a category that resolves', () async {
      final terms = await dictionary.getTerms();
      final categoryIds = {
        for (final category in await dictionary.getCategories()) category.id,
      };

      for (final term in terms) {
        expect(
          categoryIds,
          contains(term.categoryId),
          reason: '${term.id} points at category ${term.categoryId}',
        );
      }
    });

    test('gives every related pointer a term that resolves', () async {
      final terms = await dictionary.getTerms();
      final termIds = {for (final term in terms) term.id};

      for (final term in terms) {
        for (final relatedId in term.relatedIds) {
          expect(
            termIds,
            contains(relatedId),
            reason: '${term.id} relates to $relatedId',
          );
        }
      }
    });

    test('gives every lesson pointer a lesson that resolves', () async {
      final terms = await dictionary.getTerms();
      final lessonIds = {for (final lesson in await content.getLessons()) lesson.id};

      for (final term in terms.where((t) => t.lessonId != null)) {
        expect(
          lessonIds,
          contains(term.lessonId),
          reason: '${term.id} is taught by ${term.lessonId}',
        );
      }
    });

    test('carries exactly the eight terms no lesson teaches', () async {
      final terms = await dictionary.getTerms();
      expect(
        terms.where((t) => t.isReferenceOnly).map((t) => t.id),
        unorderedEquals([
          'masl',
          'wet-hulled',
          'tds',
          'cold-brew',
          'cupping',
          'gooseneck',
          'sca',
          'origin-boards',
        ]),
        reason: 'a term losing its lesson pointer silently becomes reference, '
            'which changes what the course promises about it',
      );
    });

    test('gives every term a short explanation, stub or not', () async {
      final terms = await dictionary.getTerms();
      for (final term in terms) {
        expect(term.shortExplanation, isNotEmpty, reason: term.id);
      }
    });

    test('gives every self-check exactly one correct choice', () async {
      final terms = await dictionary.getTerms();
      final checked = terms.where((t) => t.check != null);
      expect(checked, isNotEmpty, reason: 'no self-checks loaded at all');

      for (final term in checked) {
        expect(
          term.check!.choices.where((c) => c.isCorrect).length,
          1,
          reason: '${term.id} does not offer exactly one right answer',
        );
      }
    });
  });
}
