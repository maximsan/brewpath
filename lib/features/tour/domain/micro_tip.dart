import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/storage/id_set.dart';

/// The seven micro-tips, with the copy each one carries.
///
/// One small card explaining one feature the first time it matters, shown once
/// ever; the Tour introduces the Learn tab and these cover what it does not
/// reach ([#342](https://github.com/maximsan/brewpath/issues/342)). Each
/// carries a rule the learner cannot read off the screen it appears on.
enum MicroTip {
  /// The Path tab: what the line and the diamonds on it mean.
  path(
    id: 'path',
  ),

  /// A Coffee Challenge in play: that it is made for real, and logged here.
  brew(
    id: 'brew',
  ),

  /// The coffee tree, just after a lesson pushed it along.
  tree(
    id: 'tree',
  ),

  /// The Saved shelf, just after the learner's first save.
  saved(
    id: 'saved',
  ),

  /// The Coffee Dictionary: where its terms come from, and what to do there.
  dictionary(
    id: 'dictionary',
  ),

  /// The streak freeze: how one is earned, and how it is spent.
  freeze(
    id: 'freeze',
  ),

  /// The Studio, once it is unlocked: that the look it sets is app-wide.
  studio(
    id: 'studio',
  );

  const MicroTip({required this.id});

  /// The stored id — the string the seen list holds.
  ///
  /// Spelled rather than derived from the enum value: a rename must not
  /// silently re-arm a tip on every device that has already seen it.
  final String id;

  /// The smallcaps line above the title.
  String eyebrow(AppLocalizations strings) => switch (this) {
    MicroTip.path => strings.microTipPathEyebrow,
    MicroTip.brew => strings.microTipBrewEyebrow,
    MicroTip.tree => strings.microTipTreeEyebrow,
    MicroTip.saved => strings.microTipSavedEyebrow,
    MicroTip.dictionary => strings.microTipDictionaryEyebrow,
    MicroTip.freeze => strings.microTipFreezeEyebrow,
    MicroTip.studio => strings.microTipStudioEyebrow,
  };

  /// The tip's one-line claim.
  String title(AppLocalizations strings) => switch (this) {
    MicroTip.path => strings.microTipPathTitle,
    MicroTip.brew => strings.microTipBrewTitle,
    MicroTip.tree => strings.microTipTreeTitle,
    MicroTip.saved => strings.microTipSavedTitle,
    MicroTip.dictionary => strings.microTipDictionaryTitle,
    MicroTip.freeze => strings.microTipFreezeTitle,
    MicroTip.studio => strings.microTipStudioTitle,
  };

  /// The rule the tip exists to state.
  String body(AppLocalizations strings) => switch (this) {
    MicroTip.path => strings.microTipPathBody,
    MicroTip.brew => strings.microTipBrewBody,
    MicroTip.tree => strings.microTipTreeBody,
    MicroTip.saved => strings.microTipSavedBody,
    MicroTip.dictionary => strings.microTipDictionaryBody,
    MicroTip.freeze => strings.microTipFreezeBody,
    MicroTip.studio => strings.microTipStudioBody,
  };

  /// What assistive technology is read when the card appears.
  String announcement(AppLocalizations strings) => strings.microTipAnnouncement(
    eyebrow(strings),
    title(strings),
    body(strings),
  );
}

/// The seen list as it is stored: ids separated by commas.
///
/// Unrecognised ids survive a round trip. A device that has been on a newer
/// build carries tips this build has never heard of, and an older build reading
/// the row must not trim them — the learner would be shown them again on the
/// next upgrade.
abstract final class MicroTipsSeen {
  /// The ids in [stored], with blanks dropped.
  static Set<String> decode(String stored) => IdSet.decode(stored);

  /// [ids] as one column value, in a stable order so an unchanged set writes
  /// an unchanged string.
  static String encode(Set<String> ids) => IdSet.encode(ids);

  /// [stored] with [tip] added.
  static String withTip(String stored, MicroTip tip) =>
      IdSet.plus(stored, tip.id);
}
