import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/models/content/card_kind_help.dart';
import 'package:brew_path/shared/repositories/card_kind_help_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_cue.g.dart';

/// The line a card opens on, naming the format it is asking the learner to
/// play — and the key to the drawer explaining how.
///
/// The ten kinds with help are exactly the ten values here, so a card that
/// carries a cue always has something behind its `?`. The other five kinds
/// open on their own authored eyebrow and take no cue at all.
enum CardCue {
  /// Pick one of four.
  mcq,

  /// Pick every answer that belongs, then check them together.
  multi,

  /// Drag each trait onto what it belongs to.
  match,

  /// Dial a slider to where the answer lands.
  slider,

  /// Tap the items into their right order.
  sequence,

  /// Decide whether a statement holds.
  quiz,

  /// Name the note behind a tasting clue.
  flavor,

  /// Choose the fix for a cup that came out wrong.
  tastefix,

  /// Call the process from an unlabelled bag's beans.
  bagpick,

  /// Fill the blanks in a sentence.
  fill;

  /// What the cue reads, as the design writes it. Set upper case by the type
  /// rule rather than here, so assistive technology is given it as written.
  String phrase(AppLocalizations strings) => switch (this) {
    CardCue.mcq => strings.cardCueMcq,
    CardCue.multi => strings.cardCueMulti,
    CardCue.match => strings.cardCueMatch,
    CardCue.slider => strings.cardCueSlider,
    CardCue.sequence => strings.cardCueSequence,
    CardCue.quiz => strings.cardCueQuiz,
    CardCue.flavor => strings.cardCueFlavor,
    CardCue.tastefix => strings.cardCueTastefix,
    CardCue.bagpick => strings.cardCueBagpick,
    CardCue.fill => strings.cardCueFill,
  };

  /// The `kind` this cue's entry carries in the bundled help bank, which is
  /// the enum's own name for all ten.
  String get helpKey => name;
}

/// How the kind behind [cue] is played.
///
/// Keyed on the cue rather than a raw kind string: every [CardCue] has an
/// entry, so a caller cannot ask this about a format the design never wrote
/// help for. Null only if the bundled bank has lost the entry.
@riverpod
Future<CardKindHelp?> cardKindHelp(Ref ref, CardCue cue) =>
    ref.watch(cardKindHelpRepositoryProvider).getForKind(cue.helpKey);
