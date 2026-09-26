import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/storage/id_set.dart';

/// The three lines one micro-tip draws.
typedef MicroTipCopy = ({String eyebrow, String title, String body});

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

  /// The three lines this tip draws.
  ///
  /// One lookup rather than a switch per line, so an eighth tip is a case here
  /// and nowhere else.
  MicroTipCopy copy(AppLocalizations strings) => switch (this) {
    MicroTip.path => (
      eyebrow: strings.microTipPathEyebrow,
      title: strings.microTipPathTitle,
      body: strings.microTipPathBody,
    ),
    MicroTip.brew => (
      eyebrow: strings.microTipBrewEyebrow,
      title: strings.microTipBrewTitle,
      body: strings.microTipBrewBody,
    ),
    MicroTip.tree => (
      eyebrow: strings.microTipTreeEyebrow,
      title: strings.microTipTreeTitle,
      body: strings.microTipTreeBody,
    ),
    MicroTip.saved => (
      eyebrow: strings.microTipSavedEyebrow,
      title: strings.microTipSavedTitle,
      body: strings.microTipSavedBody,
    ),
    MicroTip.dictionary => (
      eyebrow: strings.microTipDictionaryEyebrow,
      title: strings.microTipDictionaryTitle,
      body: strings.microTipDictionaryBody,
    ),
    MicroTip.freeze => (
      eyebrow: strings.microTipFreezeEyebrow,
      title: strings.microTipFreezeTitle,
      body: strings.microTipFreezeBody,
    ),
    MicroTip.studio => (
      eyebrow: strings.microTipStudioEyebrow,
      title: strings.microTipStudioTitle,
      body: strings.microTipStudioBody,
    ),
  };

  /// What assistive technology is read when the card appears.
  ///
  /// Joined here rather than in the `.arb`: the three lines are separately
  /// translated, and a key holding only the full stops between them would
  /// give a translator nothing to translate.
  String announcement(AppLocalizations strings) {
    final (:eyebrow, :title, :body) = copy(strings);
    return '$eyebrow. $title. $body';
  }
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
