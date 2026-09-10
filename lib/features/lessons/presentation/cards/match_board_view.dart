import 'dart:async';

import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_cue.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_anchors.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_board.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_columns.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_line.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_lines_painter.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_standing.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The two lines that explain either outcome — the design's own wording, which
/// says what the all-first-time rule is rather than only that it was missed.
/// The verdict itself is `matchBoardVerdict`, beside the board's other rules.
const String _clearedClean =
    'Every pair first time. That is the one that '
    'counts.';
const String _clearedNotClean =
    'Cleared it, but not first time — the board only scores when every pair '
    'lands on the first try.';

/// What a bad drop says to a screen reader.
///
/// The design marks a miss in berry and shakes it, which is nothing at all to
/// a learner who cannot see it — so the board keeps an announcement the sighted
/// board does not draw.
const String missAnnouncement = 'Not that one — try it somewhere else.';

/// A board of traits and the answers they sort into.
///
/// Drag a trait onto its answer, or tap one then the other — the design offers
/// both. A right drop locks it and draws a line; a wrong one leaves it in
/// play, because the board is finished by clearing it rather than surviving
/// it. Success is paid only on a board cleared with no wrong drop.
class MatchBoardView extends StatefulWidget {
  /// Creates a [MatchBoardView].
  const MatchBoardView({
    required this.prompt,
    required this.pairs,
    required this.targets,
    required this.onSolved,
    required this.onContinue,
    super.key,
  }) : assert(pairs.length > 0, 'a board with no facts cannot be played');

  /// What the board asks.
  final String prompt;

  /// The traits to place, in the order they are shown.
  final List<MatchPair> pairs;

  /// The answers to place them under, in the order they are shown. Supplied by
  /// the host so the display order comes from one seeded source.
  final List<String> targets;

  /// Fired once, only when the board clears with no wrong drop.
  final CardSolved onSolved;

  /// Fired when the learner moves on from the cleared board.
  final CardAdvance onContinue;

  @override
  State<MatchBoardView> createState() => _MatchBoardViewState();
}

