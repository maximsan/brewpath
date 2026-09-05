/// The seven micro-tips, with the copy each one carries.
///
/// A micro-tip is the guide layer's second piece: one small card explaining one
/// feature the first time it matters, shown once ever and dismissable. The Tour
/// introduces the Learn tab; these cover everything the Tour does not reach
/// ([#342](https://github.com/maximsan/brewpath/issues/342)).
///
/// Every tip carries a rule the learner cannot read off the screen it appears
/// on — the unlock order, the 48-hour window, that only lessons grow the tree —
/// which is what the ruling checked each one against before keeping it.
///
/// [id] is what is written to disk, so it is spelled here rather than derived
/// from [name]: a rename of the enum value must not silently re-arm a tip on
/// every device that has already seen it.
enum MicroTip {
  /// The Path tab: what the line and the diamonds on it mean.
  path(
    id: 'path',
    eyebrow: 'YOUR PATH',
    title: 'The whole course, in order',
    body:
        'Each finished lesson unlocks the next, top to bottom. The diamonds '
        'branching off the line are hands-on Coffee Challenges.',
  ),

  /// A Coffee Challenge in play: that it is made for real, and logged here.
  brew(
    id: 'brew',
    eyebrow: 'COFFEE CHALLENGE',
    title: 'A real brew, not a quiz',
    body:
        'Make it at your own pace within 48 hours, then log the result here on '
        'Today. Logging it earns the challenge’s stamp.',
  ),

  /// The coffee tree, just after a lesson pushed it along.
  tree(
    id: 'tree',
    eyebrow: 'COFFEE TREE',
    title: 'Your tree just grew',
    body:
        'Completing that lesson pushed it toward harvest. Only core lessons '
        'grow it — see it any time from your Profile.',
  ),

  /// The Saved shelf, just after the learner's first save.
  saved(
    id: 'saved',
    eyebrow: 'SAVED',
    title: 'Kept for later',
    body:
        'Everything you save waits behind the ribbon at the top of Today — '
        'lessons, terms and guides on one shelf.',
  ),

  /// The Coffee Dictionary: where its terms come from, and what to do there.
  dictionary(
    id: 'dictionary',
    eyebrow: 'DICTIONARY',
    title: 'Every term you’ve met',
    body:
        'Terms join your Dictionary as lessons introduce them. Search them '
        'here, or drill them with flashcards.',
  ),

  /// The streak freeze: how one is earned, and how it is spent.
  freeze(
    id: 'freeze',
    eyebrow: 'STREAK FREEZE',
    title: 'A safety net you’ve earned',
    body:
        'Every 7 streak days in a row earns a freeze; you hold one at a time. '
        'Miss a day and it’s spent for you — your streak survives.',
  ),

  /// The Studio, once it is unlocked: that the look it sets is app-wide.
  studio(
    id: 'studio',
    eyebrow: 'STUDIO',
    title: 'Make it yours',
    body:
        'Dress Roasty and choose your tree’s variety and light. The look '
        'you set here applies everywhere in the app.',
  );

  const MicroTip({
    required this.id,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  /// The stored id — the string the seen list holds.
  final String id;

  /// The smallcaps line above the title.
  final String eyebrow;

  /// The tip's one-line claim.
  final String title;

  /// The rule the tip exists to state.
  final String body;

  /// What assistive technology is read when the card appears.
  String get announcement => '$eyebrow. $title. $body';
}

/// The seen list as it is stored: ids separated by commas.
///
/// Unrecognised ids survive a round trip. A device that has been on a newer
/// build carries tips this build has never heard of, and an older build reading
/// the row must not trim them — the learner would be shown them again on the
/// next upgrade.
abstract final class MicroTipsSeen {
  static const String _separator = ',';

  /// The ids in [stored], with blanks dropped.
  static Set<String> decode(String stored) => stored
      .split(_separator)
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toSet();

  /// [ids] as one column value, in a stable order so an unchanged set writes
  /// an unchanged string.
  static String encode(Set<String> ids) =>
      (ids.toList()..sort()).join(_separator);

  /// [stored] with [tip] added.
  static String withTip(String stored, MicroTip tip) =>
      encode(decode(stored)..add(tip.id));
}
