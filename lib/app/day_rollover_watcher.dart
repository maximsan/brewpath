import 'dart:async';

import 'package:brew_path/app/day_rollover.dart';
import 'package:brew_path/app/day_surfaces.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Recomputes the day-dependent surfaces when the day turns over.
///
/// Two moments reach it: a resume, and a timer armed for the next local
/// midnight, so an app left *foregrounded* across it does not sit on yesterday
/// until the learner taps something (ADR-0030). It wraps the app rather than a
/// tab because all four shell tabs stay mounted.
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
  Timer? _midnight;

  /// The local calendar day the surfaces were last derived against.
  late int _lastSeenDay;

  @override
  void initState() {
    super.initState();
    // A cold start builds every provider against this day anyway, so it is
    // recorded rather than invalidated — there is nothing stale yet.
    _lastSeenDay = epochDay(widget.clock());
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    _armMidnight();
  }

  @override
  void dispose() {
    _midnight?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  void _onResume() {
    if (!mounted) return;
    _refreshIfDayChanged();
    // The wait to midnight is measured from now: a device asleep past one
    // midnight would otherwise keep a timer aimed at an hour already gone.
    _armMidnight();
  }

  void _onMidnight() {
    if (!mounted) return;
    _refreshIfDayChanged();
    _armMidnight();
  }

  void _armMidnight() {
    _midnight?.cancel();
    _midnight = Timer(untilNextMidnight(widget.clock()), _onMidnight);
  }

  void _refreshIfDayChanged() {
    final now = widget.clock();
    if (!dayHasRolledOver(lastSeenDay: _lastSeenDay, now: now)) return;
    _lastSeenDay = epochDay(now);
    invalidateDaySurfaces(ref);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
