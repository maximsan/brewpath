import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/utils/date_utils.dart';

/// Which chrome a location wears, and what the shared header calls itself.
///
/// One rule, in one place. Four screens each answering the question their own
/// way is how the app ended up with three placeholder bars and a fourth header
/// that was nothing like them.

/// The kind of chrome a location gets.
///
/// ⚠️ **Tier is about chrome, not about which navigator a route sits on.**
/// Settings runs on the root navigator yet is [pushed], because what the
/// learner sees is a page with a back arrow. Conflating the two is how a route
/// ends up filed by its plumbing instead of by its appearance.
enum HeaderTier {
  /// One of the four branch roots: wears the shared, shell-owned header.
  tabRoot,

  /// A page the learner went *into* — a module, a card, a term, settings. It
  /// brings its own bar with a back arrow, so the shared header stays away.
  pushed,

  /// A flow with no chrome at all: a lesson, its ending, a mini-game.
  immersive;

  /// Whether the shell draws its header here. Only [tabRoot] does.
  bool get showsSharedHeader => this == HeaderTier.tabRoot;
}

/// Which standing entry the header offers on a tab.
enum HeaderAction {
  /// The way into the Coffee Dictionary, on Learn, Path and Cards.
  dictionary,

  /// The Settings gear, which *replaces* the entries on Profile rather than
  /// joining them.
  settings,
}

/// A tab's heading and the entry it offers.
class TabHeader {
  /// Creates a [TabHeader].
  const TabHeader({
    required this.eyebrow,
    required this.title,
    required this.action,
  });

  /// The smallcaps line above — `TODAY`, `YOUR PATH`.
  final String eyebrow;

  /// The display line — the day, the course, the collection.
  final String title;

  /// The entry on the right.
  final HeaderAction action;
}

/// The four branch roots, in bottom-nav order.
const List<AppRoute> _tabRoots = [
  AppRoutes.learn,
  AppRoutes.path,
  AppRoutes.cards,
  AppRoutes.profile,
];

/// The routes with no chrome at all. Named from the catalogue rather than
/// re-spelled, so a rename cannot leave this list pointing at nothing.
const List<AppRoute> _immersiveRoutes = [
  AppRoutes.lesson,
  AppRoutes.lessonComplete,
  AppRoutes.moduleSummary,
  AppRoutes.miniGameIntro,
  AppRoutes.miniGamePlay,
];

/// Which chrome [location] wears.
///
/// A branch root is matched **exactly** — `/learn` is the Learn tab, while
/// `/learn/dictionary` is a page pushed on top of it and brings its own bar.
HeaderTier headerTierFor(String location) {
  if (_tabRoots.any((route) => route.path == location)) {
    return HeaderTier.tabRoot;
  }
  final segments = location.split('/').where((s) => s.isNotEmpty).toList();
  if (_immersiveRoutes.any((route) => _startsSegment(segments, route.path))) {
    return HeaderTier.immersive;
  }
  final underBranch = _tabRoots.any(
    (route) => location.startsWith('${route.path}/'),
  );
  return underBranch ? HeaderTier.pushed : HeaderTier.immersive;
}

/// Whether [segments] contains [routePath]'s leading literal segment.
///
/// Whole segments, never a substring: a collectible id containing the word
/// "lesson" must not read as a lesson route.
bool _startsSegment(List<String> segments, String routePath) {
  final head = routePath.split('/').first;
  return head.isNotEmpty && segments.contains(head);
}

/// What the shared header shows at [location], or null where it does not draw.
///
/// [today] is required rather than defaulted, so this stays a pure function of
/// its inputs: the app already has one place that decides when *today* changed,
/// and a fallback clock here would quietly compete with it.
TabHeader? tabHeaderFor(String location, {required DateTime today}) {
  return switch (location) {
    _ when location == AppRoutes.learn.path => TabHeader(
      eyebrow: 'TODAY',
      title: longDate(today),
      action: HeaderAction.dictionary,
    ),
    _ when location == AppRoutes.path.path => const TabHeader(
      eyebrow: 'YOUR PATH',
      title: 'Beginner Foundations',
      action: HeaderAction.dictionary,
    ),
    _ when location == AppRoutes.cards.path => const TabHeader(
      eyebrow: 'YOUR DECK',
      title: 'Collection',
      action: HeaderAction.dictionary,
    ),
    // The design greets the learner by name; nothing in the app captures one,
    // so the greeting stands on its own rather than inventing a field.
    _ when location == AppRoutes.profile.path => const TabHeader(
      eyebrow: 'PROFILE',
      title: 'Hello there.',
      action: HeaderAction.settings,
    ),
    _ => null,
  };
}
