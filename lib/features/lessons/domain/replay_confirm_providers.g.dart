// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_confirm_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What to ask before replaying [lessonId], or null when nothing should be
/// asked — the lesson is unfinished, or the course no longer carries it.
///
/// The day comes from [currentDayProvider] rather than the clock, so a sheet
/// left open over midnight is rebuilt with the streak line it should have.

@ProviderFor(replayConfirm)
final replayConfirmProvider = ReplayConfirmFamily._();

/// What to ask before replaying [lessonId], or null when nothing should be
/// asked — the lesson is unfinished, or the course no longer carries it.
///
/// The day comes from [currentDayProvider] rather than the clock, so a sheet
/// left open over midnight is rebuilt with the streak line it should have.

final class ReplayConfirmProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReplayConfirmView?>,
          ReplayConfirmView?,
          FutureOr<ReplayConfirmView?>
        >
    with
        $FutureModifier<ReplayConfirmView?>,
        $FutureProvider<ReplayConfirmView?> {
  /// What to ask before replaying [lessonId], or null when nothing should be
  /// asked — the lesson is unfinished, or the course no longer carries it.
  ///
  /// The day comes from [currentDayProvider] rather than the clock, so a sheet
  /// left open over midnight is rebuilt with the streak line it should have.
  ReplayConfirmProvider._({
    required ReplayConfirmFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'replayConfirmProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$replayConfirmHash();

  @override
  String toString() {
    return r'replayConfirmProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ReplayConfirmView?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReplayConfirmView?> create(Ref ref) {
    final argument = this.argument as String;
    return replayConfirm(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReplayConfirmProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$replayConfirmHash() => r'0f5c0dae95b8e7c35d0ab5bfc08e6a7573d69b9b';

/// What to ask before replaying [lessonId], or null when nothing should be
/// asked — the lesson is unfinished, or the course no longer carries it.
///
/// The day comes from [currentDayProvider] rather than the clock, so a sheet
/// left open over midnight is rebuilt with the streak line it should have.

final class ReplayConfirmFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReplayConfirmView?>, String> {
  ReplayConfirmFamily._()
    : super(
        retry: null,
        name: r'replayConfirmProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What to ask before replaying [lessonId], or null when nothing should be
  /// asked — the lesson is unfinished, or the course no longer carries it.
  ///
  /// The day comes from [currentDayProvider] rather than the clock, so a sheet
  /// left open over midnight is rebuilt with the streak line it should have.

  ReplayConfirmProvider call(String lessonId) =>
      ReplayConfirmProvider._(argument: lessonId, from: this);

  @override
  String toString() => r'replayConfirmProvider';
}
