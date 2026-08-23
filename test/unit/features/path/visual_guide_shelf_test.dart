import 'package:brew_path/features/path/domain/visual_guide_shelf.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
