import 'package:brew_path/core/utils/date_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_day.g.dart';

/// The local calendar day the app is currently showing.
///
/// A provider rather than a `DateTime.now()` at the point of use, because the
/// day is **the fourth day-dependent surface** `invalidateDaySurfaces` warns
/// about: derived at build time, only ever as fresh as the last build, and
/// silently wrong for a learner who left the app backgrounded overnight. It
/// joins that list so the rollover recomputes it with the rest.
@riverpod
DateTime currentDay(Ref ref) => dateOnly(DateTime.now());
