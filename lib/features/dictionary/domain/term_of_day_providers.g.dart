// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term_of_day_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Today's term, or null when the tier's pool is empty.
///
/// **Unresolved entitlement reads as free**, the direction every gate in the
/// app resolves it: offering a free learner a reference-only term for a frame
/// is the leak, and offering a paying learner a smaller pool for a frame is a
/// rebuild away from being right.
///
/// Watching [currentDayProvider] rather than reading a clock here is what
/// unfreezes this: the day is already on `invalidateDaySurfaces`, so a learner
/// who leaves the app open overnight gets tomorrow's term when they come back
/// rather than the one their last build happened to derive.

@ProviderFor(termOfDayView)
final termOfDayViewProvider = TermOfDayViewProvider._();

/// Today's term, or null when the tier's pool is empty.
///
/// **Unresolved entitlement reads as free**, the direction every gate in the
/// app resolves it: offering a free learner a reference-only term for a frame
/// is the leak, and offering a paying learner a smaller pool for a frame is a
/// rebuild away from being right.
///
/// Watching [currentDayProvider] rather than reading a clock here is what
/// unfreezes this: the day is already on `invalidateDaySurfaces`, so a learner
/// who leaves the app open overnight gets tomorrow's term when they come back
/// rather than the one their last build happened to derive.

final class TermOfDayViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<TermOfDayView?>,
          TermOfDayView?,
          FutureOr<TermOfDayView?>
        >
    with $FutureModifier<TermOfDayView?>, $FutureProvider<TermOfDayView?> {
  /// Today's term, or null when the tier's pool is empty.
  ///
  /// **Unresolved entitlement reads as free**, the direction every gate in the
  /// app resolves it: offering a free learner a reference-only term for a frame
  /// is the leak, and offering a paying learner a smaller pool for a frame is a
  /// rebuild away from being right.
  ///
  /// Watching [currentDayProvider] rather than reading a clock here is what
  /// unfreezes this: the day is already on `invalidateDaySurfaces`, so a learner
  /// who leaves the app open overnight gets tomorrow's term when they come back
  /// rather than the one their last build happened to derive.
  TermOfDayViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'termOfDayViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$termOfDayViewHash();

  @$internal
  @override
  $FutureProviderElement<TermOfDayView?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TermOfDayView?> create(Ref ref) {
    return termOfDayView(ref);
  }
}

String _$termOfDayViewHash() => r'd3ce2a28d58a392ac9185dad7b3facc59e6b20c2';
