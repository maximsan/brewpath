import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/dash_runs.dart';
import 'package:brew_path/core/widgets/dashed_rounded_border.dart';
import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/domain/challenge_surface_state.dart';
import 'package:brew_path/features/challenges/presentation/challenge_recap_sheet.dart';
import 'package:brew_path/features/path/presentation/path_lesson_row.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A challenge and how it reads right now, as Path draws it.
typedef PathChallenge = ({
  BrewChallenge challenge,
  ChallengeSurfaceState state,
});

/// The module's capstone as Path shows it, or null when the module has none
/// or the learner has not earned it yet.
///
/// Read here rather than inside the node so the lesson list above it knows
/// whether a row follows its last lesson.
PathChallenge? pathModuleCapstone(WidgetRef ref, String moduleId) {
  final bank = ref.watch(challengeBankProvider).asData?.value;
  if (bank == null) return null;
  final challenge = challengeForModule(bank, moduleId);
  if (challenge == null) return null;

  final offered = ref.watch(moduleChallengeOfferProvider(moduleId));
  final state = pathChallengeState(
    ref,
    id: challenge.id,
    offerable: offered.asData?.value != null,
  );
  // A capstone the learner cannot reach yet says nothing on the Path: the
  // module node above it already carries the lock.
  if (state == ChallengeSurfaceState.locked) return null;
  return (challenge: challenge, state: state);
}

/// How the challenge [id] reads, from the learner's own record.
ChallengeSurfaceState pathChallengeState(
  WidgetRef ref, {
  required String id,
  required bool offerable,
}) {
  final active = ref.watch(activeChallengeProvider).asData?.value;
  final completed =
      ref.watch(completedChallengesProvider).asData?.value ?? const <String>{};
  final saved = ref.watch(savedChallengesProvider).asData?.value ?? const [];

  return challengeSurfaceState(
    id: id,
    activeId: active?.id,
    completed: completed,
    saved: {for (final entry in saved) entry.id},
    offerable: offerable,
  );
}

/// A Coffee Challenge as a row on the path's spine: a diamond at the junction,
/// a dashed card with the cup, and a pill that says what a tap does.
///
/// The design's `.lesson-row.challenge-sub`. Both the module's capstone and a
/// finished lesson's own challenge draw through it, so the two cannot drift.
class PathChallengeRow extends ConsumerStatefulWidget {
  /// Creates a [PathChallengeRow].
  const PathChallengeRow({
    required this.challenge,
    required this.state,
    required this.isLast,
    super.key,
  });

  /// The challenge on the row.
  final BrewChallenge challenge;

  /// How it reads right now. Never [ChallengeSurfaceState.locked]: a locked
  /// challenge is not drawn on the Path at all.
  final ChallengeSurfaceState state;

  /// Whether this is the module's last row, which drops its hairline and ends
  /// the spine at its own junction.
  final bool isLast;

  /// The design's `.challenge-sub { padding: 8px 0 }`.
  static const double _rowPadding = 8;

  /// The design's `gap: 14px` between the spine column and the trail.
  static const double _columnGap = 14;

  /// The card's `margin-left: -12px`, which pulls it back over the column gap
  /// so the connector between the diamond and the card is short.
  static const double _cardPullBack = 12;

  /// The `.challenge-trail { padding-right: 14px }`.
  static const double _trailPadding = 14;

  @override
  ConsumerState<PathChallengeRow> createState() => _PathChallengeRowState();
}

class _PathChallengeRowState extends ConsumerState<PathChallengeRow> {
  /// Whether a write is in flight — the guard against a second tap starting
  /// the same challenge twice before the first has landed.
  bool _busy = false;

  BrewChallenge get _challenge => widget.challenge;
  ChallengeSurfaceState get _state => widget.state;

  /// What the trail's word is, which is also what a screen reader hears.
  String get _stateWord => switch (_state) {
    ChallengeSurfaceState.completed => 'Done',
    ChallengeSurfaceState.active => 'Active',
    ChallengeSurfaceState.saved => 'Resume',
    ChallengeSurfaceState.available || ChallengeSurfaceState.locked => 'Start',
  };

  /// The kicker over the title: what the row is, and how long it takes while
  /// that is still the question.
  String get _kicker {
    switch (_state) {
      case ChallengeSurfaceState.completed:
      case ChallengeSurfaceState.active:
        return 'Challenge';
      case ChallengeSurfaceState.saved:
        return 'For later';
      case ChallengeSurfaceState.available:
      case ChallengeSurfaceState.locked:
        final duration = effortParts(_challenge.effort).duration;
        return duration == null ? 'Challenge' : 'Challenge · $duration';
    }
  }

  Future<void> _act() async {
    if (_busy) return;
    _busy = true;
    try {
      switch (_state) {
        case ChallengeSurfaceState.completed:
          await _recap();
        case ChallengeSurfaceState.active:
          context.goNamed(AppRoutes.learn.name);
        case ChallengeSurfaceState.available:
        case ChallengeSurfaceState.saved:
          await _start();
        case ChallengeSurfaceState.locked:
          return;
      }
    } finally {
      _busy = false;
    }
  }

