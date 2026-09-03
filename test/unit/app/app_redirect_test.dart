import 'package:brew_path/app/app_redirect.dart';
import 'package:brew_path/app/pending_link.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:flutter_test/flutter_test.dart';

GateDecision decide(
  String location, {
  bool onboarded = true,
  bool entitled = true,
  bool completionDue = false,
  Set<String> completed = const {},
  PendingLink? pending,
}) => redirectFor(
  location: Uri.parse(location),
  gates: GateState(
    onboardingCompleted: onboarded,
    courseEntitled: entitled,
    courseCompletionDue: completionDue,
    completedLessonIds: completed,
  ),
  pending: pending ?? PendingLink(),
);

/// Where a location is sent, which is what most of these tests are about.
String? redirect(
  String location, {
  bool onboarded = true,
  bool entitled = true,
  bool completionDue = false,
  Set<String> completed = const {},
  PendingLink? pending,
}) => decide(
  location,
  onboarded: onboarded,
  entitled: entitled,
  completionDue: completionDue,
  completed: completed,
  pending: pending,
).location;

/// The free set's own first entry, so growing that list cannot leave these
/// tests asserting about a lesson the tier no longer carries.
final String _freeLesson = freeLessonIds.first;

/// A lesson the free tier does not carry — checked against the rule below
/// rather than trusted.
const String _paidLesson = 'm5l4';

String _run(String lessonId) => '/learn/lesson/$lessonId';

void main() {
  group('the gates that were already there', () {
    test('the platform root funnels to Loading', () {
      expect(redirect('/'), AppRoutes.loading.path);
    });

    test('an un-onboarded learner is sent to Welcome', () {
      expect(redirect('/learn', onboarded: false), AppRoutes.welcome.path);
    });

    test('onboarding routes are left alone while it runs', () {
      expect(redirect('/welcome', onboarded: false), isNull);
      expect(redirect('/onboarding/name', onboarded: false), isNull);
    });

    test('a finished learner is bounced out of the intro', () {
      expect(redirect('/welcome'), AppRoutes.learn.path);
      expect(redirect('/onboarding/name'), AppRoutes.learn.path);
    });

    test('the Studio needs the entitlement', () {
      expect(redirect('/profile/studio', entitled: false), '/profile');
      expect(redirect('/profile/studio'), isNull);
    });

    test('the completion moment intercepts Today only', () {
      expect(redirect('/learn', completionDue: true), '/course-complete');
      expect(redirect('/cards', completionDue: true), isNull);
    });
  });

  group('the course wall', () {
    test('the fixture is what these tests say it is', () {
      // Guards every expectation below: if the free set ever grew to cover
      // this lesson, the gate tests would pass by asserting nothing.
      expect(isLessonFree(_paidLesson), isFalse);
      expect(isLessonFree(_freeLesson), isTrue);
    });

    test('a free lesson opens, and opens again', () {
      expect(redirect(_run(_freeLesson), entitled: false), isNull);
    });

    test('a paid lesson is refused, and the refusal is reported', () {
      final decision = decide(_run(_paidLesson), entitled: false);

      expect(decision.location, AppRoutes.learn.path);
      // Named, so the bounce can be followed by an offer rather than leaving
      // the learner somewhere they did not ask for with no word about why.
      expect(decision.refusedLesson, _paidLesson);
    });

    test('owning the course opens it', () {
      expect(redirect(_run(_paidLesson)), isNull);
    });

    test('a lesson already finished stays open (ADR-0016)', () {
      expect(
        redirect(
          _run(_paidLesson),
          entitled: false,
          completed: {_paidLesson},
        ),
        isNull,
      );
    });

    test("the run's ending is walled too", () {
      // Otherwise the ending is a way of claiming a lesson never played.
      expect(
        redirect('${_run(_paidLesson)}/complete', entitled: false),
        AppRoutes.learn.path,
      );
    });

    test('an unresolved entitlement reads as locked', () {
      // What every caller of `courseEntitlement` is asked to do: showing a
      // lock briefly to a paying learner is recoverable, the other way is not.
      expect(redirect(_run(_paidLesson), entitled: false), isNotNull);
    });

    test('the tab itself is not a lesson route', () {
      expect(redirect('/learn', entitled: false), isNull);
      expect(redirect('/learn/saved', entitled: false), isNull);
    });

    test('nothing else reports a refusal', () {
      // Every other gate moves the learner for a reason they can see, so an
      // offer raised off one of those bounces would come out of nowhere.
      expect(decide('/profile/studio', entitled: false).refusedLesson, isNull);
      expect(decide('/learn', completionDue: true).refusedLesson, isNull);
      expect(decide(_run(_freeLesson)).refusedLesson, isNull);
    });
  });

  group('reading a lesson out of a location', () {
    test('both lesson routes name their lesson', () {
      expect(lessonIdIn(Uri.parse('/learn/lesson/m2l1')), 'm2l1');
      expect(lessonIdIn(Uri.parse('/learn/lesson/m2l1/complete')), 'm2l1');
    });

    test('a query string is not part of the id', () {
      expect(
        lessonIdIn(Uri.parse('/learn/lesson/m2l1/complete?correct=4&total=5')),
        'm2l1',
      );
    });

    test('anything else is not a lesson', () {
      expect(lessonIdIn(Uri.parse('/learn')), isNull);
      expect(lessonIdIn(Uri.parse('/learn/lesson/')), isNull);
      expect(lessonIdIn(Uri.parse('/cards/c1')), isNull);
    });
  });

  group('a link survives onboarding', () {
    test('the target is held, not discarded, when the gate bounces it', () {
      final pending = PendingLink();

      expect(
        redirect('/cards/c1', onboarded: false, pending: pending),
        AppRoutes.welcome.path,
      );
      expect(pending.take(), '/cards/c1');
    });

    test('and is resolved once onboarding finishes', () {
      final pending = PendingLink();
      redirect('/cards/c1', onboarded: false, pending: pending);

      // The learner is standing on the last onboarding step when the gate
      // flips. Without this they land on Learn and never see the card they
      // installed the app for.
      expect(redirect('/onboarding/name', pending: pending), '/cards/c1');
    });

    test("and only once — the next navigation is the learner's own", () {
      final pending = PendingLink();
      redirect('/cards/c1', onboarded: false, pending: pending);
      redirect('/onboarding/name', pending: pending);

      expect(redirect('/cards', pending: pending), isNull);
    });

    test('the query a link carries is kept', () {
      final pending = PendingLink();
      redirect('/cards/c1?from=share', onboarded: false, pending: pending);

      expect(pending.take(), '/cards/c1?from=share');
    });

    test("the app's own navigation cannot clobber the arrival", () {
      final pending = PendingLink();
      redirect('/cards/c1', onboarded: false, pending: pending);

      // Finishing onboarding writes the row and invalidates the gate, then
      // navigates to Learn without waiting for the recompute — so the
      // redirect runs for `/learn` while the gate still reads false. That
      // internal hop must not become the thing the learner is resumed onto.
      redirect('/learn', onboarded: false, pending: pending);

      expect(redirect('/welcome', pending: pending), '/cards/c1');
    });

    test('nothing is held when the learner never arrived on a link', () {
      final pending = PendingLink();
      redirect('/welcome', onboarded: false, pending: pending);

      expect(pending.take(), isNull);
    });
  });
}
