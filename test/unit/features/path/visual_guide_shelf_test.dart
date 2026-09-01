import 'package:brew_path/features/path/domain/visual_guide_shelf.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

VisualGuide _guide(String subject, String lesson) => VisualGuide(
  id: 'g-$subject',
  subject: subject,
  unlock: VisualGuideUnlock(lesson: lesson),
  label: subject.toUpperCase(),
  title: subject,
  summary: 'summary',
  fact: 'fact',
);

/// Bank order, which the shelf must preserve.
final List<VisualGuide> _guides = [
  _guide('variety', 'm1l6'),
  _guide('anatomy', 'm1l7'),
  _guide('roast', 'm3l1'),
];

void main() {
  test('nothing complete gives an empty shelf, and everything remaining', () {
    final shelf = deriveVisualGuideShelf(_guides, const {});
    expect(shelf.earned, isEmpty);
    expect(shelf.remaining, 3);
    expect(shelf.isLocked, isTrue);
  });

  test('one qualifying completion earns one guide', () {
    final shelf = deriveVisualGuideShelf(_guides, const {'m1l6'});
    expect(shelf.earned.map((g) => g.subject), ['variety']);
    expect(shelf.remaining, 2);
    expect(shelf.isLocked, isFalse);
  });

  test('a completion that teaches nothing changes neither', () {
    final shelf = deriveVisualGuideShelf(_guides, const {'m2l1', 'm5l6'});
    expect(shelf.earned, isEmpty);
    expect(shelf.remaining, 3);
  });

  test('everything complete leaves nothing remaining', () {
    final shelf = deriveVisualGuideShelf(_guides, const {
      'm1l6',
      'm1l7',
      'm3l1',
    });
    expect(shelf.earned, hasLength(3));
    expect(shelf.remaining, 0);
  });

  test('earned guides keep bank order, not completion order', () {
    final shelf = deriveVisualGuideShelf(_guides, const {'m3l1', 'm1l6'});
    expect(
      shelf.earned.map((g) => g.subject),
      ['variety', 'roast'],
      reason: 'the guide opened yesterday must be where it was left',
    );
  });

  test('a locked guide never leaves the derivation', () {
    final shelf = deriveVisualGuideShelf(_guides, const {'m1l6'});
    expect(
      shelf.earned.map((g) => g.subject),
      isNot(contains('roast')),
      reason: 'the screen cannot render one by mistake if it never receives it',
    );
  });

  test('an empty bank is a locked shelf with nothing to promise', () {
    final shelf = deriveVisualGuideShelf(const [], const {'m1l6'});
    expect(shelf.earned, isEmpty);
    expect(shelf.remaining, 0);
    expect(shelf.isLocked, isTrue);
  });

  group('the next unlock', () {
    /// Course order, in which `m1l6` comes first — the guide bank is drawn in
    /// its own order, where the `m3l1` guide is listed first.
    final course = [
      for (final id in ['m1l6', 'm1l7', 'm3l1'])
        testLesson(id: id, title: 'Lesson $id'),
    ];

    test('names the earliest unearned guide by course order, not bank '
        'order', () {
      final title = nextGuideUnlockTitle(
        _guides,
        const {},
        courseLessons: course,
      );

      expect(
        title,
        'Lesson m1l6',
        reason:
            'the bank lists the m3l1 guide first; the learner meets m1l6 first',
      );
    });

    test('moves on as guides are earned', () {
      final title = nextGuideUnlockTitle(
        _guides,
        const {'m1l6'},
        courseLessons: course,
      );

      expect(title, 'Lesson m1l7');
    });

    test('nothing left to promise says nothing', () {
      final title = nextGuideUnlockTitle(
        _guides,
        const {'m1l6', 'm1l7', 'm3l1'},
        courseLessons: course,
      );

      expect(title, isNull);
    });

    test('a hint nobody can source is left unsaid', () {
      // No course order passed: the shelf declines to guess rather than
      // pointing at whichever guide the bank happens to list first.
      final title = nextGuideUnlockTitle(
        _guides,
        const {},
        courseLessons: const [],
      );

      expect(title, isNull);
    });
  });
}
