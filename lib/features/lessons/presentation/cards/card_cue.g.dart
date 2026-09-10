// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_cue.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How the kind behind [cue] is played.
///
/// Keyed on the cue rather than a raw kind string: every [CardCue] has an
/// entry, so a caller cannot ask this about a format the design never wrote
/// help for. Null only if the bundled bank has lost the entry.

@ProviderFor(cardKindHelp)
final cardKindHelpProvider = CardKindHelpFamily._();

/// How the kind behind [cue] is played.
///
/// Keyed on the cue rather than a raw kind string: every [CardCue] has an
/// entry, so a caller cannot ask this about a format the design never wrote
/// help for. Null only if the bundled bank has lost the entry.

final class CardKindHelpProvider
    extends
        $FunctionalProvider<
          AsyncValue<CardKindHelp?>,
          CardKindHelp?,
          FutureOr<CardKindHelp?>
        >
    with $FutureModifier<CardKindHelp?>, $FutureProvider<CardKindHelp?> {
  /// How the kind behind [cue] is played.
  ///
  /// Keyed on the cue rather than a raw kind string: every [CardCue] has an
  /// entry, so a caller cannot ask this about a format the design never wrote
  /// help for. Null only if the bundled bank has lost the entry.
  CardKindHelpProvider._({
    required CardKindHelpFamily super.from,
    required CardCue super.argument,
  }) : super(
         retry: null,
         name: r'cardKindHelpProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardKindHelpHash();

  @override
  String toString() {
    return r'cardKindHelpProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CardKindHelp?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CardKindHelp?> create(Ref ref) {
    final argument = this.argument as CardCue;
    return cardKindHelp(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CardKindHelpProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardKindHelpHash() => r'be617581732c9f64259c169ef2d332ef2d740dd9';

/// How the kind behind [cue] is played.
///
/// Keyed on the cue rather than a raw kind string: every [CardCue] has an
/// entry, so a caller cannot ask this about a format the design never wrote
/// help for. Null only if the bundled bank has lost the entry.

final class CardKindHelpFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CardKindHelp?>, CardCue> {
  CardKindHelpFamily._()
    : super(
        retry: null,
        name: r'cardKindHelpProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How the kind behind [cue] is played.
  ///
  /// Keyed on the cue rather than a raw kind string: every [CardCue] has an
  /// entry, so a caller cannot ask this about a format the design never wrote
  /// help for. Null only if the bundled bank has lost the entry.

  CardKindHelpProvider call(CardCue cue) =>
      CardKindHelpProvider._(argument: cue, from: this);

  @override
  String toString() => r'cardKindHelpProvider';
}
