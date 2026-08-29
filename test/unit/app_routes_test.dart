import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/widget_harness.dart';

/// Guards name↔path sync: each [AppRoute] declares its name and path together,
/// and the router builds every `GoRoute` from them. These assertions resolve
/// each name back to its location so the two can never silently drift.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(useInMemoryDatabase);

  late ProviderContainer container;
  late GoRouter router;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    router = container.read(appRouterProvider);
  });

  String locationOf(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
  }) => router.namedLocation(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
  );

  test('param-less routes resolve to their canonical paths', () {
    expect(locationOf(AppRoutes.loading.name), '/loading');
    expect(locationOf(AppRoutes.welcome.name), '/welcome');
    expect(locationOf(AppRoutes.onboardingGoal.name), '/onboarding/goal');
    expect(locationOf(AppRoutes.onboardingBrewer.name), '/onboarding/brewer');
    expect(locationOf(AppRoutes.learn.name), '/learn');
    expect(locationOf(AppRoutes.path.name), '/path');
    expect(locationOf(AppRoutes.cards.name), '/cards');
    expect(locationOf(AppRoutes.profile.name), '/profile');
    expect(locationOf(AppRoutes.profileSettings.name), '/profile/settings');
  });

  test('parametrized routes interpolate path parameters', () {
    expect(
      locationOf(
        AppRoutes.moduleDetail.name,
        pathParameters: {'moduleId': 'beans'},
      ),
      '/learn/module/beans',
    );
    expect(
      locationOf(AppRoutes.lesson.name, pathParameters: {'lessonId': 'l1'}),
      '/learn/lesson/l1',
    );
    expect(
      locationOf(AppRoutes.cardDetail.name, pathParameters: {'cardId': 'c1'}),
      '/cards/c1',
    );
  });

  test('lesson and lessonComplete carry their query parameters', () {
    expect(
      locationOf(
        AppRoutes.lesson.name,
        pathParameters: {'lessonId': 'l1'},
        queryParameters: {'review': 'true'},
      ),
      '/learn/lesson/l1?review=true',
    );
    expect(
      locationOf(
        AppRoutes.lessonComplete.name,
        pathParameters: {'lessonId': 'l1'},
        queryParameters: {
          'review': 'false',
          'practice': 'false',
          'score': '80',
        },
      ),
      '/learn/lesson/l1/complete?review=false&practice=false&score=80',
    );
  });

  /// Which chrome every registered route wears.
  ///
  /// The point is the **completeness** assertion below, not the values: a
  /// route added to the router without anyone deciding what chrome it gets
  /// would otherwise inherit one silently, which is the whole failure mode
  /// `headerTierFor` exists to prevent.
  const tierByName = <String, HeaderTier>{
    'loading': HeaderTier.immersive,
    'welcome': HeaderTier.immersive,
    // Meet Roasty is the same beat as Welcome — full bleed, no chrome, one
    // way forward.
    'meetRoasty': HeaderTier.immersive,
    'courseComplete': HeaderTier.immersive,
    'onboardingGoal': HeaderTier.immersive,
    'onboardingBrewer': HeaderTier.immersive,
    'learn': HeaderTier.tabRoot,
    'path': HeaderTier.tabRoot,
    'cards': HeaderTier.tabRoot,
    'profile': HeaderTier.tabRoot,
    'saved': HeaderTier.pushed,
    'dictionary': HeaderTier.pushed,
    'dictionaryTerm': HeaderTier.pushed,
    'moduleDetail': HeaderTier.pushed,
    'cardDetail': HeaderTier.pushed,
    'profileSettings': HeaderTier.pushed,
    // Root navigator like Settings, and its own back-arrow bar — pushed is
    // about the chrome the learner sees, not the navigator underneath.
    'profileStreak': HeaderTier.pushed,
    // Two pushes deep — Settings, then the guide — and it carries a back-arrow
    // bar of its own, the same as the screen it was opened from.
    'appGuide': HeaderTier.pushed,
    // Its own bar with a close icon, over the shell — pushed, like the
    // streak view it sits beside.
    'profileTree': HeaderTier.pushed,
    'lesson': HeaderTier.immersive,
    'lessonComplete': HeaderTier.immersive,
    'moduleSummary': HeaderTier.immersive,
    'miniGameIntro': HeaderTier.immersive,
    'miniGamePlay': HeaderTier.immersive,
    'onboardingName': HeaderTier.immersive,
  };

  test('every registered route has a decided chrome tier', () {
    final registered = <String>{};
    void walk(List<RouteBase> routes) {
      for (final route in routes) {
        if (route is GoRoute && route.name != null) registered.add(route.name!);
        walk(route.routes);
        if (route is StatefulShellRoute) {
          for (final branch in route.branches) {
            walk(branch.routes);
          }
        }
      }
    }

    walk(router.configuration.routes);

    expect(
      registered.difference(tierByName.keys.toSet()),
      isEmpty,
      reason: 'a route was added without deciding what chrome it wears',
    );
    expect(
      tierByName.keys.toSet().difference(registered),
      isEmpty,
      reason: 'the tier table names a route the router no longer has',
    );
  });
}
