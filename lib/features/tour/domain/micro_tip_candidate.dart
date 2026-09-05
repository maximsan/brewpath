import 'package:brew_path/features/tour/domain/micro_tip.dart';
import 'package:brew_path/features/tour/domain/micro_tip_place.dart';
import 'package:flutter/foundation.dart';

/// What the app is doing right now, in the only terms the tip rule reads.
///
/// A value rather than five arguments, so the rule can be exercised against a
/// fixture and so a new signal is a field here instead of another parameter at
/// every call site.
@immutable
class MicroTipSignals {
  /// Creates the signals a tip is chosen from.
  const MicroTipSignals({
    this.savedJustHappened = false,
    this.studioUnlocked = false,
    this.challengeActive = false,
    this.lessonJustCompleted = false,
    this.freezeHeld = false,
    this.freezeJustEarned = false,
  });

  /// Whether a save has landed since the app opened.
  ///
  /// The tip answers the action the learner just took, so it is an event and
  /// not a count: a learner who already has a full shelf is not told what
  /// saving does the next time they open the app.
  final bool savedJustHappened;

  /// Whether the Studio's door is open to this learner. A locked Studio raises
  /// the Plus gate instead of a screen, so there is nothing to explain.
  final bool studioUnlocked;

  /// Whether a Coffee Challenge is in play.
  final bool challengeActive;

  /// Whether a lesson has been finished since the app opened — the beat the
  /// tree tip follows.
  final bool lessonJustCompleted;

  /// Whether an unspent streak freeze is held.
  final bool freezeHeld;

  /// Whether the freeze-earned beat has shown since the app opened.
  ///
  /// The other half of the design's condition, and not the same fact as
  /// [freezeHeld]: a freeze earned at a lesson's ending and spent on a missed
  /// day before the learner is next on Learn leaves nothing held, and they were
  /// still shown a safety net nobody explained.
  final bool freezeJustEarned;
}

/// The one tip worth showing right now, or null.
///
/// **One candidate at a time, in a fixed priority.** A fresh save outranks
/// everything, because it answers what the learner just did on whatever screen
/// they did it. Then the place whose own tip is the reason it is open, then the
/// Learn tab's three, each following a beat the learner has just seen.
///
/// **A tip already in [seen] is passed over, not treated as the answer.** So
/// dismissing the challenge tip lets the tree tip through on the next pass
/// rather than leaving the Learn tab silent for as long as the challenge lasts
/// — which is what #517 asks for: the three in order, with the wait between
/// them.
///
/// [suppressed] is the guide layer's own silence — the Tour running, or a sheet
/// or dialog over the screen. It is separate from [place] because it is a fact
/// about what is *on* the screen rather than about which screen it is.
MicroTip? microTipCandidate({
  required TipPlace place,
  required MicroTipSignals signals,
  required Set<String> seen,
  required bool suppressed,
}) {
  if (!microTipsWelcome(place: place, suppressed: suppressed)) return null;
  for (final tip in _inPriorityOrder(place, signals)) {
    if (!seen.contains(tip.id)) return tip;
  }
  return null;
}

/// Whether the layer may have anything on screen here at all.
///
/// Named once because two callers ask it: this file, deciding whether there is
/// a tip to choose, and the host, deciding whether to draw the one it is
/// already holding. Two copies of the rule would let a card stay up on a screen
/// that would not have raised it.
bool microTipsWelcome({required TipPlace place, required bool suppressed}) =>
    !suppressed && place.takesTips;

Iterable<MicroTip> _inPriorityOrder(
  TipPlace place,
  MicroTipSignals signals,
) sync* {
  if (signals.savedJustHappened) yield MicroTip.saved;
  switch (place) {
    case TipPlace.dictionary:
      yield MicroTip.dictionary;
    case TipPlace.studio:
      if (signals.studioUnlocked) yield MicroTip.studio;
    case TipPlace.pathTab:
      yield MicroTip.path;
    // The Learn tab's own order: what to go and make, then what just grew,
    // then the safety net.
    case TipPlace.learnTab:
      if (signals.challengeActive) yield MicroTip.brew;
      if (signals.lessonJustCompleted) yield MicroTip.tree;
      if (signals.freezeHeld || signals.freezeJustEarned) {
        yield MicroTip.freeze;
      }
    case TipPlace.termOfDay || TipPlace.otherInShell || TipPlace.elsewhere:
      break;
  }
}
