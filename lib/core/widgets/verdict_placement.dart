import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// Where the verdict block is standing — the whole of what varies between its
/// hosts.
///
/// A mascot size, a body step, a wrong-answer tone and the room above the
/// block, travelling as one value: the design moves them together, and passing
/// them loose is what let five copies drift into combinations it never draws.
enum VerdictPlacement {
  /// A graded card in the lesson player.
  card(
    mascot: _mascotOnCard,
    speaksInBody: false,
    room: OffTokens.verdictRoomOnCard,
  ),

  /// A mini-game's round — `bagpick` and `tastefix`.
  ///
  /// A graded card in every other respect; the design simply closes a
  /// mini-game a shade tighter than a lesson card.
  miniGame(
    mascot: _mascotOnCard,
    speaksInBody: false,
    room: OffTokens.verdictRoomInMiniGame,
  ),

  /// The cards the design sets a step larger — `decision` and `recall`, which
  /// pass `bodySize="body"`.
  ///
  /// They talk back rather than mark an answer, and the design gives that
  /// reading the body step the rest of the run reserves for prose.
  conversational(
    mascot: _mascotOnCard,
    speaksInBody: true,
    room: OffTokens.verdictRoomOnCard,
  ),

  /// A term entry's self-check, drawn smaller and toned **accent** rather than
  /// berry.
  ///
  /// A term entry is reference rather than a graded run: berry is the colour
  /// the lesson player spends on a wrong answer, and a look-up that answers
  /// back in it reads as a worse failure than missing a self-check is.
  reference(
    mascot: _mascotInReference,
    speaksInBody: false,
    wrongInAccent: true,
    room: OffTokens.verdictRoomInReference,
  ),

  /// A vocab quiz round, which reads as reference for the same reason and is
  /// drawn the same way. A full screen rather than a panel inside an entry,
  /// and the design gives it a little more room for that.
  vocabRound(
    mascot: _mascotInReference,
    speaksInBody: false,
    wrongInAccent: true,
    room: OffTokens.verdictRoomInVocabRound,
  ),

  /// The predict card's held guess — the design's `size={64} bodySize="body"`.
  ///
  /// Smaller than a graded card's mascot and set at the body step: the block
  /// is repeating the learner's own guess back to them, which reads as prose
  /// rather than as a mark.
  heldGuess(
    mascot: _mascotOnHold,
    speaksInBody: true,
    room: OffTokens.verdictRoomOnCard,
  ),

  /// The recall card's payoff — the design's `art={false} borderTop`.
  ///
  /// The one standing with no mascot. It is a reply to a guess made minutes
  /// ago rather than a verdict on the answer just given, and Roasty has
  /// already spoken above it; a second face would read as a second marking.
  /// The rule off the top is what separates the two.
  openingGuess(
    mascot: null,
    speaksInBody: true,
    rulesOff: true,
    room: OffTokens.verdictRoomOnPayoff,
  );

  const VerdictPlacement({
    required this.mascot,
    required this.speaksInBody,
    required OffToken<double> room,
    this.rulesOff = false,
    this.wrongInAccent = false,
  }) : _room = room;

  /// The design's mascot size on a graded card, holding a guess, and inside a
  /// term entry.
  static const double _mascotOnCard = 72;
  static const double _mascotOnHold = 64;
  static const double _mascotInReference = 48;

  /// How large Roasty is drawn here, or null where the block draws no mascot.
  final double? mascot;

  /// Whether a rule sits above the block, separating it from what it follows.
  final bool rulesOff;

  /// Whether a wrong answer is named in the accent rather than berry.
  final bool wrongInAccent;

  final OffToken<double> _room;

  /// The room the design leaves above the block here.
  ///
  /// On the placement rather than in each host, because the design carries it
  /// as a prop of the block, and every host spacing it by hand is how none of
  /// them ended up at the design's value.
  double get room => _room.value;

  /// Whether the verdict announces itself on arrival.
  ///
  /// True everywhere but the payoff, which mounts on the same commit as the
  /// graded verdict above it: two live regions firing together interrupt each
  /// other, and the one that says how the card went is the one worth hearing.
  /// The payoff is read in its place, like the rest of the card.
  bool get announces => this != VerdictPlacement.openingGuess;

  /// Whether the explanation takes the body step rather than support.
  final bool speaksInBody;

  /// The colour a wrong answer is named in.
  Color wrongTone(MoodColors mood) => wrongInAccent ? mood.accent : mood.berry;

  /// How the explanation is set here.
  ///
  /// **Muted at either step.** The design's block colours this text
  /// `var(--ink-mute)` whatever `bodySize` it is given — the step says how
  /// much room the explanation takes, never how loudly it speaks — and
  /// `AppText.body` defaults to full ink, so the colour has to be named.
  TextStyle explanationStyle(MoodColors mood) => speaksInBody
      ? AppText.body(color: mood.inkMute)
      : AppText.support(mood: mood);
}
