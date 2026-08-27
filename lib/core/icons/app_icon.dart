/// The six sets the design draws its marks in.
///
/// The set is not decoration: [AppIconSet.nav] is the master family every other
/// set defers to, so a concept drawn there is never redrawn elsewhere — the
/// Duel types reuse its Cup, Route and Globe rather than owning their own.
enum AppIconSet {
  /// One tab, one coffee-vocabulary shape. The master set.
  nav,

  /// Coffee Duel types, naming each duel's subject.
  duel,

  /// One literal line mark per knowledge topic.
  dict,

  /// Status and feedback, where colour carries as much meaning as shape.
  status,

  /// Workhorse chrome — smaller, lighter, not part of the concept family.
  action,

  /// What kind of thing a row is, in the replay and saved lists.
  kinds,
}

/// One mark of the design system's icon family.
///
/// Every value here has a matching `assets/icons/<slug>.svg`, written from the
/// design source by `tool/extract_icons.js` — nothing in this enum draws
/// anything, it only names what the design drew. A value with no file, or a
/// file with no value, fails `test/unit/core/icons/app_icon_test.dart`, which
/// is what keeps this list and the assets from drifting apart.
///
/// Render one with `IconMark`, never with `SvgPicture` directly: the marks
/// paint in `currentColor` and in sentinel colours that only that widget knows
/// how to map onto the mood.
enum AppIcon {
  // Navigation — the master set.
  /// Today. The everyday drink → the lessons home.
  cup(AppIconSet.nav, hasActive: true),

  /// Path. A trail of stops → the structured journey.
  route(AppIconSet.nav, hasActive: true),

  /// Atlas. Drawn, and held back to v2 with the tab it belongs to.
  globe(AppIconSet.nav),

  /// Cards. A deck → the collectible knowledge cards.
  cards(AppIconSet.nav, hasActive: true),

  /// Profile. The coffee plant → you, growing with points.
  leaf(AppIconSet.nav, hasActive: true),

  // Coffee Duel types. Cup, Globe and Route are the nav set's, reused.
  /// Taste match.
  tiles(AppIconSet.duel),

  /// Processing, as a cherry in section.
  cherrySection(AppIconSet.duel),

  // Knowledge marks — one per topic, and no two topics share one.
  /// Beans.
  beans(AppIconSet.dict),

  /// Processing. Not a droplet: water is not the category.
  processing(AppIconSet.dict),

  /// Roasting. Not a flame: the design leaves the flame to the streak.
  roasting(AppIconSet.dict),

  /// Brewing.
  brewing(AppIconSet.dict),

  /// Espresso.
  espresso(AppIconSet.dict),

  /// Sensory.
  sensory(AppIconSet.dict),

  /// Grind.
  grind(AppIconSet.dict),

  /// Equipment.
  equipment(AppIconSet.dict),

  /// Trade.
  trade(AppIconSet.dict),

  // Status and feedback.
  /// Correct, or learned.
  check(AppIconSet.status),

  /// Incorrect.
  cross(AppIconSet.status),

  /// Locked.
  lock(AppIconSet.status),

  /// The current or locked step on a path.
  statusDot(AppIconSet.status),

  /// A win.
  crown(AppIconSet.status),

  /// The fastest answer.
  bolt(AppIconSet.status),

  /// The points currency.
  bean(AppIconSet.status),

  // Actions and navigation — chrome, at a lighter weight than the family.
  /// Drill in.
  chevron(AppIconSet.action),

  /// Direction along a scale.
  arrow(AppIconSet.action),

  /// Expand or collapse.
  caret(AppIconSet.action),

  /// Back.
  back(AppIconSet.action),

  /// Close, or quit.
  close(AppIconSet.action),

  /// Share.
  share(AppIconSet.action),

  /// Copy link.
  link(AppIconSet.action),

  /// Run it back.
  rematch(AppIconSet.action),

  /// Overflow.
  more(AppIconSet.action),

  /// Save or favourite. Filled when saved, which is the design's own rule for
  /// this mark rather than a second drawing of it.
  bookmark(AppIconSet.action, hasActive: true),

  /// Settings.
  gear(AppIconSet.action),

  /// The Coffee Duel entry.
  duel(AppIconSet.action),

  // Content kinds, tagging what a row is.
  /// A module.
  module(AppIconSet.kinds),

  /// A match game.
  match(AppIconSet.kinds),

  /// A quiz game.
  quiz(AppIconSet.kinds),

  /// A flavour or tasting activity.
  flavour(AppIconSet.kinds);

  const AppIcon(this.set, {this.hasActive = false});

  /// The set the design draws this mark in.
  final AppIconSet set;

  /// Whether the design gives this mark a second, active state.
  ///
  /// Five do. The four tabs fill their shape and knock the interior lines out
  /// when selected, which is a different drawing rather than the same drawing
  /// recoloured; the bookmark fills when saved. [activeAsset] is the file.
  final bool hasActive;

  /// Where the extractor writes this mark. Directory and extension in one
  /// place, so a move is one edit rather than forty.
  String get asset => 'assets/icons/$_slug.svg';

  /// The active state's file, or the resting one for a mark that has none —
  /// so a call site can ask for "the active version" without first asking
  /// whether there is one.
  String get activeAsset =>
      hasActive ? 'assets/icons/${_slug}_active.svg' : asset;

  /// `cherrySection` → `cherry_section`. Dart names the value, the design
  /// names the file, and this is the one place the two spellings meet.
  String get _slug => name.replaceAllMapped(
    RegExp('[A-Z]'),
    (match) => '_${match[0]!.toLowerCase()}',
  );
}
