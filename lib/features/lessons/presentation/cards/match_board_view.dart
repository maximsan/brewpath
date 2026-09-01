import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_board.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_fact_tile.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The verdict on a board that was cleared without a wrong drop, and the two
/// lines that explain either outcome — the design's own wording, which says
/// what the all-first-time rule is rather than only that it was missed.
const String _cleanBoard = 'CLEAN BOARD';
const String _clearedClean =
    'Every pair first time. That is the one that '
    'counts.';
const String _clearedNotClean =
    'Cleared it, but not first time — the board only scores when every pair '
    'lands on the first try.';

/// A board of facts and the answers they sort into.
///
/// Tap a fact, then tap where it belongs. A right placement locks the fact
/// away; a wrong one says so and leaves the fact in play, because the board
/// is finished by clearing it rather than by surviving it. The card pays its
/// one success signal only on a board cleared without a wrong drop.
///
/// Nothing here knows what is hosting it: the mini-game player and the lesson
/// player both get this renderer unchanged, which is why it sits in the shared
/// card layer.
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

  /// The facts to place, in the order they are shown.
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

class _MatchBoardViewState extends State<MatchBoardView> {
  final Set<int> _placedFactIndices = {};
  int? _selectedFactIndex;

  /// Wrong drops so far. A count rather than a flag because the design's
  /// verdict names it — `2 WRONG DROPS` — and `_faulted` is derived from it so
  /// the two cannot disagree about whether the board was clean.
  int _wrongDrops = 0;
  bool _signalled = false;
  String? _feedback;

  bool get _faulted => _wrongDrops > 0;

  bool get _cleared => matchBoardCleared(
    solvedCount: _placedFactIndices.length,
    total: widget.pairs.length,
  );

  void _selectFact(int index) {
    if (_placedFactIndices.contains(index)) return;
    setState(() {
      _selectedFactIndex = _selectedFactIndex == index ? null : index;
      _feedback = null;
    });
  }

  void _placeOn(String target) {
    final selected = _selectedFactIndex;
    if (selected == null) {
      setState(() => _feedback = 'Pick a fact first.');
      return;
    }

    final correct = matchAccepts(widget.pairs[selected], target);
    setState(() {
      _selectedFactIndex = null;
      if (correct) {
        _placedFactIndices.add(selected);
        _feedback = null;
      } else {
        _wrongDrops++;
        _feedback = 'Not that one — try it somewhere else.';
      }
    });
    _paySignalIfEarned();
  }

  /// The one-signal contract, checked after the placement is committed so the
  /// card has already latched when the host hears from it.
  ///
  /// `_signalled` is belt-and-braces — a cleared board disables every target,
  /// so this cannot be reached twice — but the guard states the contract
  /// rather than leaving it to be inferred from the widget tree.
  void _paySignalIfEarned() {
    if (_signalled) return;
    if (!matchBoardPaysSignal(cleared: _cleared, faulted: _faulted)) return;
    _signalled = true;
    widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return CardShell(
      latched: _cleared,
      onContinue: widget.onContinue,
      label: 'MATCH',
      children: [
        Text(widget.prompt, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        ..._facts(),
        const SizedBox(height: AppSpacing.md),
        // Wrapped, not a Row: lesson `match` cards carry up to four targets
        // with long labels, which no single row fits on a phone.
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [for (final target in widget.targets) _target(target)],
        ),
        if (_feedback != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              _feedback!,
              style: theme.textTheme.bodyMedium?.copyWith(color: mood.warn),
            ),
          ),
        ],
        if (_cleared) ...[
          const SizedBox(height: AppSpacing.md),
          AnswerFeedback(
            verdict: _faulted
                ? '$_wrongDrops WRONG ${_wrongDrops == 1 ? 'DROP' : 'DROPS'}'
                : _cleanBoard,
            outcome: _faulted ? Verdict.wrong : Verdict.right,
            explanation: _faulted ? _clearedNotClean : _clearedClean,
          ),
        ],
      ],
    );
  }

  List<Widget> _facts() => [
    for (var index = 0; index < widget.pairs.length; index++)
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: MatchFactTile(
          text: widget.pairs[index].left,
          selected: _selectedFactIndex == index,
          placedUnder: _placedFactIndices.contains(index)
              ? widget.pairs[index].right
              : null,
          onTap: () => _selectFact(index),
        ),
      ),
  ];

  Widget _target(String target) => Semantics(
    button: true,
    label: 'Place under $target',
    excludeSemantics: true,
    child: OutlinedButton(
      onPressed: _cleared ? null : () => _placeOn(target),
      child: Text(target),
    ),
  );
}
