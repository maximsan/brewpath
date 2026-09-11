import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchased_term.g.dart';

/// The term of the plan this session just bought, so the welcome can say
/// what was bought; null until a purchase lands. Kept alive because the
/// welcome is read after the paywall that recorded it is gone.
@Riverpod(keepAlive: true)
class PurchasedTerm extends _$PurchasedTerm {
  @override
  PlusTerm? build() => null;

  /// The term a purchase granted, or null before one has.
  PlusTerm? get term => state;

  /// Records the term a purchase just granted.
  set term(PlusTerm? value) => state = value;
}
