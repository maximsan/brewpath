import 'package:brew_path/core/utils/date_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_day.g.dart';

/// The app's clock, handed out as a function so the caller decides *when* to
/// read it.
///
/// One seam: override this and every day and every window in the app moves
/// with it. A function rather than an instant because elapsed time and the
/// calendar day want opposite things — see [currentDayProvider] (ADR-0030).
@riverpod
DateTime Function() appClock(Ref ref) => DateTime.now;

/// The local calendar day the app is currently showing.
///
/// Read once and cached until the rollover refreshes it, so every surface
/// derived against today agrees on which day that is. A window measured in
/// elapsed hours calls [appClockProvider] per read instead: it wants the
/// moment, not the day the app settled on (ADR-0030).
@riverpod
DateTime currentDay(Ref ref) => dateOnly(ref.watch(appClockProvider)());
