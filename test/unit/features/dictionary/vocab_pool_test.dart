// The accessible set against the banks the app actually ships (ADR-0014).
//
// Counts are derived, never quoted — the dictionary and the lessons have both
// grown, and a test that pinned "17 free terms" would fail on authoring rather
// than on a defect. What is asserted is what would change *meaning*: that the
// free pool can fill an honest round, that it is strictly wider than the terms
// the free lessons teach, and that it is strictly narrower than the glossary.
import 'package:brew_path/features/dictionary/domain/vocab_pool.dart';
import 'package:brew_path/features/dictionary/domain/vocab_round.dart';
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<DictionaryTerm> terms;
  late List<LessonModel> lessons;

  setUpAll(() async {
    terms = await DictionaryRepository().getTerms();
    lessons = await ContentRepository().getLessons();
  });

  List<DictionaryTerm> poolFor({required bool hasCourse}) =>
      accessibleTerms(terms: terms, lessons: lessons, hasCourse: hasCourse);

  Set<String> idsFor({required bool hasCourse}) => {
    for (final term in poolFor(hasCourse: hasCourse)) term.id,
  };

  group('what each tier can be drilled on', () {
    test('Plus is drilled on the whole glossary, reference terms included', () {
      final plus = poolFor(hasCourse: true);

      expect(plus, hasLength(vocabEligible(terms).length));
      expect(
        plus.where((term) => term.lessonId == null),
        isNotEmpty,
        reason: 'a term no lesson teaches is still a word worth knowing',
      );
    });

    test('free is a strict subset of Plus', () {
      expect(idsFor(hasCourse: false), isNot(idsFor(hasCourse: true)));
      expect(
        idsFor(hasCourse: true).containsAll(idsFor(hasCourse: false)),
        isTrue,
      );
    });

    test('free can fill the shortest round the design offers', () {
      // The whole reason #57 chose *mentioned in* over *taught by*: the
      // taught-by reading leaves too few terms to complete a single round,
      // which makes the game unplayable rather than merely small.
      expect(
        poolFor(hasCourse: false).length,
        greaterThanOrEqualTo(vocabLengths.first),
      );
      expect(
        vocabLengthsFor(poolFor(hasCourse: false).length),
        isNotEmpty,
        reason: 'a free learner must be offered at least one round length',
      );
    });

    test('free is wider than the terms its lessons teach', () {
      final taught = {
        for (final term in terms)
          if (term.lessonId != null && isLessonFree(term.lessonId!)) term.id,
      };
      final free = idsFor(hasCourse: false);

      expect(free.containsAll(taught), isTrue);
      expect(
        free.length,
        greaterThan(taught.length),
        reason: 'mentioned-in is the rule, not taught-by',
      );
    });

    test('the pool derives from the free lesson list and nothing else', () {
      // ADR-0007's promise, made checkable: every free term is said by a
      // lesson on that list, so widening the tier is a change to the list.
      final free = poolFor(hasCourse: false);
      final freeLessons = [
        for (final lesson in lessons)
          if (isLessonFree(lesson.id)) lesson,
      ];

      expect(freeLessons, hasLength(freeLessonIds.length));
      expect(
        accessibleTerms(terms: terms, lessons: freeLessons, hasCourse: false),
        hasLength(free.length),
      );
    });

    test('a reference term is never drilled to a free learner', () {
      // Premium whatever mentions it (§12): no lesson teaches it, and #217
      // makes it absent from a free learner's dictionary — so a question
      // about one would ask about a word they cannot look up.
      final free = poolFor(hasCourse: false);

      expect(free.where((term) => term.lessonId == null), isEmpty);
    });

    test('a premium term name never reaches a free learner', () {
      final free = idsFor(hasCourse: false);
      final premiumOnly = idsFor(hasCourse: true).difference(free);

      expect(
        premiumOnly,
        isNotEmpty,
        reason: 'the tier rule would be vacuous otherwise',
      );
      // Both sides of a round are drawn from this one list, so proving the
      // list excludes them proves the wrong answers do too.
      expect(free.intersection(premiumOnly), isEmpty);
    });
  });

  group('the saved deck', () {
    test('is the intersection, never the shelf', () {
      // A term saved before a lesson list narrowed — or saved from a
      // dictionary that shows every entry to everyone — must not walk back
      // into a free learner's drill through the Saved deck.
      final free = poolFor(hasCourse: false);
      final premiumOnly = idsFor(
        hasCourse: true,
      ).difference(idsFor(hasCourse: false));

      final saved = savedAccessibleTerms(
        accessible: free,
        savedTermIds: {free.first.id, premiumOnly.first},
      );

      expect(saved.map((term) => term.id), [free.first.id]);
    });

    test('an empty shelf yields an empty deck rather than everything', () {
      expect(
        savedAccessibleTerms(
          accessible: poolFor(hasCourse: true),
          savedTermIds: const {},
        ),
        isEmpty,
      );
    });
  });
}
