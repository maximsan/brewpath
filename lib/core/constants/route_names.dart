/// Named-route path constants for the app's go_router configuration.
abstract class RouteNames {
  /// Learn tab root — the module list.
  static const learn = '/learn';

  /// A single learning module's detail screen.
  static const moduleDetail = '/learn/module/:moduleId';

  /// An immersive single-lesson flow.
  static const lesson = '/learn/lesson/:lessonId';

  /// Path tab — the progress journey.
  static const path = '/path';

  /// Cards tab — the collected-cards grid.
  static const cards = '/cards';

  /// A single collected card's detail screen.
  static const cardDetail = '/cards/:cardId';

  /// A screen with favorite cards
  static const favorites = '/cards/favorites';

  /// Profile tab.
  static const profile = '/profile';
}
