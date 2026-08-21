import 'package:brew_path/app/day_rollover.dart';
import 'package:brew_path/app/day_surfaces.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Recomputes the day-dependent surfaces when the app resumes on a new day.
///
/// The streak, the freeze and the Keep Sharp recommendation are **derived
/// against `DateTime.now()` at build time**, so they are only ever as fresh as
/// the last build. A learner who leaves the app backgrounded overnight would
/// otherwise come back to yesterday's streak — the fold is right, it has simply
/// not been re-run.
///
/// **Only on an actual rollover.** Invalidating on every resume would rebuild
/// three provider trees each time the learner glances at a notification, for a
/// value that cannot have changed. The day it last looked at is remembered and
/// compared, so an ordinary app-switch costs one integer comparison.
///
/// **No timer**, for the reason `ChallengeExpiryWatcher` gives: the moments
/// that matter are the ones where the app can act. The declared limitation is
/// that an app left *foregrounded* across midnight fires no resume and stays
/// stale until the next interaction — closing that needs a timer to midnight,
/// which is not worth what a read on resume already answers.
///
/// It wraps the app rather than a tab because all four shell tabs stay mounted:
/// a learner who resumes on Profile must get the same recompute as one who
/// resumes on Learn.
///
/// It lives in `app/` rather than beside `ChallengeExpiryWatcher` in a feature
/// folder because it spans two of them — progress and learn — and belongs to
/// neither. The day it turns on is the app's, not a feature's.
class DayRolloverWatcher extends ConsumerStatefulWidget {
  /// Creates a [DayRolloverWatcher].
  const DayRolloverWatcher({
    required this.child,
    this.clock = DateTime.now,
    super.key,
  });

  /// The app this wraps.
  final Widget child;

  /// Reads the current instant. Injected so a rollover is testable without
  /// waiting for midnight.
  final DateTime Function() clock;

  @override
  ConsumerState<DayRolloverWatcher> createState() => _DayRolloverWatcherState();
}

class _DayRolloverWatcherState extends ConsumerState<DayRolloverWatcher> {
  AppLifecycleListener? _lifecycle;

  /// The local calendar day the surfaces were last derived against.
  late int _lastSeenDay;

  @override
  void initState() {
    super.initState();
    // A cold start builds every provider against this day anyway, so it is
    // recorded rather than invalidated — there is nothing stale yet.
    _lastSeenDay = epochDay(widget.clock());
    _lifecycle = AppLifecycleListener(onResume: _refreshIfDayChanged);
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  void _refreshIfDayChanged() {
    if (!mounted) return;
    final now = widget.clock();
    if (!dayHasRolledOver(lastSeenDay: _lastSeenDay, now: now)) return;
    _lastSeenDay = epochDay(now);
    invalidateDaySurfaces(ref);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