  /// Puts the challenge in play and goes to Today, where it now sits.
  Future<void> _start() async {
    await startChallenge(
      ref.read(snapshotRepositoryProvider),
      id: _challenge.id,
      now: DateTime.now(),
    );
    if (!mounted) return;
    ref
      ..invalidate(activeChallengeProvider)
      ..invalidate(savedChallengesProvider);
    context.goNamed(AppRoutes.learn.name);
  }

  /// A brewed challenge opens its recap rather than restarting; the recap's
  /// own *Brew it again* is the way back into play. No points are handed out
  /// for looking.
  Future<void> _recap() async {
    final choice = await showChallengeRecapSheet(
      context: context,
      challenge: _challenge,
      pointsAwarded: 0,
    );
    if (choice != ChallengeRecapChoice.brewAgain || !mounted) return;
    await _start();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      label: '${_challenge.title}, coffee challenge, $_stateWord',
      onTap: _act,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: widget.isLast ? Colors.transparent : mood.rule,
            ),
          ),
        ),
        child: Stack(
          children: [
            PathSpine(isFirst: false, isLast: widget.isLast),
            InkWell(
              onTap: _act,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: PathChallengeRow._rowPadding,
                ),
                child: Row(
                  children: [
                    _Junction(done: _state == ChallengeSurfaceState.completed),
                    const SizedBox(
                      width:
                          PathChallengeRow._columnGap -
                          PathChallengeRow._cardPullBack,
                    ),
                    Expanded(
                      child: _Card(
                        state: _state,
                        kicker: _kicker,
                        title: _challenge.title,
                      ),
                    ),
                    if (_state != ChallengeSurfaceState.completed) ...[
                      const SizedBox(width: PathChallengeRow._columnGap),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: PathChallengeRow._trailPadding,
                        ),
                        child: _Pill(state: _state, word: _stateWord),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The `.challenge-junction`: the same 32-px well a lesson's bean sits in,
/// with the design's 7-px diamond at its centre — the branch off the spine.
class _Junction extends StatelessWidget {
  const _Junction({required this.done});

  final bool done;

  static const double _wellSize = 32;
  static const double _diamondSide = 7;
  static const double _diamondRadius = 1.5;
  static const double _quarterTurn = math.pi / 4;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Container(
      width: _wellSize,
      height: _wellSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: mood.bg, shape: BoxShape.circle),
      child: Transform.rotate(
        angle: _quarterTurn,
        child: Container(
          width: _diamondSide,
          height: _diamondSide,
          decoration: BoxDecoration(
            // `.cq-completed .challenge-diamond { background: var(--sage) }`.
            color: done ? mood.sage : mood.accent,
            borderRadius: BorderRadius.circular(_diamondRadius),
          ),
        ),
      ),
    );
  }
}

/// The `.challenge-card`, with the short dashed connector that ties it back
/// to the diamond.
class _Card extends StatelessWidget {
  const _Card({required this.state, required this.kicker, required this.title});

  final ChallengeSurfaceState state;
  final String kicker;
  final String title;

  /// `padding: 12px 14px`.
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    vertical: 12,
    horizontal: 14,
  );

  /// `gap: 12px` between the badge and the words.
  static const double _gap = 12;

  /// `.challenge-kicker { margin-bottom: 4px }`.
  static const double _kickerGap = 4;

  /// The border's accent share: `color-mix(in oklab, var(--accent) 38%,
  /// var(--rule))`, and 40% once the challenge is active.
  static const double _restingTint = 0.38;
  static const double _activeTint = 0.40;

  /// The fill: `color-mix(in oklab, var(--accent) 6%, transparent)`.
  static const double _wash = 0.06;

  /// The connector: `left: -11px; width: 10px`, dashed at
  /// `color-mix(in oklab, var(--accent) 45%, var(--rule))`.
  static const double _connectorInset = -11;
  static const double _connectorWidth = 10;
  static const double _connectorTint = 0.45;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final done = state == ChallengeSurfaceState.completed;
    final active = state == ChallengeSurfaceState.active;

    final BorderSide side;
    if (done) {
      side = BorderSide(color: mood.rule);
    } else {
      side = BorderSide(
        color: Color.lerp(
          mood.rule,
          mood.accent,
          active ? _activeTint : _restingTint,
        )!,
      );
    }
    // Dashed while it is still an invitation; solid once in play or brewed.
    final ShapeBorder shape = done || active
        ? RoundedRectangleBorder(
            side: side,
            borderRadius: BorderRadius.circular(AppRadii.chrome),
          )
        : DashedRoundedBorder(radius: AppRadii.chrome, side: side);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: _connectorInset,
          top: 0,
          bottom: 0,
          width: _connectorWidth,
          child: CustomPaint(
            painter: _ConnectorPainter(
              color: done
                  ? mood.rule
                  : Color.lerp(mood.rule, mood.accent, _connectorTint)!,
              dashed: !done,
            ),
          ),
        ),
        Container(
          padding: _padding,
          decoration: ShapeDecoration(
            color: done ? null : mood.accent.withValues(alpha: _wash),
            shape: shape,
          ),
          child: Row(
            children: [
              _Badge(done: done),
              const SizedBox(width: _gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kicker.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.micro(
                        mood: mood,
                        color: done ? mood.sage : mood.accent,
                        face: AppFace.mono,
                      ),
                    ),
                    const SizedBox(height: _kickerGap),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.support(
                        mood: mood,
                        color: mood.ink,
                        face: AppFace.control,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The dashed stub between the diamond and the card, drawn on the row's
/// midline.
class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  /// Short dashes, so three of them fit the 10-px run the design gives it.
  static const double _dash = 2;
  static const double _gap = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = PathLessonRow.spineWidth;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    for (final run in dashRuns(size.width, dash: _dash, gap: _gap)) {
      canvas.drawLine(Offset(run.from, y), Offset(run.to, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashed != dashed;
}

/// The `.challenge-badge`: a 28-px ring with the cup in it, dashed and accent
/// while the brew is still to come, solid and sage once it is done.
class _Badge extends StatelessWidget {
  const _Badge({required this.done});

  final bool done;

  static const double _size = 28;
  static const double _cupSize = 15;

  /// `border: 1px dashed color-mix(in oklab, var(--accent) 55%, transparent)`
  /// over `color-mix(in oklab, var(--accent) 10%, var(--bg))`.
  static const double _ring = 0.55;
  static const double _wash = 0.10;

  /// The brewed ring: sage at 50%, over sage at 8%.
  static const double _doneRing = 0.5;
  static const double _doneWash = 0.08;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final tint = done ? mood.sage : mood.accent;
    final side = BorderSide(
      color: tint.withValues(alpha: done ? _doneRing : _ring),
    );

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: Color.alphaBlend(
          tint.withValues(alpha: done ? _doneWash : _wash),
          mood.bg,
        ),
        shape: done
            ? CircleBorder(side: side)
            : DashedRoundedBorder(radius: _size / 2, side: side),
      ),
      child: IconMark(AppIcon.cup, size: _cupSize, color: tint),
    );
  }
}

/// The `.challenge-pill`: filled for *Start*, outlined for *Resume*, and a
/// pulsing dot beside *Active*. A brewed row draws none.
class _Pill extends StatelessWidget {
  const _Pill({required this.state, required this.word});

  final ChallengeSurfaceState state;
  final String word;

  /// `padding: 8px 11px; min-width: 76px`.
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 11,
  );
  static const double _minWidth = 76;

  /// `.challenge-pill.live { padding-right: 4px }`: the dot sits in the room
  /// the fill would have taken.
  static const double _livePaddingRight = 4;

  /// `gap: 6px` between the dot and the word.
  static const double _dotGap = 6;

  /// `.challenge-pill.resume`'s border: accent at 60%.
  static const double _resumeRing = 0.6;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final active = state == ChallengeSurfaceState.active;
    final saved = state == ChallengeSurfaceState.saved;

    final Decoration? decoration;
    final Color ink;
    if (active) {
      decoration = null;
      ink = mood.accent;
    } else if (saved) {
      decoration = BoxDecoration(
        border: Border.all(color: mood.accent.withValues(alpha: _resumeRing)),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      );
      ink = mood.accent;
    } else {
      decoration = BoxDecoration(
        color: mood.accent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      );
      ink = mood.accentInk;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: _minWidth),
      padding: active ? _padding.copyWith(right: _livePaddingRight) : _padding,
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (active) ...[
            const _PulseDot(),
            const SizedBox(width: _dotGap),
          ],
          Text(
            word.toUpperCase(),
            style: AppText.micro(
              mood: mood,
              color: ink,
              face: AppFace.mono,
              tracking: AppTracking.meta,
            ),
          ),
        ],
      ),
    );
  }
}

/// The `.pulse-dot`: a 6-px accent dot breathing on a 1.6-s loop, and still
/// under reduced motion.
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  static const double _size = 6;

  /// `cq-pulse 1.6s`: out and back, so each leg is half.
  static const Duration _leg = Duration(milliseconds: 800);

  /// The low point of the loop: `opacity: 0.35; transform: scale(0.7)`.
  static const double _dimmest = 0.35;
  static const double _smallest = 0.7;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _leg,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: context.mood.accent,
        shape: BoxShape.circle,
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      return dot;
    }
    if (!_controller.isAnimating) {
      unawaited(_controller.repeat(reverse: true));
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = Curves.easeInOut.transform(_controller.value);
        return Opacity(
          opacity: lerpDouble(1, _dimmest, progress)!,
          child: Transform.scale(
            scale: lerpDouble(1, _smallest, progress),
            child: child,
          ),
        );
      },
      child: dot,
    );
  }
}
