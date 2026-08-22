// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_day.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The local calendar day the app is currently showing.
///
/// A provider rather than a `DateTime.now()` at the point of use, because the
/// day is **the fourth day-dependent surface** `invalidateDaySurfaces` warns
/// about: derived at build time, only ever as fresh as the last build, and
/// silently wrong for a learner who left the app backgrounded overnight. It
/// joins that list so the rollover recomputes it with the rest.

@ProviderFor(currentDay)
final currentDayProvider = CurrentDayProvider._();

/// The local calendar day the app is currently showing.
///
/// A provider rather than a `DateTime.now()` at the point of use, because the
/// day is **the fourth day-dependent surface** `invalidateDaySurfaces` warns
/// about: derived at build time, only ever as fresh as the last build, and
/// silently wrong for a learner who left the app backgrounded overnight. It
/// joins that list so the rollover recomputes it with the rest.

final class CurrentDayProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// The local calendar day the app is currently showing.
  ///
  /// A provider rather than a `DateTime.now()` at the point of use, because the
  /// day is **the fourth day-dependent surface** `invalidateDaySurfaces` warns
  /// about: derived at build time, only ever as fresh as the last build, and
  /// silently wrong for a learner who left the app backgrounded overnight. It
  /// joins that list so the rollover recomputes it with the rest.
  CurrentDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDayHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return currentDay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$currentDayHash() => r'0f9a19f7cae9f8728576a23dc3edc521f939abf4';
