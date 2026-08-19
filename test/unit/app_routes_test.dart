import 'package:brew_path/app/app_router.dart';
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
      locationOf(
        AppRoutes.practiceLesson.name,
        pathParameters: {'lessonId': 'l1'},
      ),
      '/learn/practice/lesson/l1',
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
}
