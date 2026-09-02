import 'package:brew_path/app/app_redirect.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_deep_link.dart';
import 'package:brew_path/features/cards/presentation/card_locked_face.dart';
import 'package:brew_path/features/cards/presentation/card_sheet.dart';
import 'package:brew_path/features/cards/presentation/cards_screen.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/content_fixtures.dart';

/// What a shared link does once it has been forwarded: the two behaviours that
/// only real navigation can answer — leaving the route the link arrived on,
/// and a second link landing on the page the first one is still using.
///
/// Deliberately a small router rather than the app's own: `appRouter` starts
/// on Loading, which navigates for itself, and a test that steers it is racing
/// the app's startup rather than testing anything.
final List<CardWithCollection> _collection = [
  testCardWithCollection('a', collected: true),
  testCardWithCollection('b', collected: false),
];

class _FakeContent extends ContentRepository {
  @override
  Future<List<LessonModel>> getLessons() async => [testLesson()];
}

const _coursePath = '/path';

Future<GoRouter> _pumpAt(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(420, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: '/cards',
        builder: (_, _) => const CardsScreen(),
        routes: [
          GoRoute(
            path: ':cardId',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              opaque: false,
              transitionsBuilder: (_, _, _, child) => child,
              child: CardDeepLink(cardId: state.pathParameters['cardId']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: _coursePath,
        // Named, because the deep-link page navigates by name — the repo's
        // rule, and what the real router registers.
        name: AppRoutes.path.name,
        builder: (_, _) => const Scaffold(body: Text('the course')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cardsWithCollectionProvider.overrideWith((ref) async => _collection),
        contentRepositoryProvider.overrideWith((ref) => _FakeContent()),
        challengeBankProvider.overrideWith((ref) async => []),
        completedChallengesProvider.overrideWith((ref) async => <String>{}),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  group('the address a shared link carries', () {
    test('forwards into the tab that reads a card', () {
      expect(forwardPublicCardAddress(Uri.parse('/card/c1')), '/cards/c1');
      expect(
        forwardPublicCardAddress(Uri.parse('/card/c-m2l1')),
        '/cards/c-m2l1',
      );
    });

    test('carries the query with it', () {
      expect(
        forwardPublicCardAddress(Uri.parse('/card/c1?from=share')),
        '/cards/c1?from=share',
      );
    });

    test('a path no card could own lands on the collection', () {
      // The AASA file claims `/card/*` and `*` matches across slashes, so the
      // app opens for these. Silence, never an error screen.
      expect(forwardPublicCardAddress(Uri.parse('/card/a/b')), '/cards');
      expect(forwardPublicCardAddress(Uri.parse('/card')), '/cards');
    });

    test('leaves the collection itself alone', () {
      expect(forwardPublicCardAddress(Uri.parse('/cards')), isNull);
      expect(forwardPublicCardAddress(Uri.parse('/cards/c1')), isNull);
      expect(forwardPublicCardAddress(Uri.parse('/learn')), isNull);
    });
  });

  group('what a link does once it lands', () {
    testWidgets('an unearned card offers the way in', (tester) async {
      await _pumpAt(tester, '/cards/b');

      expect(find.byType(CardLockedFace), findsOneWidget);
      expect(find.text('Go to the course'), findsOneWidget);
    });

    testWidgets('the way in leaves the link route behind it', (tester) async {
      final router = await _pumpAt(tester, '/cards/b');

      await tester.tap(find.text('Go to the course'));
      await tester.pumpAndSettle();

      expect(find.text('the course'), findsOneWidget);
      expect(find.byType(CardSheetBody), findsNothing);
      // The page the link arrived on must not be left standing under the
      // course, holding a pop nobody coordinates.
      expect(find.byType(CardDeepLink), findsNothing);
      expect(router.routerDelegate.currentConfiguration.uri.path, _coursePath);
    });

    testWidgets('a second link opens the second card', (tester) async {
      final router = await _pumpAt(tester, '/cards/a');
      expect(find.byType(CardSheetBody), findsOneWidget);

      // Same route, new id: go_router updates the page in place rather than
      // pushing, so anything remembering "already handled" must be keyed to
      // the card or the second link resolves nothing.
      router.go('/cards/b');
      await tester.pumpAndSettle();

      expect(find.byType(CardLockedFace), findsOneWidget);
    });
  });
}
