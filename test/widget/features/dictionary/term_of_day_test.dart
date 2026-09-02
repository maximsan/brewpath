import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/dictionary/domain/term_of_day.dart';
import 'package:brew_path/features/dictionary/presentation/term_of_day_banner.dart';
import 'package:brew_path/features/dictionary/presentation/term_of_day_copy.dart';
import 'package:brew_path/features/dictionary/presentation/term_of_day_screen.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/widget_harness.dart';

/// A day to pin the pick to, so the assertions below name a real term rather
/// than whatever the machine's clock makes today.
final _pinnedDay = DateTime(2026, 9, 2);

/// The term that day lands on for [hasCourse], read from the same bank the app
/// ships — the expected value is derived, never transcribed, so authoring a new
/// word cannot silently make this test assert the wrong one.
///
/// Read through `runAsync`, because loading the bank is real file I/O: awaited
/// inside the test's fake-async zone it never completes, and the test hangs
/// rather than fails.
Future<DictionaryTerm> _expectedTerm(
  WidgetTester tester, {
  required bool hasCourse,
}) async {
  final term = await tester.runAsync(() async {
    final terms = await DictionaryRepository().getTerms();
    return termOfDay(
      pool: termOfDayPool(terms: terms, hasCourse: hasCourse),
      date: _pinnedDay,
    );
  });
  return term!;
}

/// What the full entry resolves to in the harness below — the term id it was
/// asked for, so the assertion can name *which* entry opened rather than only
/// that something did.
class _EntryStub extends StatelessWidget {
  const _EntryStub({required this.termId});

  final String termId;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('entry:$termId')));
}

/// Today's term for a free learner, against the real clock — what both
/// surfaces should be naming when nothing is pinned.
Future<DictionaryTerm> _todaysTerm(WidgetTester tester) async {
  final term = await tester.runAsync(() async {
    final terms = await DictionaryRepository().getTerms();
    return termOfDay(
      pool: termOfDayPool(terms: terms, hasCourse: false),
      date: DateTime.now(),
    );
  });
  return term!;
}

