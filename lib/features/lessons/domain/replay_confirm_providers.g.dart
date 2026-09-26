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
/// The day is [currentDayProvider]'s, not the clock's, so the streak line
/// agrees with every other day surface on which day today is. The sheet is
/// read once, at the tap; one left open over midnight keeps its lines.

@ProviderFor(replayConfirm)
final replayConfirmProvider = ReplayConfirmFamily._();

/// What to ask before replaying [lessonId], or null when nothing should be
/// asked — the lesson is unfinished, or the course no longer carries it.
///
/// The day is [currentDayProvider]'s, not the clock's, so the streak line
/// agrees with every other day surface on which day today is. The sheet is
/// read once, at the tap; one left open over midnight keeps its lines.

final class ReplayConfirmProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReplayConfirmFacts?>,
          ReplayConfirmFacts?,
          FutureOr<ReplayConfirmFacts?>
        >
    with
        $FutureModifier<ReplayConfirmFacts?>,
        $FutureProvider<ReplayConfirmFacts?> {
  /// What to ask before replaying [lessonId], or null when nothing should be
  /// asked — the lesson is unfinished, or the course no longer carries it.
  ///
  /// The day is [currentDayProvider]'s, not the clock's, so the streak line
  /// agrees with every other day surface on which day today is. The sheet is
  /// read once, at the tap; one left open over midnight keeps its lines.
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
  $FutureProviderElement<ReplayConfirmFacts?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReplayConfirmFacts?> create(Ref ref) {
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

String _$replayConfirmHash() => r'a6e0453ced434083b0fd02667d144b836ff55fc1';

/// What to ask before replaying [lessonId], or null when nothing should be
/// asked — the lesson is unfinished, or the course no longer carries it.
///
/// The day is [currentDayProvider]'s, not the clock's, so the streak line
/// agrees with every other day surface on which day today is. The sheet is
/// read once, at the tap; one left open over midnight keeps its lines.

final class ReplayConfirmFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReplayConfirmFacts?>, String> {
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
  /// The day is [currentDayProvider]'s, not the clock's, so the streak line
  /// agrees with every other day surface on which day today is. The sheet is
  /// read once, at the tap; one left open over midnight keeps its lines.

  ReplayConfirmProvider call(String lessonId) =>
      ReplayConfirmProvider._(argument: lessonId, from: this);

  @override
  String toString() => r'replayConfirmProvider';
}
