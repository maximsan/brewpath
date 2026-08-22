import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/utils/date_utils.dart';

/// Which chrome a location wears, and what the shared header calls itself.
///
/// One rule, in one place. Four screens each answering the question their own
/// way is how the app ended up with three placeholder bars and a fourth header
/// that was nothing like them.

/// The kind of chrome a location gets.
enum HeaderTier {
  /// One of the four branch roots: wears the shared, shell-owned header.
  tabRoot,

  /// Pushed inside a branch — a module, a card, a term. Brings its own bar
  /// with a back arrow, so the shared header must stay out of its way.
  pushed,

  /// Escapes the shell entirely: lessons, mini-games, settings, onboarding.
  /// Shows no shell chrome because the shell is not on screen.
  immersive;

  /// Whether the shell draws its header here. Only [tabRoot] does.
  bool get showsSharedHeader => this == HeaderTier.tabRoot;
}

/// A tab's two-line heading: a smallcaps eyebrow over a display title.
class HeaderTitle {
  /// Creates a [HeaderTitle].
  const HeaderTitle({required this.eyebrow, required this.title});

  /// The smallcaps line above — `TODAY`, `YOUR PATH`.
  final String eyebrow;

  /// The display line — the day, the course, the collection.
  final String title;
}

/// The four branch roots, in bottom-nav order.
const List<AppRoute> _tabRoots = [
  AppRoutes.learn,
  AppRoutes.path,
  AppRoutes.cards,
  AppRoutes.profile,
];

/// Which chrome [location] wears.
///
/// A branch root is matched **exactly** — `/learn` is the Learn tab, while
/// `/learn/dictionary` is a page pushed on top of it and brings its own bar.
/// Anything under a branch that is not the root is [HeaderTier.pushed];
/// anything outside every branch never reaches the shell at all.
HeaderTier headerTierFor(String location) {
  if (_tabRoots.any((route) => route.path == location)) {
    return HeaderTier.tabRoot;
  }
  final branch = _tabRoots
      .where((route) => location.startsWith('${route.path}/'))
      .firstOrNull;
  if (branch == null) return HeaderTier.immersive;
  return _immersiveUnderBranch(location)
      ? HeaderTier.immersive
      : HeaderTier.pushed;
}

/// The routes that sit under a branch in the catalogue but escape the shell on
/// the root navigator, so no shell chrome is drawn over them.
const _immersiveSegments = [
  'lesson/',
  'module-summary/',
  'mini-game/',
  'settings',
];

bool _immersiveUnderBranch(String location) =>
    _immersiveSegments.any((segment) => location.contains('/$segment'));

/// What the shared header calls itself at [location], or null where it does
/// not draw.
///
/// [today] is passed in rather than read from a clock so the title is a pure
/// function of its inputs — the caller owns freshness, and the app already has
/// one place that decides when *today* changed.
HeaderTitle? headerTitleFor(String location, {DateTime? today}) {
  if (headerTierFor(location) != HeaderTier.tabRoot) return null;

  if (location == AppRoutes.learn.path) {
    final day = today ?? DateTime.now();
    return HeaderTitle(
      eyebrow: 'TODAY',
      title: longDate(day),
    );
  }
  if (location == AppRoutes.path.path) {
    return const HeaderTitle(
      eyebrow: 'YOUR PATH',
      title: 'Beginner Foundations',
    );
  }
  if (location == AppRoutes.cards.path) {
    return const HeaderTitle(eyebrow: 'YOUR DECK', title: 'Collection');
  }
  // The design greets the learner by name; nothing in the app captures one, so
  // the greeting stands on its own rather than inventing a field to fill it.
  return const HeaderTitle(eyebrow: 'PROFILE', title: 'Hello there.');
}
