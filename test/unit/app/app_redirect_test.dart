import 'package:brew_path/app/app_redirect.dart';
import 'package:brew_path/app/pending_link.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

String? redirect(
  String location, {
  bool onboarded = true,
  bool entitled = true,
  bool completionDue = false,
  PendingLink? pending,
}) => redirectFor(
  location: Uri.parse(location),
  onboardingCompleted: onboarded,
  courseEntitled: entitled,
  courseCompletionDue: completionDue,
  pending: pending ?? PendingLink(),
);

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
      expect(redirect('/onboarding/goal', onboarded: false), isNull);
    });

    test('a finished learner is bounced out of the intro', () {
      expect(redirect('/welcome'), AppRoutes.learn.path);
      expect(redirect('/onboarding/goal'), AppRoutes.learn.path);
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