/// Opens the screen on [_pinnedDay] for a learner of the given tier.
///
/// Hosted on a small router rather than a bare `MaterialApp`: the screen's one
/// action navigates, and a host with no router turns *"does it open the
/// entry?"* into a crash rather than an answer. Not the real shell either —
/// booting it once per test collides on the router's global navigator keys.
Future<void> _pumpScreen(
  WidgetTester tester, {
  required bool hasCourse,
}) async {
  _useTallViewport(tester);
  final container = ProviderContainer(
    overrides: [
      currentDayProvider.overrideWithValue(_pinnedDay),
      courseEntitlementProvider.overrideWith((ref) async => hasCourse),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.cupping,
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const TermOfDayScreen(),
              routes: [
                GoRoute(
                  path: AppRoutes.dictionaryTerm.path,
                  name: AppRoutes.dictionaryTerm.name,
                  builder: (context, state) =>
                      _EntryStub(termId: state.pathParameters['termId']!),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  await _settleProviders(tester);
}

/// Waits for the screen's providers without ever settling.
///
/// **Not `settleLoaders`.** That helper ends on a `pumpAndSettle`, which its
/// own comment says hangs on Roasty's idle animation — and this screen mounts
/// Roasty as soon as it has a term. So the loop below is the same real-time
/// polling with the settle left off.
Future<void> _settleProviders(WidgetTester tester) async {
  await tester.pump();
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    final loading = find.byType(CircularProgressIndicator).evaluate();
    if (loading.isEmpty && attempt >= 2) break;
  }
}

/// Bounded pumps rather than `pumpAndSettle`, for the same reason.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// A tall viewport, so the whole screen lays out rather than being clipped.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Opens the dictionary in the real shell, the way a learner reaches it.
Future<void> _openDictionary(WidgetTester tester) async {
  _useTallViewport(tester);
  final container = await pumpWithProviders(tester, const BrewPathApp());
  container.read(appRouterProvider).go('/learn/dictionary');
  await settleLoaders(tester);
}

void main() {
  setUp(useInMemoryDatabase);

  group('the screen', () {
    testWidgets('shows the day, the word and what it means', (tester) async {
      final term = await _expectedTerm(tester, hasCourse: false);
      await _pumpScreen(tester, hasCourse: false);

      expect(find.text(TermOfDayCopy.title.toUpperCase()), findsOneWidget);
      expect(find.text(longDate(_pinnedDay).toUpperCase()), findsOneWidget);
      expect(find.text(term.term), findsOneWidget);
      expect(find.text(term.shortExplanation), findsOneWidget);
    });

    testWidgets('the short explanation is what it offers, never the full one', (
      tester,
    ) async {
      final term = await _expectedTerm(tester, hasCourse: false);
      await _pumpScreen(tester, hasCourse: false);

      expect(term.deepExplanation, isNotNull);
      expect(
        find.text(term.deepExplanation!),
        findsNothing,
        reason: 'the full entry is what the button leads to, not what is shown',
      );
    });
  });

  group('"Read the full entry"', () {
    testWidgets('opens the entry for a learner who owns the course', (
      tester,
    ) async {
      final term = await _expectedTerm(tester, hasCourse: true);
      await _pumpScreen(tester, hasCourse: true);

      await tester.tap(find.text(TermOfDayCopy.readFullEntry));
      await _settle(tester);

      expect(find.text('entry:${term.id}'), findsOneWidget);
      expect(
        find.text(LockedFullEntry(term: term.term).header),
        findsNothing,
        reason: 'they own it; there is nothing to sell them',
      );
    });

    testWidgets('raises the gate for a learner who does not', (tester) async {
      final term = await _expectedTerm(tester, hasCourse: false);
      await _pumpScreen(tester, hasCourse: false);

      await tester.tap(find.text(TermOfDayCopy.readFullEntry));
      await _settle(tester);

      expect(
        find.text(LockedFullEntry(term: term.term).header),
        findsOneWidget,
        reason:
            'the label promises the full entry, so it must not deliver '
            'the short one they are already reading',
      );
    });
  });

  group('the banner', () {
    testWidgets('leads the dictionary index', (tester) async {
      await _openDictionary(tester);

      expect(find.byType(TermOfDayBanner), findsOneWidget);
      expect(find.text(TermOfDayCopy.openEntry.toUpperCase()), findsOneWidget);
    });

    testWidgets('opens the screen, on the same word it was showing', (
      tester,
    ) async {
      await _openDictionary(tester);
      // The real clock, not a pinned day: this is the path that proves the
      // frozen date is gone, so it has to run against whatever today is.
      final today = await _todaysTerm(tester);

      expect(
        find.text(today.term),
        findsOneWidget,
        reason: 'the banner names the term the pick chose for today',
      );

      await tester.tap(find.text(TermOfDayCopy.openEntry.toUpperCase()));
      await _settle(tester);

      expect(find.byType(TermOfDayScreen), findsOneWidget);
      expect(find.text(TermOfDayCopy.readFullEntry), findsOneWidget);
      expect(
        find.text(today.term),
        findsOneWidget,
        reason: 'and the screen it opens names the same one',
      );
    });

    testWidgets('scrolls with the index rather than overflowing it', (
      tester,
    ) async {
      // No tall viewport: a phone-height screen is the case that caught this.
      // Fixed above the list, the banner overflowed the column by 19px, and a
      // widget test fails on an overflow — so rendering here *is* the
      // assertion.
      final container = await pumpWithProviders(tester, const BrewPathApp());
      container.read(appRouterProvider).go('/learn/dictionary');
      await settleLoaders(tester);

      expect(find.byType(TermOfDayBanner), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('stands down once the learner starts searching', (
      tester,
    ) async {
      await _openDictionary(tester);

      await tester.enterText(find.byType(TextField), 'crema');
      await _settle(tester);

      expect(
        find.byType(TermOfDayBanner),
        findsNothing,
        reason:
            'a learner who is searching has already said what they came '
            'for; the offer would be in the way of it',
      );
    });
  });
}