class _MatchBoardViewState extends State<MatchBoardView>
    with SingleTickerProviderStateMixin {
  final Set<int> _placedFactIndices = {};
  int? _selectedFactIndex;
  int? _draggingFactIndex;

  /// Wrong drops so far. A count rather than a flag because the design's
  /// verdict names it — `2 WRONG DROPS` — and `_faulted` is derived from it so
  /// the two cannot disagree about whether the board was clean.
  int _wrongDrops = 0;
  bool _signalled = false;

  /// The bad pair still being shown, and the ticks that drive the two
  /// animations. A tick rather than a flag so two in a row each play.
  MatchMiss? _miss;
  int _snapTick = 0;
  int _shakeTick = 0;
  String? _snapTarget;

  Timer? _missHold;

  late final AnimationController _lineRun = AnimationController(
    vsync: this,
    duration: matchLineRunDuration,
  );

  final MatchAnchors _anchors = MatchAnchors();

  bool get _faulted => _wrongDrops > 0;

  bool get _cleared => matchBoardCleared(
    solvedCount: _placedFactIndices.length,
    total: widget.pairs.length,
  );

  @override
  void dispose() {
    _missHold?.cancel();
    _lineRun.dispose();
    super.dispose();
  }

  void _selectFact(int index) {
    if (_placedFactIndices.contains(index)) return;
    setState(() {
      _selectedFactIndex = _selectedFactIndex == index ? null : index;
    });
  }

  void _place(int factIndex, String target) {
    final correct = matchAccepts(widget.pairs[factIndex], target);
    setState(() {
      _selectedFactIndex = null;
      if (correct) {
        _placedFactIndices.add(factIndex);
        _snapTarget = target;
        _snapTick++;
      } else {
        _wrongDrops++;
        _miss = (fact: factIndex, target: target);
        _shakeTick++;
      }
    });
    if (correct) _runLine();
    if (!correct) _holdMiss();
    _paySignalIfEarned();
  }

  /// Draws the new connector in. Reduced motion lands it whole in one frame
  /// rather than at a zero duration, which is the app's rule elsewhere.
  void _runLine() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _lineRun.value = 1;
      return;
    }
    unawaited(_lineRun.forward(from: 0));
  }

  /// The design holds a wrong pair marked for 480ms, then lets it go.
  ///
  /// A cancellable timer rather than a delayed future: a board left mid-hold —
  /// the learner walking out of the lesson — must not come back to a disposed
  /// widget, and `mounted` alone leaves the timer running.
  void _holdMiss() {
    _missHold?.cancel();
    _missHold = Timer(matchWrongHoldDuration, () {
      if (!mounted) return;
      setState(() => _miss = null);
    });
  }

  /// The one-signal contract, checked after the placement is committed so the
  /// card has already latched when the host hears from it.
  ///
  /// `_signalled` is belt-and-braces — a cleared board takes every trait out
  /// of play — but the guard states the contract rather than leaving it to be
  /// inferred from the widget tree.
  void _paySignalIfEarned() {
    if (_signalled) return;
    if (!matchBoardPaysSignal(cleared: _cleared, faulted: _faulted)) return;
    _signalled = true;
    widget.onSolved();
  }

  /// Where a tapped answer sends its trait, and what a dropped one lands on.
  void _placeOnTarget(String target, {int? dragged}) {
    final fact = dragged ?? _selectedFactIndex;
    if (fact == null || _placedFactIndices.contains(fact)) return;
    _place(fact, target);
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return CardShell(
      latched: _cleared,
      onContinue: widget.onContinue,
      cue: CardCue.match,
      children: [
        Text(widget.prompt, style: AppText.title(mood: mood)),
        const SizedBox(height: AppSpacing.md),
        _board(),
        if (_miss != null)
          Semantics(
            liveRegion: true,
            label: missAnnouncement,
            child: const SizedBox.shrink(),
          ),
        if (_cleared) ...[
          const SizedBox(height: AppSpacing.md),
          AnswerFeedback(
            verdict: matchBoardVerdict(_wrongDrops),
            outcome: _faulted ? Verdict.wrong : Verdict.right,
            explanation: _faulted ? _clearedNotClean : _clearedClean,
          ),
        ],
      ],
    );
  }

  Widget _board() => MatchColumns(
    pairs: widget.pairs,
    targets: widget.targets,
    anchors: _anchors,
    board: MatchBoardStanding(
      placed: _placedFactIndices,
      linked: {
        for (final index in _placedFactIndices) widget.pairs[index].right,
      },
      selected: _selectedFactIndex,
      dragging: _draggingFactIndex,
      miss: _miss,
      cleared: _cleared,
      snapTarget: _snapTarget,
      snapTick: _snapTick,
      shakeTick: _shakeTick,
    ),
    callbacks: MatchColumnCallbacks(
      onSelectTrait: _selectFact,
      onDragTrait: (index) => setState(() => _draggingFactIndex = index),
      onDragEnded: () => setState(() => _draggingFactIndex = null),
      onTarget: _placeOnTarget,
    ),
    overlay: AnimatedBuilder(
      animation: _lineRun,
      builder: (context, _) => CustomPaint(
        painter: MatchLinesPainter(connectors: _connectors()),
      ),
    ),
  );

  /// Every line the board is currently showing: one per landed pair, plus the
  /// bad drop still being marked.
  List<MatchConnector> _connectors() {
    final mood = context.mood;
    final elapsed = _lineRun.lastElapsedDuration ?? matchLineRunDuration;
    final newest = _placedFactIndices.isEmpty ? null : _placedFactIndices.last;

    final lines = <MatchConnector>[];
    for (final fact in _placedFactIndices) {
      final run = fact == newest && _lineRun.isAnimating
          ? elapsed
          : matchLineRunDuration;
      final line = _anchors.between(fact, widget.pairs[fact].right);
      if (line == null) continue;
      lines.add((
        from: line.from,
        to: line.to,
        color: mood.sage,
        draw: matchLineDrawFraction(run),
        arrow: matchArrowOpacity(run),
      ));
    }

    final miss = _miss;
    if (miss != null) {
      final line = _anchors.between(miss.fact, miss.target);
      // The design does not animate a wrong line: it is already there when
      // the shake starts.
      if (line != null) {
        lines.add((
          from: line.from,
          to: line.to,
          color: mood.berry,
          draw: 1,
          arrow: 1,
        ));
      }
    }
    return lines;
  }
}
