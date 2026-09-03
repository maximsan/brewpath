import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/monetization/domain/lesson_access.dart';
import 'package:flutter_test/flutter_test.dart';

/// The one rule every surface asks. Path draws it, Today sells it and the
/// router enforces it, so a disagreement between them would be three answers
/// to one question — the failure ADR-0016 was written after.
void main() {
  /// Read off the free set rather than written down: growing that list must
  /// change what these tests assert, not silently stop them asserting it.
  final free = freeLessonIds.first;
  const paid = 'm5l4';

  test('the fixture is what these tests say it is', () {
    expect(isLessonFree(free), isTrue);
    expect(isLessonFree(paid), isFalse);
  });

  test('a free lesson is open to everyone, for good', () {
    expect(
      isLessonPurchaseLocked(
        lessonId: free,
        hasCourse: false,
        isCompleted: false,
      ),
      isFalse,
    );
    // Replay is part of what the free tier carries — finishing it takes
    // nothing back.
    expect(
      isLessonPurchaseLocked(
        lessonId: free,
        hasCourse: false,
        isCompleted: true,
      ),
      isFalse,
    );
  });

  test('every other lesson is behind the purchase', () {
    expect(
      isLessonPurchaseLocked(
        lessonId: paid,
        hasCourse: false,
        isCompleted: false,
      ),
      isTrue,
    );
  });

  test('owning the course locks nothing', () {
    expect(
      isLessonPurchaseLocked(
        lessonId: paid,
        hasCourse: true,
        isCompleted: false,
      ),
      isFalse,
    );
  });

  test('a lesson already finished never locks (ADR-0016)', () {
    // What the practice list depends on: it offers finished lessons only, so
    // every row in it is a row the gate lets through.
    expect(
      isLessonPurchaseLocked(
        lessonId: paid,
        hasCourse: false,
        isCompleted: true,
      ),
      isFalse,
    );
  });

  test('the whole free set is free, not just the first of it', () {
    for (final lessonId in freeLessonIds) {
      expect(
        isLessonPurchaseLocked(
          lessonId: lessonId,
          hasCourse: false,
          isCompleted: false,
        ),
        isFalse,
        reason: lessonId,
      );
    }
  });
}
