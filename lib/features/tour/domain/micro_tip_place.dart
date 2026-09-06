import 'package:brew_path/core/constants/app_routes.dart';

/// Where the learner is, as the micro-tip layer sees it.
///
/// Coarser than the route table on purpose: the layer only has to tell apart
/// the places a tip fires on, the places a tip may *land* on after a save, and
/// everywhere a tip must never appear. A screen that is none of those is
/// [elsewhere], which is the whole "never inside a lesson, a mini-game or a
/// drill" rule in one value.
enum TipPlace {
  /// The Learn tab's root — the day's work, where the challenge, tree and
  /// freeze tips fire.
  learnTab,

  /// The Path tab's root.
  pathTab,

  /// The Coffee Dictionary's index. Not a term inside it: the design fires the
  /// dictionary tip on the index alone, where the search and the drills it
  /// talks about are.
  dictionary,

  /// The Studio. Reached over the tab bar, which is why it is its own place
  /// rather than one more in-shell screen.
  studio,

  /// Today's term, on a page of its own. Over the tab bar like the Studio, and
  /// a place a term can be saved from.
  termOfDay,

  /// Any other screen inside the tab shell — the Saved shelf, a term, the
  /// collection, Profile. No tip fires here, but a save can happen, so the
  /// saved tip may land.
  otherInShell,

  /// Everywhere a tip must never appear: a lesson and its ending, a mini-game,
  /// a drill, settings, and the whole onboarding flow.
  elsewhere;

  /// Whether the bottom tab bar is on screen here, which is what the design
  /// raises the card clear of.
  bool get showsTabBar => switch (this) {
    learnTab || pathTab || dictionary || otherInShell => true,
    studio || termOfDay || elsewhere => false,
  };

  /// Whether a tip that has already been chosen may show here.
  bool get takesTips => this != elsewhere;
}

final String _learn = AppRoutes.learn.path;
final String _profile = AppRoutes.profile.path;

/// The addresses the layer names, spelled from the route catalogue rather than
/// re-typed, so a path change cannot leave this pointing at nothing.
final String _dictionaryPath = '$_learn/${AppRoutes.dictionary.path}';
final String _termOfDayPath = '$_learn/${AppRoutes.termOfDay.path}';
final String _savedPath = '$_learn/${AppRoutes.saved.path}';
final String _studioPath = '$_profile/${AppRoutes.studio.path}';

/// Which [TipPlace] [location] is.
///
/// A pure function of the address, so the rule can be read and tested without
/// a router. Unlisted addresses fall to [TipPlace.elsewhere]: a new screen owes
/// the learner nothing until someone decides a tip belongs on it, and silence
/// is the safe answer.
TipPlace tipPlaceFor(String location) {
  if (location == _learn) return TipPlace.learnTab;
  if (location == AppRoutes.path.path) return TipPlace.pathTab;
  if (location == _dictionaryPath) return TipPlace.dictionary;
  if (location == _studioPath) return TipPlace.studio;
  if (location == _termOfDayPath) return TipPlace.termOfDay;
  if (location == _savedPath || location == _profile) {
    return TipPlace.otherInShell;
  }
  // A term sits under the dictionary and keeps the tab bar; the collection's
  // one child is a sheet over the grid, so anything under `/cards` is the tab.
  if (location.startsWith('$_dictionaryPath/') ||
      location == AppRoutes.cards.path ||
      location.startsWith('${AppRoutes.cards.path}/')) {
    return TipPlace.otherInShell;
  }
  return TipPlace.elsewhere;
}
